import Foundation
import ActivityKit

/// ActivityKit 프레임워크 추상화 매니저
/// Infrastructure Layer: 외부 프레임워크와의 상호작용을 담당
@available(iOS 16.1, *)
public final class ActivityKitManager: ActivityKitManagerProtocol {
    
    // MARK: - Properties
    
    private let eventContinuation: AsyncStream<ActivityEvent>.Continuation
    private let eventStream: AsyncStream<ActivityEvent>
    
    // ActivityKit Activity 인스턴스들을 추적
    private var activeActivities: [String: Any] = [:]
    private let activitiesQueue = DispatchQueue(label: "com.expo.liveactivity.activities", attributes: .concurrent)
    
    // MARK: - Initialization
    
    public init() {
        let (stream, continuation) = AsyncStream<ActivityEvent>.makeStream()
        self.eventStream = stream
        self.eventContinuation = continuation
        
        setupActivityObservers()
    }
    
    // MARK: - ActivityKitManagerProtocol Implementation
    
    public func isLiveActivitySupported() -> Bool {
        guard #available(iOS 16.1, *) else { return false }
        return ActivityAuthorizationInfo().areActivitiesEnabled
    }
    
    public func startNativeActivity(_ config: LiveActivityConfig) async -> Result<String, ActivityError> {
        guard isLiveActivitySupported() else {
            return .failure(.systemNotSupported)
        }
        
        do {
            // Activity Type에 따른 분기 처리
            switch config.type {
            case .foodDelivery:
                return await startFoodDeliveryActivity(config)
            case .rideshare:
                return await startRideshareActivity(config)
            case .workout:
                return await startWorkoutActivity(config)
            case .timer:
                return await startTimerActivity(config)
            case .custom:
                return await startCustomActivity(config)
            }
        } catch {
            return .failure(.unknown(error.localizedDescription))
        }
    }
    
    public func updateNativeActivity(nativeId: String, content: ActivityContent) async -> Result<Void, ActivityError> {
        return await activitiesQueue.async {
            guard let activity = self.activeActivities[nativeId] else {
                return .failure(.activityNotFound(nativeId))
            }
            
            do {
                // Type-safe casting and update
                if let foodActivity = activity as? Activity<FoodDeliveryAttributes> {
                    let contentState = self.createFoodDeliveryContentState(from: content)
                    await foodActivity.update(using: contentState)
                } else if let rideshareActivity = activity as? Activity<RideshareAttributes> {
                    let contentState = self.createRideshareContentState(from: content)
                    await rideshareActivity.update(using: contentState)
                } else if let workoutActivity = activity as? Activity<WorkoutAttributes> {
                    let contentState = self.createWorkoutContentState(from: content)
                    await workoutActivity.update(using: contentState)
                } else if let timerActivity = activity as? Activity<TimerAttributes> {
                    let contentState = self.createTimerContentState(from: content)
                    await timerActivity.update(using: contentState)
                }
                
                return .success(())
            } catch {
                return .failure(.unknown(error.localizedDescription))
            }
        }
    }
    
