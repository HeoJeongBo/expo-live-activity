import Foundation

/// Live Activity 서비스 구현
/// Application Service Layer: Use Cases를 조합하여 복잡한 비즈니스 로직 처리
public final class LiveActivityService: LiveActivityServiceProtocol {
    
    // MARK: - Dependencies (Dependency Injection)
    
    private let activityKitManager: ActivityKitManagerProtocol
    private let repository: ActivityRepositoryProtocol
    private let eventPublisher: EventPublisherProtocol
    
    // MARK: - Initialization
    
    public init(
        activityKitManager: ActivityKitManagerProtocol,
        repository: ActivityRepositoryProtocol,
        eventPublisher: EventPublisherProtocol
    ) {
        self.activityKitManager = activityKitManager
        self.repository = repository
        self.eventPublisher = eventPublisher
    }
    
    // MARK: - LiveActivityServiceProtocol Implementation
    
    public func startActivity(_ config: LiveActivityConfig) async -> Result<LiveActivityInstance, ActivityError> {
        // 1. 시스템 지원 여부 확인
        guard activityKitManager.isLiveActivitySupported() else {
            return .failure(.systemNotSupported)
        }
        
        // 2. ActivityKit을 통한 네이티브 Activity 시작
        let nativeResult = await activityKitManager.startNativeActivity(config)
        switch nativeResult {
        case .success(let nativeActivityId):
            // 3. 성공적으로 시작된 Activity 인스턴스 생성
            let activityInstance = LiveActivityInstance(
                id: config.id,
                config: config,
                isActive: true,
                createdAt: Date(),
                updatedAt: Date(),
                nativeActivityId: nativeActivityId
            )
            
            return .success(activityInstance)
            
        case .failure(let error):
            return .failure(error)
        }
    }
    
    public func updateActivity(_ request: ActivityUpdateRequest) async -> Result<Void, ActivityError> {
        // 1. Activity 존재 확인
        let findResult = await repository.findById(request.activityId)
        switch findResult {
        case .success(let activity):
            guard let existingActivity = activity else {
                return .failure(.activityNotFound(request.activityId))
            }
            
            guard existingActivity.isActive else {
                return .failure(.activityNotFound(request.activityId))
            }
            
            // 2. 네이티브 Activity ID 확인
            guard let nativeActivityId = existingActivity.nativeActivityId else {
                return .failure(.unknown("네이티브 Activity ID가 없습니다"))
            }
            
            // 3. ActivityKit을 통한 업데이트
            let updateResult = await activityKitManager.updateNativeActivity(
                nativeId: nativeActivityId,
                content: request.content
            )
            
            return updateResult
            
        case .failure(let error):
            return .failure(error)
        }
    }
    
    public func endActivity(_ request: ActivityEndRequest) async -> Result<Void, ActivityError> {
        // 1. Activity 존재 확인
        let findResult = await repository.findById(request.activityId)
        switch findResult {
        case .success(let activity):
            guard let existingActivity = activity else {
                return .failure(.activityNotFound(request.activityId))
            }
            
            // 2. 네이티브 Activity ID 확인
            guard let nativeActivityId = existingActivity.nativeActivityId else {
                return .failure(.unknown("네이티브 Activity ID가 없습니다"))
            }
            
            // 3. ActivityKit을 통한 종료
            let endResult = await activityKitManager.endNativeActivity(
                nativeId: nativeActivityId,
                finalContent: request.finalContent,
                dismissalPolicy: request.dismissalPolicy
            )
            
            return endResult
            
        case .failure(let error):
            return .failure(error)
        }
    }
    
    public func getActiveActivities() async -> Result<[LiveActivityInstance], ActivityError> {
        return await repository.findAllActive()
    }
    
    public func getActivity(id: String) async -> Result<LiveActivityInstance?, ActivityError> {
        return await repository.findById(id)
    }
    
    public func eventStream() -> AsyncStream<ActivityEvent> {
        return eventPublisher.subscribe()
    }
}

