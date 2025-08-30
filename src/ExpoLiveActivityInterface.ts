type Subscription = {
  remove: () => void;
};

import type {
  ActivityContent,
  ActivityEndEvent,
  ActivityEndRequest,
  ActivityUpdateEvent,
  ActivityUpdateRequest,
  AudioRecordingEvent,
  DynamicIslandContent,
  DynamicIslandUpdateRequest,
  ErrorEvent,
  ExpoLiveActivityModuleEvents,
  LiveActivityConfig,
  LiveActivityInstance,
  PushAuthorizationStatus,
  RemoteUpdateRequest,
  UserActionEvent,
  ValidationResult,
} from './ExpoLiveActivity.types';
// Import the native module. On web, it will be resolved to ExpoLiveActivity.web.ts
// and on native platforms to ExpoLiveActivity.ts
import ExpoLiveActivityModule from './ExpoLiveActivityModule';

// Legacy type for backward compatibility - defined locally to avoid import deprecation warning
type ChangeEventPayload = {
  value: string;
};

// MARK: - Module Constants

/**
 * Live Activity 지원 여부
 */
export const isSupported: boolean = ExpoLiveActivityModule.isSupported ?? false;

/**
 * Dynamic Island 지원 여부
 */
export const isDynamicIslandSupported: boolean =
  ExpoLiveActivityModule.isDynamicIslandSupported ?? false;

// MARK: - Live Activity Management

/**
 * Live Activity 시작
 * @param config Activity 설정
 * @returns 생성된 Activity 인스턴스
 */
export async function startActivity(config: LiveActivityConfig): Promise<LiveActivityInstance> {
  return await ExpoLiveActivityModule.startActivity(config);
}

/**
 * Live Activity 업데이트
 * @param activityId Activity ID
 * @param content 업데이트할 콘텐츠
 * @returns 성공 여부
 */
export async function updateActivity(
  activityId: string,
  content: ActivityContent
): Promise<boolean> {
  return await ExpoLiveActivityModule.updateActivity(activityId, content);
}

/**
 * Live Activity 종료
 * @param activityId Activity ID
 * @param options 종료 옵션
 * @returns 성공 여부
 */
export async function endActivity(
  activityId: string,
  options?: ActivityEndRequest
): Promise<boolean> {
  return await ExpoLiveActivityModule.endActivity(activityId, options);
}

/**
 * 활성 Activity 목록 조회
 * @returns 활성 Activity 목록
 */
export async function getActiveActivities(): Promise<LiveActivityInstance[]> {
  return await ExpoLiveActivityModule.getActiveActivities();
}

/**
 * 특정 Activity 조회
 * @param activityId Activity ID
 * @returns Activity 인스턴스 또는 null
 */
export async function getActivity(activityId: string): Promise<LiveActivityInstance | null> {
  return await ExpoLiveActivityModule.getActivity(activityId);
}

// MARK: - Dynamic Island

/**
 * Dynamic Island 업데이트 (iOS 전용)
 * @param activityId Activity ID
 * @param content Dynamic Island 콘텐츠
 * @returns 성공 여부
 */
export async function updateDynamicIsland(
  activityId: string,
  content: DynamicIslandContent
): Promise<boolean> {
  if (!isDynamicIslandSupported) {
    console.warn('Dynamic Island is not supported on this platform');
    return false;
  }
  return await ExpoLiveActivityModule.updateDynamicIsland(activityId, content);
}

// MARK: - Push Notifications

/**
 * Push 토큰 등록 (iOS 전용)
 * @param token APNS 토큰
 * @returns 성공 여부
 */
export async function registerPushToken(token: string): Promise<boolean> {
  if (ExpoLiveActivityModule.registerPushToken) {
    return await ExpoLiveActivityModule.registerPushToken(token);
  }
  console.warn('Push token registration is not supported on this platform');
  return false;
}

/**
 * 원격 업데이트 요청 (iOS 전용)
 * @param activityId Activity ID
 * @param content 업데이트할 콘텐츠
 * @param pushToken 대상 Push 토큰
 * @returns 성공 여부
 */
export async function requestRemoteUpdate(
  activityId: string,
  content: ActivityContent,
  pushToken: string
): Promise<boolean> {
  if (ExpoLiveActivityModule.requestRemoteUpdate) {
    return await ExpoLiveActivityModule.requestRemoteUpdate(activityId, content, pushToken);
  }
  console.warn(
    'Remote update via push is not supported on this platform. Use updateActivity instead.'
  );
  return false;
}

/**
 * Push 알림 권한 상태 확인
 * @returns Push 권한 상태
 */
export async function getPushAuthorizationStatus(): Promise<PushAuthorizationStatus> {
  if (ExpoLiveActivityModule.getPushAuthorizationStatus) {
    return await ExpoLiveActivityModule.getPushAuthorizationStatus();
  }
  return 'notDetermined';
}