    public func endNativeActivity(
        nativeId: String,
        finalContent: ActivityContent?,
        dismissalPolicy: DismissalPolicy
    ) async -> Result<Void, ActivityError> {
        return await activitiesQueue.async {
            guard let activity = self.activeActivities[nativeId] else {
                return .failure(.activityNotFound(nativeId))
            }
            
            do {
                let policy = self.convertDismissalPolicy(dismissalPolicy)
                
                if let finalContent = finalContent {
                    // Type-safe final content update
                    if let foodActivity = activity as? Activity<FoodDeliveryAttributes> {
                        let finalState = self.createFoodDeliveryContentState(from: finalContent)
                        await foodActivity.end(using: finalState, dismissalPolicy: policy)
                    } else if let rideshareActivity = activity as? Activity<RideshareAttributes> {
                        let finalState = self.createRideshareContentState(from: finalContent)
                        await rideshareActivity.end(using: finalState, dismissalPolicy: policy)
                    } else if let workoutActivity = activity as? Activity<WorkoutAttributes> {
                        let finalState = self.createWorkoutContentState(from: finalContent)
                        await workoutActivity.end(using: finalState, dismissalPolicy: policy)
                    } else if let timerActivity = activity as? Activity<TimerAttributes> {
                        let finalState = self.createTimerContentState(from: finalContent)
                        await timerActivity.end(using: finalState, dismissalPolicy: policy)
                    }
                } else {
                    // End without final content
                    if let foodActivity = activity as? Activity<FoodDeliveryAttributes> {
                        await foodActivity.end(dismissalPolicy: policy)
                    } else if let rideshareActivity = activity as? Activity<RideshareAttributes> {
                        await rideshareActivity.end(dismissalPolicy: policy)
                    } else if let workoutActivity = activity as? Activity<WorkoutAttributes> {
                        await workoutActivity.end(dismissalPolicy: policy)
                    } else if let timerActivity = activity as? Activity<TimerAttributes> {
                        await timerActivity.end(dismissalPolicy: policy)
                    }
                }
                
                // Remove from tracking
                self.activeActivities.removeValue(forKey: nativeId)
                return .success(())
            } catch {
                return .failure(.unknown(error.localizedDescription))
            }
        }
    }
    
    public func nativeEventStream() -> AsyncStream<ActivityEvent> {
        return eventStream
    }
    
    // MARK: - Private Activity Creation Methods
    
    private func startFoodDeliveryActivity(_ config: LiveActivityConfig) async -> Result<String, ActivityError> {
        do {
            let attributes = FoodDeliveryAttributes(
                orderId: config.id,
                restaurant: config.customData["restaurant"] as? String ?? config.title
            )
            
            let contentState = createFoodDeliveryContentState(from: config.content)
            
            let activity = try Activity.request(
                attributes: attributes,
                content: .init(state: contentState, staleDate: config.expirationDate),
                pushType: .token
            )
            
            let nativeId = activity.id
            await activitiesQueue.async(flags: .barrier) {
                self.activeActivities[nativeId] = activity
            }
            
            return .success(nativeId)
        } catch {
            return .failure(.unknown(error.localizedDescription))
        }
    }
    
    private func startRideshareActivity(_ config: LiveActivityConfig) async -> Result<String, ActivityError> {
        do {
            let attributes = RideshareAttributes(
                rideId: config.id,
                destination: config.customData["destination"] as? String ?? "목적지"
            )
            
            let contentState = createRideshareContentState(from: config.content)
            
            let activity = try Activity.request(
                attributes: attributes,
                content: .init(state: contentState, staleDate: config.expirationDate),
                pushType: .token
            )
            
            let nativeId = activity.id
            await activitiesQueue.async(flags: .barrier) {
                self.activeActivities[nativeId] = activity
            }
            
            return .success(nativeId)
        } catch {
            return .failure(.unknown(error.localizedDescription))
        }
    }
    
    private func startWorkoutActivity(_ config: LiveActivityConfig) async -> Result<String, ActivityError> {
        do {
            let attributes = WorkoutAttributes(
                workoutId: config.id,
                workoutType: config.customData["workoutType"] as? String ?? "운동"
            )
            
            let contentState = createWorkoutContentState(from: config.content)
            
            let activity = try Activity.request(
                attributes: attributes,
                content: .init(state: contentState, staleDate: config.expirationDate),
                pushType: .token
            )
            
            let nativeId = activity.id
            await activitiesQueue.async(flags: .barrier) {
                self.activeActivities[nativeId] = activity
            }
            
            return .success(nativeId)
        } catch {
            return .failure(.unknown(error.localizedDescription))
        }
    }
    
    private func startTimerActivity(_ config: LiveActivityConfig) async -> Result<String, ActivityError> {
        do {
            let attributes = TimerAttributes(
                timerId: config.id,
                timerName: config.title
            )
            
            let contentState = createTimerContentState(from: config.content)
            
            let activity = try Activity.request(
                attributes: attributes,
                content: .init(state: contentState, staleDate: config.expirationDate),
                pushType: .token
            )
            
            let nativeId = activity.id
            await activitiesQueue.async(flags: .barrier) {
                self.activeActivities[nativeId] = activity
            }
            
            return .success(nativeId)
        } catch {
            return .failure(.unknown(error.localizedDescription))
        }
    }
    
