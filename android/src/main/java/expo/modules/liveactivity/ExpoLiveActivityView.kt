package expo.modules.liveactivity

import android.content.Context
import android.graphics.Color
import android.view.Gravity
import android.view.ViewGroup
import android.widget.*
import expo.modules.kotlin.AppContext
import expo.modules.kotlin.viewevent.EventDispatcher
import expo.modules.kotlin.views.ExpoView
import expo.modules.liveactivity.core.models.*
import expo.modules.liveactivity.infrastructure.ui.NotificationLayoutBuilder

/**
 * Android Live Activity View Component
 * Provides a preview of how Live Activity notifications will appear
 */
class ExpoLiveActivityView(context: Context, appContext: AppContext) : ExpoView(context, appContext) {
    
    // Event dispatchers
    private val onLoad by EventDispatcher()
    private val onActivityAction by EventDispatcher()
    
    // UI Components
    private val rootContainer: LinearLayout
    private val titleText: TextView
    private val statusText: TextView
    private val messageText: TextView
    private val progressBar: ProgressBar
    private val timeText: TextView
    private val actionsContainer: LinearLayout
    
    // Current activity configuration
    private var currentConfig: LiveActivityConfig? = null
    
    init {
        // Create root container
        rootContainer = LinearLayout(context).apply {
            orientation = LinearLayout.VERTICAL
            setPadding(32, 24, 32, 24)
            setBackgroundColor(Color.parseColor("#F5F5F5"))
            layoutParams = LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.WRAP_CONTENT)
        }
        
