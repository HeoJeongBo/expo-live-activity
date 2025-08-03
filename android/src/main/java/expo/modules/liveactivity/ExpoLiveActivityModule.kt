package expo.modules.liveactivity

import android.content.Context
import expo.modules.kotlin.modules.Module
import expo.modules.kotlin.modules.ModuleDefinition
import expo.modules.kotlin.Promise
import expo.modules.kotlin.exception.Exceptions
import expo.modules.liveactivity.core.services.LiveActivityServiceProtocol
import expo.modules.liveactivity.core.services.LiveActivityService
import expo.modules.liveactivity.core.models.*
import expo.modules.liveactivity.core.usecases.*
import expo.modules.liveactivity.infrastructure.repositories.InMemoryActivityRepository
import expo.modules.liveactivity.infrastructure.notifications.NotificationActivityManager
import expo.modules.liveactivity.infrastructure.services.AndroidNotificationService
import expo.modules.liveactivity.presentation.events.ActivityEventPublisher
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import java.util.*

class ExpoLiveActivityModule : Module() {
    
    // MARK: - Dependencies (Lazy Initialization)
    
    private val appContext: Context by lazy { 
        appContext ?: throw IllegalStateException("App context is null")
    }
    
    private val notificationManager: NotificationActivityManagerProtocol by lazy {
        NotificationActivityManager(appContext)
    }
    
    private val repository: ActivityRepositoryProtocol by lazy {
        InMemoryActivityRepository()
    }
    
    private val eventPublisher: ActivityEventPublisherProtocol by lazy {
        ActivityEventPublisher()
    }
    
    private val validator: ActivityConfigValidatorProtocol by lazy {
        ActivityConfigValidator()
    }
    
    private val notificationService: AndroidNotificationServiceProtocol by lazy {
        AndroidNotificationService(appContext, notificationManager)
    }
    
    private val liveActivityService: LiveActivityServiceProtocol by lazy {
        LiveActivityService(
            notificationManager = notificationManager,
            repository = repository,
            eventPublisher = eventPublisher
        )
    }
    
    // Use Cases
    private val startActivityUseCase: StartActivityUseCaseProtocol by lazy {
        StartActivityUseCase(
            activityService = liveActivityService,
            repository = repository,
            validator = validator,
            eventPublisher = eventPublisher
        )
    }
    
    private val updateActivityUseCase: UpdateActivityUseCaseProtocol by lazy {
        UpdateActivityUseCase(
            activityService = liveActivityService,
            repository = repository,
            eventPublisher = eventPublisher
        )
    }
    
    private val endActivityUseCase: EndActivityUseCaseProtocol by lazy {
        EndActivityUseCase(
            activityService = liveActivityService,
            repository = repository,
            eventPublisher = eventPublisher
        )
    }
    
    private val coroutineScope = CoroutineScope(Dispatchers.Main)
    
    // MARK: - Module Definition
    
