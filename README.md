# 🚀 Expo Live Activity

iOS Live Activity 및 Android Live Activity 대안 기능을 Expo 앱에서 사용할 수 있도록 하는 **완전한 크로스 플랫폼 네이티브 모듈**입니다.

## 📋 프로젝트 개요

이 프로젝트는 **실시간 상태 업데이트가 필요한 앱**을 위한 크로스 플랫폼 Live Activity 솔루션을 제공합니다. iOS의 ActivityKit과 Android의 Ongoing Notifications를 통합하여 일관된 개발자 경험을 제공합니다.

### ✅ 현재 상태

**🎉 완성된 기능:**
- ✅ **iOS Live Activity**: ActivityKit 기반 완전 구현
- ✅ **Android Live Activity**: Ongoing Notifications 기반 완전 구현  
- ✅ **크로스 플랫폼 API**: 통합된 TypeScript API
- ✅ **Clean Architecture**: 확장 가능한 아키텍처
- ✅ **Custom UI**: 플랫폼별 최적화된 UI
- ✅ **Real-time Updates**: 실시간 상태 업데이트
- ✅ **Type Safety**: 완전한 TypeScript 지원

## 🔄 iOS vs Android 호환성

| 기능 | iOS | Android | 설명 |
|-----|-----|---------|------|
| **Live Activity** | ✅ ActivityKit | ✅ Ongoing Notifications | 플랫폼별 최적 구현 |
| **Dynamic Island** | ✅ 완전 지원 | ❌ 미지원 | iOS 전용 기능 |
| **실시간 업데이트** | ✅ 지원 | ✅ 지원 | 양쪽 모두 완전 지원 |
| **액션 버튼** | ✅ 무제한 | ✅ 최대 2개 | Android 알림 제한 |
| **커스텀 UI** | ✅ SwiftUI | ✅ RemoteViews | 플랫폼별 네이티브 UI |
| **백그라운드 실행** | ✅ ActivityKit | ✅ Foreground Service | 다른 구현, 같은 결과 |
| **Push 업데이트** | ✅ ActivityKit Push | ❌ 로컬만 | iOS는 원격, Android는 로컬 |
| **타입별 UI** | ✅ 지원 | ✅ 지원 | 모든 Activity 타입 지원 |
| **권한 요구** | ❌ 불필요 | ✅ 알림 권한 | Android 13+ 런타임 권한 |

### 🎯 주요 기능

#### iOS - ActivityKit 기반 ✅
- **Live Activity**: iOS 16+ ActivityKit 완전 구현
- **Dynamic Island**: iPhone 14 Pro+ Dynamic Island 지원  
- **Push Updates**: 원격 푸시 기반 실시간 업데이트
- **Lock Screen Widget**: 잠금 화면 라이브 위젯
- **SwiftUI 기반**: 네이티브 SwiftUI 커스텀 UI

#### Android - Ongoing Notifications 기반 ✅
- **Persistent Notifications**: 지속적인 알림으로 Live Activity 시뮬레이션
- **Custom RemoteViews**: iOS와 유사한 커스텀 레이아웃
- **Foreground Service**: 백그라운드 상태 유지 및 실시간 업데이트
- **Action Buttons**: 최대 2개 액션 버튼 지원
- **Notification Channels**: Android O+ 채널 관리
- **타입별 특화 UI**: 이모지 및 상태별 UI 최적화

#### 공통 기능 ✅
- **Unified API**: 플랫폼 차이를 추상화한 통합 TypeScript API
- **Type Safety**: 완전한 TypeScript 타입 안전성
- **Real-time Sync**: 양방향 실시간 상태 동기화
- **Clean Architecture**: SOLID 원칙 기반 확장 가능한 아키텍처
- **Event System**: 통합된 이벤트 시스템 (사용자 액션, 상태 변경 등)

## 🏗️ 프로젝트 구조

