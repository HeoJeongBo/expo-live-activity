import Foundation

// MARK: - Service Protocols (Dependency Inversion Principle)

/// Live Activity 서비스 프로토콜
/// 고수준 모듈이 저수준 모듈에 의존하지 않도록 하는 추상화
public protocol LiveActivityServiceProtocol {
    /// Live Activity 시작
    /// - Parameter config: Activity 설정
    /// - Returns: 생성된 Activity 인스턴스 또는 에러
    func startActivity(_ config: LiveActivityConfig) async -> Result<LiveActivityInstance, ActivityError>
    
    /// Live Activity 업데이트
    /// - Parameter request: 업데이트 요청
    /// - Returns: 성공 여부 또는 에러
    func updateActivity(_ request: ActivityUpdateRequest) async -> Result<Void, ActivityError>
    
    /// Live Activity 종료
    /// - Parameter request: 종료 요청
    /// - Returns: 성공 여부 또는 에러
    func endActivity(_ request: ActivityEndRequest) async -> Result<Void, ActivityError>
    
    /// 활성 Activity 목록 조회
    /// - Returns: 활성 Activity 목록 또는 에러
    func getActiveActivities() async -> Result<[LiveActivityInstance], ActivityError>
    
    /// 특정 Activity 조회
    /// - Parameter id: Activity ID
    /// - Returns: Activity 인스턴스 또는 에러
    func getActivity(id: String) async -> Result<LiveActivityInstance?, ActivityError>
    
    /// Activity 이벤트 스트림
    /// - Returns: Activity 이벤트 AsyncStream
    func eventStream() -> AsyncStream<ActivityEvent>
}

/// Dynamic Island 서비스 프로토콜
public protocol DynamicIslandServiceProtocol {
    /// Dynamic Island 업데이트
    /// - Parameter request: Dynamic Island 업데이트 요청
    /// - Returns: 성공 여부 또는 에러
    func updateDynamicIsland(_ request: DynamicIslandUpdateRequest) async -> Result<Void, ActivityError>
    
    /// Dynamic Island 지원 여부 확인
    /// - Returns: 지원 여부
    func isDynamicIslandSupported() -> Bool
    
    /// Dynamic Island 상태 조회
    /// - Parameter activityId: Activity ID
    /// - Returns: 현재 Dynamic Island 콘텐츠 또는 에러
    func getDynamicIslandContent(activityId: String) async -> Result<DynamicIslandContent?, ActivityError>
}

/// Activity Repository 프로토콜 (Data Access Layer)
public protocol ActivityRepositoryProtocol {
    /// Activity 저장
    /// - Parameter activity: 저장할 Activity 인스턴스
    /// - Returns: 성공 여부 또는 에러
    func save(_ activity: LiveActivityInstance) async -> Result<Void, ActivityError>
    
    /// Activity 조회
    /// - Parameter id: Activity ID
    /// - Returns: Activity 인스턴스 또는 에러
    func findById(_ id: String) async -> Result<LiveActivityInstance?, ActivityError>
    
    /// 모든 활성 Activity 조회
    /// - Returns: 활성 Activity 목록 또는 에러
    func findAllActive() async -> Result<[LiveActivityInstance], ActivityError>
    
    /// Activity 삭제
    /// - Parameter id: Activity ID
    /// - Returns: 성공 여부 또는 에러
    func delete(_ id: String) async -> Result<Void, ActivityError>
    
    /// Activity 업데이트
    /// - Parameter activity: 업데이트할 Activity 인스턴스
    /// - Returns: 성공 여부 또는 에러
    func update(_ activity: LiveActivityInstance) async -> Result<Void, ActivityError>
}

/// ActivityKit 추상화 프로토콜
public protocol ActivityKitManagerProtocol {
    /// 시스템 Live Activity 지원 여부
    /// - Returns: 지원 여부
    func isLiveActivitySupported() -> Bool
    
    /// ActivityKit을 통한 Activity 시작
    /// - Parameter config: Activity 설정
    /// - Returns: 네이티브 Activity ID 또는 에러
    func startNativeActivity(_ config: LiveActivityConfig) async -> Result<String, ActivityError>
    