// MARK: - Validation

/**
 * Activity 설정 검증
 * @param config Activity 설정
 * @returns 검증 결과
 */
export function validateActivityConfig(config: LiveActivityConfig): ValidationResult {
  return ExpoLiveActivityModule.validateActivityConfig(config);
}

// MARK: - Event Listeners

/**
 * Activity 업데이트 이벤트 리스너 추가
 * @param listener 이벤트 리스너
 * @returns 구독 객체
 */
export function addActivityUpdateListener(
  listener: (event: ActivityUpdateEvent) => void
): Subscription {
  if (ExpoLiveActivityModule.addListener) {
    return ExpoLiveActivityModule.addListener('onActivityUpdate', (event: unknown) => {
      listener(event as ActivityUpdateEvent);
    });
  }
  // Fallback for platforms without addListener support
  console.warn('addListener not supported on this platform');
  return { remove: () => {} };
}

/**
 * 사용자 액션 이벤트 리스너 추가
 * @param listener 이벤트 리스너
 * @returns 구독 객체
 */
export function addUserActionListener(listener: (event: UserActionEvent) => void): Subscription {
  if (ExpoLiveActivityModule.addListener) {
    return ExpoLiveActivityModule.addListener('onUserAction', (event: unknown) => {
      listener(event as UserActionEvent);
    });
  }
  // Fallback for platforms without addListener support
  console.warn('addListener not supported on this platform');
  return { remove: () => {} };
}

/**
 * Activity 종료 이벤트 리스너 추가
 * @param listener 이벤트 리스너
 * @returns 구독 객체
 */
export function addActivityEndListener(listener: (event: ActivityEndEvent) => void): Subscription {
  if (ExpoLiveActivityModule.addListener) {
    return ExpoLiveActivityModule.addListener('onActivityEnd', (event: unknown) => {
      listener(event as ActivityEndEvent);
    });
  }
  // Fallback for platforms without addListener support
  console.warn('addListener not supported on this platform');
  return { remove: () => {} };
}

/**
 * 에러 이벤트 리스너 추가
 * @param listener 이벤트 리스너
 * @returns 구독 객체
 */
export function addErrorListener(listener: (event: ErrorEvent) => void): Subscription {
  if (ExpoLiveActivityModule.addListener) {
    return ExpoLiveActivityModule.addListener('onError', (event: unknown) => {
      listener(event as ErrorEvent);
    });
  }
  // Fallback for platforms without addListener support
  console.warn('addListener not supported on this platform');
  return { remove: () => {} };
}

/**
 * 오디오 녹음 이벤트 리스너 추가
 * @param listener 이벤트 리스너
 * @returns 구독 객체
 */
export function addAudioRecordingListener(
  listener: (event: AudioRecordingEvent) => void
): Subscription {
  if (ExpoLiveActivityModule.addListener) {
    return ExpoLiveActivityModule.addListener('onAudioRecordingUpdate', (event: unknown) => {
      listener(event as AudioRecordingEvent);
    });
  }
  // Fallback for platforms without addListener support
  console.warn('addListener not supported on this platform');
  return { remove: () => {} };
}

// MARK: - Helper Functions

/**
 * 음식 배달 Activity 생성 헬퍼
 * @param config 기본 설정
 * @returns Live Activity 설정
 */
export function createFoodDeliveryActivity(config: {
  id: string;
  restaurant: string;
  status: string;
  estimatedTime: number;
  orderItems?: string[];
}): LiveActivityConfig {
  return {
    id: config.id,
    type: 'foodDelivery',
    title: `${config.restaurant} 주문`,
    content: {
      status: config.status,
      estimatedTime: config.estimatedTime,
      customData: {
        restaurant: config.restaurant,
        orderItems: config.orderItems || [],
      },
    },
    actions: [
      {
        id: 'cancel',
        title: '주문 취소',
        destructive: true,
      },
      {
        id: 'call',
        title: '매장 전화',
        icon: 'phone',
      },
    ],
    priority: 'high',
  };
}

/**
 * 차량 호출 Activity 생성 헬퍼
 * @param config 기본 설정
 * @returns Live Activity 설정
 */
export function createRideshareActivity(config: {
  id: string;
  destination: string;
  status: string;
  eta: number;
  driver?: {
    name: string;
    vehicle: string;
    rating?: number;
  };
}): LiveActivityConfig {
  return {
    id: config.id,
    type: 'rideshare',
    title: `${config.destination}로 이동`,
    content: {
      status: config.status,
      estimatedTime: config.eta,
      customData: {
        destination: config.destination,
        driverName: config.driver?.name,
        vehicleInfo: config.driver?.vehicle,
        driverRating: config.driver?.rating,
      },
    },
    actions: [
      {
        id: 'cancel',
        title: '호출 취소',
        destructive: true,
      },
      {
        id: 'call_driver',
        title: '기사 전화',
        icon: 'phone',
      },
    ],
    priority: 'high',
  };
}

