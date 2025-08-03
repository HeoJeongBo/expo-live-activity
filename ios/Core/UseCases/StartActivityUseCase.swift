import Foundation

/// Live Activity 시작 Use Case 구현
/// Single Responsibility: Activity 시작 비즈니스 로직만 담당
public final class StartActivityUseCase: StartActivityUseCaseProtocol {
    
    // MARK: - Dependencies (Dependency Injection)
    
    private let activityService: LiveActivityServiceProtocol
    private let repository: ActivityRepositoryProtocol
    private let validator: ActivityConfigValidatorProtocol
    private let eventPublisher: EventPublisherProtocol
    
    // MARK: - Initialization
    
    public init(
        activityService: LiveActivityServiceProtocol,
        repository: ActivityRepositoryProtocol,
        validator: ActivityConfigValidatorProtocol,
        eventPublisher: EventPublisherProtocol
    ) {
        self.activityService = activityService
        self.repository = repository
        self.validator = validator
        self.eventPublisher = eventPublisher
    }
    
    // MARK: - Use Case Execution
    
    /// Activity 시작 실행
    /// Clean Code: 함수는 한 가지 일만 하며, 작고 읽기 쉽게 구성
    public func execute(_ config: LiveActivityConfig) async -> Result<LiveActivityInstance, ActivityError> {
        // 1. 입력 검증 (Validation First)
        let validationResult = validator.validate(config)
        guard validationResult.isValid else {
            let error = ActivityError.invalidConfiguration(
                validationResult.errors.map { $0.message }.joined(separator: ", ")
            )
            eventPublisher.publish(.error(error))
            return .failure(error)
        }
        
        // 2. 중복 Activity 확인
        let existingActivityResult = await repository.findById(config.id)
        switch existingActivityResult {
        case .success(let existingActivity):
            if let existing = existingActivity, existing.isActive {
                let error = ActivityError.alreadyStarted(config.id)
                eventPublisher.publish(.error(error))
                return .failure(error)
            }
        case .failure(let error):
            eventPublisher.publish(.error(error))
            return .failure(error)
        }
        
        // 3. Activity 시작 시도
        let startResult = await activityService.startActivity(config)
        switch startResult {
        case .success(let activity):
            // 4. 성공 시 저장 및 이벤트 발행
            let saveResult = await repository.save(activity)
            switch saveResult {
            case .success:
                eventPublisher.publish(.started(activity))
                return .success(activity)
            case .failure(let error):
                // Rollback: 시작된 Activity 정리
                await rollbackStartedActivity(activity)
                eventPublisher.publish(.error(error))
                return .failure(error)
            }
        case .failure(let error):
            eventPublisher.publish(.error(error))
            return .failure(error)
        }
    }
    
    // MARK: - Private Helper Methods
    
    /// 실패 시 시작된 Activity 롤백
    /// Error Handling: 실패 상황에 대한 적절한 복구 로직
    private func rollbackStartedActivity(_ activity: LiveActivityInstance) async {
        guard let nativeId = activity.nativeActivityId else { return }
        
        let endRequest = ActivityEndRequest(
            activityId: activity.id,
            finalContent: nil,
            dismissalPolicy: .immediate
        )
        
        _ = await activityService.endActivity(endRequest)
    }
}

/// Live Activity 업데이트 Use Case 구현
public final class UpdateActivityUseCase: UpdateActivityUseCaseProtocol {
    
    // MARK: - Dependencies
    
    private let activityService: LiveActivityServiceProtocol
    private let repository: ActivityRepositoryProtocol
    private let eventPublisher: EventPublisherProtocol
    
    // MARK: - Initialization
    
    public init(
        activityService: LiveActivityServiceProtocol,
        repository: ActivityRepositoryProtocol,
        eventPublisher: EventPublisherProtocol
    ) {
        self.activityService = activityService
        self.repository = repository
        self.eventPublisher = eventPublisher
    }
    
    // MARK: - Use Case Execution
    
    public func execute(_ request: ActivityUpdateRequest) async -> Result<Void, ActivityError> {
        // 1. Activity 존재 확인
        let findResult = await repository.findById(request.activityId)
        switch findResult {
        case .success(let activity):
            guard let existingActivity = activity else {
                let error = ActivityError.activityNotFound(request.activityId)
                eventPublisher.publish(.error(error))
                return .failure(error)
            }
            
            // 2. Activity 활성 상태 확인
            guard existingActivity.isActive else {
                let error = ActivityError.activityNotFound(request.activityId)
                eventPublisher.publish(.error(error))
                return .failure(error)
            }
            
            // 3. Activity 업데이트 실행
            let updateResult = await activityService.updateActivity(request)
            switch updateResult {
            case .success:
                // 4. 업데이트된 Activity 저장
                let updatedActivity = LiveActivityInstance(
                    id: existingActivity.id,
                    config: LiveActivityConfig(
                        id: existingActivity.config.id,
                        type: existingActivity.config.type,
                        title: existingActivity.config.title,
                        content: request.content, // 새로운 콘텐츠로 업데이트
                        actions: existingActivity.config.actions,
                        expirationDate: existingActivity.config.expirationDate,
                        priority: existingActivity.config.priority
                    ),
                    isActive: existingActivity.isActive,
                    createdAt: existingActivity.createdAt,
                    updatedAt: request.timestamp, // 업데이트 시간 갱신
                    nativeActivityId: existingActivity.nativeActivityId
                )
                
                let saveResult = await repository.update(updatedActivity)
                switch saveResult {
                case .success:
                    eventPublisher.publish(.updated(request))
                    return .success(())
                case .failure(let error):
                    eventPublisher.publish(.error(error))
                    return .failure(error)
                }
            case .failure(let error):
                eventPublisher.publish(.error(error))
                return .failure(error)
            }
            
        case .failure(let error):
            eventPublisher.publish(.error(error))
            return .failure(error)
        }
    }
}

