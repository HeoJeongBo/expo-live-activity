import type { StyleProp, ViewStyle } from 'react-native';

// MARK: - Core Types

/**
 * Live Activity 설정 타입
 */
export interface LiveActivityConfig {
  /** Activity 고유 ID */
  id: string;
  /** Activity 타입 */
  type: ActivityType;
  /** Activity 제목 */
  title: string;
  /** Activity 콘텐츠 */
  content: ActivityContent;
  /** 액션 버튼 목록 (최대 2개) */
  actions?: ActivityAction[];
  /** 만료 시간 (최대 8시간) */
  expirationDate?: Date;
  /** 우선순위 */
  priority?: ActivityPriority;
}

/**
 * Activity 타입 (확장 가능)
 */
export type ActivityType =
  | 'foodDelivery'
  | 'rideshare'
  | 'workout'
  | 'timer'
  | 'audioRecording'
  | 'custom';

/**
 * Activity 우선순위
 */
export type ActivityPriority = 'low' | 'normal' | 'high';

/**
 * Activity 콘텐츠
 */
export interface ActivityContent {
  /** 현재 상태 */
  status?: string;
  /** 진행률 (0.0 ~ 1.0) */
  progress?: number;
  /** 메시지 */
  message?: string;
  /** 예상 시간 (분) */
  estimatedTime?: number;
  /** 커스텀 데이터 */
  customData?: Record<string, unknown>;
}

/**
 * Activity 액션 (버튼)
 */
export interface ActivityAction {
  /** 액션 ID */
  id: string;
  /** 버튼 제목 */
  title: string;
  /** 아이콘 (SF Symbol 또는 이미지 이름) */
  icon?: string;
  /** 위험한 액션 여부 (빨간색 표시) */
  destructive?: boolean;
  /** 딥링크 URL */
  deepLink?: string;
}

/**
 * Live Activity 인스턴스
 */
export interface LiveActivityInstance {
  /** Activity ID */
  id: string;
  /** Activity 설정 */
  config: LiveActivityConfig;
  /** 활성 상태 */
  isActive: boolean;
  /** 생성 시간 */
  createdAt: Date;
  /** 업데이트 시간 */
  updatedAt: Date;
  /** 네이티브 Activity ID */
  nativeActivityId?: string;
}

// MARK: - Request Types

/**
 * Activity 업데이트 요청
 */
export interface ActivityUpdateRequest {
  /** Activity ID */
  activityId: string;
  /** 업데이트할 콘텐츠 */
  content: ActivityContent;
  /** 요청 시간 */
  timestamp?: Date;
}

/**
 * Activity 종료 요청
 */
export interface ActivityEndRequest {
  /** Activity ID */
  activityId: string;
  /** 최종 콘텐츠 */
  finalContent?: ActivityContent;
  /** 해제 정책 */
  dismissalPolicy?: DismissalPolicy;
}

/**
 * Activity 해제 정책
 */
export type DismissalPolicy = 'immediate' | 'default' | 'after';

// MARK: - Dynamic Island Types

/**
 * Dynamic Island 콘텐츠
 */
export interface DynamicIslandContent {
  /** 컴팩트 모드 앞쪽 요소 */
  compactLeading?: DynamicIslandElement;
  /** 컴팩트 모드 뒤쪽 요소 */
  compactTrailing?: DynamicIslandElement;
  /** 미니멀 모드 요소 */
  minimal?: DynamicIslandElement;
  /** 확장 모드 콘텐츠 */
  expanded?: DynamicIslandExpandedContent;
}

/**
 * Dynamic Island 요소
 */
export interface DynamicIslandElement {
  /** 요소 타입 */
  type: 'text' | 'icon' | 'emoji' | 'progress';
  /** 콘텐츠 */
  content: string;
  /** 색상 (HEX) */
  color?: string;
  /** 폰트 스타일 */
  font?: 'caption' | 'body' | 'headline' | 'title';
}

/**
 * Dynamic Island 확장 콘텐츠
 */
export interface DynamicIslandExpandedContent {
  /** 높이 */
  height: 'compact' | 'normal' | 'large';
  /** 콘텐츠 타입 */
  content: {
    /** 레이아웃 타입 */
    layout: 'vertical' | 'horizontal' | 'grid';
    /** 요소 목록 */
    elements: DynamicIslandExpandedElement[];
  };
}