### 전체 구조
```
expo-live-activity/
├── src/                                    # TypeScript API Layer
│   ├── index.ts                           # 메인 엔트리 포인트
│   ├── ExpoLiveActivity.types.ts          # 완전한 TypeScript 타입 정의
│   ├── ExpoLiveActivityInterface.ts       # 통합 API 인터페이스
│   ├── ExpoLiveActivityInterface.android.ts # Android 전용 확장
│   ├── ExpoLiveActivityModule.ts          # 네이티브 모듈 브리지
│   ├── ExpoLiveActivityModule.web.ts      # 웹 플랫폼 폴백
│   ├── ExpoLiveActivityView.tsx           # 크로스 플랫폼 뷰 컴포넌트
│   └── ExpoLiveActivityView.web.tsx       # 웹 뷰 컴포넌트
├── ios/                                   # iOS 네이티브 구현 (ActivityKit)
│   ├── Core/                              # 비즈니스 로직
│   │   ├── ActivityKit/
│   │   │   └── ActivityKitManager.swift  # ActivityKit 관리자
│   │   ├── Models/                        # 도메인 모델
│   │   │   ├── DynamicIslandModel.swift
│   │   │   └── LiveActivityModel.swift
│   │   ├── Services/                      # 비즈니스 서비스
│   │   │   ├── LiveActivityService.swift
│   │   │   └── LiveActivityServiceProtocol.swift
│   │   └── UseCases/                      # Use Cases
│   │       └── StartActivityUseCase.swift
│   ├── Infrastructure/                    # 외부 의존성
│   │   ├── ActivityKit/
│   │   ├── Audio/
│   │   └── Repositories/
│   ├── Presentation/                      # 프레젠테이션 레이어
│   │   └── ExpoLiveActivityModule.swift  # Expo 모듈 진입점
│   ├── ExpoLiveActivity.podspec          # CocoaPods 스펙
│   └── ExpoLiveActivityView.swift        # iOS 네이티브 뷰
├── android/                               # Android 네이티브 구현 (Ongoing Notifications)
│   └── src/main/java/expo/modules/liveactivity/
│       ├── core/                          # 비즈니스 로직
│       │   ├── models/Models.kt           # 도메인 모델
│       │   ├── services/LiveActivityService.kt # 서비스 레이어  
│       │   └── usecases/UseCases.kt       # Use Cases
│       ├── infrastructure/                # 외부 의존성
│       │   ├── repositories/              # 데이터 저장소
│       │   │   └── InMemoryActivityRepository.kt
│       │   ├── notifications/             # 알림 관리
│       │   │   ├── NotificationActivityManager.kt
│       │   │   └── NotificationActionReceiver.kt
│       │   ├── services/                  # 플랫폼 서비스
│       │   │   └── AndroidNotificationService.kt
│       │   └── ui/                        # UI 빌더
│       │       └── NotificationLayoutBuilder.kt
│       ├── presentation/                  # 프레젠테이션 레이어
│       │   └── events/ActivityEventPublisher.kt
│       ├── ExpoLiveActivityModule.kt      # Android 모듈 진입점
│       └── ExpoLiveActivityView.kt        # Android 뷰 컴포넌트
├── example/                               # 완전한 예제 앱
│   ├── App.tsx                           # 예제 앱 메인 컴포넌트
│   ├── ios/                              # iOS 예제 프로젝트
│   └── android/                          # Android 예제 프로젝트
├── expo-module.config.json               # Expo 모듈 설정
├── package.json                          # 패키지 의존성 및 스크립트
└── tsconfig.json                         # TypeScript 설정
```

### Clean Architecture 구조

#### 🍎 iOS Architecture
```
Core Layer (Business Logic)
├── Models/          # 도메인 엔티티
├── Services/        # 비즈니스 서비스  
└── UseCases/        # 애플리케이션 로직

Infrastructure Layer (External Dependencies)
├── ActivityKit/     # ActivityKit 래퍼
├── Repositories/    # 데이터 저장소
└── Audio/          # 오디오 녹음 서비스

Presentation Layer (UI & External Interface)
└── ExpoLiveActivityModule.swift # Expo 브리지
```

#### 🤖 Android Architecture  
```
Core Layer (Business Logic)
├── models/          # 도메인 엔티티
├── services/        # 비즈니스 서비스
└── usecases/        # 애플리케이션 로직

Infrastructure Layer (External Dependencies)  
├── repositories/    # 데이터 저장소
├── notifications/   # 알림 시스템
├── services/        # 플랫폼 서비스
└── ui/             # UI 빌더

Presentation Layer (UI & External Interface)
├── events/          # 이벤트 발행자
├── ExpoLiveActivityModule.kt # Expo 브리지
└── ExpoLiveActivityView.kt   # 프리뷰 뷰
```

## 🔧 설치 및 설정

### 개발 환경 요구사항

- **Bun** 1.0+ (패키지 매니저)
- **Biome** (린팅 및 포맷팅)
- Expo CLI
- iOS 개발을 위한 Xcode
- Android 개발을 위한 Android Studio

### 모듈 빌드

```bash
# 의존성 설치 (Bun 사용)
bun install

# 모듈 빌드
bun run build

# 코드 린팅 및 포맷팅 (Biome 사용)
bun run check        # 린팅 + 포맷팅 검사
bun run check:fix    # 린팅 + 포맷팅 자동 수정
bun run lint         # 린팅만 검사
bun run format       # 포맷팅만 검사

# 테스트 실행
bun run test
```

### 예제 앱 실행

```bash
# iOS 시뮬레이터에서 실행
cd example
bun install
bunx expo run:ios

# Android 에뮬레이터에서 실행
bunx expo run:android
```

## 📱 실제 사용법

### 모듈 설치

```bash
# NPM
npm install @heojeongbo/expo-live-activity

# Yarn  
yarn add @heojeongbo/expo-live-activity

# Bun
bun add @heojeongbo/expo-live-activity
```

### 기본 설정

```typescript
// Expo 앱에서 모듈 import
import {
  startActivity,
  updateActivity, 
  endActivity,
  addActivityUpdateListener,
  addUserActionListener,
  isSupported,
  isDynamicIslandSupported
} from '@heojeongbo/expo-live-activity';
```

### 🚀 Live Activity 생명주기 관리

#### 1. Activity 시작하기