    private func startCustomActivity(_ config: LiveActivityConfig) async -> Result<String, ActivityError> {
        // Custom Activity는 Generic Activity Attributes 사용
        do {
            let attributes = CustomAttributes(
                activityId: config.id,
                title: config.title,
                customData: config.customData
            )
            
            let contentState = createCustomContentState(from: config.content)
            
            let activity = try Activity.request(
                attributes: attributes,
                content: .init(state: contentState, staleDate: config.expirationDate),
                pushType: .token
            )
            
            let nativeId = activity.id
            await activitiesQueue.async(flags: .barrier) {
                self.activeActivities[nativeId] = activity
            }
            
            return .success(nativeId)
        } catch {
            return .failure(.unknown(error.localizedDescription))
        }
    }
    
    // MARK: - Content State Creation Methods
    
    private func createFoodDeliveryContentState(from content: ActivityContent) -> FoodDeliveryContentState {
        return FoodDeliveryContentState(
            status: content.status ?? "주문 접수",
            estimatedTime: content.estimatedTime ?? 30,
            progress: content.progress ?? 0.0,
            message: content.message
        )
    }
    
    private func createRideshareContentState(from content: ActivityContent) -> RideshareContentState {
        return RideshareContentState(
            status: content.status ?? "차량 호출 중",
            eta: content.estimatedTime ?? 5,
            driverName: content.customData["driverName"] as? String,
            vehicleInfo: content.customData["vehicleInfo"] as? String
        )
    }
    
    private func createWorkoutContentState(from content: ActivityContent) -> WorkoutContentState {
        return WorkoutContentState(
            duration: content.estimatedTime ?? 0,
            calories: content.customData["calories"] as? Int ?? 0,
            heartRate: content.customData["heartRate"] as? Int,
            currentExercise: content.status ?? "운동 중"
        )
    }
    
    private func createTimerContentState(from content: ActivityContent) -> TimerContentState {
        return TimerContentState(
            remainingTime: content.estimatedTime ?? 0,
            totalTime: content.customData["totalTime"] as? Int ?? 0,
            isRunning: content.customData["isRunning"] as? Bool ?? true
        )
    }
    
    private func createCustomContentState(from content: ActivityContent) -> CustomContentState {
        return CustomContentState(
            status: content.status,
            progress: content.progress,
            message: content.message,
            customData: content.customData
        )
    }
    
    // MARK: - Helper Methods
    
    private func convertDismissalPolicy(_ policy: DismissalPolicy) -> ActivityUIDismissalPolicy {
        switch policy {
        case .immediate:
            return .immediate
        case .default:
            return .default
        case .after:
            return .after(.seconds(3))
        }
    }
    
    private func setupActivityObservers() {
        // ActivityKit의 activity state 변화를 관찰
        Task {
            for await activityUpdate in Activity<FoodDeliveryAttributes>.activityUpdates {
                handleActivityUpdate(activityUpdate)
            }
        }
        
        Task {
            for await activityUpdate in Activity<RideshareAttributes>.activityUpdates {
                handleActivityUpdate(activityUpdate)
            }
        }
        
        Task {
            for await activityUpdate in Activity<WorkoutAttributes>.activityUpdates {
                handleActivityUpdate(activityUpdate)
            }
        }
        
        Task {
            for await activityUpdate in Activity<TimerAttributes>.activityUpdates {
                handleActivityUpdate(activityUpdate)
            }
        }
        
        Task {
            for await activityUpdate in Activity<CustomAttributes>.activityUpdates {
                handleActivityUpdate(activityUpdate)
            }
        }
    }
    
    private func handleActivityUpdate<T: ActivityAttributes>(_ activityUpdate: ActivityUpdate<T>) {
        switch activityUpdate.event {
        case .active:
            // Activity가 활성화됨
            break
        case .ended:
            // Activity가 종료됨
            let nativeId = activityUpdate.activity.id
            activitiesQueue.async(flags: .barrier) {
                self.activeActivities.removeValue(forKey: nativeId)
            }
        case .dismissed:
            // Activity가 사용자에 의해 해제됨
            let nativeId = activityUpdate.activity.id
            activitiesQueue.async(flags: .barrier) {
                self.activeActivities.removeValue(forKey: nativeId)
            }
        }
    }
    