    /// ActivityKit을 통한 Activity 업데이트
    /// - Parameters:
    ///   - nativeId: 네이티브 Activity ID
    ///   - content: 업데이트할 콘텐츠
    /// - Returns: 성공 여부 또는 에러
    func updateNativeActivity(nativeId: String, content: ActivityContent) async -> Result<Void, ActivityError>
    
    /// ActivityKit을 통한 Activity 종료
    /// - Parameters:
    ///   - nativeId: 네이티브 Activity ID
    ///   - finalContent: 최종 콘텐츠
    ///   - dismissalPolicy: 해제 정책
    /// - Returns: 성공 여부 또는 에러
    func endNativeActivity(
        nativeId: String,
        finalContent: ActivityContent?,
        dismissalPolicy: DismissalPolicy
    ) async -> Result<Void, ActivityError>
    
    /// ActivityKit 이벤트 스트림
    /// - Returns: ActivityKit 이벤트 AsyncStream
    func nativeEventStream() -> AsyncStream<ActivityEvent>
}

/// Push 알림 서비스 프로토콜
public protocol PushNotificationServiceProtocol {
    /// Push 토큰 등록
    /// - Parameter token: APNS 토큰
    /// - Returns: 성공 여부 또는 에러
    func registerPushToken(_ token: String) async -> Result<Void, ActivityError>
    
    /// Activity 원격 업데이트 요청
    /// - Parameters:
    ///   - activityId: Activity ID
    ///   - content: 업데이트할 콘텐츠
    ///   - pushToken: 대상 Push 토큰
    /// - Returns: 성공 여부 또는 에러
    func requestRemoteUpdate(
        activityId: String,
        content: ActivityContent,
        pushToken: String
    ) async -> Result<Void, ActivityError>
    
    /// Push 알림 권한 상태 확인
    /// - Returns: 권한 상태
    func getPushAuthorizationStatus() async -> PushAuthorizationStatus
}

/// Push 알림 권한 상태
public enum PushAuthorizationStatus {
    case notDetermined
    case denied
    case authorized
    case provisional
    case ephemeral
}

// MARK: - Use Case Protocols

/// Live Activity 시작 Use Case
public protocol StartActivityUseCaseProtocol {
    /// Activity 시작 실행
    /// - Parameter config: Activity 설정
    /// - Returns: 생성된 Activity 인스턴스 또는 에러
    func execute(_ config: LiveActivityConfig) async -> Result<LiveActivityInstance, ActivityError>
}

/// Live Activity 업데이트 Use Case
public protocol UpdateActivityUseCaseProtocol {
    /// Activity 업데이트 실행
    /// - Parameter request: 업데이트 요청
    /// - Returns: 성공 여부 또는 에러
    func execute(_ request: ActivityUpdateRequest) async -> Result<Void, ActivityError>
}

/// Live Activity 종료 Use Case
public protocol EndActivityUseCaseProtocol {
    /// Activity 종료 실행
    /// - Parameter request: 종료 요청
    /// - Returns: 성공 여부 또는 에러
    func execute(_ request: ActivityEndRequest) async -> Result<Void, ActivityError>
}

// MARK: - Validation Protocols

/// Activity 설정 검증 프로토콜
public protocol ActivityConfigValidatorProtocol {
    /// 설정 유효성 검증
    /// - Parameter config: 검증할 설정
    /// - Returns: 검증 결과
    func validate(_ config: LiveActivityConfig) -> ValidationResult
}

/// 검증 결과
public struct ValidationResult {
    let isValid: Bool
    let errors: [ValidationError]
    
    public init(isValid: Bool, errors: [ValidationError] = []) {
        self.isValid = isValid
        self.errors = errors
    }
    
    public static let valid = ValidationResult(isValid: true)
}

/// 검증 에러
public struct ValidationError {
    let field: String
    let message: String
    
    public init(field: String, message: String) {
        self.field = field
        self.message = message
    }
}

// MARK: - Event Publisher Protocol

/// 이벤트 발행 프로토콜
public protocol EventPublisherProtocol {
    /// 이벤트 발행
    /// - Parameter event: 발행할 이벤트
    func publish(_ event: ActivityEvent)
    
    /// 이벤트 구독
    /// - Returns: 이벤트 AsyncStream
    func subscribe() -> AsyncStream<ActivityEvent>
}