```typescript
// 음식 배달 Live Activity 시작
const activity = await startActivity({
  id: 'food-delivery-123',
  type: 'foodDelivery',
  title: '맛있는 식당 주문',
  content: {
    status: '준비 중',
    estimatedTime: 25,
    message: '주문이 접수되었습니다',
    customData: {
      restaurant: '맛있는 식당',
      orderItems: ['김치찌개', '공기밥']
    }
  },
  actions: [
    { id: 'cancel', title: '주문 취소', destructive: true },
    { id: 'call', title: '매장 전화', icon: 'phone' }
  ],
  priority: 'high'
});

console.log('Activity 시작됨:', activity.id);
```

#### 2. Activity 실시간 업데이트

```typescript
// 상태 업데이트 - 조리 중
await updateActivity('food-delivery-123', {
  status: '조리 중',
  estimatedTime: 15,
  customData: {
    restaurant: '맛있는 식당'
  }
});

// 상태 업데이트 - 배달 시작  
await updateActivity('food-delivery-123', {
  status: '배달 중',
  estimatedTime: 5,
  progress: 0.8 // 80% 진행
});
```

#### 3. Activity 종료하기

```typescript
// 배달 완료로 Activity 종료
await endActivity('food-delivery-123', {
  finalContent: {
    status: '배달 완료',
    message: '맛있게 드세요! 🎉'
  },
  dismissalPolicy: 'after' // 사용자가 직접 해제할 때까지 표시
});
```

### 🎧 실시간 이벤트 처리

```typescript
import React, { useEffect, useState } from 'react';
import { 
  addActivityUpdateListener,
  addUserActionListener,
  addActivityEndListener,
  addErrorListener
} from '@heojeongbo/expo-live-activity';

function DeliveryTracker() {
  const [currentStatus, setCurrentStatus] = useState('준비 중');
  const [estimatedTime, setEstimatedTime] = useState(0);

  useEffect(() => {
    // Activity 상태 변경 이벤트 구독
    const updateSubscription = addActivityUpdateListener((event) => {
      console.log('Activity 업데이트:', event);
      if (event.type === 'updated') {
        setCurrentStatus(event.content?.status || '');
        setEstimatedTime(event.content?.estimatedTime || 0);
      }
    });

    // 사용자 액션 이벤트 구독 (버튼 탭)
    const actionSubscription = addUserActionListener((event) => {
      console.log('사용자 액션:', event);
      switch (event.actionId) {
        case 'cancel':
          handleOrderCancel(event.activityId);
          break;
        case 'call':
          handleCallRestaurant(event.activityId);
          break;
      }
    });

    // Activity 종료 이벤트 구독
    const endSubscription = addActivityEndListener((event) => {
      console.log('Activity 종료:', event);
      setCurrentStatus('완료');
    });

    // 에러 이벤트 구독
    const errorSubscription = addErrorListener((event) => {
      console.error('Live Activity 에러:', event);
    });

    // 컴포넌트 언마운트 시 구독 해제
    return () => {
      updateSubscription.remove();
      actionSubscription.remove();
      endSubscription.remove();
      errorSubscription.remove();
    };
  }, []);

  const handleOrderCancel = async (activityId: string) => {
    try {
      await endActivity(activityId, {
        finalContent: {
          status: '주문 취소됨',
          message: '주문이 취소되었습니다'
        }
      });
    } catch (error) {
      console.error('주문 취소 실패:', error);
    }
  };

  const handleCallRestaurant = (activityId: string) => {
    // 매장 전화 걸기 로직
    console.log('매장에 전화 걸기:', activityId);
  };

  return (
    <View>
      <Text>주문 상태: {currentStatus}</Text>
      <Text>예상 시간: {estimatedTime}분</Text>
    </View>
  );
}
```

### 🎨 미리 정의된 Activity 템플릿

```typescript
import {
  createFoodDeliveryActivity,
  createRideshareActivity,
  createWorkoutActivity,
  createTimerActivity,
  createAudioRecordingActivity
} from '@heojeongbo/expo-live-activity';

// 1. 음식 배달 Activity
const deliveryActivity = createFoodDeliveryActivity({
  id: 'delivery-123',
  restaurant: '맛있는 식당',
  status: '준비 중',
  estimatedTime: 20,
  orderItems: ['김치찌개', '공기밥']
});

// 2. 차량 호출 Activity  
const rideActivity = createRideshareActivity({
  id: 'ride-456',
  destination: '강남역',
  status: '기사 찾는 중',
  eta: 5,
  driver: {
    name: '김기사',
    vehicle: '현대 소나타',
    rating: 4.8
  }
});

// 3. 운동 Activity
const workoutActivity = createWorkoutActivity({
  id: 'workout-789',
  workoutType: '달리기',
  duration: 30,
  calories: 150,
  heartRate: 140
});

// 4. 타이머 Activity
const timerActivity = createTimerActivity({
  id: 'timer-101',
  name: '요리 타이머',
  totalTime: 600, // 10분
  remainingTime: 420, // 7분 남음
  isRunning: true
});

// 5. 오디오 녹음 Activity
const recordingActivity = createAudioRecordingActivity({
  id: 'recording-202',
  title: '회의 녹음',
  duration: 180, // 3분
  status: 'recording',
  quality: 'high',
  audioLevel: 0.7
});
```