/// Live Activity 종료 Use Case 구현
public final class EndActivityUseCase: EndActivityUseCaseProtocol {
    
    // MARK: - Dependencies
    
    private let activityService: LiveActivityServiceProtocol
    private let repository: ActivityRepositoryProtocol
    private let eventPublisher: EventPublisherProtocol
    
    // MARK: - Initialization
    
    public init(
        activityService: LiveActivityServiceProtocol,
        repository: ActivityRepositoryProtocol,
        eventPublisher: EventPublisherProtocol
    ) {
        self.activityService = activityService
        self.repository = repository
        self.eventPublisher = eventPublisher
    }
    
    // MARK: - Use Case Execution
    
    public func execute(_ request: ActivityEndRequest) async -> Result<Void, ActivityError> {
        // 1. Activity 존재 확인
        let findResult = await repository.findById(request.activityId)
        switch findResult {
        case .success(let activity):
            guard let existingActivity = activity else {
                let error = ActivityError.activityNotFound(request.activityId)
                eventPublisher.publish(.error(error))
                return .failure(error)
            }
            
            // 2. Activity 종료 실행
            let endResult = await activityService.endActivity(request)
            switch endResult {
            case .success:
                // 3. Activity 상태 업데이트 (비활성화)
                let inactiveActivity = LiveActivityInstance(
                    id: existingActivity.id,
                    config: existingActivity.config,
                    isActive: false, // 비활성 상태로 변경
                    createdAt: existingActivity.createdAt,
                    updatedAt: Date(),
                    nativeActivityId: existingActivity.nativeActivityId
                )
                
                let updateResult = await repository.update(inactiveActivity)
                switch updateResult {
                case .success:
                    eventPublisher.publish(.ended(request))
                    return .success(())
                case .failure(let error):
                    eventPublisher.publish(.error(error))
                    return .failure(error)
                }
            case .failure(let error):
                eventPublisher.publish(.error(error))
                return .failure(error)
            }
            
        case .failure(let error):
            eventPublisher.publish(.error(error))
            return .failure(error)
        }
    }
}

// MARK: - Activity Config Validator Implementation

/// Activity 설정 검증기 구현
/// Single Responsibility: 오직 검증 로직만 담당
public final class ActivityConfigValidator: ActivityConfigValidatorProtocol {
    
    public init() {}
    
    public func validate(_ config: LiveActivityConfig) -> ValidationResult {
        var errors: [ValidationError] = []
        
        // ID 검증
        if config.id.isEmpty {
            errors.append(ValidationError(field: "id", message: "Activity ID는 필수입니다"))
        } else if config.id.count > 50 {
            errors.append(ValidationError(field: "id", message: "Activity ID는 50자를 초과할 수 없습니다"))
        }
        
        // 제목 검증
        if config.title.isEmpty {
            errors.append(ValidationError(field: "title", message: "Activity 제목은 필수입니다"))
        } else if config.title.count > 100 {
            errors.append(ValidationError(field: "title", message: "Activity 제목은 100자를 초과할 수 없습니다"))
        }
        
        // 만료 날짜 검증
        if let expirationDate = config.expirationDate {
            if expirationDate <= Date() {
                errors.append(ValidationError(field: "expirationDate", message: "만료 날짜는 현재 시간보다 미래여야 합니다"))
            }
            
            // ActivityKit 제한: 최대 8시간
            let maxExpirationDate = Date().addingTimeInterval(8 * 60 * 60)
            if expirationDate > maxExpirationDate {
                errors.append(ValidationError(field: "expirationDate", message: "만료 날짜는 현재로부터 8시간을 초과할 수 없습니다"))
            }
        }
        
        // 액션 개수 검증 (iOS 제한)
        if config.actions.count > 2 {
            errors.append(ValidationError(field: "actions", message: "최대 2개의 액션만 지원됩니다"))
        }
        
        // 액션 ID 중복 검증
        let actionIds = config.actions.map { $0.id }
        if Set(actionIds).count != actionIds.count {
            errors.append(ValidationError(field: "actions", message: "액션 ID는 중복될 수 없습니다"))
        }
        
        return ValidationResult(isValid: errors.isEmpty, errors: errors)
    }
}

// MARK: - Event Publisher Implementation

/// 이벤트 발행자 구현
/// Observer 패턴을 통한 이벤트 발행/구독
public final class ActivityEventPublisher: EventPublisherProtocol {
    
    private let eventContinuation: AsyncStream<ActivityEvent>.Continuation
    private let eventStream: AsyncStream<ActivityEvent>
    
    public init() {
        let (stream, continuation) = AsyncStream<ActivityEvent>.makeStream()
        self.eventStream = stream
        self.eventContinuation = continuation
    }
    
    public func publish(_ event: ActivityEvent) {
        eventContinuation.yield(event)
    }
    
    public func subscribe() -> AsyncStream<ActivityEvent> {
        return eventStream
    }
    
    deinit {
        eventContinuation.finish()
    }
}