        // Title text
        titleText = TextView(context).apply {
            textSize = 18f
            setTextColor(Color.BLACK)
            setTypeface(null, android.graphics.Typeface.BOLD)
            layoutParams = LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT,
                LinearLayout.LayoutParams.WRAP_CONTENT
            ).apply {
                bottomMargin = 8
            }
        }
        
        // Status text
        statusText = TextView(context).apply {
            textSize = 16f
            setTextColor(Color.parseColor("#333333"))
            layoutParams = LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT,
                LinearLayout.LayoutParams.WRAP_CONTENT
            ).apply {
                bottomMargin = 4
            }
        }
        
        // Message text
        messageText = TextView(context).apply {
            textSize = 14f
            setTextColor(Color.parseColor("#666666"))
            layoutParams = LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT,
                LinearLayout.LayoutParams.WRAP_CONTENT
            ).apply {
                bottomMargin = 8
            }
        }
        
        // Progress bar
        progressBar = ProgressBar(context, null, android.R.attr.progressBarStyleHorizontal).apply {
            layoutParams = LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT,
                LinearLayout.LayoutParams.WRAP_CONTENT
            ).apply {
                bottomMargin = 8
            }
            visibility = GONE
        }
        
        // Time text
        timeText = TextView(context).apply {
            textSize = 12f
            setTextColor(Color.parseColor("#888888"))
            gravity = Gravity.END
            layoutParams = LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT,
                LinearLayout.LayoutParams.WRAP_CONTENT
            ).apply {
                bottomMargin = 16
            }
        }
        
        // Actions container
        actionsContainer = LinearLayout(context).apply {
            orientation = LinearLayout.HORIZONTAL
            gravity = Gravity.END
            layoutParams = LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT,
                LinearLayout.LayoutParams.WRAP_CONTENT
            )
        }
        
        // Add all views to root container
        rootContainer.addView(titleText)
        rootContainer.addView(statusText)
        rootContainer.addView(messageText)
        rootContainer.addView(progressBar)
        rootContainer.addView(timeText)
        rootContainer.addView(actionsContainer)
        
        // Add root container to view
        addView(rootContainer)
        
        // Show placeholder initially
        showPlaceholder()
        
        // Dispatch load event
        onLoad(mapOf("loaded" to true))
    }
    
    /**
     * Update the view with activity configuration
     */
    fun updateActivity(config: LiveActivityConfig) {
        currentConfig = config
        
        // Update title
        titleText.text = config.title
        
        // Update content
        val content = config.content
        
        // Status
        content.status?.let { status ->
            statusText.text = getStatusWithEmoji(status, config.type)
            statusText.visibility = VISIBLE
        } ?: run {
            statusText.visibility = GONE
        }
        
        // Message
        content.message?.let { message ->
            messageText.text = message
            messageText.visibility = VISIBLE
        } ?: run {
            messageText.visibility = GONE
        }
        
        // Progress
        content.progress?.let { progress ->
            progressBar.progress = (progress * 100).toInt()
            progressBar.visibility = VISIBLE
        } ?: run {
            progressBar.visibility = GONE
        }
        
        // Estimated time
        content.estimatedTime?.let { time ->
            timeText.text = "${time}분 남음"
            timeText.visibility = VISIBLE
        } ?: run {
            timeText.visibility = GONE
        }
        
        // Update actions
        updateActions(config.actions)
    }
    
    /**
     * Update content only (for updates)
     */
    fun updateContent(content: ActivityContent) {
        currentConfig?.let { config ->
            val updatedConfig = config.copy(content = content)
            updateActivity(updatedConfig)
        }
    }
    
    private fun updateActions(actions: List<ActivityAction>) {
        // Clear existing actions
        actionsContainer.removeAllViews()
        
        // Add new actions (max 2)
        actions.take(2).forEach { action ->
            val button = Button(context).apply {
                text = action.title
                textSize = 12f
                setPadding(24, 12, 24, 12)
                
                // Style based on action type
                if (action.isDestructive) {
                    setTextColor(Color.WHITE)
                    setBackgroundColor(Color.parseColor("#FF3B30"))
                } else {
                    setTextColor(Color.parseColor("#007AFF"))
                    setBackgroundColor(Color.parseColor("#E3F2FD"))
                }
                
                layoutParams = LinearLayout.LayoutParams(
                    LinearLayout.LayoutParams.WRAP_CONTENT,
                    LinearLayout.LayoutParams.WRAP_CONTENT
                ).apply {
                    marginStart = 8
                }
                
                setOnClickListener {
                    handleActionClick(action)
                }
            }
            
            actionsContainer.addView(button)
        }
        
        actionsContainer.visibility = if (actions.isNotEmpty()) VISIBLE else GONE
    }
    
    private fun handleActionClick(action: ActivityAction) {
        currentConfig?.let { config ->
            onActivityAction(mapOf(
                "activityId" to config.id,
                "actionId" to action.id,
                "actionTitle" to action.title,
                "timestamp" to System.currentTimeMillis()
            ))
        }
    }
    
    private fun getStatusWithEmoji(status: String, type: ActivityType): String {
        return when (type) {
            ActivityType.FOOD_DELIVERY -> when (status.lowercase()) {
                "preparing", "준비 중" -> "🍳 준비 중"
                "cooking", "조리 중" -> "👨‍🍳 조리 중"
                "ready", "준비 완료" -> "✅ 준비 완료"
                "picked_up", "픽업 완료" -> "🚗 배달 시작"
                "on_the_way", "배달 중" -> "🚚 배달 중"
                "delivered", "배달 완료" -> "📦 배달 완료"
                else -> status
            }
            ActivityType.RIDESHARE -> when (status.lowercase()) {
                "searching", "검색 중" -> "🔍 기사 찾는 중"
                "accepted", "수락됨" -> "✅ 기사 배정"
                "arriving", "도착 중" -> "🚗 기사 도착 중"
                "arrived", "도착" -> "📍 기사 도착"
                "in_progress", "이동 중" -> "🚕 목적지로 이동"
                "completed", "완료" -> "🏁 도착 완료"
                else -> status
            }
            ActivityType.AUDIO_RECORDING -> when (status.lowercase()) {
                "preparing", "준비 중" -> "🎙️ 준비 중"
                "recording", "녹음 중" -> "🔴 녹음 중"
                "paused", "일시정지" -> "⏸️ 일시정지"
                "stopped", "정지" -> "⏹️ 정지"
                "completed", "완료" -> "✅ 녹음 완료"
                else -> status
            }
            ActivityType.TIMER -> when (status.lowercase()) {
                "running", "실행 중" -> "▶️ 실행 중"
                "paused", "일시정지" -> "⏸️ 일시정지"
                "stopped", "정지" -> "⏹️ 정지"
                "completed", "완료" -> "⏰ 시간 종료"
                else -> status
            }
            ActivityType.WORKOUT -> when (status.lowercase()) {
                "active", "활성" -> "💪 운동 중"
                "paused", "일시정지" -> "⏸️ 일시정지"
                "completed", "완료" -> "🏁 운동 완료"
                else -> status
            }
            else -> status
        }
    }
    
    private fun showPlaceholder() {
        titleText.text = "Live Activity Preview"
        statusText.text = "Activity 상태가 여기에 표시됩니다"
        messageText.text = "추가 메시지와 정보가 여기에 나타납니다"
        timeText.text = ""
        progressBar.visibility = GONE
        actionsContainer.removeAllViews()
        actionsContainer.visibility = GONE
    }
}
