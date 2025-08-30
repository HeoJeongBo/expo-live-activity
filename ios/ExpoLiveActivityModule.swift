import ExpoModulesCore
import Foundation

/// Expo Live Activity 모듈 - Presentation Layer
/// Clean Architecture: 외부 인터페이스(JavaScript)와 내부 비즈니스 로직을 연결
public class ExpoLiveActivityModule: Module {
    
    // MARK: - Dependencies (Lazy Initialization)
    
    private lazy var activityKitManager: ActivityKitManagerProtocol = {
        if #available(iOS 16.1, *) {
            return ActivityKitManager()
        } else {
            return MockActivityKitManager()
        }
    }()
    
    private lazy var repository: ActivityRepositoryProtocol = {
        // 실제 앱에서는 UserDefaults 기반 repository 사용
        // 개발/테스트 시에는 InMemory repository 사용 가능
        return UserDefaultsActivityRepository()
    }()
    
    private lazy var eventPublisher: EventPublisherProtocol = {
        return ActivityEventPublisher()
    }()
    
    private lazy var validator: ActivityConfigValidatorProtocol = {
        return ActivityConfigValidator()
    }()
    
    private lazy var liveActivityService: LiveActivityServiceProtocol = {
        return LiveActivityService(
            activityKitManager: activityKitManager,
            repository: repository,
            eventPublisher: eventPublisher
        )
    }()
    
    private lazy var dynamicIslandService: DynamicIslandServiceProtocol = {
        return DynamicIslandService(
            activityKitManager: activityKitManager,
            repository: repository
        )
    }()
    
    private lazy var pushService: PushNotificationServiceProtocol = {
        return PushNotificationService()
    }()
    
    // Use Cases
    private lazy var startActivityUseCase: StartActivityUseCaseProtocol = {
        return StartActivityUseCase(
            activityService: liveActivityService,
            repository: repository,
            validator: validator,
            eventPublisher: eventPublisher
        )
    }()
    
    private lazy var updateActivityUseCase: UpdateActivityUseCaseProtocol = {
        return UpdateActivityUseCase(
            activityService: liveActivityService,
            repository: repository,
            eventPublisher: eventPublisher
        )
    }()
    
    private lazy var endActivityUseCase: EndActivityUseCaseProtocol = {
        return EndActivityUseCase(
            activityService: liveActivityService,
            repository: repository,
            eventPublisher: eventPublisher
        )
    }()
    
    // MARK: - Module Definition
    
    public func definition() -> ModuleDefinition {
        Name("ExpoLiveActivity")
        
        // Constants
        Constants([
            "isSupported": self.activityKitManager.isLiveActivitySupported(),
            "isDynamicIslandSupported": self.dynamicIslandService.isDynamicIslandSupported()
        ])
        
        // Events
        Events([
            "onActivityUpdate",
            "onUserAction", 
            "onActivityEnd",
            "onError",
            "onAudioRecordingUpdate"
        ])
        
        // Event Listener Management
        AsyncFunction("addListener") { (eventName: String) -> [String: Any] in
            // This is a no-op on iOS since events are sent automatically
            // The listener management is handled by the React Native event system
            return ["remove": { /* No-op for iOS */ }]
        }
        
        // MARK: - Live Activity Management Functions
        
        /// Live Activity 시작
        AsyncFunction("startActivity") { [weak self] (config: [String: Any]) -> [String: Any] in
            guard let self = self else {
                throw ActivityError.unknown("모듈이 해제됨")
            }
            
            do {
                let activityConfig = try self.parseActivityConfig(from: config)
                let result = await self.startActivityUseCase.execute(activityConfig)
                
                switch result {
                case .success(let activity):
                    return self.serializeActivity(activity)
                case .failure(let error):
                    throw error
                }
            } catch {
                throw ActivityError.invalidConfiguration(error.localizedDescription)
            }
        }
        
        /// Live Activity 업데이트
        AsyncFunction("updateActivity") { [weak self] (activityId: String, content: [String: Any]) -> Bool in
            guard let self = self else {
                throw ActivityError.unknown("모듈이 해제됨")
            }
            
            do {
                let activityContent = try self.parseActivityContent(from: content)
                let updateRequest = ActivityUpdateRequest(activityId: activityId, content: activityContent)
                let result = await self.updateActivityUseCase.execute(updateRequest)
                
                switch result {
                case .success:
                    return true
                case .failure(let error):
                    throw error
                }
            } catch {
                throw ActivityError.invalidConfiguration(error.localizedDescription)
            }
        }
        
        /// Live Activity 종료
        AsyncFunction("endActivity") { [weak self] (activityId: String, options: [String: Any]?) -> Bool in
            guard let self = self else {
                throw ActivityError.unknown("모듈이 해제됨")
            }
            
            let finalContent: ActivityContent?
            let dismissalPolicy: DismissalPolicy
            
            if let options = options {
                finalContent = try? self.parseActivityContent(from: options["finalContent"] as? [String: Any] ?? [:])
                dismissalPolicy = DismissalPolicy(rawValue: options["dismissalPolicy"] as? String ?? "default") ?? .default
            } else {
                finalContent = nil
                dismissalPolicy = .default
            }
            
            let endRequest = ActivityEndRequest(
                activityId: activityId,
                finalContent: finalContent,
                dismissalPolicy: dismissalPolicy
            )
            
            let result = await self.endActivityUseCase.execute(endRequest)
            switch result {
            case .success:
                return true
            case .failure(let error):
                throw error
            }
        }
        
        /// 활성 Activity 목록 조회
        AsyncFunction("getActiveActivities") { [weak self] () -> [[String: Any]] in
            guard let self = self else { return [] }
            
            let result = await self.liveActivityService.getActiveActivities()
            switch result {
            case .success(let activities):
                return activities.map(self.serializeActivity)
            case .failure:
                return []
            }
        }
        
        /// 특정 Activity 조회
        AsyncFunction("getActivity") { [weak self] (activityId: String) -> [String: Any]? in
            guard let self = self else { return nil }
            
            let result = await self.liveActivityService.getActivity(id: activityId)
            switch result {
            case .success(let activity):
                return activity.map(self.serializeActivity)
            case .failure:
                return nil
            }
        }
        
        // MARK: - Dynamic Island Functions
        
        /// Dynamic Island 업데이트
        AsyncFunction("updateDynamicIsland") { [weak self] (activityId: String, content: [String: Any]) -> Bool in
            guard let self = self else {
                throw ActivityError.unknown("모듈이 해제됨")
            }
            
            do {
                let dynamicIslandContent = try self.parseDynamicIslandContent(from: content)
                let updateRequest = DynamicIslandUpdateRequest(
                    activityId: activityId,
                    content: dynamicIslandContent
                )
                
                let result = await self.dynamicIslandService.updateDynamicIsland(updateRequest)
                switch result {
                case .success:
                    return true
                case .failure(let error):
                    throw error
                }
            } catch {
                throw ActivityError.invalidConfiguration(error.localizedDescription)
            }
        }
        
        // MARK: - Push Notification Functions
        
        /// Push 토큰 등록
        AsyncFunction("registerPushToken") { [weak self] (token: String) -> Bool in
            guard let self = self else {
                throw ActivityError.unknown("모듈이 해제됨")
            }
            
            let result = await self.pushService.registerPushToken(token)
            switch result {
            case .success:
                return true
            case .failure(let error):
                throw error
            }
        }
        
        /// 원격 업데이트 요청
        AsyncFunction("requestRemoteUpdate") { [weak self] (activityId: String, content: [String: Any], pushToken: String) -> Bool in
            guard let self = self else {
                throw ActivityError.unknown("모듈이 해제됨")
            }
            
            do {
                let activityContent = try self.parseActivityContent(from: content)
                let result = await self.pushService.requestRemoteUpdate(
                    activityId: activityId,
                    content: activityContent,
                    pushToken: pushToken
                )
                
                switch result {
                case .success:
                    return true
                case .failure(let error):
                    throw error
                }
            } catch {
                throw ActivityError.invalidConfiguration(error.localizedDescription)
            }
        }
        
        // MARK: - Utility Functions
        
        /// Push 알림 권한 상태 확인
        AsyncFunction("getPushAuthorizationStatus") { [weak self] () -> String in
            guard let self = self else { return "notDetermined" }
            
            let status = await self.pushService.getPushAuthorizationStatus()
            return status.rawValue
        }
        
        /// Activity 설정 검증
        Function("validateActivityConfig") { [weak self] (config: [String: Any]) -> [String: Any] in
            guard let self = self else {
                return ["isValid": false, "errors": [["field": "module", "message": "모듈이 해제됨"]]]
            }
            
            do {
                let activityConfig = try self.parseActivityConfig(from: config)
                let validationResult = self.validator.validate(activityConfig)
                
                return [
                    "isValid": validationResult.isValid,
                    "errors": validationResult.errors.map { error in
                        ["field": error.field, "message": error.message]
                    }
                ]
            } catch {
                return [
                    "isValid": false,
                    "errors": [["field": "config", "message": error.localizedDescription]]
                ]
            }
        }
        
        // MARK: - Module Lifecycle
        
        OnCreate {
            // 이벤트 스트림 구독
            self.subscribeToEvents()
        }
        
        OnDestroy {
            // 리소스 정리
            // EventPublisher는 deinit에서 자동으로 정리됨
        }
    }
    
    // MARK: - Private Helper Methods
    
    private func subscribeToEvents() {
        Task {
            let eventStream = liveActivityService.eventStream()
            for await event in eventStream {
                handleActivityEvent(event)
            }
        }
    }
    
    private func handleActivityEvent(_ event: ActivityEvent) {
        switch event {
        case .started(let activity):
            sendEvent("onActivityUpdate", [
                "type": "started",
                "activity": serializeActivity(activity)
            ])
            
        case .updated(let request):
            sendEvent("onActivityUpdate", [
                "type": "updated",
                "activityId": request.activityId,
                "content": serializeActivityContent(request.content),
                "timestamp": request.timestamp.timeIntervalSince1970
            ])
            
        case .ended(let request):
            sendEvent("onActivityEnd", [
                "activityId": request.activityId,
                "finalContent": request.finalContent.map(serializeActivityContent),
                "dismissalPolicy": request.dismissalPolicy.rawValue
            ])
            
        case .userAction(let action):
            sendEvent("onUserAction", [
                "activityId": action.activityId,
                "actionId": action.actionId,
                "timestamp": action.timestamp.timeIntervalSince1970
            ])
            
        case .error(let error):
            sendEvent("onError", [
                "message": error.localizedDescription,
                "code": error.errorCode
            ])
        }
    }
}