/**
 * Dynamic Island 확장 요소
 */
export interface DynamicIslandExpandedElement {
  /** 요소 ID */
  id: string;
  /** 요소 타입 */
  type: 'title' | 'subtitle' | 'body' | 'progress' | 'button' | 'image';
  /** 콘텐츠 */
  content: string;
  /** 스타일 */
  style?: {
    fontSize?: number;
    fontWeight?: 'regular' | 'medium' | 'semibold' | 'bold';
    color?: string;
    backgroundColor?: string;
  };
}

/**
 * Dynamic Island 업데이트 요청
 */
export interface DynamicIslandUpdateRequest {
  /** Activity ID */
  activityId: string;
  /** Dynamic Island 콘텐츠 */
  content: DynamicIslandContent;
  /** 애니메이션 타입 */
  animationType?: 'none' | 'smooth' | 'bounce' | 'fade';
}

// MARK: - Event Types

/**
 * 기본 이벤트 핸들러 타입
 */
type EventHandler = (event: unknown) => void;

/**
 * 모듈 이벤트 타입
 */
export interface ExpoLiveActivityModuleEvents {
  /** Activity 업데이트 이벤트 */
  onActivityUpdate: EventHandler;
  /** 사용자 액션 이벤트 */
  onUserAction: EventHandler;
  /** Activity 종료 이벤트 */
  onActivityEnd: EventHandler;
  /** 에러 이벤트 */
  onError: EventHandler;
  /** 오디오 녹음 이벤트 */
  onAudioRecordingUpdate: EventHandler;
  /** 레거시 이벤트 (하위 호환성) */
  onChange: EventHandler;
  /** 인덱스 시그니처 */
  [key: string]: EventHandler;
}

/**
 * Activity 업데이트 이벤트
 */
export interface ActivityUpdateEvent {
  /** 이벤트 타입 */
  type: 'started' | 'updated';
  /** Activity 인스턴스 (started일 때) */
  activity?: LiveActivityInstance;
  /** Activity ID (updated일 때) */
  activityId?: string;
  /** 업데이트된 콘텐츠 (updated일 때) */
  content?: ActivityContent;
  /** 타임스탬프 */
  timestamp: number;
}

/**
 * 사용자 액션 이벤트
 */
export interface UserActionEvent {
  /** Activity ID */
  activityId: string;
  /** 액션 ID */
  actionId: string;
  /** 타임스탬프 */
  timestamp: number;
}

/**
 * Activity 종료 이벤트
 */
export interface ActivityEndEvent {
  /** Activity ID */
  activityId: string;
  /** 최종 콘텐츠 */
  finalContent?: ActivityContent;
  /** 해제 정책 */
  dismissalPolicy: DismissalPolicy;
}

/**
 * 에러 이벤트
 */
export interface ErrorEvent {
  /** 에러 메시지 */
  message: string;
  /** 에러 코드 */
  code: ActivityErrorCode;
}

/**
 * Activity 에러 코드
 */
export type ActivityErrorCode =
  | 'INVALID_CONFIGURATION'
  | 'ACTIVITY_NOT_FOUND'
  | 'ALREADY_STARTED'
  | 'SYSTEM_NOT_SUPPORTED'
  | 'PERMISSION_DENIED'
  | 'NETWORK_ERROR'
  | 'UNKNOWN_ERROR';

// MARK: - Push Notification Types

/**
 * Push 권한 상태
 */
export type PushAuthorizationStatus =
  | 'notDetermined'
  | 'denied'
  | 'authorized'
  | 'provisional'
  | 'ephemeral';

/**
 * 원격 업데이트 요청
 */
export interface RemoteUpdateRequest {
  /** Activity ID */
  activityId: string;
  /** 업데이트할 콘텐츠 */
  content: ActivityContent;
  /** Push 토큰 */
  pushToken: string;
}

// MARK: - Validation Types

/**
 * 검증 결과
 */
export interface ValidationResult {
  /** 유효 여부 */
  isValid: boolean;
  /** 에러 목록 */
  errors: ValidationError[];
}

/**
 * 검증 에러
 */
export interface ValidationError {
  /** 필드명 */
  field: string;
  /** 에러 메시지 */
  message: string;
}

// MARK: - Utility Types

/**
 * 성공/실패 결과 타입
 */
export type Result<T, E = Error> = { success: true; data: T } | { success: false; error: E };