    deinit {
        eventContinuation.finish()
    }
}

// MARK: - ActivityKit Attributes Definitions

/// 음식 배달 Activity Attributes
@available(iOS 16.1, *)
struct FoodDeliveryAttributes: ActivityAttributes {
    public typealias ContentState = FoodDeliveryContentState
    
    let orderId: String
    let restaurant: String
}

@available(iOS 16.1, *)
struct FoodDeliveryContentState: ContentState, Hashable, Codable {
    let status: String
    let estimatedTime: Int
    let progress: Double
    let message: String?
}

/// 차량 호출 Activity Attributes
@available(iOS 16.1, *)
struct RideshareAttributes: ActivityAttributes {
    public typealias ContentState = RideshareContentState
    
    let rideId: String
    let destination: String
}

@available(iOS 16.1, *)
struct RideshareContentState: ContentState, Hashable, Codable {
    let status: String
    let eta: Int
    let driverName: String?
    let vehicleInfo: String?
}

/// 운동 Activity Attributes
@available(iOS 16.1, *)
struct WorkoutAttributes: ActivityAttributes {
    public typealias ContentState = WorkoutContentState
    
    let workoutId: String
    let workoutType: String
}

@available(iOS 16.1, *)
struct WorkoutContentState: ContentState, Hashable, Codable {
    let duration: Int
    let calories: Int
    let heartRate: Int?
    let currentExercise: String
}

/// 타이머 Activity Attributes
@available(iOS 16.1, *)
struct TimerAttributes: ActivityAttributes {
    public typealias ContentState = TimerContentState
    
    let timerId: String
    let timerName: String
}

@available(iOS 16.1, *)
struct TimerContentState: ContentState, Hashable, Codable {
    let remainingTime: Int
    let totalTime: Int
    let isRunning: Bool
}

/// 커스텀 Activity Attributes
@available(iOS 16.1, *)
struct CustomAttributes: ActivityAttributes {
    public typealias ContentState = CustomContentState
    
    let activityId: String
    let title: String
    let customDataKeys: [String]
    let customDataValues: [String]
    
    init(activityId: String, title: String, customData: [String: Any]) {
        self.activityId = activityId
        self.title = title
        self.customDataKeys = Array(customData.keys)
        self.customDataValues = customData.values.map { "\($0)" }
    }
    
    var customData: [String: Any] {
        var result: [String: Any] = [:]
        for (index, key) in customDataKeys.enumerated() {
            if index < customDataValues.count {
                result[key] = customDataValues[index]
            }
        }
        return result
    }
}

@available(iOS 16.1, *)
struct CustomContentState: ContentState, Hashable, Codable {
    let status: String?
    let progress: Double?
    let message: String?
    let customDataKeys: [String]
    let customDataValues: [String]
    
    init(status: String?, progress: Double?, message: String?, customData: [String: Any]) {
        self.status = status
        self.progress = progress
        self.message = message
        self.customDataKeys = Array(customData.keys)
        self.customDataValues = customData.values.map { "\($0)" }
    }
    
    var customData: [String: Any] {
        var result: [String: Any] = [:]
        for (index, key) in customDataKeys.enumerated() {
            if index < customDataValues.count {
                result[key] = customDataValues[index]
            }
        }
        return result
    }
    
    // Hashable 구현
    func hash(into hasher: inout Hasher) {
        hasher.combine(status)
        hasher.combine(progress)
        hasher.combine(message)
        hasher.combine(customDataKeys)
        hasher.combine(customDataValues)
    }
    
    // Equatable 구현
    static func == (lhs: CustomContentState, rhs: CustomContentState) -> Bool {
        return lhs.status == rhs.status &&
               lhs.progress == rhs.progress &&
               lhs.message == rhs.message &&
               lhs.customDataKeys == rhs.customDataKeys &&
               lhs.customDataValues == rhs.customDataValues
    }
}