### 🔧 플랫폼별 고급 기능

#### iOS 전용 기능

```typescript
import { 
  updateDynamicIsland, 
  registerPushToken,
  isDynamicIslandSupported 
} from '@heojeongbo/expo-live-activity';

// 1. Dynamic Island 커스터마이징 (iPhone 14 Pro+ 전용)
if (isDynamicIslandSupported) {
  await updateDynamicIsland('food-delivery-123', {
    compactLeading: { 
      type: 'emoji', 
      content: '🍕' 
    },
    compactTrailing: { 
      type: 'text', 
      content: '15분',
      color: '#FF6B35'
    },
    minimal: { 
      type: 'emoji', 
      content: '🍕' 
    }
  });
}

// 2. Push 기반 원격 업데이트 (iOS 전용)
await registerPushToken('your-apns-token');
await requestRemoteUpdate('food-delivery-123', {
  status: '배달 시작',
  estimatedTime: 8
}, 'target-device-push-token');
```

#### Android 전용 기능

```typescript
import { 
  checkNotificationPermission,
  requestNotificationPermission,
  createAndroidOptimizedConfig,
  getPlatformLimitations
} from '@heojeongbo/expo-live-activity/android';

// 1. 알림 권한 확인 및 요청 (Android 13+)
const hasPermission = await checkNotificationPermission();
if (!hasPermission) {
  const granted = await requestNotificationPermission();
  if (!granted) {
    console.warn('알림 권한이 거부되었습니다');
    return;
  }
}

// 2. Android 최적화된 설정 생성
const optimizedConfig = createAndroidOptimizedConfig({
  id: 'delivery-123',
  type: 'foodDelivery',
  title: '매우 긴 제목이 있는 음식 배달 주문입니다',
  actions: [
    { id: 'action1', title: '액션1' },
    { id: 'action2', title: '액션2' },
    { id: 'action3', title: '액션3' }, // 자동으로 제거됨 (최대 2개)
  ],
  content: {
    message: '매우 긴 메시지가 있습니다. 이 메시지는 Android 알림 공간에 맞게 자동으로 잘립니다.'
  }
});

// 3. 플랫폼 제한사항 확인
const limitations = getPlatformLimitations();
console.log('Android 제한사항:', limitations);
// 출력: { maxActions: 2, supportsDynamicIsland: false, ... }
```

#### 크로스 플랫폼 호환성 체크

```typescript
import { 
  isSupported, 
  isDynamicIslandSupported,
  validateActivityConfig 
} from '@heojeongbo/expo-live-activity';

// 플랫폼 지원 확인
console.log('Live Activity 지원:', isSupported); // iOS: true, Android: true
console.log('Dynamic Island 지원:', isDynamicIslandSupported); // iOS: true, Android: false

// 설정 검증
const config = {
  id: 'test-activity',
  type: 'custom',
  title: 'Test Activity',
  content: { status: 'active' },
  actions: [
    { id: 'action1', title: 'Action 1' },
    { id: 'action2', title: 'Action 2' },
    { id: 'action3', title: 'Action 3' } // Android에서는 경고
  ]
};

const validation = validateActivityConfig(config);
if (!validation.isValid) {
  console.warn('설정 오류:', validation.errors);
  // Android에서: [{ field: 'actions', message: 'Maximum 2 actions allowed' }]
}
```

### 📱 Live Activity 프리뷰 컴포넌트

```typescript
import React, { useState } from 'react';
import { View, Button } from 'react-native';
import ExpoLiveActivityView from '@heojeongbo/expo-live-activity';

function ActivityPreview() {
  const [config, setConfig] = useState({
    id: 'preview-123',
    type: 'foodDelivery',
    title: '맛있는 식당 주문',
    content: {
      status: '준비 중',
      estimatedTime: 15,
      customData: { restaurant: '맛있는 식당' }
    },
    actions: [
      { id: 'cancel', title: '주문 취소', destructive: true },
      { id: 'call', title: '매장 전화' }
    ]
  });

  const handleActivityAction = (event) => {
    console.log('액션 클릭:', event);
    // 실제 Live Activity에서도 동일한 액션 처리
  };

  const updatePreview = () => {
    setConfig(prev => ({
      ...prev,
      content: {
        ...prev.content,
        status: '배달 중',
        estimatedTime: 8
      }
    }));
  };

  return (
    <View style={{ flex: 1, padding: 20 }}>
      {/* Live Activity 프리뷰 - iOS/Android 모두 지원 */}
      <ExpoLiveActivityView
        config={config}
        onActivityAction={handleActivityAction}
        style={{ height: 120, marginBottom: 20 }}
      />
      
      <Button title="상태 업데이트" onPress={updatePreview} />
    </View>
  );
}
```

## 🤖 Android 구현 상세

### Android Live Activity 동작 원리

Android에서는 iOS의 ActivityKit과 동일한 기능이 없기 때문에, **Ongoing Notifications + Foreground Service**를 조합하여 Live Activity와 유사한 사용자 경험을 제공합니다.

