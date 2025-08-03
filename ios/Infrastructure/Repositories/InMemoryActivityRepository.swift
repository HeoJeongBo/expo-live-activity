import Foundation

/// In-Memory Activity Repository 구현
/// 개발 및 테스트용 메모리 저장소
public final class InMemoryActivityRepository: ActivityRepositoryProtocol {
    
    // MARK: - Properties
    
    private var activities: [String: LiveActivityInstance] = [:]
    private let queue = DispatchQueue(label: "com.expo.liveactivity.repository", attributes: .concurrent)
    
    // MARK: - Initialization
    
    public init() {}
    
    // MARK: - ActivityRepositoryProtocol Implementation
    
    public func save(_ activity: LiveActivityInstance) async -> Result<Void, ActivityError> {
        return await withCheckedContinuation { continuation in
            queue.async(flags: .barrier) {
                self.activities[activity.id] = activity
                continuation.resume(returning: .success(()))
            }
        }
    }
    
    public func findById(_ id: String) async -> Result<LiveActivityInstance?, ActivityError> {
        return await withCheckedContinuation { continuation in
            queue.async {
                let activity = self.activities[id]
                continuation.resume(returning: .success(activity))
            }
        }
    }
    
    public func findAllActive() async -> Result<[LiveActivityInstance], ActivityError> {
        return await withCheckedContinuation { continuation in
            queue.async {
                let activeActivities = Array(self.activities.values.filter { $0.isActive })
                continuation.resume(returning: .success(activeActivities))
            }
        }
    }
    
    public func delete(_ id: String) async -> Result<Void, ActivityError> {
        return await withCheckedContinuation { continuation in
            queue.async(flags: .barrier) {
                self.activities.removeValue(forKey: id)
                continuation.resume(returning: .success(()))
            }
        }
    }
    
    public func update(_ activity: LiveActivityInstance) async -> Result<Void, ActivityError> {
        return await withCheckedContinuation { continuation in
            queue.async(flags: .barrier) {
                guard self.activities[activity.id] != nil else {
                    continuation.resume(returning: .failure(.activityNotFound(activity.id)))
                    return
                }
                
                self.activities[activity.id] = activity
                continuation.resume(returning: .success(()))
            }
        }
    }
    
    // MARK: - Additional Helper Methods
    
    /// 모든 Activity 삭제 (테스트용)
    public func deleteAll() async -> Result<Void, ActivityError> {
        return await withCheckedContinuation { continuation in
            queue.async(flags: .barrier) {
                self.activities.removeAll()
                continuation.resume(returning: .success(()))
            }
        }
    }
    
    /// Activity 개수 조회 (테스트용)
    public func count() async -> Int {
        return await withCheckedContinuation { continuation in
            queue.async {
                continuation.resume(returning: self.activities.count)
            }
        }
    }
}

/// UserDefaults 기반 Activity Repository 구현
/// 앱 재시작 후에도 데이터 유지
public final class UserDefaultsActivityRepository: ActivityRepositoryProtocol {
    
    // MARK: - Properties
    
    private let userDefaults: UserDefaults
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    private let queue = DispatchQueue(label: "com.expo.liveactivity.userdefaults", attributes: .concurrent)
    
    private static let activitiesKey = "expo_live_activities"
    
    // MARK: - Initialization
    
    public init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
        
        // JSON 인코더/디코더 설정
        encoder.dateEncodingStrategy = .iso8601
        decoder.dateDecodingStrategy = .iso8601
    }
    
    // MARK: - ActivityRepositoryProtocol Implementation
    
    public func save(_ activity: LiveActivityInstance) async -> Result<Void, ActivityError> {
        return await withCheckedContinuation { continuation in
            queue.async(flags: .barrier) {
                do {
                    var activities = self.loadActivitiesFromUserDefaults()
                    activities[activity.id] = activity
                    try self.saveActivitiesToUserDefaults(activities)
                    continuation.resume(returning: .success(()))
                } catch {
                    continuation.resume(returning: .failure(.unknown(error.localizedDescription)))
                }
            }
        }
    }
    
    public func findById(_ id: String) async -> Result<LiveActivityInstance?, ActivityError> {
        return await withCheckedContinuation { continuation in
            queue.async {
                let activities = self.loadActivitiesFromUserDefaults()
                let activity = activities[id]
                continuation.resume(returning: .success(activity))
            }
        }
    }
    
    public func findAllActive() async -> Result<[LiveActivityInstance], ActivityError> {
        return await withCheckedContinuation { continuation in
            queue.async {
                let activities = self.loadActivitiesFromUserDefaults()
                let activeActivities = Array(activities.values.filter { $0.isActive })
                continuation.resume(returning: .success(activeActivities))
            }
        }
    }
    
    public func delete(_ id: String) async -> Result<Void, ActivityError> {
        return await withCheckedContinuation { continuation in
            queue.async(flags: .barrier) {
                do {
                    var activities = self.loadActivitiesFromUserDefaults()
                    activities.removeValue(forKey: id)
                    try self.saveActivitiesToUserDefaults(activities)
                    continuation.resume(returning: .success(()))
                } catch {
                    continuation.resume(returning: .failure(.unknown(error.localizedDescription)))
                }
            }
        }
    }
    
    public func update(_ activity: LiveActivityInstance) async -> Result<Void, ActivityError> {
        return await withCheckedContinuation { continuation in
            queue.async(flags: .barrier) {
                do {
                    var activities = self.loadActivitiesFromUserDefaults()
                    guard activities[activity.id] != nil else {
                        continuation.resume(returning: .failure(.activityNotFound(activity.id)))
                        return
                    }
                    
                    activities[activity.id] = activity
                    try self.saveActivitiesToUserDefaults(activities)
                    continuation.resume(returning: .success(()))
                } catch {
                    continuation.resume(returning: .failure(.unknown(error.localizedDescription)))
                }
            }
        }
    }
    
    // MARK: - Private Helper Methods
    
    private func loadActivitiesFromUserDefaults() -> [String: LiveActivityInstance] {
        guard let data = userDefaults.data(forKey: Self.activitiesKey) else {
            return [:]
        }
        
        do {
            let activities = try decoder.decode([String: CodableActivityInstance].self, from: data)
            return activities.mapValues { $0.toLiveActivityInstance() }
        } catch {
            print("Failed to load activities from UserDefaults: \(error)")
            return [:]
        }
    }
    
    private func saveActivitiesToUserDefaults(_ activities: [String: LiveActivityInstance]) throws {
        let codableActivities = activities.mapValues { CodableActivityInstance(from: $0) }
        let data = try encoder.encode(codableActivities)
        userDefaults.set(data, forKey: Self.activitiesKey)
    }
}

