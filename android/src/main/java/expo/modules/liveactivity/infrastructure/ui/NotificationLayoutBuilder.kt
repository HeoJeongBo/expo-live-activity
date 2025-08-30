package expo.modules.liveactivity.infrastructure.ui

import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.widget.RemoteViews
import expo.modules.liveactivity.core.models.*
import expo.modules.liveactivity.infrastructure.notifications.NotificationActionReceiver

/**
 * Builder for creating custom notification layouts using RemoteViews
 * This provides iOS Live Activity-like UI on Android
 */
class NotificationLayoutBuilder(private val context: Context) {

    companion object {
        // Layout resource IDs (these would be defined in res/layout/)
        private const val LAYOUT_LIVE_ACTIVITY_COMPACT = android.R.layout.activity_list_item
        private const val LAYOUT_LIVE_ACTIVITY_EXPANDED = android.R.layout.activity_list_item

        // View IDs (these would be defined in the layout files)
        private const val ID_TITLE = android.R.id.title
        private const val ID_STATUS = android.R.id.text1
        private const val ID_MESSAGE = android.R.id.text2
        private const val ID_PROGRESS = android.R.id.progress
        private const val ID_TIME = android.R.id.secondaryProgress
        private const val ID_ACTION1 = android.R.id.button1
        private const val ID_ACTION2 = android.R.id.button2
    }

    /**
     * Build a compact notification layout
     */
    fun buildCompactLayout(config: LiveActivityConfig, notificationId: Int): RemoteViews {
        val remoteViews = RemoteViews(context.packageName, LAYOUT_LIVE_ACTIVITY_COMPACT)

        // Set title
        remoteViews.setTextViewText(ID_TITLE, config.title)

        // Set status and message
        val content = config.content
        content.status?.let {
            remoteViews.setTextViewText(ID_STATUS, it)
            remoteViews.setViewVisibility(ID_STATUS, android.view.View.VISIBLE)
        } ?: remoteViews.setViewVisibility(ID_STATUS, android.view.View.GONE)

        content.message?.let {
            remoteViews.setTextViewText(ID_MESSAGE, it)
            remoteViews.setViewVisibility(ID_MESSAGE, android.view.View.VISIBLE)
        } ?: remoteViews.setViewVisibility(ID_MESSAGE, android.view.View.GONE)

        // Set progress if available
        content.progress?.let { progress ->
            val progressInt = (progress * 100).toInt()
            remoteViews.setProgressBar(ID_PROGRESS, 100, progressInt, false)
            remoteViews.setViewVisibility(ID_PROGRESS, android.view.View.VISIBLE)
        } ?: remoteViews.setViewVisibility(ID_PROGRESS, android.view.View.GONE)

        // Set estimated time
        content.estimatedTime?.let { time ->
            remoteViews.setTextViewText(ID_TIME, "${time}분 남음")
            remoteViews.setViewVisibility(ID_TIME, android.view.View.VISIBLE)
        } ?: remoteViews.setViewVisibility(ID_TIME, android.view.View.GONE)

        return remoteViews
    }

    /**
     * Build an expanded notification layout with actions
     */
    fun buildExpandedLayout(config: LiveActivityConfig, notificationId: Int): RemoteViews {
        val remoteViews = buildCompactLayout(config, notificationId)

        // Add action buttons (max 2 for better UX)
        val actions = config.actions.take(2)

        if (actions.isNotEmpty()) {
            actions.getOrNull(0)?.let { action ->
                setupActionButton(remoteViews, ID_ACTION1, action, config.id, notificationId)
            } ?: remoteViews.setViewVisibility(ID_ACTION1, android.view.View.GONE)

            actions.getOrNull(1)?.let { action ->
                setupActionButton(remoteViews, ID_ACTION2, action, config.id, notificationId)
            } ?: remoteViews.setViewVisibility(ID_ACTION2, android.view.View.GONE)
        } else {
            remoteViews.setViewVisibility(ID_ACTION1, android.view.View.GONE)
            remoteViews.setViewVisibility(ID_ACTION2, android.view.View.GONE)
        }

        return remoteViews
    }

