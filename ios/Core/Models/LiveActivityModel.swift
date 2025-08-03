import Foundation

// MARK: - Core Domain Models

/// Live Activity 설정 모델 (Domain Entity)
public struct LiveActivityConfig {
    let id: String
    let type: ActivityType
    let title: String
    let content: ActivityContent
    let actions: [ActivityAction]
    let expirationDate: Date?
    let priority: ActivityPriority
    
    public init(
        id: String,
        type: ActivityType,
        title: String,
        content: ActivityContent,
        actions: [ActivityAction] = [],
        expirationDate: Date? = nil,
        priority: ActivityPriority = .normal
    ) {
        self.id = id
        self.type = type
        self.title = title
        self.content = content
        self.actions = actions
        self.expirationDate = expirationDate
        self.priority = priority
    }
}

/// Activity 타입 (확장 가능한 열거형)
public enum ActivityType: String, CaseIterable {
    case foodDelivery = "foodDelivery"
    case rideshare = "rideshare"
    case workout = "workout"
    case timer = "timer"
    case custom = "custom"
    
    var displayName: String {
        switch self {
        case .foodDelivery: return "음식 배달"
        case .rideshare: return "차량 호출"
        case .workout: return "운동"
        case .timer: return "타이머"
        case .custom: return "사용자 정의"
        }
    }
}

/// Activity 우선순위
public enum ActivityPriority: String, CaseIterable {
    case low = "low"
    case normal = "normal"
    case high = "high"
    
    var displayPriority: String {
        switch self {
        case .low: return "낮음"
        case .normal: return "보통"
        case .high: return "높음"
        }
    }
}

/// Activity 콘텐츠 (Value Object)
public struct ActivityContent {
    let status: String?
    let progress: Double?
    let message: String?
    let estimatedTime: Int?
    let customData: [String: Any]
    
    public init(
        status: String? = nil,
        progress: Double? = nil,
        message: String? = nil,
        estimatedTime: Int? = nil,
        customData: [String: Any] = [:]
    ) {
        self.status = status
        self.progress = progress
        self.message = message
        self.estimatedTime = estimatedTime
        self.customData = customData
    }
}

/// Activity 액션 (Value Object)
public struct ActivityAction {
    let id: String
    let title: String
    let icon: String?
    let isDestructive: Bool
    let deepLink: String?
    
    public init(
        id: String,
        title: String,
        icon: String? = nil,
        isDestructive: Bool = false,
        deepLink: String? = nil
    ) {
        self.id = id
        self.title = title
        self.icon = icon
        self.isDestructive = isDestructive
        self.deepLink = deepLink
    }
}

/// Live Activity 인스턴스 (Entity)
public struct LiveActivityInstance {
    let id: String
    let config: LiveActivityConfig
    let isActive: Bool
    let createdAt: Date
    let updatedAt: Date
    let nativeActivityId: String? // ActivityKit Activity ID
    
    public init(
        id: String,
        config: LiveActivityConfig,
        isActive: Bool = false,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        nativeActivityId: String? = nil
    ) {
        self.id = id
        self.config = config
        self.isActive = isActive
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.nativeActivityId = nativeActivityId
    }
}

// MARK: - Activity Update Models

/// Activity 업데이트 모델
public struct ActivityUpdateRequest {
    let activityId: String
    let content: ActivityContent
    let timestamp: Date
    
    public init(activityId: String, content: ActivityContent, timestamp: Date = Date()) {
        self.activityId = activityId
        self.content = content
        self.timestamp = timestamp
    }
}

/// Activity 종료 요청
public struct ActivityEndRequest {
    let activityId: String
    let finalContent: ActivityContent?
    let dismissalPolicy: DismissalPolicy
    
    public init(
        activityId: String,
        finalContent: ActivityContent? = nil,
        dismissalPolicy: DismissalPolicy = .default
    ) {
        self.activityId = activityId
        self.finalContent = finalContent
        self.dismissalPolicy = dismissalPolicy
    }
}

/// Activity 해제 정책
public enum DismissalPolicy: String {
    case immediate = "immediate"
    case `default` = "default"
    case after = "after"
}

// MARK: - Event Models

/// Activity 이벤트 (Domain Event)
public enum ActivityEvent {
    case started(LiveActivityInstance)
    case updated(ActivityUpdateRequest)
    case ended(ActivityEndRequest)
    case userAction(ActivityUserActionEvent)
    case error(ActivityError)
}

/// 사용자 액션 이벤트
public struct ActivityUserActionEvent {
    let activityId: String
    let actionId: String
    let timestamp: Date
    
    public init(activityId: String, actionId: String, timestamp: Date = Date()) {
        self.activityId = activityId
        self.actionId = actionId
        self.timestamp = timestamp
    }
}

// MARK: - Error Models

/// Activity 관련 에러
public enum ActivityError: Error, LocalizedError {
    case invalidConfiguration(String)
    case activityNotFound(String)
    case alreadyStarted(String)
    case systemNotSupported
    case permissionDenied
    case networkError(String)
    case unknown(String)
    
    public var errorDescription: String? {
        switch self {
        case .invalidConfiguration(let message):
            return "잘못된 설정: \(message)"
        case .activityNotFound(let id):
            return "Activity를 찾을 수 없습니다: \(id)"
        case .alreadyStarted(let id):
            return "이미 시작된 Activity입니다: \(id)"
        case .systemNotSupported:
            return "시스템에서 Live Activity를 지원하지 않습니다"
        case .permissionDenied:
            return "Live Activity 권한이 거부되었습니다"
        case .networkError(let message):
            return "네트워크 오류: \(message)"
        case .unknown(let message):
            return "알 수 없는 오류: \(message)"
        }
    }
}

// MARK: - Result Type

/// 결과 타입 (함수형 에러 처리)
public enum Result<Success, Failure: Error> {
    case success(Success)
    case failure(Failure)
    
    public var isSuccess: Bool {
        if case .success = self { return true }
        return false
    }
    
    public var isFailure: Bool {
        return !isSuccess
    }
}