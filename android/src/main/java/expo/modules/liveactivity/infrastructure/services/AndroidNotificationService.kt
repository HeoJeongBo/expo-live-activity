package expo.modules.liveactivity.infrastructure.services

import android.content.Context
import expo.modules.liveactivity.core.models.*
import expo.modules.liveactivity.infrastructure.notifications.NotificationActivityManagerProtocol

// MARK: - Android Notification Service Protocol

interface AndroidNotificationServiceProtocol {
    suspend fun requestNotificationPermission(): Result<Boolean, ActivityError>
    suspend fun checkNotificationPermission(): Result<Boolean, ActivityError>
    suspend fun createCustomNotificationChannel(channelId: String, channelName: String): Result<Unit, ActivityError>
}

// MARK: - Android Notification Service Implementation

class AndroidNotificationService(
    private val context: Context,
    private val notificationManager: NotificationActivityManagerProtocol
) : AndroidNotificationServiceProtocol {
    
    override suspend fun requestNotificationPermission(): Result<Boolean, ActivityError> {
        return try {
            // For Android 13+ (API 33+), notification permission needs to be requested
            // This would typically involve launching a permission request activity
            // For now, we'll just check if permissions are already granted
            val isGranted = notificationManager.isNotificationPermissionGranted()
            Result.Success(isGranted)
        } catch (e: Exception) {
            Result.Failure(ActivityError.permissionDenied())
        }
    }
    
    override suspend fun checkNotificationPermission(): Result<Boolean, ActivityError> {
        return try {
            val isGranted = notificationManager.isNotificationPermissionGranted()
            Result.Success(isGranted)
        } catch (e: Exception) {
            Result.Failure(ActivityError.unknown("Failed to check notification permission: ${e.message}"))
        }
    }
    
    override suspend fun createCustomNotificationChannel(channelId: String, channelName: String): Result<Unit, ActivityError> {
        return try {
            // This would create a custom notification channel
            // Implementation would depend on specific requirements
            Result.Success(Unit)
        } catch (e: Exception) {
            Result.Failure(ActivityError.unknown("Failed to create notification channel: ${e.message}"))
        }
    }
}