    /**
     * Build a layout for specific activity types with specialized UI
     */
    fun buildTypedLayout(config: LiveActivityConfig, notificationId: Int): RemoteViews {
        return when (config.type) {
            ActivityType.FOOD_DELIVERY -> buildFoodDeliveryLayout(config, notificationId)
            ActivityType.RIDESHARE -> buildRideshareLayout(config, notificationId)
            ActivityType.WORKOUT -> buildWorkoutLayout(config, notificationId)
            ActivityType.TIMER -> buildTimerLayout(config, notificationId)
            ActivityType.AUDIO_RECORDING -> buildAudioRecordingLayout(config, notificationId)
            ActivityType.CUSTOM -> buildExpandedLayout(config, notificationId)
        }
    }

    private fun buildFoodDeliveryLayout(config: LiveActivityConfig, notificationId: Int): RemoteViews {
        val remoteViews = buildCompactLayout(config, notificationId)

        // Add food delivery specific elements
        val customData = config.content.customData

        // Restaurant name
        (customData["restaurant"] as? String)?.let { restaurant ->
            remoteViews.setTextViewText(ID_MESSAGE, "${restaurant}에서 주문")
        }

        // Delivery status with emoji
        config.content.status?.let { status ->
            val statusWithEmoji = when (status.lowercase()) {
                "preparing", "준비 중" -> "🍳 준비 중"
                "cooking", "조리 중" -> "👨‍🍳 조리 중"
                "ready", "준비 완료" -> "✅ 준비 완료"
                "picked_up", "픽업 완료" -> "🚗 배달 시작"
                "on_the_way", "배달 중" -> "🚚 배달 중"
                "delivered", "배달 완료" -> "📦 배달 완료"
                else -> status
            }
            remoteViews.setTextViewText(ID_STATUS, statusWithEmoji)
        }

        return remoteViews
    }

    private fun buildRideshareLayout(config: LiveActivityConfig, notificationId: Int): RemoteViews {
        val remoteViews = buildCompactLayout(config, notificationId)

        // Add rideshare specific elements
        val customData = config.content.customData

        // Driver info
        (customData["driver"] as? Map<*, *>)?.let { driver ->
            val driverName = driver["name"] as? String
            val vehicle = driver["vehicle"] as? String
            if (driverName != null && vehicle != null) {
                remoteViews.setTextViewText(ID_MESSAGE, "$driverName - $vehicle")
            }
        }

        // Ride status with emoji
        config.content.status?.let { status ->
            val statusWithEmoji = when (status.lowercase()) {
                "searching", "검색 중" -> "🔍 기사 찾는 중"
                "accepted", "수락됨" -> "✅ 기사 배정"
                "arriving", "도착 중" -> "🚗 기사 도착 중"
                "arrived", "도착" -> "📍 기사 도착"
                "in_progress", "이동 중" -> "🚕 목적지로 이동"
                "completed", "완료" -> "🏁 도착 완료"
                else -> status
            }
            remoteViews.setTextViewText(ID_STATUS, statusWithEmoji)
        }

        return remoteViews
    }

    private fun buildWorkoutLayout(config: LiveActivityConfig, notificationId: Int): RemoteViews {
        val remoteViews = buildCompactLayout(config, notificationId)

        // Add workout specific elements
        val customData = config.content.customData

        // Workout type with emoji
        (customData["workoutType"] as? String)?.let { workoutType ->
            val typeWithEmoji = when (workoutType.lowercase()) {
                "running", "달리기" -> "🏃‍♂️ 달리기"
                "cycling", "자전거" -> "🚴‍♂️ 자전거"
                "swimming", "수영" -> "🏊‍♂️ 수영"
                "walking", "걷기" -> "🚶‍♂️ 걷기"
                "yoga", "요가" -> "🧘‍♂️ 요가"
                "weight_training", "웨이트" -> "🏋️‍♂️ 웨이트"
                else -> "💪 $workoutType"
            }
            remoteViews.setTextViewText(ID_STATUS, typeWithEmoji)
        }

        // Duration and calories
        val duration = customData["duration"] as? Int
        val calories = customData["calories"] as? Int
        if (duration != null || calories != null) {
            val info = mutableListOf<String>()
            duration?.let { info.add("${it}분") }
            calories?.let { info.add("${it}kcal") }
            remoteViews.setTextViewText(ID_MESSAGE, info.joinToString(" • "))
        }

        return remoteViews
    }

