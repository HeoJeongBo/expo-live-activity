package expo.modules.liveactivity.presentation.events

import expo.modules.liveactivity.core.models.ActivityEvent
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.MutableSharedFlow
import kotlinx.coroutines.flow.asSharedFlow

// MARK: - Event Publisher Protocol

interface ActivityEventPublisherProtocol {
    val eventFlow: Flow<ActivityEvent>
    fun publishEvent(event: ActivityEvent)
}

// MARK: - Event Publisher Implementation

class ActivityEventPublisher : ActivityEventPublisherProtocol {
    
    companion object {
        @Volatile
        private var INSTANCE: ActivityEventPublisher? = null
        
        fun getInstance(): ActivityEventPublisher? = INSTANCE
        
        internal fun setInstance(instance: ActivityEventPublisher) {
            INSTANCE = instance
        }
    }
    
    private val _eventFlow = MutableSharedFlow<ActivityEvent>(
        replay = 0,
        extraBufferCapacity = 10
    )
    
    override val eventFlow: Flow<ActivityEvent> = _eventFlow.asSharedFlow()
    
    override fun publishEvent(event: ActivityEvent) {
        _eventFlow.tryEmit(event)
    }
    
    init {
        // Set the singleton instance
        setInstance(this)
    }
}