// MARK: - Codable Wrapper for LiveActivityInstance

/// LiveActivityInstance를 UserDefaults에 저장하기 위한 Codable 래퍼
private struct CodableActivityInstance: Codable {
    let id: String
    let config: CodableActivityConfig
    let isActive: Bool
    let createdAt: Date
    let updatedAt: Date
    let nativeActivityId: String?
    
    init(from activity: LiveActivityInstance) {
        self.id = activity.id
        self.config = CodableActivityConfig(from: activity.config)
        self.isActive = activity.isActive
        self.createdAt = activity.createdAt
        self.updatedAt = activity.updatedAt
        self.nativeActivityId = activity.nativeActivityId
    }
    
    func toLiveActivityInstance() -> LiveActivityInstance {
        return LiveActivityInstance(
            id: id,
            config: config.toLiveActivityConfig(),
            isActive: isActive,
            createdAt: createdAt,
            updatedAt: updatedAt,
            nativeActivityId: nativeActivityId
        )
    }
}

/// LiveActivityConfig를 UserDefaults에 저장하기 위한 Codable 래퍼
private struct CodableActivityConfig: Codable {
    let id: String
    let type: String
    let title: String
    let content: CodableActivityContent
    let actions: [CodableActivityAction]
    let expirationDate: Date?
    let priority: String
    
    init(from config: LiveActivityConfig) {
        self.id = config.id
        self.type = config.type.rawValue
        self.title = config.title
        self.content = CodableActivityContent(from: config.content)
        self.actions = config.actions.map { CodableActivityAction(from: $0) }
        self.expirationDate = config.expirationDate
        self.priority = config.priority.rawValue
    }
    
    func toLiveActivityConfig() -> LiveActivityConfig {
        return LiveActivityConfig(
            id: id,
            type: ActivityType(rawValue: type) ?? .custom,
            title: title,
            content: content.toActivityContent(),
            actions: actions.map { $0.toActivityAction() },
            expirationDate: expirationDate,
            priority: ActivityPriority(rawValue: priority) ?? .normal
        )
    }
}

/// ActivityContent를 UserDefaults에 저장하기 위한 Codable 래퍼
private struct CodableActivityContent: Codable {
    let status: String?
    let progress: Double?
    let message: String?
    let estimatedTime: Int?
    let customDataJson: String? // [String: Any]를 JSON 문자열로 저장
    
    init(from content: ActivityContent) {
        self.status = content.status
        self.progress = content.progress
        self.message = content.message
        self.estimatedTime = content.estimatedTime
        
        // customData를 JSON 문자열로 변환
        if !content.customData.isEmpty {
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: content.customData)
                self.customDataJson = String(data: jsonData, encoding: .utf8)
            } catch {
                self.customDataJson = nil
            }
        } else {
            self.customDataJson = nil
        }
    }
    
    func toActivityContent() -> ActivityContent {
        var customData: [String: Any] = [:]
        
        // JSON 문자열을 customData로 변환
        if let jsonString = customDataJson,
           let jsonData = jsonString.data(using: .utf8) {
            do {
                if let data = try JSONSerialization.jsonObject(with: jsonData) as? [String: Any] {
                    customData = data
                }
            } catch {
                // JSON 파싱 실패 시 빈 딕셔너리 사용
            }
        }
        
        return ActivityContent(
            status: status,
            progress: progress,
            message: message,
            estimatedTime: estimatedTime,
            customData: customData
        )
    }
}

/// ActivityAction을 UserDefaults에 저장하기 위한 Codable 래퍼
private struct CodableActivityAction: Codable {
    let id: String
    let title: String
    let icon: String?
    let isDestructive: Bool
    let deepLink: String?
    
    init(from action: ActivityAction) {
        self.id = action.id
        self.title = action.title
        self.icon = action.icon
        self.isDestructive = action.isDestructive
        self.deepLink = action.deepLink
    }
    
    func toActivityAction() -> ActivityAction {
        return ActivityAction(
            id: id,
            title: title,
            icon: icon,
            isDestructive: isDestructive,
            deepLink: deepLink
        )
    }
}