/**
 * 운동 Activity 생성 헬퍼
 * @param config 기본 설정
 * @returns Live Activity 설정
 */
export function createWorkoutActivity(config: {
  id: string;
  workoutType: string;
  duration: number;
  calories: number;
  heartRate?: number;
}): LiveActivityConfig {
  return {
    id: config.id,
    type: 'workout',
    title: `${config.workoutType} 운동`,
    content: {
      status: '운동 중',
      estimatedTime: config.duration,
      customData: {
        workoutType: config.workoutType,
        calories: config.calories,
        heartRate: config.heartRate,
      },
    },
    actions: [
      {
        id: 'pause',
        title: '일시정지',
      },
      {
        id: 'stop',
        title: '운동 종료',
        destructive: true,
      },
    ],
    priority: 'normal',
  };
}

/**
 * 타이머 Activity 생성 헬퍼
 * @param config 기본 설정
 * @returns Live Activity 설정
 */
export function createTimerActivity(config: {
  id: string;
  name: string;
  totalTime: number;
  remainingTime: number;
  isRunning: boolean;
}): LiveActivityConfig {
  return {
    id: config.id,
    type: 'timer',
    title: config.name,
    content: {
      status: config.isRunning ? '실행 중' : '일시정지',
      estimatedTime: config.remainingTime,
      customData: {
        totalTime: config.totalTime,
        isRunning: config.isRunning,
      },
    },
    actions: [
      {
        id: config.isRunning ? 'pause' : 'resume',
        title: config.isRunning ? '일시정지' : '재개',
      },
      {
        id: 'stop',
        title: '정지',
        destructive: true,
      },
    ],
    priority: 'normal',
  };
}

/**
 * 오디오 녹음 Activity 생성 헬퍼
 * @param config 기본 설정
 * @returns Live Activity 설정
 */
export function createAudioRecordingActivity(config: {
  id: string;
  title: string;
  duration: number;
  status: string;
  quality?: string;
  audioLevel?: number;
}): LiveActivityConfig {
  return {
    id: config.id,
    type: 'audioRecording',
    title: config.title,
    content: {
      status: config.status,
      estimatedTime: Math.floor(config.duration / 60), // 분 단위로 변환
      customData: {
        duration: config.duration,
        quality: config.quality || 'medium',
        audioLevel: config.audioLevel || 0,
        formattedDuration: formatDuration(config.duration),
      },
    },
    actions: [
      {
        id: config.status === 'recording' ? 'pause' : 'resume',
        title: config.status === 'recording' ? '일시정지' : '재개',
        icon: config.status === 'recording' ? 'pause.circle' : 'play.circle',
      },
      {
        id: 'stop',
        title: '녹음 종료',
        destructive: true,
        icon: 'stop.circle',
      },
    ],
    priority: 'high',
  };
}

/**
 * 시간을 MM:SS 형식으로 포맷팅
 * @param seconds 초 단위 시간
 * @returns 포맷된 시간 문자열
 */
function formatDuration(seconds: number): string {
  const mins = Math.floor(seconds / 60);
  const secs = seconds % 60;
  return `${mins.toString().padStart(2, '0')}:${secs.toString().padStart(2, '0')}`;
}

// MARK: - Legacy Support (Backward Compatibility)

/**
 * @deprecated Use addActivityUpdateListener instead
 */
export function addChangeListener(listener: (event: ChangeEventPayload) => void): Subscription {
  return ExpoLiveActivityModule.addListener('onChange', (event: unknown) => {
    listener(event as ChangeEventPayload);
  });
}

/**
 * @deprecated Use startActivity with proper config instead
 */
export async function setValueAsync(_value: string): Promise<void> {
  // Legacy function - does nothing in new implementation
  console.warn('setValueAsync is deprecated. Use startActivity instead.');
}

/**
 * @deprecated Use Live Activity APIs instead
 */
export function hello(): string {
  return 'Hello from Live Activity module! Use the new Live Activity APIs.';
}

/**
 * @deprecated Use isSupported constant instead
 */
export const PI = Math.PI;

// MARK: - Type Exports

export type {
  LiveActivityConfig,
  LiveActivityInstance,
  ActivityContent,
  ActivityUpdateRequest,
  ActivityEndRequest,
  DynamicIslandContent,
  DynamicIslandUpdateRequest,
  ValidationResult,
  PushAuthorizationStatus,
  ExpoLiveActivityModuleEvents,
  ActivityUpdateEvent,
  UserActionEvent,
  ActivityEndEvent,
  ErrorEvent,
  RemoteUpdateRequest,
};
