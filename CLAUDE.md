# CLAUDE.md - AI 컨텍스트 문서

## 프로젝트 개요

이 프로젝트는 **iOS Live Activity 기능을 Expo 앱에서 사용할 수 있도록 하는 네이티브 모듈**입니다. 현재는 Expo 모듈의 기본 구조를 제공하며, 최종 목표는 ActivityKit을 활용한 완전한 Live Activity 구현입니다.

### 핵심 정보
- **패키지명**: `@heojeongbo/expo-live-activity`
- **버전**: 0.2.0
- **현재 상태**: Expo 네이티브 모듈 기본 프로젝트 (스캐폴딩 단계)
- **최종 목표**: iOS Live Activity & Dynamic Island 완전 구현
- **주요 플랫폼**: iOS (주), Android (미래), Web (폴백)
- **개발 스택**: TypeScript, Swift, Bun, Biome

## 개발 방향성 및 목표

### 🎯 최종 목표: Complete Live Activity Implementation

**Phase 1: ActivityKit Integration (우선순위 높음)**
- iOS ActivityKit 프레임워크 통합
- Live Activity 생성/시작/업데이트/종료 API
- Dynamic Island 상태 업데이트
- 푸시 알림 기반 원격 업데이트

**Phase 2: Android Live Activity 대안 구현**
- Ongoing Notifications + Foreground Service 기반 구현
- Custom RemoteViews로 iOS와 유사한 UI 제공
- 백그라운드 실시간 업데이트 지원
- 알림 채널 및 우선순위 관리

**Phase 3: Cross-Platform Integration**
- 통합 API로 플랫폼 차이 추상화
- 커스텀 Live Activity UI 템플릿
- 실시간 데이터 동기화
- 배터리 효율성 최적화

### 📱 Live Activity 사용 사례
```typescript
// 목표 API 설계 예시
await ExpoLiveActivity.startActivity({
  id: 'food-delivery-123',
  title: '음식 배달',
  content: {
    status: '준비 중',
    estimatedTime: '15분',
    restaurant: '맛있는 식당'
  },
  buttons: [
    { title: '주문 취소', action: 'cancel' },
    { title: '매장 전화', action: 'call' }
  ]
});

await ExpoLiveActivity.updateActivity('food-delivery-123', {
  status: '배달 중',
  estimatedTime: '5분'
});
```

## Clean Code 원칙 및 아키텍처

### 🏗️ 아키텍처 원칙

**1. Single Responsibility Principle (SRP)**
- 각 클래스/모듈은 하나의 책임만 가짐
- `ExpoLiveActivityModule`: Live Activity 관리만
- `ExpoLiveActivityView`: UI 렌더링만
- `LiveActivityManager`: ActivityKit 추상화만

**2. Dependency Inversion Principle (DIP)**
- 고수준 모듈이 저수준 모듈에 의존하지 않음
- Protocol/Interface 기반 설계
```swift
protocol LiveActivityServiceProtocol {
    func startActivity<T: ActivityAttributes>(_ attributes: T) async throws
    func updateActivity<T: ActivityAttributes>(_ attributes: T) async throws
}
```

**3. Open/Closed Principle (OCP)**
- 확장에는 열려있고 수정에는 닫혀있는 설계
- 새로운 Live Activity 타입 추가 시 기존 코드 수정 불필요

### 📂 Clean Architecture 기반 프로젝트 구조

