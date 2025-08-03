/**
 * Android-specific Live Activity Implementation
 * Uses persistent notifications to simulate iOS Live Activity behavior
 */

import type { LiveActivityConfig } from './ExpoLiveActivity.types';

// Re-export everything from the main interface
export * from './ExpoLiveActivityInterface';

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
export function getPlatformLimitations() {
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