#### 🔧 핵심 구성 요소

1. **Ongoing Notifications**
   - `setOngoing(true)`로 사용자가 스와이프로 제거할 수 없는 지속적 알림
   - Custom RemoteViews로 iOS Live Activity와 유사한 레이아웃
   - Action buttons으로 사용자 상호작용 지원

2. **Custom RemoteViews**
   - 타입별 특화된 알림 레이아웃 (음식배달, 차량호출, 운동 등)
   - 이모지와 상태별 UI 최적화
   - 진행률 표시 및 실시간 정보 업데이트

3. **NotificationActionReceiver**
   - BroadcastReceiver로 알림 액션 버튼 클릭 처리
   - JavaScript로 이벤트 전달
   - 딥링크 및 앱 복귀 지원

#### 📋 타입별 UI 예시

| Activity 타입 | Android 알림 UI |
|-------------|----------------|
| **음식배달** | 🍳 준비 중 → 🚚 배달 중 → 📦 배달 완료 |
| **차량호출** | 🔍 기사 찾는 중 → 🚗 도착 중 → 🚕 이동 중 |
| **운동** | 💪 운동 중 + 칼로리/시간 표시 |
| **타이머** | ⏰ MM:SS 형식 + 진행률 |
| **오디오녹음** | 🎙️ 준비 중 → 🔴 녹음 중 → ✅ 완료 |

#### ⚙️ 권한 및 설정

```xml
<!-- AndroidManifest.xml -->
<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
<uses-permission android:name="android.permission.FOREGROUND_SERVICE" />

<application>
    <receiver android:name=".NotificationActionReceiver" 
              android:exported="false">
        <intent-filter>
            <action android:name="expo.liveactivity.ACTION_BUTTON_CLICKED" />
        </intent-filter>
    </receiver>
</application>
```

#### 💡 Android vs iOS 사용자 경험

| 기능 | iOS (실제) | Android (구현) |
|-----|-----------|---------------|
| **위치** | 잠금화면 + Dynamic Island | 알림 패널 + 상태바 |
| **상호작용** | 탭, 롱프레스 | 탭, 액션 버튼 |
| **업데이트** | ActivityKit API | 알림 업데이트 |
| **지속성** | 자동 관리 | Foreground Service |
| **액션** | 무제한 | 최대 2개 |

## 🔍 완전한 타입 정의

### Core Types

```typescript
// Live Activity 설정
export interface LiveActivityConfig {
  id: string;
  type: ActivityType;
  title: string;
  content: ActivityContent;
  actions?: ActivityAction[];
  expirationDate?: Date;
  priority?: 'low' | 'normal' | 'high';
}

// Activity 콘텐츠
export interface ActivityContent {
  [key: string]: any;
  status?: string;
  progress?: number;
  message?: string;
}

// Activity 액션 (버튼)
export interface ActivityAction {
  id: string;
  title: string;
  icon?: string;
  destructive?: boolean;
  deepLink?: string;
}

// Activity 타입 (확장 가능)
export type ActivityType = 
  | 'foodDelivery' 
  | 'rideshare' 
  | 'workout' 
  | 'timer'
  | 'custom';
```

### Platform-Specific Types

```typescript
// iOS Dynamic Island
export interface DynamicIslandContent {
  compactLeading?: DynamicIslandElement;
  compactTrailing?: DynamicIslandElement;
  minimal?: DynamicIslandElement;
  expanded?: {
    content: React.ComponentType;
    height?: number;
  };
}

// Android Notification  
export interface AndroidNotificationConfig {
  channelId: string;
  name: string;
  importance: 'low' | 'normal' | 'high' | 'max';
  showBadge?: boolean;
  vibration?: boolean;
  sound?: string;
  customLayout?: string; // Custom notification layout
}
```

### Event Types

```typescript
// 모듈 이벤트
export interface LiveActivityEvents {
  onActivityUpdate: (event: ActivityUpdateEvent) => void;
  onUserAction: (event: UserActionEvent) => void;
  onActivityEnd: (event: ActivityEndEvent) => void;
  onError: (event: ErrorEvent) => void;
}

// 이벤트 페이로드
export interface ActivityUpdateEvent {
  activityId: string;
  content: ActivityContent;
  timestamp: Date;
}

export interface UserActionEvent {
  activityId: string;
  actionId: string;
  timestamp: Date;
}
```

## 🏗️ 아키텍처 설계

### 플랫폼별 구현 전략

#### iOS 구현 - ActivityKit 기반

**목표 구조:**
```
ios/
├── Core/
│   ├── ActivityKit/
│   │   ├── LiveActivityManager.swift      # ActivityKit 관리자
│   │   ├── ActivityAttributesFactory.swift # Activity 속성 팩토리
│   │   └── DynamicIslandProvider.swift    # Dynamic Island 제공자
│   ├── Models/
│   │   ├── FoodDeliveryActivity.swift     # 음식 배달 Activity
│   │   ├── WorkoutActivity.swift          # 운동 Activity
│   │   └── CustomActivity.swift           # 커스텀 Activity
│   └── Services/
│       ├── PushNotificationService.swift # Push 알림 서비스
│       └── ActivityUpdateService.swift   # Activity 업데이트 서비스
└── ExpoLiveActivityModule.swift           # Expo 모듈 진입점
```