// MARK: - Parsing Extensions

extension ExpoLiveActivityModule {
    
    private func parseActivityConfig(from dict: [String: Any]) throws -> LiveActivityConfig {
        guard let id = dict["id"] as? String else {
            throw ActivityError.invalidConfiguration("ID가 필요합니다")
        }
        
        guard let title = dict["title"] as? String else {
            throw ActivityError.invalidConfiguration("제목이 필요합니다")
        }
        
        let typeString = dict["type"] as? String ?? "custom"
        let type = ActivityType(rawValue: typeString) ?? .custom
        
        let contentDict = dict["content"] as? [String: Any] ?? [:]
        let content = try parseActivityContent(from: contentDict)
        
        let actionsArray = dict["actions"] as? [[String: Any]] ?? []
        let actions = try actionsArray.map(parseActivityAction)
        
        let expirationDate: Date?
        if let timestamp = dict["expirationDate"] as? Double {
            expirationDate = Date(timeIntervalSince1970: timestamp)
        } else {
            expirationDate = nil
        }
        
        let priorityString = dict["priority"] as? String ?? "normal"
        let priority = ActivityPriority(rawValue: priorityString) ?? .normal
        
        return LiveActivityConfig(
            id: id,
            type: type,
            title: title,
            content: content,
            actions: actions,
            expirationDate: expirationDate,
            priority: priority
        )
    }
    
