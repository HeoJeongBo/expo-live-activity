import Foundation
import AVFoundation
import ActivityKit

/// 오디오 녹음 매니저
/// Infrastructure Layer: AVFoundation과의 상호작용을 담당
@available(iOS 16.1, *)
public final class AudioRecordingManager: NSObject, AudioRecordingServiceProtocol {
    
    // MARK: - Properties
    
    private let audioSession = AVAudioSession.sharedInstance()
    private var audioRecorders: [String: AVAudioRecorder] = [:]
    private var recordingSessions: [String: AudioRecordingSession] = [:]
    private var liveActivityManager: LiveActivityServiceProtocol?
    
    private let eventContinuation: AsyncStream<AudioRecordingEvent>.Continuation
    private let eventStream: AsyncStream<AudioRecordingEvent>
    
    private let recordingsQueue = DispatchQueue(label: "com.expo.liveactivity.recordings", attributes: .concurrent)
    
    // MARK: - Initialization
    
    public override init() {
        let (stream, continuation) = AsyncStream<AudioRecordingEvent>.makeStream()
        self.eventStream = stream
        self.eventContinuation = continuation
        
        super.init()
        
        setupAudioSession()
    }
    
    public func setLiveActivityManager(_ manager: LiveActivityServiceProtocol) {
        self.liveActivityManager = manager
    }
    
    // MARK: - AudioRecordingServiceProtocol Implementation
    
    public func startRecording(_ config: AudioRecordingConfig) async -> Result<AudioRecordingSession, AudioRecordingError> {
        // 권한 확인
        guard await checkMicrophonePermission() else {
            return .failure(.permissionDenied)
        }
        
        // 이미 녹음 중인지 확인
        if recordingSessions[config.sessionId] != nil {
            return .failure(.alreadyRecording(config.sessionId))
        }
        
        do {
            // 파일 경로 생성
            let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let audioFilename = documentsPath.appendingPathComponent("\(config.sessionId).m4a")
            
            // 오디오 레코더 설정
            let recorder = try AVAudioRecorder(url: audioFilename, settings: config.quality.settings)
            recorder.delegate = self
            recorder.isMeteringEnabled = true
            
            // 녹음 시작
            guard recorder.record() else {
                return .failure(.recordingFailed("레코더 시작 실패"))
            }
            
            // 세션 생성
            let session = AudioRecordingSession(
                sessionId: config.sessionId,
                title: config.title,
                status: .recording,
                duration: 0,
                quality: config.quality,
                startedAt: Date(),
                filePath: audioFilename,
                fileSize: 0,
                audioLevel: 0.0
            )
            
            await recordingsQueue.async(flags: .barrier) {
                self.audioRecorders[config.sessionId] = recorder
                self.recordingSessions[config.sessionId] = session
            }
            
            // Live Activity 시작
            if config.showLiveActivity {
                await startLiveActivityForRecording(session)
            }
            
            // 오디오 레벨 모니터링 시작
            startAudioLevelMonitoring(for: config.sessionId)
            
            // 이벤트 발송
            let event = AudioRecordingEvent(
                sessionId: config.sessionId,
                type: .started,
                duration: 0
            )
            eventContinuation.yield(event)
            
            return .success(session)
            
        } catch {
            return .failure(.recordingFailed(error.localizedDescription))
        }
    }
    
    public func pauseRecording(_ sessionId: String) async -> Result<Void, AudioRecordingError> {
        guard let recorder = audioRecorders[sessionId] else {
            return .failure(.sessionNotFound(sessionId))
        }
        
        guard recorder.isRecording else {
            return .failure(.notRecording(sessionId))
        }
        
        recorder.pause()
        
        // 세션 상태 업데이트
        await updateSessionStatus(sessionId: sessionId, status: .paused)
        
        // Live Activity 업데이트
        await updateLiveActivityForRecording(sessionId: sessionId)
        
        // 이벤트 발송
        let event = AudioRecordingEvent(
            sessionId: sessionId,
            type: .paused,
            duration: recorder.currentTime
        )
        eventContinuation.yield(event)
        
        return .success(())
    }
    
