package expo.modules.liveactivity.infrastructure.notifications

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import androidx.core.app.NotificationManagerCompat
import expo.modules.liveactivity.core.models.ActivityEvent
import expo.modules.liveactivity.presentation.events.ActivityEventPublisher
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import java.util.*

/**
 * BroadcastReceiver for handling notification action button clicks
 */
class NotificationActionReceiver : BroadcastReceiver() {
    
    companion object {
        const val ACTION_BUTTON_CLICKED = "expo.liveactivity.ACTION_BUTTON_CLICKED"
    }
    
    private val coroutineScope = CoroutineScope(Dispatchers.Main)
    
    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action != ACTION_BUTTON_CLICKED) return
        
        val activityId = intent.getStringExtra("activityId") ?: return
        val actionId = intent.getStringExtra("actionId") ?: return
        val notificationId = intent.getIntExtra("notificationId", -1)
        
        // Handle the action click
        handleActionClick(context, activityId, actionId, notificationId)
    }
    
    private fun handleActionClick(context: Context, activityId: String, actionId: String, notificationId: Int) {
        coroutineScope.launch {
            try {
                // Publish user action event
                val eventPublisher = ActivityEventPublisher.getInstance()
                eventPublisher?.publishEvent(
                    ActivityEvent.UserAction(
                        activityId = activityId,
                        actionId = actionId,
                        timestamp = Date()
                    )
                )
                
                // Handle specific actions based on actionId
                when (actionId) {
                    "cancel", "stop", "dismiss" -> {
                        // Auto-dismiss the notification for cancel/stop actions
                        dismissNotification(context, notificationId)
                    }
                    "call", "contact" -> {
                        // Handle call actions - could open phone app or return to main app
                        openMainApp(context, activityId)
                    }
                    else -> {
                        // Default behavior - return to main app
                        openMainApp(context, activityId)
                    }
                }
                
            } catch (e: Exception) {
                // Log error but don't crash
                android.util.Log.e("NotificationActionReceiver", "Error handling action click", e)
            }
        }
    }
    
    private fun dismissNotification(context: Context, notificationId: Int) {
        try {
            val notificationManager = NotificationManagerCompat.from(context)
            notificationManager.cancel(notificationId)
        } catch (e: Exception) {
            android.util.Log.e("NotificationActionReceiver", "Error dismissing notification", e)
        }
    }
    
    private fun openMainApp(context: Context, activityId: String) {
        try {
            val launchIntent = context.packageManager.getLaunchIntentForPackage(context.packageName)
            launchIntent?.let { intent ->
                intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP)
                intent.putExtra("activityId", activityId)
                intent.putExtra("source", "notification_action")
                context.startActivity(intent)
            }
        } catch (e: Exception) {
            android.util.Log.e("NotificationActionReceiver", "Error opening main app", e)
        }
    }
}