```
expo-live-activity/
├── src/                                    # TypeScript Layer
│   ├── index.ts                           # Public API Entry Point
│   ├── core/                              # Business Logic
│   │   ├── types/                         # Domain Types
│   │   │   ├── LiveActivity.types.ts      # Live Activity Domain Models
│   │   │   ├── DynamicIsland.types.ts     # Dynamic Island Types
│   │   │   └── index.ts                   # Type Exports
│   │   ├── usecases/                      # Use Cases (Business Logic)
│   │   │   ├── StartLiveActivity.ts       # Start Activity Use Case
│   │   │   ├── UpdateLiveActivity.ts      # Update Activity Use Case
│   │   │   └── StopLiveActivity.ts        # Stop Activity Use Case
│   │   └── repositories/                  # Data Access Interfaces
│   │       └── LiveActivityRepository.ts  # Abstract Repository
│   ├── infrastructure/                    # External Dependencies
│   │   ├── native/                        # Native Module Bridge
│   │   │   ├── ExpoLiveActivityModule.ts  # Native Bridge
│   │   │   └── ExpoLiveActivityModule.web.ts # Web Fallback
│   │   └── repositories/                  # Repository Implementations
│   │       └── NativeLiveActivityRepository.ts
│   └── presentation/                      # UI Layer
│       ├── components/                    # React Components
│       │   ├── ExpoLiveActivityView.tsx   # Main View Component
│       │   └── ExpoLiveActivityView.web.tsx # Web View
│       └── hooks/                         # Custom React Hooks
│           └── useLiveActivity.ts         # Live Activity Hook
├── ios/                                   # iOS Native Implementation
│   ├── Core/                              # Business Logic Layer
│   │   ├── Models/                        # Domain Models
│   │   │   ├── LiveActivityModel.swift   # Live Activity Domain Model
│   │   │   └── DynamicIslandModel.swift  # Dynamic Island Model
│   │   ├── Services/                      # Business Services
│   │   │   ├── LiveActivityService.swift # Activity Management
│   │   │   └── DynamicIslandService.swift # Dynamic Island Management
│   │   └── UseCases/                      # iOS Use Cases
│   │       ├── StartActivityUseCase.swift
│   │       ├── UpdateActivityUseCase.swift
│   │       └── StopActivityUseCase.swift
│   ├── Infrastructure/                    # External Dependencies
│   │   ├── ActivityKit/                   # ActivityKit Wrapper
│   │   │   ├── ActivityKitManager.swift  # ActivityKit Abstraction
│   │   │   └── ActivityAttributesFactory.swift
│   │   └── Repositories/                  # Data Layer
│   │       └── ActivityKitRepository.swift
│   ├── Presentation/                      # UI Layer
│   │   ├── ExpoLiveActivityModule.swift  # Expo Module Entry
│   │   ├── ExpoLiveActivityView.swift    # Native View
│   │   └── Extensions/                    # UI Extensions
│   └── ExpoLiveActivity.podspec          # CocoaPods Spec
└── example/                               # Example Implementation
    ├── src/                               # Clean Example Code
    │   ├── components/                    # Reusable Components
    │   ├── screens/                       # Screen Components
    │   └── services/                      # Business Logic
    └── App.tsx                            # Main App
```

### 🧹 Clean Code 규칙

**명명 규칙**
```typescript
// ✅ Good: 의도가 명확한 네이밍
const startLiveActivityForFoodDelivery = () => {};
const updateDeliveryStatus = (status: DeliveryStatus) => {};

// ❌ Bad: 모호한 네이밍  
const start = () => {};
const update = (data: any) => {};
```

**함수 규칙**
```typescript
// ✅ Good: 단일 책임, 작은 함수
const validateActivityId = (id: string): boolean => {
  return id.length > 0 && id.length <= 50;
};

const createActivityAttributes = (config: ActivityConfig): ActivityAttributes => {
  return {
    id: config.id,
    title: config.title,
    content: config.content
  };
};

// ❌ Bad: 여러 책임을 가진 큰 함수
const processActivity = (data: any) => {
  // validation + creation + update logic...
};
```

**에러 처리**
```typescript
// ✅ Good: 명시적 에러 타입
enum LiveActivityError {
  INVALID_ID = 'INVALID_ACTIVITY_ID',
  ALREADY_STARTED = 'ACTIVITY_ALREADY_STARTED',
  NOT_SUPPORTED = 'PLATFORM_NOT_SUPPORTED'
}

// ✅ Good: Result 패턴 사용
type Result<T, E> = { success: true; data: T } | { success: false; error: E };

const startActivity = async (config: ActivityConfig): Promise<Result<Activity, LiveActivityError>> => {
  // implementation
};
```

## 현재 구현 상태

### ✅ 완료된 기본 구조
- [x] Expo 모듈 스캐폴딩
- [x] TypeScript 타입 시스템
- [x] iOS 네이티브 모듈 기본 구조
- [x] WKWebView 기반 예제 뷰
- [x] JavaScript ↔ Swift 브리지
- [x] 크로스 플랫폼 지원 구조

### 🚧 현재 작업 중 (기본 프로젝트)
- [ ] Clean Architecture 리팩토링
- [ ] 도메인 모델 정의
- [ ] Use Case 레이어 구현
- [ ] Repository 패턴 적용

### 📋 다음 우선순위