/// Dynamic Island 서비스 구현
public final class DynamicIslandService: DynamicIslandServiceProtocol {
    
    // MARK: - Dependencies
    
    private let activityKitManager: ActivityKitManagerProtocol
    private let repository: ActivityRepositoryProtocol
    
    // MARK: - Initialization
    
    public init(
        activityKitManager: ActivityKitManagerProtocol,
        repository: ActivityRepositoryProtocol
    ) {
        self.activityKitManager = activityKitManager
        self.repository = repository
    }
    
    // MARK: - DynamicIslandServiceProtocol Implementation
    
    public func updateDynamicIsland(_ request: DynamicIslandUpdateRequest) async -> Result<Void, ActivityError> {
        // Dynamic Island는 ActivityKit Activity의 UI 업데이트를 통해 처리
        // 실제 구현에서는 SwiftUI View를 업데이트하는 로직이 필요
        
        // 1. Activity 존재 확인
        let findResult = await repository.findById(request.activityId)
        switch findResult {
        case .success(let activity):
            guard let existingActivity = activity else {
                return .failure(.activityNotFound(request.activityId))
            }
            
            guard existingActivity.isActive else {
                return .failure(.activityNotFound(request.activityId))
            }
            
            // 2. Dynamic Island 콘텐츠를 ActivityContent로 변환
            let activityContent = convertDynamicIslandToActivityContent(request.content)
            
            // 3. Activity 업데이트 (Dynamic Island 업데이트는 Activity 업데이트를 통해 처리)
            guard let nativeActivityId = existingActivity.nativeActivityId else {
                return .failure(.unknown("네이티브 Activity ID가 없습니다"))
            }
            
            let updateResult = await activityKitManager.updateNativeActivity(
                nativeId: nativeActivityId,
                content: activityContent
            )
            
            return updateResult
            
        case .failure(let error):
            return .failure(error)
        }
    }
    
    public func isDynamicIslandSupported() -> Bool {
        // iPhone 14 Pro 이상에서 Dynamic Island 지원
        // 실제 구현에서는 기기 모델 확인 로직 필요
        if #available(iOS 16.1, *) {
            return activityKitManager.isLiveActivitySupported()
        }
        return false
    }
    
    public func getDynamicIslandContent(activityId: String) async -> Result<DynamicIslandContent?, ActivityError> {
        // 현재 Activity의 상태를 DynamicIslandContent로 변환
        let findResult = await repository.findById(activityId)
        switch findResult {
        case .success(let activity):
            guard let existingActivity = activity else {
                return .success(nil)
            }
            
            // Activity 타입에 따른 Dynamic Island 콘텐츠 생성
            let dynamicIslandContent = createDynamicIslandContent(from: existingActivity)
            return .success(dynamicIslandContent)
            
        case .failure(let error):
            return .failure(error)
        }
    }
    
    // MARK: - Private Helper Methods
    
    private func convertDynamicIslandToActivityContent(_ content: DynamicIslandContent) -> ActivityContent {
        var customData: [String: Any] = [:]
        
        // Dynamic Island 요소들을 customData로 변환
        if let compactLeading = content.compactLeading {
            customData["compactLeading"] = compactLeading.content
        }
        
        if let compactTrailing = content.compactTrailing {
            customData["compactTrailing"] = compactTrailing.content
        }
        
        if let minimal = content.minimal {
            customData["minimal"] = minimal.content
        }
        
        return ActivityContent(
            status: content.compactLeading?.content,
            message: content.minimal?.content,
            customData: customData
        )
    }
    
    private func createDynamicIslandContent(from activity: LiveActivityInstance) -> DynamicIslandContent? {
        // Activity 타입에 따른 Dynamic Island 템플릿 사용
        switch activity.config.type {
        case .foodDelivery:
            let status = activity.config.content.status ?? "배달 중"
            let time = "\(activity.config.content.estimatedTime ?? 30)분"
            let restaurant = activity.config.content.customData["restaurant"] as? String ?? activity.config.title
            return DynamicIslandTemplate.foodDelivery(status: status, time: time, restaurant: restaurant).content
            
        case .rideshare:
            let status = activity.config.content.status ?? "이동 중"
            let eta = "\(activity.config.content.estimatedTime ?? 5)분"
            let driver = activity.config.content.customData["driverName"] as? String ?? "기사님"
            return DynamicIslandTemplate.rideshare(status: status, eta: eta, driver: driver).content
            
        case .workout:
            let type = activity.config.content.customData["workoutType"] as? String ?? "운동"
            let duration = "\(activity.config.content.estimatedTime ?? 0)분"
            let calories = "\(activity.config.content.customData["calories"] as? Int ?? 0)"
            return DynamicIslandTemplate.workout(type: type, duration: duration, calories: calories).content
            
        case .timer:
            let remaining = "\(activity.config.content.estimatedTime ?? 0)초"
            let total = "\(activity.config.content.customData["totalTime"] as? Int ?? 0)초"
            return DynamicIslandTemplate.timer(remaining: remaining, total: total).content
            
        case .custom:
            // 커스텀 타입의 경우 기본적인 Dynamic Island 콘텐츠 생성
            return DynamicIslandContent(
                compactLeading: DynamicIslandElement(type: .text, content: "📱"),
                compactTrailing: DynamicIslandElement(type: .text, content: activity.config.content.status ?? ""),
                minimal: DynamicIslandElement(type: .text, content: "📱")
            )
        }
    }
}

