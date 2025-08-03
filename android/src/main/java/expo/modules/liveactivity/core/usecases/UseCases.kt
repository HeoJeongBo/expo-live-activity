package expo.modules.liveactivity.core.usecases

import expo.modules.liveactivity.core.models.*
import expo.modules.liveactivity.core.services.LiveActivityServiceProtocol
import expo.modules.liveactivity.infrastructure.repositories.ActivityRepositoryProtocol
import expo.modules.liveactivity.presentation.events.ActivityEventPublisherProtocol

// MARK: - Use Case Protocols

interface StartActivityUseCaseProtocol {
    suspend fun execute(config: LiveActivityConfig): Result<LiveActivityInstance, ActivityError>
}

interface UpdateActivityUseCaseProtocol {
    suspend fun execute(request: ActivityUpdateRequest): Result<Unit, ActivityError>
}

interface EndActivityUseCaseProtocol {
    suspend fun execute(request: ActivityEndRequest): Result<Unit, ActivityError>
}

interface ActivityConfigValidatorProtocol {
    fun validate(config: LiveActivityConfig): ValidationResult
}

// MARK: - Start Activity Use Case

class StartActivityUseCase(
    private val activityService: LiveActivityServiceProtocol,
    private val repository: ActivityRepositoryProtocol,
    private val validator: ActivityConfigValidatorProtocol,
    private val eventPublisher: ActivityEventPublisherProtocol
) : StartActivityUseCaseProtocol {
    
    override suspend fun execute(config: LiveActivityConfig): Result<LiveActivityInstance, ActivityError> {
        // Validate configuration
        val validationResult = validator.validate(config)
        if (!validationResult.isValid) {
            val errorMessage = validationResult.errors.joinToString(", ") { "${it.field}: ${it.message}" }
            return Result.Failure(ActivityError.invalidConfiguration(errorMessage))
        }
        
        // Check if activity already exists and is active
        val existingActivity = repository.getActivity(config.id)
        if (existingActivity?.isActive == true) {
            return Result.Failure(ActivityError.alreadyStarted(config.id))
        }
        
        // Start activity
        return activityService.startActivity(config)
    }
}

// MARK: - Update Activity Use Case

class UpdateActivityUseCase(
    private val activityService: LiveActivityServiceProtocol,
    private val repository: ActivityRepositoryProtocol,
    private val eventPublisher: ActivityEventPublisherProtocol
) : UpdateActivityUseCaseProtocol {
    
    override suspend fun execute(request: ActivityUpdateRequest): Result<Unit, ActivityError> {
        // Check if activity exists and is active
        val activity = repository.getActivity(request.activityId)
            ?: return Result.Failure(ActivityError.activityNotFound(request.activityId))
        
        if (!activity.isActive) {
            return Result.Failure(ActivityError.activityNotFound(request.activityId))
        }
        
        // Update activity
        return activityService.updateActivity(request)
    }
}

// MARK: - End Activity Use Case

class EndActivityUseCase(
    private val activityService: LiveActivityServiceProtocol,
    private val repository: ActivityRepositoryProtocol,
    private val eventPublisher: ActivityEventPublisherProtocol
) : EndActivityUseCaseProtocol {
    
    override suspend fun execute(request: ActivityEndRequest): Result<Unit, ActivityError> {
        // Check if activity exists and is active
        val activity = repository.getActivity(request.activityId)
            ?: return Result.Failure(ActivityError.activityNotFound(request.activityId))
        
        if (!activity.isActive) {
            return Result.Failure(ActivityError.activityNotFound(request.activityId))
        }
        
        // End activity
        return activityService.endActivity(request)
    }
}

// MARK: - Activity Config Validator

class ActivityConfigValidator : ActivityConfigValidatorProtocol {
    
    override fun validate(config: LiveActivityConfig): ValidationResult {
        val errors = mutableListOf<ValidationError>()
        
        // Validate ID
        if (config.id.isBlank()) {
            errors.add(ValidationError("id", "Activity ID cannot be empty"))
        }
        
        if (config.id.length > 50) {
            errors.add(ValidationError("id", "Activity ID cannot exceed 50 characters"))
        }
        
        // Validate title
        if (config.title.isBlank()) {
            errors.add(ValidationError("title", "Activity title cannot be empty"))
        }
        
        if (config.title.length > 100) {
            errors.add(ValidationError("title", "Activity title cannot exceed 100 characters"))
        }
        
        // Validate actions (max 2 for Android notifications)
        if (config.actions.size > 2) {
            errors.add(ValidationError("actions", "Maximum 2 actions allowed for Android notifications"))
        }
        
        // Validate action IDs
        config.actions.forEach { action ->
            if (action.id.isBlank()) {
                errors.add(ValidationError("actions", "Action ID cannot be empty"))
            }
            if (action.title.isBlank()) {
                errors.add(ValidationError("actions", "Action title cannot be empty"))
            }
        }
        
        // Validate expiration date
        config.expirationDate?.let { expiration ->
            val maxExpiration = System.currentTimeMillis() + (8 * 60 * 60 * 1000) // 8 hours
            if (expiration.time > maxExpiration) {
                errors.add(ValidationError("expirationDate", "Expiration date cannot exceed 8 hours from now"))
            }
        }
        
        // Validate progress
        config.content.progress?.let { progress ->
            if (progress < 0.0 || progress > 1.0) {
                errors.add(ValidationError("content.progress", "Progress must be between 0.0 and 1.0"))
            }
        }
        
        return ValidationResult(
            isValid = errors.isEmpty(),
            errors = errors
        )
    }
}