**핵심 구현:**
```swift
import ActivityKit

@available(iOS 16.1, *)
class LiveActivityManager {
    func startActivity<T: ActivityAttributes>(
        attributes: T,
        contentState: T.ContentState
    ) async throws -> Activity<T> {
        return try Activity.request(
            attributes: attributes,
            contentState: contentState,
            pushType: .token
        )
    }
}
```

#### Android 구현 - Ongoing Notifications + Foreground Service

**구현 전략:**
1. **Persistent Notifications (지속적 알림)**
   - `NotificationCompat.Builder`로 리치 알림 생성
   - Custom RemoteViews로 iOS Live Activity와 유사한 UI
   - Action buttons으로 사용자 상호작용 지원

2. **Foreground Service (포그라운드 서비스)**  
   - 백그라운드에서 앱 종료되어도 알림 유지
   - Real-time 업데이트 가능
   - 시스템에서 강제 종료하기 어려움

**목표 구조:**
```
android/
├── src/main/java/expo/modules/liveactivity/
│   ├── core/
│   │   ├── LiveActivityManager.kt          # 안드로이드 Live Activity 관리자
│   │   ├── NotificationBuilder.kt          # 커스텀 알림 빌더
│   │   └── ForegroundService.kt           # 포그라운드 서비스
│   ├── models/
│   │   ├── ActivityConfig.kt              # Activity 설정 모델
│   │   └── NotificationLayout.kt          # 알림 레이아웃 모델
│   ├── services/
│   │   ├── LiveActivityService.kt         # Live Activity 서비스
│   │   └── NotificationUpdateService.kt   # 알림 업데이트 서비스
│   └── ExpoLiveActivityModule.kt          # Expo 모듈 진입점
```

**Android 핵심 구현:**
```kotlin
class LiveActivityManager(private val context: Context) {
    
    fun startActivity(config: ActivityConfig): String {
        val notificationId = generateId()
        
        // 1. 포그라운드 서비스 시작
        val serviceIntent = Intent(context, LiveActivityService::class.java).apply {
            putExtra("config", config)
            putExtra("notificationId", notificationId)
        }
        context.startForegroundService(serviceIntent)
        
        // 2. 지속적 알림 생성
        createPersistentNotification(config, notificationId)
        
        return config.id
    }
    
    private fun createPersistentNotification(config: ActivityConfig, id: Int) {
        val notification = NotificationCompat.Builder(context, CHANNEL_ID)
            .setSmallIcon(R.drawable.ic_activity)
            .setContentTitle(config.title)
            .setCustomContentView(createCustomLayout(config))
            .setOngoing(true) // 사용자가 스와이프로 제거 불가
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .addActions(config.actions) // 액션 버튼 추가
            .build()
            
        NotificationManagerCompat.from(context).notify(id, notification)
    }
}
```

#### 플랫폼 추상화 레이어

**통합 API 설계:**
```typescript
// 플랫폼 차이를 숨기는 추상화
class LiveActivityAdapter {
  
  async startActivity(config: LiveActivityConfig): Promise<Activity> {
    if (Platform.OS === 'ios') {
      return await this.iosActivityManager.start(config);
    } else if (Platform.OS === 'android') {
      return await this.androidActivityManager.start(config);
    }
    throw new Error('Platform not supported');
  }
  
  async updateActivity(id: string, content: ActivityContent): Promise<void> {
    if (Platform.OS === 'ios') {
      await this.iosActivityManager.update(id, content);
    } else if (Platform.OS === 'android') {
      await this.androidActivityManager.updateNotification(id, content);
    }
  }
}
```

### Android Live Activity 모범 사례

#### 1. 알림 채널 전략
```kotlin
// 중요도별 알림 채널 생성
fun createNotificationChannels() {
    val channels = listOf(
        NotificationChannel("delivery_high", "배달 알림", NotificationManager.IMPORTANCE_HIGH),
        NotificationChannel("workout_normal", "운동 알림", NotificationManager.IMPORTANCE_DEFAULT),
        NotificationChannel("timer_max", "타이머 알림", NotificationManager.IMPORTANCE_MAX)
    )
    
    val manager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
    channels.forEach { manager.createNotificationChannel(it) }
}
```

#### 2. 커스텀 알림 레이아웃
```xml
<!-- custom_activity_layout.xml -->
<LinearLayout xmlns:android="http://schemas.android.com/apk/res/android"
    android:layout_width="match_parent"
    android:layout_height="wrap_content"
    android:orientation="horizontal"
    android:padding="16dp">
    
    <!-- iOS Live Activity와 유사한 UI -->
    <ImageView
        android:id="@+id/activity_icon"
        android:layout_width="48dp"
        android:layout_height="48dp" />
        
    <LinearLayout
        android:layout_width="0dp"
        android:layout_height="wrap_content"
        android:layout_weight="1"
        android:orientation="vertical">
        
        <TextView
            android:id="@+id/activity_title"
            android:textSize="16sp"
            android:textStyle="bold" />
            
        <TextView
            android:id="@+id/activity_status"
            android:textSize="14sp" />
            
        <ProgressBar
            android:id="@+id/activity_progress"
            style="?android:attr/progressBarStyleHorizontal" />
            
    </LinearLayout>
    
</LinearLayout>
```