    private fun buildTimerLayout(config: LiveActivityConfig, notificationId: Int): RemoteViews {
        val remoteViews = buildCompactLayout(config, notificationId)

        // Add timer specific elements
        val customData = config.content.customData

        // Timer name
        (customData["name"] as? String)?.let { name ->
            remoteViews.setTextViewText(ID_STATUS, "⏰ $name")
        }

        // Remaining time
        (customData["remainingTime"] as? Int)?.let { remaining ->
            val minutes = remaining / 60
            val seconds = remaining % 60
            remoteViews.setTextViewText(ID_TIME, String.format("%02d:%02d", minutes, seconds))
        }

        // Timer state
        (customData["isRunning"] as? Boolean)?.let { isRunning ->
            val status = if (isRunning) "▶️ 실행 중" else "⏸️ 일시정지"
            remoteViews.setTextViewText(ID_MESSAGE, status)
        }

        return remoteViews
    }

    private fun buildAudioRecordingLayout(config: LiveActivityConfig, notificationId: Int): RemoteViews {
        val remoteViews = buildCompactLayout(config, notificationId)

        // Add audio recording specific elements
        val customData = config.content.customData

        // Recording status with emoji
        config.content.status?.let { status ->
            val statusWithEmoji = when (status.lowercase()) {
                "preparing", "준비 중" -> "🎙️ 준비 중"
                "recording", "녹음 중" -> "🔴 녹음 중"
                "paused", "일시정지" -> "⏸️ 일시정지"
                "stopped", "정지" -> "⏹️ 정지"
                "completed", "완료" -> "✅ 녹음 완료"
                else -> status
            }
            remoteViews.setTextViewText(ID_STATUS, statusWithEmoji)
        }

        // Recording duration
        (customData["duration"] as? Int)?.let { duration ->
            val minutes = duration / 60
            val seconds = duration % 60
            remoteViews.setTextViewText(ID_TIME, String.format("%02d:%02d", minutes, seconds))
        }

        // Audio quality
        (customData["quality"] as? String)?.let { quality ->
            val qualityText = when (quality.lowercase()) {
                "low" -> "표준 음질"
                "medium" -> "고음질"
                "high" -> "최고 음질"
                else -> quality
            }
            remoteViews.setTextViewText(ID_MESSAGE, qualityText)
        }

        return remoteViews
    }

    private fun setupActionButton(
        remoteViews: RemoteViews,
        buttonId: Int,
        action: ActivityAction,
        activityId: String,
        notificationId: Int
    ) {
        // Set button text
        remoteViews.setTextViewText(buttonId, action.title)
        remoteViews.setViewVisibility(buttonId, android.view.View.VISIBLE)

        // Create click intent
        val actionIntent = Intent(context, NotificationActionReceiver::class.java).apply {
            this.action = NotificationActionReceiver.ACTION_BUTTON_CLICKED
            putExtra("activityId", activityId)
            putExtra("actionId", action.id)
            putExtra("notificationId", notificationId)
        }

        val pendingIntent = PendingIntent.getBroadcast(
            context,
            (activityId + action.id).hashCode(),
            actionIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        remoteViews.setOnClickPendingIntent(buttonId, pendingIntent)

        // Style destructive actions differently (if possible)
        if (action.isDestructive) {
            // Custom styling can be applied in XML layouts if needed
        }
    }
}