    private func parseActivityContent(from dict: [String: Any]) throws -> ActivityContent {
        let status = dict["status"] as? String
        let progress = dict["progress"] as? Double
        let message = dict["message"] as? String
        let estimatedTime = dict["estimatedTime"] as? Int
        let customData = dict["customData"] as? [String: Any] ?? [:]
        
        return ActivityContent(
            status: status,
            progress: progress,
            message: message,
            estimatedTime: estimatedTime,
            customData: customData
        )
    }
    
    private func parseActivityAction(from dict: [String: Any]) throws -> ActivityAction {
        guard let id = dict["id"] as? String else {
            throw ActivityError.invalidConfiguration("액션 ID가 필요합니다")
        }
        
        guard let title = dict["title"] as? String else {
            throw ActivityError.invalidConfiguration("액션 제목이 필요합니다")
        }
        
        let icon = dict["icon"] as? String
        let isDestructive = dict["destructive"] as? Bool ?? false
        let deepLink = dict["deepLink"] as? String
        
        return ActivityAction(
            id: id,
            title: title,
            icon: icon,
            isDestructive: isDestructive,
            deepLink: deepLink
        )
    }
    
    private func parseDynamicIslandContent(from dict: [String: Any]) throws -> DynamicIslandContent {
        let compactLeading = (dict["compactLeading"] as? [String: Any]).flatMap(parseDynamicIslandElement)
        let compactTrailing = (dict["compactTrailing"] as? [String: Any]).flatMap(parseDynamicIslandElement)
        let minimal = (dict["minimal"] as? [String: Any]).flatMap(parseDynamicIslandElement)
        
        // expanded 콘텐츠는 현재 구현에서는 제외 (복잡도로 인해)
        
        return DynamicIslandContent(
            compactLeading: compactLeading,
            compactTrailing: compactTrailing,
            minimal: minimal,
            expanded: nil
        )
    }
    