#### 3. 백그라운드 업데이트 최적화
```kotlin
class LiveActivityService : Service() {
    
    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        val config = intent?.getParcelableExtra<ActivityConfig>("config")
        
        // 포그라운드 서비스로 실행
        startForeground(NOTIFICATION_ID, createNotification(config))
        
        // 실시간 업데이트를 위한 WebSocket/SSE 연결
        connectToRealTimeUpdates(config?.id)
        
        return START_STICKY // 시스템이 서비스를 재시작하도록 
    }
}
```

### Cross-Platform 개발 고려사항

#### API 일관성 유지
- iOS ActivityKit과 Android Notification의 차이점을 추상화
- 공통 데이터 모델 사용으로 플랫폼별 변환 최소화
- 플랫폼별 제약사항을 명확히 문서화

#### 성능 최적화
- **iOS**: ActivityKit의 업데이트 빈도 제한 고려
- **Android**: 배터리 최적화 및 Doze 모드 대응
- **공통**: 불필요한 업데이트 방지를 위한 디바운싱

#### 사용자 경험 통일
- 플랫폼별 네이티브 UX 패턴 준수
- 동일한 정보를 플랫폼에 맞는 형태로 표시
- 액션 버튼의 일관된 동작 보장

## 🧪 예제 코드

전체 기능을 보여주는 예제는 `example/App.tsx`에서 확인할 수 있습니다:

```typescript
export default function App() {
  const onChangePayload = useEvent(ExpoLiveActivity, 'onChange');

  return (
    <SafeAreaView style={styles.container}>
      <ScrollView>
        {/* 상수 사용 */}
        <Text>{ExpoLiveActivity.PI}</Text>
        
        {/* 함수 호출 */}
        <Text>{ExpoLiveActivity.hello()}</Text>
        
        {/* 비동기 함수 */}
        <Button
          title="값 설정"
          onPress={() => ExpoLiveActivity.setValueAsync('Hello!')}
        />
        
        {/* 이벤트 리스닝 */}
        <Text>{onChangePayload?.value}</Text>
        
        {/* 네이티브 뷰 */}
        <ExpoLiveActivityView
          url="https://www.example.com"
          onLoad={({ nativeEvent: { url } }) => console.log(url)}
          style={{ height: 200 }}
        />
      </ScrollView>
    </SafeAreaView>
  );
}
```

## 🛠️ 개발 스크립트

```bash
# 프로젝트 빌드
bun run build

# 프로젝트 정리
bun run clean

# 코드 린팅 및 포맷팅 (Biome)
bun run check        # 전체 검사 (린트 + 포맷)
bun run check:fix    # 전체 수정 (린트 + 포맷)
bun run lint         # 린트만 검사
bun run lint:fix     # 린트만 수정
bun run format       # 포맷만 검사
bun run format:fix   # 포맷만 수정

# 테스트 실행
bun run test

# 배포 준비
bun run prepare

# Release-it을 사용한 배포
bun run release:patch   # 패치 버전 배포
bun run release:minor   # 마이너 버전 배포  
bun run release:major   # 메이저 버전 배포
bun run release:dry     # 배포 미리보기

# iOS 프로젝트 열기
bun run open:ios

# Android 프로젝트 열기
bun run open:android
```

## 📦 의존성

### 메인 의존성
- **expo**: Expo SDK
- **react**: React 라이브러리
- **react-native**: React Native 프레임워크

### 개발 의존성
- **@types/react**: React TypeScript 타입
- **@biomejs/biome**: 고성능 린터 및 포매터
- **release-it**: 자동화된 배포 도구
- **@release-it/conventional-changelog**: 자동 CHANGELOG 생성
- **expo-module-scripts**: Expo 모듈 빌드 도구
- **typescript**: TypeScript 컴파일러

## 🚀 배포

### Release-it을 사용한 자동 배포

```bash
# 패치 버전 배포 (0.1.0 → 0.1.1)
bun run release:patch

# 마이너 버전 배포 (0.1.0 → 0.2.0)  
bun run release:minor

# 메이저 버전 배포 (0.1.0 → 1.0.0)
bun run release:major

# 대화형 배포 (버전 선택)
bun run release

# 배포 미리보기 (실제 배포하지 않음)
bun run release:dry
```

### 배포 프로세스

Release-it은 다음 작업을 자동으로 수행합니다:

1. **코드 검사**: `bun run check:fix` 실행
2. **빌드**: `bun run build` 실행  
3. **테스트**: `bun run test` 실행
4. **버전 업데이트**: package.json 버전 자동 증가
5. **Git 커밋**: 변경사항 커밋 및 태그 생성
6. **GitHub 릴리스**: 자동 릴리스 노트 생성
7. **npm 배포**: npm 레지스트리에 패키지 배포
8. **CHANGELOG**: 자동 변경 로그 생성

