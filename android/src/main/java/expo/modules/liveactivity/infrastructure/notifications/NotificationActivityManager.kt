package expo.modules.liveactivity.infrastructure.notifications

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import expo.modules.liveactivity.core.models.*
import expo.modules.liveactivity.infrastructure.ui.NotificationLayoutBuilder
import java.util.*

// MARK: - Notification Manager Protocol

interface NotificationActivityManagerProtocol {
    suspend fun startActivity(config: LiveActivityConfig): Result<String, ActivityError>
    suspend fun updateActivity(nativeId: String, content: ActivityContent): Result<Unit, ActivityError>
    suspend fun endActivity(nativeId: String, finalContent: ActivityContent?, dismissalPolicy: DismissalPolicy): Result<Unit, ActivityError>
    suspend fun isNotificationPermissionGranted(): Boolean
}

// MARK: - Notification Manager Implementation

class NotificationActivityManager(
    private val context: Context
) : NotificationActivityManagerProtocol {
    
    companion object {
        private const val CHANNEL_ID = "expo_live_activity_channel"
        private const val CHANNEL_NAME = "Live Activity"
        private const val CHANNEL_DESCRIPTION = "Ongoing notifications for Live Activity"
        private const val NOTIFICATION_ID_BASE = 10000
    }
    
    private val notificationManager: NotificationManagerCompat by lazy {
        NotificationManagerCompat.from(context)
    }
    
    private val layoutBuilder: NotificationLayoutBuilder by lazy {
        NotificationLayoutBuilder(context)
    }
    
    private val activeNotifications = mutableMapOf<String, Int>()
    private var nextNotificationId = NOTIFICATION_ID_BASE
    
    init {
        createNotificationChannel()
    }
    
    override suspend fun startActivity(config: LiveActivityConfig): Result<String, ActivityError> {
        try {
            if (!isNotificationPermissionGranted()) {
                return Result.Failure(ActivityError.permissionDenied())
            }
            
            val notificationId = generateNotificationId()
            val nativeId = "notification_$notificationId"
            
            val notification = buildNotification(config, notificationId)
            
            notificationManager.notify(notificationId, notification)
            activeNotifications[nativeId] = notificationId
            
            return Result.Success(nativeId)
            
        } catch (e: SecurityException) {
            return Result.Failure(ActivityError.permissionDenied())
        } catch (e: Exception) {
            return Result.Failure(ActivityError.unknown("Failed to start notification: ${e.message}"))
        }
    }
    
    override suspend fun updateActivity(nativeId: String, content: ActivityContent): Result<Unit, ActivityError> {
        try {
            val notificationId = activeNotifications[nativeId]
                ?: return Result.Failure(ActivityError.activityNotFound(nativeId))
            
            // For updates, we need the original config. In a real implementation,
            // we'd store this information. For now, we'll create a minimal config.
            val config = createMinimalConfig(content, nativeId)
            val notification = buildNotification(config, notificationId)
            
            notificationManager.notify(notificationId, notification)
            
            return Result.Success(Unit)
            
        } catch (e: SecurityException) {
            return Result.Failure(ActivityError.permissionDenied())
        } catch (e: Exception) {
            return Result.Failure(ActivityError.unknown("Failed to update notification: ${e.message}"))
        }
    }
    
    override suspend fun endActivity(nativeId: String, finalContent: ActivityContent?, dismissalPolicy: DismissalPolicy): Result<Unit, ActivityError> {
        try {
            val notificationId = activeNotifications[nativeId]
                ?: return Result.Failure(ActivityError.activityNotFound(nativeId))
            
            when (dismissalPolicy) {
                DismissalPolicy.IMMEDIATE -> {
                    notificationManager.cancel(notificationId)
                }
                DismissalPolicy.DEFAULT -> {
                    // Show final content for a brief moment, then dismiss
                    finalContent?.let {
                        val config = createMinimalConfig(it, nativeId)
                        val notification = buildNotification(config, notificationId, isEnding = true)
                        notificationManager.notify(notificationId, notification)
                    }
                    // Auto-dismiss after a delay (handled by the notification itself)
                }
                DismissalPolicy.AFTER -> {
                    // Show final content and let user dismiss
                    finalContent?.let {
                        val config = createMinimalConfig(it, nativeId)
                        val notification = buildNotification(config, notificationId, isEnding = true)
                        notificationManager.notify(notificationId, notification)
                    } ?: notificationManager.cancel(notificationId)
                }
            }
            
            activeNotifications.remove(nativeId)
            
            return Result.Success(Unit)
            
        } catch (e: SecurityException) {
            return Result.Failure(ActivityError.permissionDenied())
        } catch (e: Exception) {
            return Result.Failure(ActivityError.unknown("Failed to end notification: ${e.message}"))
        }
    }
    
    override suspend fun isNotificationPermissionGranted(): Boolean {
        return notificationManager.areNotificationsEnabled()
    }
    
    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                CHANNEL_NAME,
                NotificationManager.IMPORTANCE_DEFAULT
            ).apply {
                description = CHANNEL_DESCRIPTION
                setShowBadge(false)
                setSound(null, null)
            }
            
            val manager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            manager.createNotificationChannel(channel)
        }
    }
    
    private fun buildNotification(
        config: LiveActivityConfig,
        notificationId: Int,
        isEnding: Boolean = false
    ): android.app.Notification {
        val builder = NotificationCompat.Builder(context, CHANNEL_ID)
            .setSmallIcon(android.R.drawable.ic_dialog_info) // Default icon
            .setContentTitle(config.title)
            .setOngoing(!isEnding) // Ongoing notifications can't be swiped away
            .setAutoCancel(isEnding)
            .setPriority(getNotificationPriority(config.priority))
            .setCategory(NotificationCompat.CATEGORY_STATUS)
        
        // Use custom RemoteViews for Live Activity-like appearance
        try {
            val compactLayout = layoutBuilder.buildCompactLayout(config, notificationId)
            val expandedLayout = layoutBuilder.buildTypedLayout(config, notificationId)
            
            builder.setCustomContentView(compactLayout)
            builder.setCustomBigContentView(expandedLayout)
            builder.setStyle(NotificationCompat.DecoratedCustomViewStyle())
        } catch (e: Exception) {
            // Fallback to standard notification if custom layout fails
            android.util.Log.w("NotificationActivityManager", "Failed to create custom layout, using standard", e)
            
            val contentText = buildContentText(config.content)
            if (contentText.isNotEmpty()) {
                builder.setContentText(contentText)
            }
            
            // Progress bar if available
            config.content.progress?.let { progress ->
                val progressInt = (progress * 100).toInt()
                builder.setProgress(100, progressInt, false)
            }
            
            // Add action buttons (max 2 for Android)
            config.actions.take(2).forEach { action ->
                val actionIntent = createActionIntent(config.id, action.id, notificationId)
                val pendingIntent = PendingIntent.getBroadcast(
                    context,
                    (config.id + action.id).hashCode(),
                    actionIntent,
                    PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                )
                
                builder.addAction(
                    android.R.drawable.ic_dialog_info, // Default icon for action
                    action.title,
                    pendingIntent
                )
            }
        }
        
        // Main content intent
        val contentIntent = createContentIntent(config.id)
        val contentPendingIntent = PendingIntent.getActivity(
            context,
            config.id.hashCode(),
            contentIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        builder.setContentIntent(contentPendingIntent)
        
        return builder.build()
    }\n    \n    private fun buildContentText(content: ActivityContent): String {\n        val parts = mutableListOf<String>()\n        \n        content.status?.let { parts.add(it) }\n        content.message?.let { parts.add(it) }\n        content.estimatedTime?.let { parts.add(\"${it}분 남음\") }\n        \n        return parts.joinToString(\" • \")\n    }\n    \n    private fun getNotificationPriority(priority: ActivityPriority): Int {\n        return when (priority) {\n            ActivityPriority.LOW -> NotificationCompat.PRIORITY_LOW\n            ActivityPriority.NORMAL -> NotificationCompat.PRIORITY_DEFAULT\n            ActivityPriority.HIGH -> NotificationCompat.PRIORITY_HIGH\n        }\n    }\n    \n    private fun createActionIntent(activityId: String, actionId: String, notificationId: Int): Intent {\n        return Intent(context, NotificationActionReceiver::class.java).apply {\n            action = \"expo.liveactivity.ACTION_BUTTON_CLICKED\"\n            putExtra(\"activityId\", activityId)\n            putExtra(\"actionId\", actionId)\n            putExtra(\"notificationId\", notificationId)\n        }\n    }\n    \n    private fun createContentIntent(activityId: String): Intent {\n        // Return to the main app when notification is tapped\n        return context.packageManager.getLaunchIntentForPackage(context.packageName)\n            ?: Intent().apply {\n                putExtra(\"activityId\", activityId)\n            }\n    }\n    \n    private fun generateNotificationId(): Int {\n        return nextNotificationId++\n    }\n    \n    private fun createMinimalConfig(content: ActivityContent, nativeId: String): LiveActivityConfig {\n        return LiveActivityConfig(\n            id = nativeId,\n            type = ActivityType.CUSTOM,\n            title = content.status ?: \"Live Activity\",\n            content = content\n        )\n    }\n}"