    private func parseDynamicIslandElement(from dict: [String: Any]) -> DynamicIslandElement? {
        guard let content = dict["content"] as? String else { return nil }
        
        let typeString = dict["type"] as? String ?? "text"
        let type: DynamicIslandElement.ElementType
        
        switch typeString {
        case "text": type = .text
        case "icon": type = .icon
        case "emoji": type = .emoji
        case "progress": type = .progress
        default: type = .text
        }
        
        let color = dict["color"] as? String
        
        return DynamicIslandElement(
            type: type,
            content: content,
            color: color,
            font: nil
        )
    }
}

// MARK: - Serialization Extensions

extension ExpoLiveActivityModule {
    
    private func serializeActivity(_ activity: LiveActivityInstance) -> [String: Any] {
        return [
            "id": activity.id,
            "config": serializeActivityConfig(activity.config),
            "isActive": activity.isActive,
            "createdAt": activity.createdAt.timeIntervalSince1970,
            "updatedAt": activity.updatedAt.timeIntervalSince1970,
            "nativeActivityId": activity.nativeActivityId as Any
        ]
    }
    
    private func serializeActivityConfig(_ config: LiveActivityConfig) -> [String: Any] {
        return [
            "id": config.id,
            "type": config.type.rawValue,
            "title": config.title,
            "content": serializeActivityContent(config.content),
            "actions": config.actions.map(serializeActivityAction),
            "expirationDate": config.expirationDate?.timeIntervalSince1970 as Any,
            "priority": config.priority.rawValue
        ]
    }
    
    private func serializeActivityContent(_ content: ActivityContent) -> [String: Any] {
        return [
            "status": content.status as Any,
            "progress": content.progress as Any,
            "message": content.message as Any,
            "estimatedTime": content.estimatedTime as Any,
            "customData": content.customData
        ]
    }
    
    private func serializeActivityAction(_ action: ActivityAction) -> [String: Any] {
        return [
            "id": action.id,
            "title": action.title,
            "icon": action.icon as Any,
            "destructive": action.isDestructive,
            "deepLink": action.deepLink as Any
        ]
    }
}

// MARK: - Error Extension

extension ActivityError {
    var errorCode: String {
        switch self {
        case .invalidConfiguration:
            return "INVALID_CONFIGURATION"
        case .activityNotFound:
            return "ACTIVITY_NOT_FOUND"
        case .alreadyStarted:
            return "ALREADY_STARTED"
        case .systemNotSupported:
            return "SYSTEM_NOT_SUPPORTED"
        case .permissionDenied:
            return "PERMISSION_DENIED"
        case .networkError:
            return "NETWORK_ERROR"
        case .unknown:
            return "UNKNOWN_ERROR"
        }
    }
}

extension PushAuthorizationStatus {
    var rawValue: String {
        switch self {
        case .notDetermined: return "notDetermined"
        case .denied: return "denied"
        case .authorized: return "authorized"
        case .provisional: return "provisional"
        case .ephemeral: return "ephemeral"
        }
    }
}

// MARK: - Mock Implementation for iOS < 16.1

/// iOS 16.1 미만에서 사용할 Mock ActivityKit Manager
private class MockActivityKitManager: ActivityKitManagerProtocol {
    func isLiveActivitySupported() -> Bool { false }
    func startNativeActivity(_ config: LiveActivityConfig) async -> Result<String, ActivityError> {
        return .failure(.systemNotSupported)
    }
    func updateNativeActivity(nativeId: String, content: ActivityContent) async -> Result<Void, ActivityError> {
        return .failure(.systemNotSupported)
    }
    func endNativeActivity(nativeId: String, finalContent: ActivityContent?, dismissalPolicy: DismissalPolicy) async -> Result<Void, ActivityError> {
        return .failure(.systemNotSupported)
    }
    func nativeEventStream() -> AsyncStream<ActivityEvent> {
        return AsyncStream { _ in }
    }
}