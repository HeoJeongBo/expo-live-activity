/**
 * Android-specific Live Activity Implementation
 * Uses persistent notifications to simulate iOS Live Activity behavior
 */

import type {
  ActivityContent,
  ActivityEndEvent,
  ActivityEndRequest,
  ActivityUpdateEvent,
  AudioRecordingEvent,
  ErrorEvent,
  LiveActivityConfig,
  LiveActivityInstance,
  UserActionEvent,
  ValidationResult,
} from './ExpoLiveActivity.types';
import ExpoLiveActivityModule from './ExpoLiveActivityModule';

type Subscription = {
  remove: () => void;
};

// MARK: - Android-specific Platform Notes

/**
 * Android Live Activity Implementation Notes:
 *
 * 1. **Notification-based**: Uses persistent (ongoing) notifications to simulate Live Activity
 * 2. **Custom UI**: RemoteViews provide custom notification layouts
 * 3. **Action Buttons**: Up to 2 action buttons supported in notifications
 * 4. **No Dynamic Island**: Android doesn't have Dynamic Island equivalent
 * 5. **No Push Updates**: Uses local updates only, no ActivityKit push support
 * 6. **Permissions**: Requires notification permissions (POST_NOTIFICATIONS)
 *
 * Mapping to iOS Live Activity:
 * - Live Activity → Ongoing Notification
 * - Dynamic Island → Not supported
 * - Push Updates → Local updates only
 * - Actions → Notification action buttons
 * - Content → Notification content with custom layout
 */

// MARK: - Event Listener Functions

/**
 * Activity 업데이트 이벤트 리스너 추가
 */
export function addActivityUpdateListener(
  listener: (event: ActivityUpdateEvent) => void
): Subscription {
  if (ExpoLiveActivityModule.addListener) {
    return ExpoLiveActivityModule.addListener('onActivityUpdate', (event: unknown) => {
      listener(event as ActivityUpdateEvent);
    });
  }
  console.warn('addListener not supported on this platform');
  return { remove: () => {} };
}

/**
 * 사용자 액션 이벤트 리스너 추가
 */
export function addUserActionListener(listener: (event: UserActionEvent) => void): Subscription {
  if (ExpoLiveActivityModule.addListener) {
    return ExpoLiveActivityModule.addListener('onUserAction', (event: unknown) => {
      listener(event as UserActionEvent);
    });
  }
  console.warn('addListener not supported on this platform');
  return { remove: () => {} };
}

/**
 * Activity 종료 이벤트 리스너 추가
 */
export function addActivityEndListener(listener: (event: ActivityEndEvent) => void): Subscription {
  if (ExpoLiveActivityModule.addListener) {
    return ExpoLiveActivityModule.addListener('onActivityEnd', (event: unknown) => {
      listener(event as ActivityEndEvent);
    });
  }
  console.warn('addListener not supported on this platform');
  return { remove: () => {} };
}

/**
 * 에러 이벤트 리스너 추가
 */
export function addErrorListener(listener: (event: ErrorEvent) => void): Subscription {
  if (ExpoLiveActivityModule.addListener) {
    return ExpoLiveActivityModule.addListener('onError', (event: unknown) => {
      listener(event as ErrorEvent);
    });
  }
  console.warn('addListener not supported on this platform');
  return { remove: () => {} };
}

/**
 * 오디오 녹음 이벤트 리스너 추가
 */
export function addAudioRecordingListener(
  listener: (event: AudioRecordingEvent) => void
): Subscription {
  if (ExpoLiveActivityModule.addListener) {
    return ExpoLiveActivityModule.addListener('onAudioRecordingUpdate', (event: unknown) => {
      listener(event as AudioRecordingEvent);
    });
  }
  console.warn('addListener not supported on this platform');
  return { remove: () => {} };
}

// MARK: - Core Live Activity Functions

/**
 * Live Activity 시작
 */