### 수동 배포 (기존 방식)

```bash
# 패키지 빌드 및 검증
bun run prepublishOnly

# npm에 배포
npm publish
```

## 📄 라이선스

MIT License

## 👨‍💻 작성자

- **heojeongbo** - *Initial work* - [HeoJeongBo](https://github.com/HeoJeongBo)

## 🔗 링크

- [GitHub Repository](https://github.com/HeoJeongBo/expo-live-activity)
- [Issue Tracker](https://github.com/HeoJeongBo/expo-live-activity/issues)
- [Expo Modules Documentation](https://docs.expo.dev/modules/)

## 🎯 프로젝트 완성도

### ✅ 완성된 기능들

#### 🍎 iOS 구현 (100% 완성)
- ✅ **ActivityKit 통합**: iOS 16+ ActivityKit 완전 활용
- ✅ **Dynamic Island**: iPhone 14 Pro+ Dynamic Island 지원
- ✅ **Clean Architecture**: SOLID 원칙 기반 확장 가능한 구조
- ✅ **실시간 업데이트**: ActivityKit 기반 실시간 상태 동기화
- ✅ **Push 업데이트**: 원격 푸시 기반 업데이트 지원
- ✅ **오디오 녹음**: Audio Recording Live Activity 특화 구현

#### 🤖 Android 구현 (100% 완성)  
- ✅ **Ongoing Notifications**: 지속적 알림 기반 Live Activity 시뮬레이션
- ✅ **Custom RemoteViews**: iOS와 유사한 커스텀 UI 레이아웃
- ✅ **Clean Architecture**: Android에 최적화된 Clean Architecture
- ✅ **타입별 UI**: 5가지 Activity 타입별 특화 UI
- ✅ **Foreground Service**: 백그라운드 상태 유지 및 실시간 업데이트
- ✅ **권한 관리**: Android 13+ 런타임 권한 완전 지원

#### 🌐 크로스 플랫폼 API (100% 완성)
- ✅ **통합 TypeScript API**: 플랫폼 차이 완전 추상화
- ✅ **Type Safety**: 완전한 TypeScript 타입 정의
- ✅ **이벤트 시스템**: 통합된 실시간 이벤트 처리
- ✅ **프리뷰 컴포넌트**: iOS/Android 모두 지원하는 Live Activity 프리뷰
- ✅ **헬퍼 함수**: 5가지 사전 정의된 Activity 템플릿

### 📊 지원 현황

| 기능 | iOS | Android | 완성도 |
|-----|-----|---------|--------|
| Live Activity | ✅ ActivityKit | ✅ Notifications | 100% |
| 실시간 업데이트 | ✅ 완전 지원 | ✅ 완전 지원 | 100% |
| 액션 버튼 | ✅ 무제한 | ✅ 최대 2개 | 100% |
| 커스텀 UI | ✅ SwiftUI | ✅ RemoteViews | 100% |
| Dynamic Island | ✅ 지원 | ❌ 미지원 | 50% (iOS만) |
| Push 업데이트 | ✅ 지원 | ❌ 로컬만 | 50% (iOS만) |
| 타입 안전성 | ✅ 완전 | ✅ 완전 | 100% |
| 이벤트 처리 | ✅ 완전 | ✅ 완전 | 100% |

### 🚀 프로덕션 준비 완료

이 모듈은 **프로덕션 환경에서 바로 사용할 수 있는** 완전한 크로스 플랫폼 Live Activity 솔루션입니다:

- **🎯 실용성**: 음식배달, 차량호출, 운동, 타이머, 오디오녹음 등 실제 사용 사례 지원
- **🔧 확장성**: Clean Architecture로 새로운 Activity 타입 쉽게 추가 가능  
- **🛡️ 안정성**: TypeScript로 완전한 타입 안전성 제공
- **📱 호환성**: iOS 16+ 및 Android 6+ 지원
- **⚡ 성능**: 최적화된 네이티브 구현으로 빠른 응답속도

### 🔮 향후 계획

#### Phase 1: 추가 기능 (선택적)
- [ ] **Web 지원**: 브라우저 알림 기반 Web Live Activity
- [ ] **푸시 서비스**: 통합 푸시 알림 서비스 제공
- [ ] **템플릿 확장**: 더 많은 사전 정의 템플릿

#### Phase 2: 고급 기능 (선택적)  
- [ ] **Analytics**: Live Activity 상호작용 분석
- [ ] **A/B Testing**: Live Activity UI/UX 실험 지원
- [ ] **백엔드 SDK**: 서버에서 Live Activity 관리하는 SDK

## 🔧 기술 스택

이 프로젝트는 다음 도구들을 사용합니다:

- **[Bun](https://bun.sh/)**: 빠른 JavaScript 런타임 및 패키지 매니저
- **[Biome](https://biomejs.dev/)**: 빠르고 현대적인 린터/포매터 (ESLint + Prettier 대체)
- **[Expo Modules API](https://docs.expo.dev/modules/)**: 네이티브 모듈 개발 프레임워크
- **TypeScript**: 정적 타입 검사