/**
 * 비동기 결과 타입
 */
export type AsyncResult<T, E = Error> = Promise<Result<T, E>>;

// MARK: - Predefined Templates

/**
 * 미리 정의된 Activity 템플릿
 */
export interface ActivityTemplate {
  /** 템플릿 타입 */
  type: ActivityType;
  /** 기본 설정 */
  defaultConfig: Partial<LiveActivityConfig>;
  /** Dynamic Island 템플릿 */
  dynamicIslandTemplate: (data: Record<string, unknown>) => DynamicIslandContent;
}

/**
 * 음식 배달 템플릿 데이터
 */
export interface FoodDeliveryData {
  /** 식당명 */
  restaurant: string;
  /** 주문 상태 */
  status: string;
  /** 예상 시간 */
  estimatedTime: number;
  /** 주문 항목 */
  orderItems?: string[];
}

/**
 * 차량 호출 템플릿 데이터
 */
export interface RideshareData {
  /** 목적지 */
  destination: string;
  /** 상태 */
  status: string;
  /** 도착 예정 시간 */
  eta: number;
  /** 기사 정보 */
  driver?: {
    name: string;
    vehicle: string;
    rating?: number;
  };
}

/**
 * 운동 템플릿 데이터
 */
export interface WorkoutData {
  /** 운동 타입 */
  workoutType: string;
  /** 지속 시간 */
  duration: number;
  /** 칼로리 */
  calories: number;
  /** 심박수 */
  heartRate?: number;
}

/**
 * 타이머 템플릿 데이터
 */
export interface TimerData {
  /** 타이머 이름 */
  name: string;
  /** 남은 시간 */
  remainingTime: number;
  /** 전체 시간 */
  totalTime: number;
  /** 실행 여부 */
  isRunning: boolean;
}

/**
 * 오디오 녹음 템플릿 데이터
 */
export interface AudioRecordingData {
  /** 녹음 세션 ID */
  sessionId: string;
  /** 녹음 이름/제목 */
  title: string;
  /** 녹음 지속 시간 (초) */
  duration: number;
  /** 녹음 상태 */
  status: AudioRecordingStatus;
  /** 오디오 품질 */
  quality?: AudioQuality;
  /** 파일 경로 */
  filePath?: string;
  /** 파일 크기 (bytes) */
  fileSize?: number;
}

/**
 * 오디오 녹음 상태
 */
export type AudioRecordingStatus =
  | 'preparing'
  | 'recording'
  | 'paused'
  | 'stopped'
  | 'completed'
  | 'error';

/**
 * 오디오 품질
 */
export type AudioQuality = 'low' | 'medium' | 'high';

/**
 * 오디오 녹음 설정
 */
export interface AudioRecordingConfig {
  /** 녹음 세션 ID */
  sessionId: string;
  /** 녹음 제목 */
  title: string;
  /** 오디오 품질 */
  quality: AudioQuality;
  /** 최대 녹음 시간 (초) */
  maxDuration?: number;
  /** 백그라운드 녹음 허용 */
  allowsBackgroundRecording: boolean;
  /** Live Activity 표시 여부 */
  showLiveActivity: boolean;
}

/**
 * 오디오 녹음 이벤트
 */
export interface AudioRecordingEvent {
  /** 세션 ID */
  sessionId: string;
  /** 이벤트 타입 */
  type: 'started' | 'paused' | 'resumed' | 'stopped' | 'completed' | 'error';
  /** 녹음 지속 시간 */
  duration: number;
  /** 오디오 레벨 (0.0 ~ 1.0) */
  audioLevel?: number;
  /** 에러 메시지 (error 타입일 때) */
  error?: string;
  /** 파일 정보 (completed 타입일 때) */
  fileInfo?: {
    uri: string;
    size: number;
    duration: number;
  };
}

// MARK: - Legacy Types (Backward Compatibility)

/**
 * @deprecated Use ActivityUpdateEvent instead
 */
export type ChangeEventPayload = {
  value: string;
};

/**
 * @deprecated Use Live Activity APIs instead
 */
export type OnLoadEventPayload = {
  url: string;
};

/**
 * @deprecated Use Live Activity APIs instead
 */
export type ExpoLiveActivityViewProps = {
  url: string;
  onLoad: (event: { nativeEvent: { url: string } }) => void;
  style?: StyleProp<ViewStyle>;
};