    public func resumeRecording(_ sessionId: String) async -> Result<Void, AudioRecordingError> {
        guard let recorder = audioRecorders[sessionId] else {
            return .failure(.sessionNotFound(sessionId))
        }
        
        guard !recorder.isRecording else {
            return .failure(.alreadyRecording(sessionId))
        }
        
        guard recorder.record() else {
            return .failure(.recordingFailed("녹음 재개 실패"))
        }
        
        // 세션 상태 업데이트
        await updateSessionStatus(sessionId: sessionId, status: .recording)
        
        // Live Activity 업데이트
        await updateLiveActivityForRecording(sessionId: sessionId)
        
        // 이벤트 발송
        let event = AudioRecordingEvent(
            sessionId: sessionId,
            type: .resumed,
            duration: recorder.currentTime
        )
        eventContinuation.yield(event)
        
        return .success(())
    }
    
    public func stopRecording(_ sessionId: String) async -> Result<AudioRecordingResult, AudioRecordingError> {
        guard let recorder = audioRecorders[sessionId],
              let session = recordingSessions[sessionId] else {
            return .failure(.sessionNotFound(sessionId))
        }
        
        recorder.stop()
        
        // 파일 정보 가져오기
        let filePath = recorder.url
        let fileSize = getFileSize(at: filePath)
        let duration = recorder.currentTime
        
        // 결과 생성
        let result = AudioRecordingResult(
            sessionId: sessionId,
            filePath: filePath,
            duration: duration,
            fileSize: fileSize,
            quality: session.quality,
            metadata: [
                "startedAt": session.startedAt,
                "completedAt": Date()
            ]
        )
        
        // 세션 정리
        await recordingsQueue.async(flags: .barrier) {
            self.audioRecorders.removeValue(forKey: sessionId)
            self.recordingSessions.removeValue(forKey: sessionId)
        }
        
        // Live Activity 종료
        await endLiveActivityForRecording(sessionId: sessionId, result: result)
        
        // 이벤트 발송
        let fileInfo = AudioRecordingEvent.FileInfo(
            uri: filePath.absoluteString,
            size: fileSize,
            duration: duration
        )
        
        let event = AudioRecordingEvent(
            sessionId: sessionId,
            type: .completed,
            duration: duration,
            fileInfo: fileInfo
        )
        eventContinuation.yield(event)
        
        return .success(result)
    }
    
    public func getActiveRecordingSessions() async -> [AudioRecordingSession] {
        return await recordingsQueue.sync {
            Array(recordingSessions.values)
        }
    }
    
    public func recordingEventStream() -> AsyncStream<AudioRecordingEvent> {
        return eventStream
    }
    
    // MARK: - Private Methods
    
    private func setupAudioSession() {
        do {
            try audioSession.setCategory(.record, mode: .default)
            try audioSession.setActive(true)
        } catch {
            print("Audio session setup failed: \(error)")
        }
    }
    
    private func checkMicrophonePermission() async -> Bool {
        switch audioSession.recordPermission {
        case .granted:
            return true
        case .denied:
            return false
        case .undetermined:
            return await withCheckedContinuation { continuation in
                audioSession.requestRecordPermission { granted in
                    continuation.resume(returning: granted)
                }
            }
        @unknown default:
            return false
        }
    }
    
    private func updateSessionStatus(sessionId: String, status: AudioRecordingStatus) async {
        await recordingsQueue.async(flags: .barrier) {
            if var session = self.recordingSessions[sessionId] {
                self.recordingSessions[sessionId] = AudioRecordingSession(
                    sessionId: session.sessionId,
                    title: session.title,
                    status: status,
                    duration: session.duration,
                    quality: session.quality,
                    startedAt: session.startedAt,
                    filePath: session.filePath,
                    fileSize: session.fileSize,
                    audioLevel: session.audioLevel
                )
            }
        }
    }
    
    private func getFileSize(at url: URL) -> Int64 {
        do {
            let attributes = try FileManager.default.attributesOfItem(atPath: url.path)
            return attributes[.size] as? Int64 ?? 0
        } catch {
            return 0
        }
    }
    
    private func startAudioLevelMonitoring(for sessionId: String) {
        Task {
            while let recorder = audioRecorders[sessionId], recorder.isRecording {
                recorder.updateMeters()
                let audioLevel = recorder.averagePower(forChannel: 0)
                let normalizedLevel = max(0.0, (audioLevel + 60.0) / 60.0) // -60dB to 0dB normalized to 0.0-1.0
                
                let event = AudioRecordingEvent(
                    sessionId: sessionId,
                    type: .audioLevelUpdate,
                    duration: recorder.currentTime,
                    audioLevel: Float(normalizedLevel)
                )
                eventContinuation.yield(event)
                
                try? await Task.sleep(nanoseconds: 100_000_000) // 0.1초마다 업데이트
            }
        }
    }
    
