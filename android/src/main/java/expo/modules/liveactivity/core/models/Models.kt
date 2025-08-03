package expo.modules.liveactivity.core.models

import java.util.*

// MARK: - Core Domain Models

data class LiveActivityConfig(
    val id: String,
    val type: ActivityType,
    val title: String,
    val content: ActivityContent,
    val actions: List<ActivityAction> = emptyList(),
    val expirationDate: Date? = null,
    val priority: ActivityPriority = ActivityPriority.NORMAL
)

data class ActivityContent(
    val status: String? = null,
    val progress: Double? = null,
    val message: String? = null,
    val estimatedTime: Int? = null,
    val customData: Map<String, Any> = emptyMap()
)

data class ActivityAction(
    val id: String,
    val title: String,
    val icon: String? = null,
    val isDestructive: Boolean = false,
    val deepLink: String? = null
)

data class LiveActivityInstance(
    val id: String,
    val config: LiveActivityConfig,
    val isActive: Boolean,
    val createdAt: Date,
    val updatedAt: Date,
    val nativeActivityId: String? = null
)

// MARK: - Request Models

data class ActivityUpdateRequest(
    val activityId: String,
    val content: ActivityContent,
    val timestamp: Date = Date()
)

data class ActivityEndRequest(
    val activityId: String,
    val finalContent: ActivityContent? = null,
    val dismissalPolicy: DismissalPolicy = DismissalPolicy.DEFAULT
)

// MARK: - Enums

enum class ActivityType {
    FOOD_DELIVERY,
    RIDESHARE,
    WORKOUT,
    TIMER,
    AUDIO_RECORDING,
    CUSTOM;
    
    companion object {
        fun fromString(value: String): ActivityType {
            return when (value.lowercase()) {
                "fooddelivery" -> FOOD_DELIVERY
                "rideshare" -> RIDESHARE
                "workout" -> WORKOUT
                "timer" -> TIMER
                "audiorecording" -> AUDIO_RECORDING
                else -> CUSTOM
            }
        }
    }
}

enum class ActivityPriority {
    LOW,
    NORMAL,
    HIGH;
    
    companion object {
        fun fromString(value: String): ActivityPriority {
            return when (value.lowercase()) {
                "low" -> LOW
                "high" -> HIGH
                else -> NORMAL
            }
        }
    }
}

enum class DismissalPolicy {
    IMMEDIATE,
    DEFAULT,
    AFTER;
    
    companion object {
        fun fromString(value: String): DismissalPolicy {
            return when (value.lowercase()) {
                "immediate" -> IMMEDIATE
                "after" -> AFTER
                else -> DEFAULT
            }
        }
    }
}

// MARK: - Result Types

sealed class Result<out T, out E> {
    data class Success<T>(val data: T) : Result<T, Nothing>()
    data class Failure<E>(val error: E) : Result<Nothing, E>()
}

// MARK: - Error Types

data class ActivityError(
    val code: String,
    val message: String,
    val cause: Throwable? = null
) : Exception(message, cause) {
    
    companion object {
        fun invalidConfiguration(message: String) = ActivityError("INVALID_CONFIGURATION", message)
        fun activityNotFound(id: String) = ActivityError("ACTIVITY_NOT_FOUND", "Activity with ID '$id' not found")
        fun alreadyStarted(id: String) = ActivityError("ALREADY_STARTED", "Activity with ID '$id' is already started")
        fun systemNotSupported() = ActivityError("SYSTEM_NOT_SUPPORTED", "Live Activity is not supported on this device")
        fun permissionDenied() = ActivityError("PERMISSION_DENIED", "Permission denied for notifications")
        fun networkError(message: String) = ActivityError("NETWORK_ERROR", message)
        fun unknown(message: String) = ActivityError("UNKNOWN_ERROR", message)
    }
}

// MARK: - Validation Types

data class ValidationResult(
    val isValid: Boolean,
    val errors: List<ValidationError>
)

data class ValidationError(
    val field: String,
    val message: String
)

// MARK: - Event Types

sealed class ActivityEvent {
    data class Started(val activity: LiveActivityInstance) : ActivityEvent()
    data class Updated(val request: ActivityUpdateRequest) : ActivityEvent()
    data class Ended(val request: ActivityEndRequest) : ActivityEvent()
    data class UserAction(
        val activityId: String,
        val actionId: String,
        val timestamp: Date
    ) : ActivityEvent()
    data class Error(val error: ActivityError) : ActivityEvent()
}