/// Push 알림 서비스 구현
public final class PushNotificationService: PushNotificationServiceProtocol {
    
    // MARK: - Properties
    
    private let baseURL = URL(string: "https://api.your-server.com")! // 실제 서버 URL로 변경 필요
    private let session = URLSession.shared
    
    // MARK: - Initialization
    
    public init() {}
    
    // MARK: - PushNotificationServiceProtocol Implementation
    
    public func registerPushToken(_ token: String) async -> Result<Void, ActivityError> {
        do {
            var request = URLRequest(url: baseURL.appendingPathComponent("/push/register"))
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let body = ["pushToken": token]
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
            
            let (_, response) = try await session.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse,
               httpResponse.statusCode == 200 {
                return .success(())
            } else {
                return .failure(.networkError("Push 토큰 등록 실패"))
            }
        } catch {
            return .failure(.networkError(error.localizedDescription))
        }
    }
    
    public func requestRemoteUpdate(
        activityId: String,
        content: ActivityContent,
        pushToken: String
    ) async -> Result<Void, ActivityError> {
        do {
            var request = URLRequest(url: baseURL.appendingPathComponent("/activity/update"))
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let body: [String: Any] = [
                "activityId": activityId,
                "pushToken": pushToken,
                "content": [
                    "status": content.status ?? "",
                    "progress": content.progress ?? 0.0,
                    "message": content.message ?? "",
                    "estimatedTime": content.estimatedTime ?? 0,
                    "customData": content.customData
                ]
            ]
            
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
            
            let (_, response) = try await session.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse,
               httpResponse.statusCode == 200 {
                return .success(())
            } else {
                return .failure(.networkError("원격 업데이트 요청 실패"))
            }
        } catch {
            return .failure(.networkError(error.localizedDescription))
        }
    }
    
    public func getPushAuthorizationStatus() async -> PushAuthorizationStatus {
        return await withCheckedContinuation { continuation in
            UNUserNotificationCenter.current().getNotificationSettings { settings in
                let status: PushAuthorizationStatus
                switch settings.authorizationStatus {
                case .notDetermined:
                    status = .notDetermined
                case .denied:
                    status = .denied
                case .authorized:
                    status = .authorized
                case .provisional:
                    status = .provisional
                case .ephemeral:
                    status = .ephemeral
                @unknown default:
                    status = .notDetermined
                }
                continuation.resume(returning: status)
            }
        }
    }
}

// MARK: - Import UserNotifications

import UserNotifications