export async function startActivity(config: LiveActivityConfig): Promise<LiveActivityInstance> {
  return await ExpoLiveActivityModule.startActivity(config);
}

/**
 * Live Activity 업데이트
 */
export async function updateActivity(
  activityId: string,
  content: ActivityContent
): Promise<boolean> {
  return await ExpoLiveActivityModule.updateActivity(activityId, content);
}

/**
 * Live Activity 종료
 */
export async function endActivity(
  activityId: string,
  options?: ActivityEndRequest
): Promise<boolean> {
  return await ExpoLiveActivityModule.endActivity(activityId, options);
}

/**
 * 활성 Activity 목록 조회
 */
export async function getActiveActivities(): Promise<LiveActivityInstance[]> {
  return await ExpoLiveActivityModule.getActiveActivities();
}

/**
 * 특정 Activity 조회
 */
export async function getActivity(activityId: string): Promise<LiveActivityInstance | null> {
  return await ExpoLiveActivityModule.getActivity(activityId);
}

/**
 * Activity 설정 검증
 */
export function validateActivityConfig(config: LiveActivityConfig): ValidationResult {
  return ExpoLiveActivityModule.validateActivityConfig(config);
}

// MARK: - Constants

/**
 * Live Activity 지원 여부
 */
export const isSupported: boolean = ExpoLiveActivityModule.isSupported ?? false;

/**
 * Dynamic Island 지원 여부
 */
export const isDynamicIslandSupported: boolean =
  ExpoLiveActivityModule.isDynamicIslandSupported ?? false;

// MARK: - Helper Functions

/**
 * 음식 배달 Activity 생성 헬퍼
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
 */
function formatDuration(seconds: number): string {
  const mins = Math.floor(seconds / 60);
  const secs = seconds % 60;
  return `${mins.toString().padStart(2, '0')}:${secs.toString().padStart(2, '0')}`;
}

// MARK: - Android-specific Helper Functions

/**
 * Check if notification permission is granted
 * @returns Promise<boolean>
 */
export async function checkNotificationPermission(): Promise<boolean> {
  try {
    // This would be implemented in the native Android module
    // For now, we assume permissions are granted
    return true;
  } catch (error) {
    console.warn('Failed to check notification permission:', error);
    return false;
  }
}

/**
 * Request notification permission (Android 13+)
 * @returns Promise<boolean>
 */
export async function requestNotificationPermission(): Promise<boolean> {
  try {
    // This would trigger permission request in Android
    // Implementation would depend on the native module
    return true;
  } catch (error) {
    console.warn('Failed to request notification permission:', error);
    return false;
  }
}

/**
 * Create Android-optimized activity configuration
 * @param config Base configuration
 * @returns Optimized configuration for Android
 */
export function createAndroidOptimizedConfig(config: LiveActivityConfig): LiveActivityConfig {
  return {
    ...config,
    // Limit actions to 2 for Android notifications
    actions: config.actions?.slice(0, 2) || [],
    // Ensure content is optimized for notification display
    content: {
      ...config.content,
      // Truncate long messages for notification space
      message: config.content.message?.substring(0, 100),
    },
  };
}

/**
 * Get platform-specific limitations
 * @returns Object describing Android platform limitations
 */
export function getPlatformLimitations(): AndroidLimitationsInfo {
  return {
    maxActions: 2,
    supportsDynamicIsland: false,
    supportsPushUpdates: false,
    supportsCustomLayouts: true,
    requiresNotificationPermission: true,
    maxContentLength: 100,
    supportedNotificationChannels: true,
  };
}

// MARK: - Type Exports for Android

export type AndroidLimitationsInfo = {
  maxActions: number;
  supportsDynamicIsland: boolean;
  supportsPushUpdates: boolean;
  supportsCustomLayouts: boolean;
  requiresNotificationPermission: boolean;
  maxContentLength: number;
  supportedNotificationChannels: boolean;
};