    override fun definition() = ModuleDefinition {
        Name("ExpoLiveActivity")
        
        // Constants
        Constants(
            "isSupported" to true, // Android always supports notifications
            "isDynamicIslandSupported" to false // Android doesn't have Dynamic Island
        )
        
        // Events
        Events(
            "onActivityUpdate",
            "onUserAction", 
            "onActivityEnd",
            "onError"
        )
        
        // MARK: - Live Activity Management Functions
        
        AsyncFunction("startActivity") { config: Map<String, Any>, promise: Promise ->
            coroutineScope.launch {
                try {
                    val activityConfig = parseActivityConfig(config)
                    val result = startActivityUseCase.execute(activityConfig)
                    
                    when (result) {
                        is Result.Success -> {
                            promise.resolve(serializeActivity(result.data))
                        }
                        is Result.Failure -> {
                            promise.reject("ACTIVITY_ERROR", result.error.message, result.error)
                        }
                    }
                } catch (e: Exception) {
                    promise.reject("INVALID_CONFIGURATION", e.message, e)
                }
            }
        }
        
        AsyncFunction("updateActivity") { activityId: String, content: Map<String, Any>, promise: Promise ->
            coroutineScope.launch {
                try {
                    val activityContent = parseActivityContent(content)
                    val updateRequest = ActivityUpdateRequest(activityId, activityContent)
                    val result = updateActivityUseCase.execute(updateRequest)
                    
                    when (result) {
                        is Result.Success -> promise.resolve(true)
                        is Result.Failure -> promise.reject("ACTIVITY_ERROR", result.error.message, result.error)
                    }
                } catch (e: Exception) {
                    promise.reject("INVALID_CONFIGURATION", e.message, e)
                }
            }
        }
        
        AsyncFunction("endActivity") { activityId: String, options: Map<String, Any>?, promise: Promise ->
            coroutineScope.launch {
                try {
                    val finalContent = options?.get("finalContent")?.let { 
                        parseActivityContent(it as? Map<String, Any> ?: emptyMap())
                    }
                    val dismissalPolicyStr = options?.get("dismissalPolicy") as? String ?: "default"
                    val dismissalPolicy = DismissalPolicy.fromString(dismissalPolicyStr)
                    
                    val endRequest = ActivityEndRequest(activityId, finalContent, dismissalPolicy)
                    val result = endActivityUseCase.execute(endRequest)
                    
                    when (result) {
                        is Result.Success -> promise.resolve(true)
                        is Result.Failure -> promise.reject("ACTIVITY_ERROR", result.error.message, result.error)
                    }
                } catch (e: Exception) {
                    promise.reject("INVALID_CONFIGURATION", e.message, e)
                }
            }
        }
        
        AsyncFunction("getActiveActivities") { promise: Promise ->
            coroutineScope.launch {
                val result = liveActivityService.getActiveActivities()
                when (result) {
                    is Result.Success -> {
                        promise.resolve(result.data.map { serializeActivity(it) })
                    }
                    is Result.Failure -> promise.resolve(emptyList<Map<String, Any>>())
                }
            }
        }
        
        AsyncFunction("getActivity") { activityId: String, promise: Promise ->
            coroutineScope.launch {
                val result = liveActivityService.getActivity(activityId)
                when (result) {
                    is Result.Success -> {
                        promise.resolve(result.data?.let { serializeActivity(it) })
                    }
                    is Result.Failure -> promise.resolve(null)
                }
            }
        }
        
        // Utility Functions
        Function("validateActivityConfig") { config: Map<String, Any> ->
            try {
                val activityConfig = parseActivityConfig(config)
                val validationResult = validator.validate(activityConfig)
                
                mapOf(
                    "isValid" to validationResult.isValid,
                    "errors" to validationResult.errors.map { error ->
                        mapOf("field" to error.field, "message" to error.message)
                    }
                )
            } catch (e: Exception) {
                mapOf(
                    "isValid" to false,
                    "errors" to listOf(mapOf("field" to "config", "message" to e.message))
                )
            }
        }
        
        OnCreate {
            subscribeToEvents()
        }
        
        // View integration
        View(ExpoLiveActivityView::class) {
            Events("onLoad", "onActivityAction")
            
            Function("updateActivity") { view: ExpoLiveActivityView, config: Map<String, Any> ->
                try {
                    val activityConfig = parseActivityConfig(config)
                    view.updateActivity(activityConfig)
                } catch (e: Exception) {
                    android.util.Log.e("ExpoLiveActivityModule", "Failed to update view", e)
                }
            }
            
            Function("updateContent") { view: ExpoLiveActivityView, content: Map<String, Any> ->
                try {
                    val activityContent = parseActivityContent(content)
                    view.updateContent(activityContent)
                } catch (e: Exception) {
                    android.util.Log.e("ExpoLiveActivityModule", "Failed to update view content", e)
                }
            }
        }
        
        OnDestroy {
            // Cleanup resources
        }
    }
    
    // MARK: - Private Helper Methods
    
    private fun subscribeToEvents() {
        coroutineScope.launch {
            eventPublisher.eventFlow.collect { event ->
                handleActivityEvent(event)
            }
        }
    }
    
    private fun handleActivityEvent(event: ActivityEvent) {
        when (event) {
            is ActivityEvent.Started -> {
                sendEvent("onActivityUpdate", mapOf(
                    "type" to "started",
                    "activity" to serializeActivity(event.activity)
                ))
            }
            is ActivityEvent.Updated -> {
                sendEvent("onActivityUpdate", mapOf(
                    "type" to "updated",
                    "activityId" to event.request.activityId,
                    "content" to serializeActivityContent(event.request.content),
                    "timestamp" to event.request.timestamp.time
                ))
            }
            is ActivityEvent.Ended -> {
                sendEvent("onActivityEnd", mapOf(
                    "activityId" to event.request.activityId,
                    "finalContent" to event.request.finalContent?.let { serializeActivityContent(it) },
                    "dismissalPolicy" to event.request.dismissalPolicy.name.lowercase()
                ))
            }
            is ActivityEvent.UserAction -> {
                sendEvent("onUserAction", mapOf(
                    "activityId" to event.activityId,
                    "actionId" to event.actionId,
                    "timestamp" to event.timestamp.time
                ))
            }
            is ActivityEvent.Error -> {
                sendEvent("onError", mapOf(
                    "message" to event.error.message,
                    "code" to event.error.code
                ))
            }
        }
    }
}

