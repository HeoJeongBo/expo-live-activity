import { NativeModule, requireNativeModule } from 'expo';

import type {
  ActivityContent,
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

  // Live Activity Management
  startActivity(config: LiveActivityConfig): Promise<LiveActivityInstance>;
  updateActivity(activityId: string, content: ActivityContent): Promise<boolean>;
  endActivity(
    activityId: string,
    options?: {
      finalContent?: ActivityContent;
      dismissalPolicy?: string;
    }
  ): Promise<boolean>;
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
