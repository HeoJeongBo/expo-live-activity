import { NativeModule, requireNativeModule } from 'expo';

import type {
  ActivityContent,
  ActivityEndRequest,
  DynamicIslandContent,
  ExpoLiveActivityModuleEvents,
  LiveActivityConfig,
  LiveActivityInstance,
  PushAuthorizationStatus,
  ValidationResult,
} from './ExpoLiveActivity.types';

declare class ExpoLiveActivityModule extends NativeModule<ExpoLiveActivityModuleEvents> {
  // Constants
  isSupported: boolean;
  isDynamicIslandSupported: boolean;

  // Event Listeners
  addListener<EventName extends keyof ExpoLiveActivityModuleEvents>(
    eventName: EventName,
    listener: ExpoLiveActivityModuleEvents[EventName]
  ): { remove: () => void };

  // Live Activity Management
  startActivity(config: LiveActivityConfig): Promise<LiveActivityInstance>;
  updateActivity(activityId: string, content: ActivityContent): Promise<boolean>;
  endActivity(activityId: string, options?: ActivityEndRequest): Promise<boolean>;
  getActiveActivities(): Promise<LiveActivityInstance[]>;
  getActivity(activityId: string): Promise<LiveActivityInstance | null>;

  // Dynamic Island
  updateDynamicIsland(activityId: string, content: DynamicIslandContent): Promise<boolean>;

  // Push Notifications
  registerPushToken(token: string): Promise<boolean>;
  requestRemoteUpdate(
    activityId: string,
    content: ActivityContent,
    pushToken: string
  ): Promise<boolean>;
  getPushAuthorizationStatus(): Promise<PushAuthorizationStatus>;

  // Validation
  validateActivityConfig(config: LiveActivityConfig): ValidationResult;

  // Legacy (deprecated)
  PI: number;
  hello(): string;
  setValueAsync(value: string): Promise<void>;
}

// This call loads the native module object from the JSI.
export default requireNativeModule<ExpoLiveActivityModule>('ExpoLiveActivity');
