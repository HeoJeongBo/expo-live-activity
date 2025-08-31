/**
 * Permission Manager for Live Activity Example
 *
 * This utility manages permissions required for Live Activities:
 * - Notifications: Required for all Live Activities
 * - Microphone: Required for audio recording Live Activities
 *
 * Usage:
 * 1. Check permissions before starting activities
 * 2. Request permissions if needed
 * 3. Handle permission denials gracefully
 */

import { Audio } from 'expo-av';
import * as Notifications from 'expo-notifications';
import { Alert, Linking } from 'react-native';

export type PermissionType = 'notifications' | 'microphone';
export type ActivityType =
  | 'foodDelivery'
  | 'rideshare'
  | 'workout'
  | 'timer'
  | 'audioRecording'
  | 'custom';

export interface PermissionResult {
  type: PermissionType;
  granted: boolean;
  status: 'granted' | 'denied' | 'undetermined';
  error?: string;
}

export interface PermissionSummary {
  allRequiredGranted: boolean;
  permissions: PermissionResult[];
  missingRequired: PermissionType[];
  suggestionMessage?: string;
}

/**
 * Activity type별 필요한 권한 매핑
 */
const ACTIVITY_PERMISSION_REQUIREMENTS: Record<
  ActivityType,
  { type: PermissionType; required: boolean; reason: string }[]
> = {
  foodDelivery: [
    {
      type: 'notifications',
      required: true,
      reason: 'Live Activity를 통해 배달 상태 업데이트를 받기 위해 필요합니다',
    },
  ],
  rideshare: [
    {
      type: 'notifications',
      required: true,
      reason: 'Live Activity를 통해 차량 위치 및 도착 정보를 받기 위해 필요합니다',
    },
  ],
  workout: [
    {
      type: 'notifications',
      required: true,
      reason: 'Live Activity를 통해 운동 진행상황을 확인하기 위해 필요합니다',
    },
  ],
  timer: [
    {
      type: 'notifications',
      required: true,
      reason: 'Live Activity를 통해 타이머 상태를 확인하기 위해 필요합니다',
    },
  ],
  audioRecording: [
    {
      type: 'notifications',
      required: true,
      reason: 'Live Activity를 통해 녹음 상태를 확인하기 위해 필요합니다',
    },
    {
      type: 'microphone',
      required: true,
      reason: '오디오 녹음을 위해 마이크 접근 권한이 필요합니다',
    },
  ],
  custom: [
    {
      type: 'notifications',
      required: true,
      reason: 'Live Activity를 사용하기 위해 필요합니다',
    },
  ],
};

