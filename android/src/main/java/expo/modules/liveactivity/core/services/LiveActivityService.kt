package expo.modules.liveactivity.core.services

import expo.modules.liveactivity.core.models.*
import expo.modules.liveactivity.infrastructure.notifications.NotificationActivityManagerProtocol
import expo.modules.liveactivity.infrastructure.repositories.ActivityRepositoryProtocol
import expo.modules.liveactivity.presentation.events.ActivityEventPublisherProtocol
import kotlinx.coroutines.flow.Flow
import java.util.*

// MARK: - Service Protocol

interface LiveActivityServiceProtocol {
    suspend fun startActivity(config: LiveActivityConfig): Result<LiveActivityInstance, ActivityError>
    suspend fun updateActivity(request: ActivityUpdateRequest): Result<Unit, ActivityError>
    suspend fun endActivity(request: ActivityEndRequest): Result<Unit, ActivityError>
    suspend fun getActiveActivities(): Result<List<LiveActivityInstance>, ActivityError>
    suspend fun getActivity(id: String): Result<LiveActivityInstance?, ActivityError>
    fun eventStream(): Flow<ActivityEvent>
}

// MARK: - Service Implementation

class LiveActivityService(
    private val notificationManager: NotificationActivityManagerProtocol,
    private val repository: ActivityRepositoryProtocol,
    private val eventPublisher: ActivityEventPublisherProtocol
) : LiveActivityServiceProtocol {
    
    override suspend fun startActivity(config: LiveActivityConfig): Result<LiveActivityInstance, ActivityError> {
        try {
            // Check if activity already exists
            val existingActivity = repository.getActivity(config.id)
            if (existingActivity != null && existingActivity.isActive) {
                return Result.Failure(ActivityError.alreadyStarted(config.id))
            }
            
            // Start notification
            val notificationResult = notificationManager.startActivity(config)
            if (notificationResult is Result.Failure) {
                return Result.Failure(notificationResult.error)
            }
            
            val nativeId = (notificationResult as Result.Success).data
            
            // Create activity instance
            val activity = LiveActivityInstance(
                id = config.id,
                config = config,
                isActive = true,
                createdAt = Date(),
                updatedAt = Date(),
                nativeActivityId = nativeId
            )
            
            // Save to repository
            repository.saveActivity(activity)
            
            // Publish event
            eventPublisher.publishEvent(ActivityEvent.Started(activity))
            
            return Result.Success(activity)
            
        } catch (e: Exception) {
            val error = ActivityError.unknown("Failed to start activity: ${e.message}")
            eventPublisher.publishEvent(ActivityEvent.Error(error))
            return Result.Failure(error)
        }
    }
    
    override suspend fun updateActivity(request: ActivityUpdateRequest): Result<Unit, ActivityError> {
        try {
            val activity = repository.getActivity(request.activityId)
                ?: return Result.Failure(ActivityError.activityNotFound(request.activityId))
            
            if (!activity.isActive) {
                return Result.Failure(ActivityError.activityNotFound(request.activityId))
            }
            
            // Update notification
            val nativeId = activity.nativeActivityId
                ?: return Result.Failure(ActivityError.unknown("Native activity ID not found"))
            
            val updateResult = notificationManager.updateActivity(nativeId, request.content)
            if (updateResult is Result.Failure) {
                return Result.Failure(updateResult.error)
            }
            
            // Update activity in repository
            val updatedConfig = activity.config.copy(content = request.content)
            val updatedActivity = activity.copy(
                config = updatedConfig,
                updatedAt = Date()
            )
            repository.saveActivity(updatedActivity)
            
            // Publish event
            eventPublisher.publishEvent(ActivityEvent.Updated(request))
            
            return Result.Success(Unit)
            
        } catch (e: Exception) {
            val error = ActivityError.unknown("Failed to update activity: ${e.message}")
            eventPublisher.publishEvent(ActivityEvent.Error(error))
            return Result.Failure(error)
        }
    }
    
    override suspend fun endActivity(request: ActivityEndRequest): Result<Unit, ActivityError> {
        try {
            val activity = repository.getActivity(request.activityId)
                ?: return Result.Failure(ActivityError.activityNotFound(request.activityId))
            
            if (!activity.isActive) {
                return Result.Failure(ActivityError.activityNotFound(request.activityId))
            }
            
            // End notification
            val nativeId = activity.nativeActivityId
                ?: return Result.Failure(ActivityError.unknown("Native activity ID not found"))
            
            val endResult = notificationManager.endActivity(nativeId, request.finalContent, request.dismissalPolicy)
            if (endResult is Result.Failure) {
                return Result.Failure(endResult.error)
            }
            
            // Update activity in repository
            val finalConfig = request.finalContent?.let { activity.config.copy(content = it) } ?: activity.config
            val endedActivity = activity.copy(
                config = finalConfig,
                isActive = false,
                updatedAt = Date()
            )
            repository.saveActivity(endedActivity)
            
            // Publish event
            eventPublisher.publishEvent(ActivityEvent.Ended(request))
            
            return Result.Success(Unit)
            
        } catch (e: Exception) {
            val error = ActivityError.unknown("Failed to end activity: ${e.message}")
            eventPublisher.publishEvent(ActivityEvent.Error(error))
            return Result.Failure(error)
        }
    }
    
    override suspend fun getActiveActivities(): Result<List<LiveActivityInstance>, ActivityError> {
        return try {
            val activities = repository.getActiveActivities()
            Result.Success(activities)
        } catch (e: Exception) {
            Result.Failure(ActivityError.unknown("Failed to get active activities: ${e.message}"))
        }
    }
    
    override suspend fun getActivity(id: String): Result<LiveActivityInstance?, ActivityError> {
        return try {
            val activity = repository.getActivity(id)
            Result.Success(activity)
        } catch (e: Exception) {
            Result.Failure(ActivityError.unknown("Failed to get activity: ${e.message}"))
        }
    }
    
    override fun eventStream(): Flow<ActivityEvent> {
        return eventPublisher.eventFlow
    }
}