#### iOS Live Activity 구현
1. **ActivityKit 통합**
   ```swift
   import ActivityKit
   
   // Live Activity 시작
   func startFoodDeliveryActivity() async throws {
       let attributes = FoodDeliveryAttributes(orderId: "123")
       let contentState = FoodDeliveryContentState(status: .preparing)
       let activity = try Activity.request(attributes: attributes, contentState: contentState)
   }
   ```

2. **Dynamic Island 지원**
   ```swift
   // Dynamic Island 컴팩트 뷰
   struct FoodDeliveryDynamicIslandView: View {
       var body: some View {
           HStack {
               Text("🚚")
               Text("5분 남음")
           }
       }
   }
   ```

3. **Push 기반 업데이트**
   ```typescript
   // 원격 업데이트 API
   await ExpoLiveActivity.updateActivityRemotely({
     activityId: 'delivery-123',
     pushToken: 'apns-token',
     content: { status: 'delivered' }
   });
   ```

#### Android Live Activity 대안 구현
1. **Ongoing Notifications 시스템**
   ```kotlin
   class AndroidLiveActivityManager {
       fun createPersistentNotification(config: ActivityConfig) {
           val notification = NotificationCompat.Builder(context, CHANNEL_ID)
               .setOngoing(true)
               .setCustomContentView(createCustomLayout(config))
               .addActions(config.actions)
               .build()
       }
   }
   ```

2. **Foreground Service 통합**
   ```kotlin
   class LiveActivityService : Service() {
       override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
           startForeground(NOTIFICATION_ID, createNotification())
           return START_STICKY
       }
   }
   ```

3. **Custom RemoteViews UI**
   ```kotlin
   private fun createCustomLayout(config: ActivityConfig): RemoteViews {
       return RemoteViews(packageName, R.layout.live_activity_layout).apply {
           setTextViewText(R.id.title, config.title)
           setTextViewText(R.id.status, config.content.status)
           setProgressBar(R.id.progress, 100, config.content.progress, false)
       }
   }
   ```

## 개발 가이드라인

### 🔧 코드 작성 규칙

**1. TypeScript First**
```typescript
// 모든 타입을 명시적으로 정의
interface LiveActivityConfig {
  readonly id: string;
  readonly title: string;
  readonly content: LiveActivityContent;
  readonly expirationDate?: Date;
}
```

**2. Immutable Data Structures**
```typescript
// 불변 객체 사용
const updateActivityContent = (activity: LiveActivity, newContent: Partial<LiveActivityContent>): LiveActivity => {
  return {
    ...activity,
    content: { ...activity.content, ...newContent },
    updatedAt: new Date()
  };
};
```

**3. Error-First Design**
```typescript
// 에러를 먼저 고려한 설계
const validateAndStartActivity = async (config: LiveActivityConfig): Promise<Result<Activity, ValidationError[]>> => {
  const validationErrors = validateActivityConfig(config);
  if (validationErrors.length > 0) {
    return { success: false, error: validationErrors };
  }
  
  return await startActivity(config);
};
```

### 🧪 테스트 전략

**Unit Tests**
```typescript
describe('LiveActivityService', () => {
  it('should validate activity configuration', () => {
    const config = { id: '', title: 'Test' };
    const result = validateActivityConfig(config);
    expect(result.isValid).toBe(false);
    expect(result.errors).toContain('ID_REQUIRED');
  });
});
```

**Integration Tests**
```swift
func testActivityLifecycle() async throws {
    let service = LiveActivityService()
    let activity = try await service.start(config: testConfig)
    XCTAssertNotNil(activity.id)
    
    try await service.update(activityId: activity.id, content: updatedContent)
    try await service.stop(activityId: activity.id)
}
```

### 📚 문서화 규칙

**코드 주석**
```typescript
/**
 * Live Activity를 시작합니다.
 * 
 * @param config - Activity 설정 객체
 * @returns Promise<Result<Activity, LiveActivityError>>
 * 
 * @example
 * ```typescript
 * const result = await startActivity({
 *   id: 'delivery-123',
 *   title: '음식 배달',
 *   content: { status: '준비 중' }
 * });
 * ```
 */
```

**README 업데이트**
- API 변경 시 즉시 문서 업데이트
- 예제 코드는 실제 동작하는 코드만 포함
- 버전별 변경사항 명시

이 문서는 Clean Code 원칙을 따르며 Live Activity 구현을 목표로 하는 프로젝트 가이드입니다.