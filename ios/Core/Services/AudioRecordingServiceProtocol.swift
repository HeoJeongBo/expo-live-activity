import Foundation
import AVFoundation

/// 오디오 녹음 서비스 프로토콜
/// Domain Layer: 비즈니스 로직과 외부 의존성을 분리
public protocol AudioRecordingServiceProtocol {
    /// 녹음 시작
    /// - Parameter config: 녹음 설정
    /// - Returns: 녹음 세션 결과
    func startRecording(_ config: AudioRecordingConfig) async -> Result<AudioRecordingSession, AudioRecordingError>
    
    /// 녹음 일시정지
    /// - Parameter sessionId: 세션 ID
    /// - Returns: 성공 여부
    func pauseRecording(_ sessionId: String) async -> Result<Void, AudioRecordingError>
    
    /// 녹음 재개
    /// - Parameter sessionId: 세션 ID
    /// - Returns: 성공 여부
    func resumeRecording(_ sessionId: String) async -> Result<Void, AudioRecordingError>
    
    /// 녹음 중지
    /// - Parameter sessionId: 세션 ID
    /// - Returns: 녹음 결과
    func stopRecording(_ sessionId: String) async -> Result<AudioRecordingResult, AudioRecordingError>
    
    /// 활성 녹음 세션 조회
    /// - Returns: 활성 세션 목록
    func getActiveRecordingSessions() async -> [AudioRecordingSession]
    
    /// 녹음 이벤트 스트림
    /// - Returns: 이벤트 스트림
    func recordingEventStream() -> AsyncStream<AudioRecordingEvent>
}

/// 오디오 녹음 설정
public struct AudioRecordingConfig {
    public let sessionId: String
    public let title: String
    public let quality: AudioQuality
    public let maxDuration: TimeInterval?
    public let allowsBackgroundRecording: Bool
    public let showLiveActivity: Bool
    
    public init(
        sessionId: String,
        title: String,
        quality: AudioQuality = .medium,
        maxDuration: TimeInterval? = nil,
        allowsBackgroundRecording: Bool = true,
        showLiveActivity: Bool = true
    ) {
        self.sessionId = sessionId
        self.title = title
        self.quality = quality
        self.maxDuration = maxDuration
        self.allowsBackgroundRecording = allowsBackgroundRecording
        self.showLiveActivity = showLiveActivity
    }
}

/// 오디오 품질
public enum AudioQuality: String, CaseIterable {
    case low = "low"
    case medium = "medium"
    case high = "high"
    
    var settings: [String: Any] {
        switch self {
        case .low:
            return [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 22050,
                AVNumberOfChannelsKey: 1,
                AVEncoderAudioQualityKey: AVAudioQuality.low.rawValue
            ]
        case .medium:
            return [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 44100,
                AVNumberOfChannelsKey: 1,
                AVEncoderAudioQualityKey: AVAudioQuality.medium.rawValue
            ]
        case .high:
            return [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 44100,
                AVNumberOfChannelsKey: 2,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
            ]
        }
    }
}

/// 오디오 녹음 상태
public enum AudioRecordingStatus: String, CaseIterable {
    case preparing = "preparing"
    case recording = "recording"
    case paused = "paused"
    case stopped = "stopped"
    case completed = "completed"
    case error = "error"
}

/// 오디오 녹음 세션
public struct AudioRecordingSession {
    public let sessionId: String
    public let title: String
    public let status: AudioRecordingStatus
    public let duration: TimeInterval
    public let quality: AudioQuality
    public let startedAt: Date
    public let filePath: URL?
    public let fileSize: Int64
    public let audioLevel: Float
    
    public init(
        sessionId: String,
        title: String,
        status: AudioRecordingStatus,
        duration: TimeInterval,
        quality: AudioQuality,
        startedAt: Date,
        filePath: URL? = nil,
        fileSize: Int64 = 0,
        audioLevel: Float = 0.0
    ) {
        self.sessionId = sessionId
        self.title = title
        self.status = status
        self.duration = duration
        self.quality = quality
        self.startedAt = startedAt
        self.filePath = filePath
        self.fileSize = fileSize
        self.audioLevel = audioLevel
    }
}

/// 오디오 녹음 결과
public struct AudioRecordingResult {
    public let sessionId: String
    public let filePath: URL
    public let duration: TimeInterval
    public let fileSize: Int64
    public let quality: AudioQuality
    public let metadata: [String: Any]
    
    public init(
        sessionId: String,
        filePath: URL,
        duration: TimeInterval,
        fileSize: Int64,
        quality: AudioQuality,
        metadata: [String: Any] = [:]
    ) {
        self.sessionId = sessionId
        self.filePath = filePath
        self.duration = duration
        self.fileSize = fileSize
        self.quality = quality
        self.metadata = metadata
    }
}

/// 오디오 녹음 이벤트
public struct AudioRecordingEvent {
    public let sessionId: String
    public let type: EventType
    public let duration: TimeInterval
    public let audioLevel: Float?
    public let error: AudioRecordingError?
    public let fileInfo: FileInfo?
    
    public enum EventType: String, CaseIterable {
        case started = "started"
        case paused = "paused"
        case resumed = "resumed"
        case stopped = "stopped"
        case completed = "completed"
        case error = "error"
        case audioLevelUpdate = "audioLevelUpdate"
    }
    
    public struct FileInfo {
        public let uri: String
        public let size: Int64
        public let duration: TimeInterval
        
        public init(uri: String, size: Int64, duration: TimeInterval) {
            self.uri = uri
            self.size = size
            self.duration = duration
        }
    }
    
    public init(
        sessionId: String,
        type: EventType,
        duration: TimeInterval,
        audioLevel: Float? = nil,
        error: AudioRecordingError? = nil,
        fileInfo: FileInfo? = nil
    ) {
        self.sessionId = sessionId
        self.type = type
        self.duration = duration
        self.audioLevel = audioLevel
        self.error = error
        self.fileInfo = fileInfo
    }
}

/// 오디오 녹음 에러
public enum AudioRecordingError: Error {
    case permissionDenied
    case sessionNotFound(String)
    case alreadyRecording(String)
    case notRecording(String)
    case audioSessionSetupFailed(String)
    case fileCreationFailed(String)
    case recordingFailed(String)
    case unknown(String)
    
    public var localizedDescription: String {
        switch self {
        case .permissionDenied:
            return "마이크 접근 권한이 필요합니다."
        case .sessionNotFound(let sessionId):
            return "녹음 세션을 찾을 수 없습니다: \(sessionId)"
        case .alreadyRecording(let sessionId):
            return "이미 녹음 중입니다: \(sessionId)"
        case .notRecording(let sessionId):
            return "녹음 중이 아닙니다: \(sessionId)"
        case .audioSessionSetupFailed(let reason):
            return "오디오 세션 설정 실패: \(reason)"
        case .fileCreationFailed(let reason):
            return "파일 생성 실패: \(reason)"
        case .recordingFailed(let reason):
            return "녹음 실패: \(reason)"
        case .unknown(let reason):
            return "알 수 없는 오류: \(reason)"
        }
    }
}