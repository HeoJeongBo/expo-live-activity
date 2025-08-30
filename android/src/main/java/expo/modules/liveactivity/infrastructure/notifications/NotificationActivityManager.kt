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
        return try {
            if (!isNotificationPermissionGranted()) {
                return Result.Failure(ActivityError.permissionDenied())
            }

            val notificationId = generateNotificationId()
            val nativeId = "notification_$notificationId"

            val notification = buildNotification(config, notificationId)
            notificationManager.notify(notificationId, notification)
            activeNotifications[nativeId] = notificationId

            Result.Success(nativeId)
        } catch (e: SecurityException) {
            Result.Failure(ActivityError.permissionDenied())
        } catch (e: Exception) {
            Result.Failure(ActivityError.unknown("Failed to start notification: ${e.message}"))
        }
    }

    override suspend fun updateActivity(nativeId: String, content: ActivityContent): Result<Unit, ActivityError> {
        return try {
            val notificationId = activeNotifications[nativeId]
                ?: return Result.Failure(ActivityError.activityNotFound(nativeId))

            val config = createMinimalConfig(content, nativeId)
            val notification = buildNotification(config, notificationId)
            notificationManager.notify(notificationId, notification)

            Result.Success(Unit)
        } catch (e: SecurityException) {
            Result.Failure(ActivityError.permissionDenied())
        } catch (e: Exception) {
            Result.Failure(ActivityError.unknown("Failed to update notification: ${e.message}"))
        }
    }

    override suspend fun endActivity(nativeId: String, finalContent: ActivityContent?, dismissalPolicy: DismissalPolicy): Result<Unit, ActivityError> {
        return try {
            val notificationId = activeNotifications[nativeId]
                ?: return Result.Failure(ActivityError.activityNotFound(nativeId))

            when (dismissalPolicy) {
                DismissalPolicy.IMMEDIATE -> {
                    notificationManager.cancel(notificationId)
                }
                DismissalPolicy.DEFAULT -> {
                    finalContent?.let {
                        val config = createMinimalConfig(it, nativeId)
                        val notification = buildNotification(config, notificationId, isEnding = true)
                        notificationManager.notify(notificationId, notification)
                    }
                }
                DismissalPolicy.AFTER -> {
                    finalContent?.let {
                        val config = createMinimalConfig(it, nativeId)
                        val notification = buildNotification(config, notificationId, isEnding = true)
                        notificationManager.notify(notificationId, notification)
                    } ?: notificationManager.cancel(notificationId)
                }
            }

            activeNotifications.remove(nativeId)
            Result.Success(Unit)
        } catch (e: SecurityException) {
            Result.Failure(ActivityError.permissionDenied())
        } catch (e: Exception) {
            Result.Failure(ActivityError.unknown("Failed to end notification: ${e.message}"))
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
            .setSmallIcon(android.R.drawable.ic_dialog_info)
            .setContentTitle(config.title)
            .setOngoing(!isEnding)
            .setAutoCancel(isEnding)
            .setPriority(getNotificationPriority(config.priority))
            .setCategory(NotificationCompat.CATEGORY_STATUS)

        try {
            val compactLayout = layoutBuilder.buildCompactLayout(config, notificationId)
            val expandedLayout = layoutBuilder.buildTypedLayout(config, notificationId)

            builder.setCustomContentView(compactLayout)
            builder.setCustomBigContentView(expandedLayout)
            builder.setStyle(NotificationCompat.DecoratedCustomViewStyle())
        } catch (e: Exception) {
            android.util.Log.w("NotificationActivityManager", "Failed to create custom layout, using standard", e)

            val contentText = buildContentText(config.content)
            if (contentText.isNotEmpty()) {
                builder.setContentText(contentText)
            }

            config.content.progress?.let { progress ->
                val progressInt = (progress * 100).toInt()
                builder.setProgress(100, progressInt, false)
            }

            config.actions.take(2).forEach { action ->
                val actionIntent = createActionIntent(config.id, action.id, notificationId)
                val pendingIntent = PendingIntent.getBroadcast(
                    context,
                    (config.id + action.id).hashCode(),
                    actionIntent,
                    PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                )

                builder.addAction(
                    android.R.drawable.ic_dialog_info,
                    action.title,
                    pendingIntent
                )
            }
        }

        val contentIntent = createContentIntent(config.id)
        val contentPendingIntent = PendingIntent.getActivity(
            context,
            config.id.hashCode(),
            contentIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        builder.setContentIntent(contentPendingIntent)

        return builder.build()
    }

    private fun buildContentText(content: ActivityContent): String {
        val parts = mutableListOf<String>()
        content.status?.let { parts.add(it) }
        content.message?.let { parts.add(it) }
        content.estimatedTime?.let { parts.add("${it}분 남음") }
        return parts.joinToString(" • ")
    }

    private fun getNotificationPriority(priority: ActivityPriority): Int {
        return when (priority) {
            ActivityPriority.LOW -> NotificationCompat.PRIORITY_LOW
            ActivityPriority.NORMAL -> NotificationCompat.PRIORITY_DEFAULT
            ActivityPriority.HIGH -> NotificationCompat.PRIORITY_HIGH
        }
    }

    private fun createActionIntent(activityId: String, actionId: String, notificationId: Int): Intent {
        return Intent(context, NotificationActionReceiver::class.java).apply {
            action = "expo.liveactivity.ACTION_BUTTON_CLICKED"
            putExtra("activityId", activityId)
            putExtra("actionId", actionId)
            putExtra("notificationId", notificationId)
        }
    }

    private fun createContentIntent(activityId: String): Intent {
        return context.packageManager.getLaunchIntentForPackage(context.packageName)
            ?: Intent().apply {
                putExtra("activityId", activityId)
            }
    }

    private fun generateNotificationId(): Int {
        return nextNotificationId++
    }

    private fun createMinimalConfig(content: ActivityContent, nativeId: String): LiveActivityConfig {
        return LiveActivityConfig(
            id = nativeId,
            type = ActivityType.CUSTOM,
            title = content.status ?: "Live Activity",
            content = content
        )
    }
}