// MARK: - Parsing Extensions

private fun parseActivityConfig(config: Map<String, Any>): LiveActivityConfig {
    val id = config["id"] as? String ?: throw IllegalArgumentException("ID가 필요합니다")
    val title = config["title"] as? String ?: throw IllegalArgumentException("제목이 필요합니다")
    val typeString = config["type"] as? String ?: "custom"
    val type = ActivityType.fromString(typeString)
    val contentMap = config["content"] as? Map<String, Any> ?: emptyMap()
    val content = parseActivityContent(contentMap)
    val actionsArray = config["actions"] as? List<Map<String, Any>> ?: emptyList()
    val actions = actionsArray.map { parseActivityAction(it) }
    val expirationTimestamp = config["expirationDate"] as? Double
    val expirationDate = expirationTimestamp?.let { Date((it * 1000).toLong()) }
    val priorityString = config["priority"] as? String ?: "normal"
    val priority = ActivityPriority.fromString(priorityString)
    
    return LiveActivityConfig(
        id = id,
        type = type,
        title = title,
        content = content,
        actions = actions,
        expirationDate = expirationDate,
        priority = priority
    )
}

private fun parseActivityContent(content: Map<String, Any>): ActivityContent {
    val status = content["status"] as? String
    val progress = content["progress"] as? Double
    val message = content["message"] as? String
    val estimatedTime = content["estimatedTime"] as? Int
    val customData = content["customData"] as? Map<String, Any> ?: emptyMap()
    
    return ActivityContent(
        status = status,
        progress = progress,
        message = message,
        estimatedTime = estimatedTime,
        customData = customData
    )
}

private fun parseActivityAction(action: Map<String, Any>): ActivityAction {
    val id = action["id"] as? String ?: throw IllegalArgumentException("액션 ID가 필요합니다")
    val title = action["title"] as? String ?: throw IllegalArgumentException("액션 제목이 필요합니다")
    val icon = action["icon"] as? String
    val isDestructive = action["destructive"] as? Boolean ?: false
    val deepLink = action["deepLink"] as? String
    
    return ActivityAction(
        id = id,
        title = title,
        icon = icon,
        isDestructive = isDestructive,
        deepLink = deepLink
    )
}

// MARK: - Serialization Extensions

private fun serializeActivity(activity: LiveActivityInstance): Map<String, Any> {
    return mapOf(
        "id" to activity.id,
        "config" to serializeActivityConfig(activity.config),
        "isActive" to activity.isActive,
        "createdAt" to (activity.createdAt.time / 1000.0),
        "updatedAt" to (activity.updatedAt.time / 1000.0),
        "nativeActivityId" to (activity.nativeActivityId ?: "")
    )
}

private fun serializeActivityConfig(config: LiveActivityConfig): Map<String, Any> {
    return mapOf(
        "id" to config.id,
        "type" to config.type.name.lowercase(),
        "title" to config.title,
        "content" to serializeActivityContent(config.content),
        "actions" to config.actions.map { serializeActivityAction(it) },
        "expirationDate" to (config.expirationDate?.time?.div(1000.0)),
        "priority" to config.priority.name.lowercase()
    )
}

private fun serializeActivityContent(content: ActivityContent): Map<String, Any> {
    return mapOf(
        "status" to (content.status ?: ""),
        "progress" to (content.progress ?: 0.0),
        "message" to (content.message ?: ""),
        "estimatedTime" to (content.estimatedTime ?: 0),
        "customData" to content.customData
    )
}

private fun serializeActivityAction(action: ActivityAction): Map<String, Any> {
    return mapOf(
        "id" to action.id,
        "title" to action.title,
        "icon" to (action.icon ?: ""),
        "destructive" to action.isDestructive,
        "deepLink" to (action.deepLink ?: "")
    )
}