    // MARK: - Live Activity Integration
    
    private func startLiveActivityForRecording(_ session: AudioRecordingSession) async {
        guard let liveActivityManager = liveActivityManager else { return }
        
        let config = LiveActivityConfig(
            id: "audio-recording-\(session.sessionId)",
            type: .audioRecording,
            title: "🎙️ \(session.title)",
            content: ActivityContent(
                status: "녹음 중",
                estimatedTime: 0,
                customData: [
                    "sessionId": session.sessionId,
                    "duration": 0,
                    "quality": session.quality.rawValue,
                    "formattedDuration": "00:00"
                ]
            ),
            actions: [
                ActivityAction(id: "pause", title: "일시정지", icon: "pause.circle"),
                ActivityAction(id: "stop", title: "중지", icon: "stop.circle", destructive: true)
            ],
            priority: .high
        )
        
        _ = await liveActivityManager.startActivity(config)
    }
    
    private func updateLiveActivityForRecording(sessionId: String) async {
        guard let session = recordingSessions[sessionId],
              let liveActivityManager = liveActivityManager else { return }
        
        let recorder = audioRecorders[sessionId]
        let duration = recorder?.currentTime ?? session.duration
        let formattedDuration = formatDuration(Int(duration))
        
        let content = ActivityContent(
            status: session.status == .recording ? "녹음 중" : "일시정지",
            estimatedTime: Int(duration / 60),
            customData: [
                "sessionId": sessionId,
                "duration": Int(duration),
                "quality": session.quality.rawValue,
                "formattedDuration": formattedDuration
            ]
        )
        
        let request = ActivityUpdateRequest(
            activityId: "audio-recording-\(sessionId)",
            content: content
        )
        
        _ = await liveActivityManager.updateActivity(request)
    }
    
    private func endLiveActivityForRecording(sessionId: String, result: AudioRecordingResult) async {
        guard let liveActivityManager = liveActivityManager else { return }
        
        let formattedDuration = formatDuration(Int(result.duration))
        let fileSize = ByteCountFormatter.string(fromByteCount: result.fileSize, countStyle: .file)
        
        let finalContent = ActivityContent(
            status: "완료",
            message: "녹음이 완료되었습니다",
            customData: [
                "sessionId": sessionId,
                "duration": Int(result.duration),
                "formattedDuration": formattedDuration,
                "fileSize": fileSize
            ]
        )
        
        let request = ActivityEndRequest(
            activityId: "audio-recording-\(sessionId)",
            finalContent: finalContent,
            dismissalPolicy: .after
        )
        
        _ = await liveActivityManager.endActivity(request)
    }
    
    private func formatDuration(_ seconds: Int) -> String {
        let mins = seconds / 60
        let secs = seconds % 60
        return String(format: "%02d:%02d", mins, secs)
    }
    
    deinit {
        eventContinuation.finish()
    }
}

// MARK: - AVAudioRecorderDelegate

@available(iOS 16.1, *)
extension AudioRecordingManager: AVAudioRecorderDelegate {
    
    public func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        // 녹음 완료 처리
        let sessionId = audioRecorders.first { $0.value === recorder }?.key
        
        if let sessionId = sessionId {
            let event = AudioRecordingEvent(
                sessionId: sessionId,
                type: flag ? .completed : .error,
                duration: recorder.currentTime,
                error: flag ? nil : .recordingFailed("녹음이 비정상적으로 종료되었습니다")
            )
            eventContinuation.yield(event)
        }
    }
    
    public func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        // 녹음 에러 처리
        let sessionId = audioRecorders.first { $0.value === recorder }?.key
        
        if let sessionId = sessionId {
            let event = AudioRecordingEvent(
                sessionId: sessionId,
                type: .error,
                duration: recorder.currentTime,
                error: .recordingFailed(error?.localizedDescription ?? "알 수 없는 녹음 오류")
            )
            eventContinuation.yield(event)
        }
    }
}