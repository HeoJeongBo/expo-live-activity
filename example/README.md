# Live Activity Example App

이 예제 앱은 `@heojeongbo/expo-live-activity` 모듈의 사용법을 보여주며, **권한 관리**를 포함한 완전한 구현 예시를 제공합니다.

## 🎯 주요 기능

### ✅ 권한 관리 시스템
- **자동 권한 체크**: Activity 시작 전 필요한 권한 자동 확인
- **사용자 친화적 권한 요청**: 설명과 함께 권한 요청 다이얼로그
- **권한 상태 실시간 모니터링**: 앱 내에서 권한 상태 확인
- **설정 앱 연동**: 권한 거부 시 설정 앱으로 안내

### 📱 Live Activity 타입별 구현
1. **음식 배달 Activity**: 알림 권한 필요
2. **차량 호출 Activity**: 알림 권한 필요  
3. **운동 Activity**: 알림 권한 필요
4. **타이머 Activity**: 알림 권한 필요
5. **오디오 녹음 Activity**: 알림 + 마이크 권한 필요

## 🛠️ 설정 및 실행

### 1. 의존성 설치
```bash
cd example
npm install

# 또는 Bun 사용
bun install
```

### 2. 필요한 권한 모듈이 포함되어 있는지 확인
```json
// package.json
{
  "dependencies": {
    "expo-notifications": "~0.30.0",  // 알림 권한용
    "expo-av": "~15.0.3"              // 마이크 권한용 (오디오 녹음 전용)
  }
}
```

### 3. 앱 실행
```bash
# iOS
npx expo run:ios

# Android  
npx expo run:android
```

## 🔧 권한 설정

### iOS (app.json)
```json
{
  "expo": {
    "ios": {
      "infoPlist": {
        "NSMicrophoneUsageDescription": "This app uses the microphone for audio recording Live Activities.",
        "NSSupportsLiveActivities": true,
        "NSSupportsLiveActivitiesFrequentUpdates": true
      },
      "entitlements": {
        "com.apple.developer.usernotifications.live-activities": true
      }
    },
    "plugins": [
      ["expo-notifications", { ... }],
      ["expo-av", {
        "microphonePermission": "This app uses the microphone to record audio for Live Activities."
      }]
    ]
  }
}
```

### Android (app.json)
```json
{
  "expo": {
    "android": {
      "permissions": [
        "android.permission.POST_NOTIFICATIONS",
        "android.permission.RECORD_AUDIO",
        "android.permission.FOREGROUND_SERVICE",
        "android.permission.WAKE_LOCK"
      ]
    }
  }
}
```

## 📂 프로젝트 구조

```
example/
├── src/
│   └── utils/
│       └── PermissionManager.ts      # 권한 관리 유틸리티
├── App.tsx                           # 메인 앱 컴포넌트 (권한 통합)
├── app.json                          # Expo 설정 (권한 포함)
├── package.json                      # 의존성 설정
└── README.md                         # 이 문서
```

## 🎮 사용법

### 1. 앱 시작 시 자동 권한 체크
앱이 시작되면 자동으로 기본 권한(알림) 상태를 확인합니다.

### 2. 권한 관리 섹션 사용
- **권한 확인**: 현재 권한 상태 확인
- **권한 요청**: 부족한 권한 요청
- **앱 설정 열기**: 수동 권한 설정을 위한 설정 앱 이동

### 3. Activity 시작
각 Activity 버튼을 누르면:
1. 필요한 권한 자동 확인
2. 권한 부족 시 사용자 친화적 다이얼로그 표시  
3. 권한 승인 시 Activity 시작
4. 권한 거부 시 설정 앱 안내

## 🔍 권한 관리 코드 예시

### PermissionManager 사용법
```typescript
import { PermissionManager } from './src/utils/PermissionManager';

// 1. 권한 상태 확인
const status = await PermissionManager.checkLiveActivityPermissions('audioRecording');
console.log('모든 필수 권한 승인됨:', status.allRequiredGranted);

// 2. 권한 요청
const result = await PermissionManager.requestLiveActivityPermissions('audioRecording');

// 3. Activity 시작 전 권한 체크 헬퍼
await PermissionManager.ensurePermissionsForActivity('foodDelivery', async () => {
  const config = createFoodDeliveryActivity({ ... });
  return await startActivity(config);
});
```

### 사용자 친화적 권한 다이얼로그
```typescript
PermissionManager.showPermissionDialog(
  'audioRecording',
  () => {
    // 권한 승인 시 Activity 시작
    startAudioRecordingActivity();
  },
  () => {
    // 권한 거부 시 처리
    console.log('권한이 필요합니다');
  }
);
```

## ⚠️ 중요 사항

### 1. 권한 모듈 의존성
이 예제는 다음 Expo 모듈들을 **반드시** 설치해야 합니다:
- `expo-notifications`: 알림 권한 관리
- `expo-av`: 마이크 권한 관리

### 2. Live Activity 모듈 자체는 권한을 관리하지 않음
`@heojeongbo/expo-live-activity` 모듈 자체는 권한을 자동으로 처리하지 않습니다. 
개발자가 직접 `expo-notifications`와 `expo-av`를 사용해서 권한을 관리해야 합니다.

### 3. 플랫폼별 차이점
- **iOS**: ActivityKit 사용, 알림 권한은 자동 처리되지만 마이크는 수동 요청 필요
- **Android**: 모든 권한을 수동으로 요청해야 함 (Android 13+)

## 🚀 프로덕션 적용 가이드

이 예제의 `PermissionManager` 클래스를 여러분의 앱에 복사해서 사용하시면 됩니다:

1. `src/utils/PermissionManager.ts` 파일을 프로젝트에 복사
2. `expo-notifications`와 `expo-av` 설치
3. `app.json`에 권한 설정 추가
4. Activity 시작 전 `ensurePermissionsForActivity` 사용

## 📱 테스트 방법

### iOS 테스트
1. iOS 시뮬레이터 또는 실제 기기에서 실행
2. 권한 요청 다이얼로그 확인
3. 설정 > 개인정보보호 및 보안 > 알림에서 권한 상태 확인
4. Live Activity가 잠금 화면과 Dynamic Island에 표시되는지 확인

### Android 테스트  
1. Android 에뮬레이터 또는 실제 기기에서 실행
2. 알림 권한 요청 다이얼로그 확인 (Android 13+)
3. 설정 > 앱 > 권한에서 권한 상태 확인
4. 지속적인 알림이 알림 패널에 표시되는지 확인

이 예제를 통해 Live Activity와 권한 관리를 완전히 이해하고 여러분의 앱에 적용할 수 있습니다! 🎉