export const PermissionManager = {
  /**
   * 특정 권한의 현재 상태를 확인합니다
   */
  checkPermissionStatus: async (type: PermissionType): Promise<PermissionResult> => {
    try {
      switch (type) {
        case 'notifications': {
          const { status } = await Notifications.getPermissionsAsync();
          return {
            type,
            granted: status === 'granted',
            status: status as 'granted' | 'denied' | 'undetermined',
          };
        }

        case 'microphone': {
          try {
            const { status } = await Audio.getPermissionsAsync();
            return {
              type,
              granted: status === 'granted',
              status: status as 'granted' | 'denied' | 'undetermined',
            };
          } catch (error) {
            return {
              type,
              granted: false,
              status: 'denied',
              error: 'expo-av 모듈이 설치되지 않았습니다. npm install expo-av를 실행하세요.',
            };
          }
        }

        default:
          return {
            type,
            granted: false,
            status: 'denied',
            error: `지원되지 않는 권한 타입: ${type}`,
          };
      }
    } catch (error) {
      return {
        type,
        granted: false,
        status: 'denied',
        error: error instanceof Error ? error.message : '권한 확인 중 오류가 발생했습니다',
      };
    }
  },

  /**
   * 특정 권한을 요청합니다
   */
  requestPermission: async (type: PermissionType): Promise<PermissionResult> => {
    try {
      switch (type) {
        case 'notifications': {
          const { status } = await Notifications.requestPermissionsAsync();
          return {
            type,
            granted: status === 'granted',
            status: status as 'granted' | 'denied' | 'undetermined',
          };
        }

        case 'microphone': {
          try {
            const { status } = await Audio.requestPermissionsAsync();
            return {
              type,
              granted: status === 'granted',
              status: status as 'granted' | 'denied' | 'undetermined',
            };
          } catch (error) {
            return {
              type,
              granted: false,
              status: 'denied',
              error: 'expo-av 모듈이 설치되지 않았습니다.',
            };
          }
        }

        default:
          return {
            type,
            granted: false,
            status: 'denied',
            error: `지원되지 않는 권한 타입: ${type}`,
          };
      }
    } catch (error) {
      return {
        type,
        granted: false,
        status: 'denied',
        error: error instanceof Error ? error.message : '권한 요청 중 오류가 발생했습니다',
      };
    }
  },

  /**
   * Live Activity 타입에 따른 권한 요구사항을 가져옵니다
   */
  getActivityPermissionRequirements: (activityType: ActivityType) => {
    return ACTIVITY_PERMISSION_REQUIREMENTS[activityType] || [];
  },

  /**
   * Live Activity 시작 전 필요한 권한들을 체크합니다
   */
  checkLiveActivityPermissions: async (activityType: ActivityType): Promise<PermissionSummary> => {
    const requirements = PermissionManager.getActivityPermissionRequirements(activityType);
    const permissionTypes = requirements.map((req) => req.type);

    const results = await Promise.all(
      permissionTypes.map((type) => PermissionManager.checkPermissionStatus(type))
    );

    const missingRequired = requirements
      .filter((req) => req.required)
      .map((req) => req.type)
      .filter((type) => {
        const result = results.find((r) => r.type === type);
        return !result || !result.granted;
      });

    const allRequiredGranted = missingRequired.length === 0;

    let suggestionMessage: string | undefined;
    if (!allRequiredGranted) {
      const missingReasons = requirements
        .filter((req) => req.required && missingRequired.includes(req.type))
        .map((req) => `• ${PermissionManager.getPermissionDisplayName(req.type)}: ${req.reason}`)
        .join('\n');

      suggestionMessage = `다음 권한이 필요합니다:\n${missingReasons}`;
    }

    return {
      allRequiredGranted,
      permissions: results,
      missingRequired,
      suggestionMessage,
    };
  },

  /**
   * Live Activity 시작 전 필요한 권한들을 요청합니다
   */
  requestLiveActivityPermissions: async (
    activityType: ActivityType
  ): Promise<PermissionSummary> => {
    const requirements = PermissionManager.getActivityPermissionRequirements(activityType);
    const requiredTypes = requirements.filter((req) => req.required).map((req) => req.type);

    // 필수 권한들 요청
    const results = await Promise.all(
      requiredTypes.map((type) => PermissionManager.requestPermission(type))
    );

    const missingRequired = requirements
      .filter((req) => req.required)
      .map((req) => req.type)
      .filter((type) => {
        const result = results.find((r) => r.type === type);
        return !result || !result.granted;
      });

    const allRequiredGranted = missingRequired.length === 0;

    let suggestionMessage: string | undefined;
    if (!allRequiredGranted) {
      suggestionMessage = '일부 필수 권한이 거부되었습니다. 설정에서 권한을 허용해주세요.';
    }

    return {
      allRequiredGranted,
      permissions: results,
      missingRequired,
      suggestionMessage,
    };
  },

  /**
   * 권한 타입의 표시 이름을 가져옵니다
   */
  getPermissionDisplayName: (type: PermissionType): string => {
    switch (type) {
      case 'notifications':
        return '알림';
      case 'microphone':
        return '마이크';
      default:
        return type;
    }
  },

  /**
   * 앱 설정 화면을 엽니다
   */
  openAppSettings: (): void => {
    try {
      Linking.openSettings();
    } catch (error) {
      console.warn('앱 설정을 열 수 없습니다:', error);
    }
  },

  /**
   * 사용자 친화적인 권한 요청 다이얼로그를 표시합니다
   */
  showPermissionDialog: async (
    activityType: ActivityType,
    onPermissionGranted: () => void,
    onPermissionDenied: () => void
  ): Promise<void> => {
    const permissionCheck = await PermissionManager.checkLiveActivityPermissions(activityType);

    if (permissionCheck.allRequiredGranted) {
      onPermissionGranted();
      return;
    }

    Alert.alert(
      '권한 필요',
      permissionCheck.suggestionMessage || '이 Activity를 사용하기 위해 권한이 필요합니다.',
      [
        {
          text: '취소',
          style: 'cancel',
          onPress: onPermissionDenied,
        },
        {
          text: '권한 요청',
          onPress: async () => {
            const requestResult =
              await PermissionManager.requestLiveActivityPermissions(activityType);

            if (requestResult.allRequiredGranted) {
              onPermissionGranted();
            } else {
              Alert.alert(
                '권한 필요',
                '일부 권한이 거부되었습니다. 설정에서 권한을 허용해주세요.',
                [
                  { text: '확인', style: 'cancel', onPress: onPermissionDenied },
                  { text: '설정 열기', onPress: PermissionManager.openAppSettings },
                ]
              );
            }
          },
        },
      ]
    );
  },

  /**
   * Activity 시작 전 권한을 체크하고 요청하는 헬퍼 함수
   */
  ensurePermissionsForActivity: async <T>(
    activityType: ActivityType,
    activityStarter: () => Promise<T>
  ): Promise<T | null> => {
    return new Promise((resolve) => {
      PermissionManager.showPermissionDialog(
        activityType,
        async () => {
          try {
            const result = await activityStarter();
            resolve(result);
          } catch (error) {
            console.error('Activity 시작 실패:', error);
            Alert.alert('오류', `Activity 시작 중 오류가 발생했습니다: ${error}`);
            resolve(null);
          }
        },
        () => {
          resolve(null);
        }
      );
    });
  },
};

// 편의 함수들 export
export const checkLiveActivityPermissions =
  PermissionManager.checkLiveActivityPermissions.bind(PermissionManager);
export const requestLiveActivityPermissions =
  PermissionManager.requestLiveActivityPermissions.bind(PermissionManager);
export const showPermissionDialog = PermissionManager.showPermissionDialog.bind(PermissionManager);
export const ensurePermissionsForActivity =
  PermissionManager.ensurePermissionsForActivity.bind(PermissionManager);
export const openAppSettings = PermissionManager.openAppSettings.bind(PermissionManager);
