# Expo Live Activity

iOS Live Activity 및 Android Live Activity 대안 기능을 Expo 앱에서 사용할 수 있도록 하는 크로스 플랫폼 네이티브 모듈입니다.

## 📋 프로젝트 개요

이 프로젝트는 **실시간 상태 업데이트가 필요한 앱**을 위한 크로스 플랫폼 Live Activity 솔루션을 제공합니다. iOS의 ActivityKit과 Android의 Ongoing Notifications를 통합하여 일관된 개발자 경험을 제공합니다.

### 🎯 현재 상태 및 목표

**현재**: Expo 네이티브 모듈 기본 프로젝트 (스캐폴딩 단계)  
**목표**: 완전한 Live Activity 크로스 플랫폼 구현

### 주요 기능 (계획)

#### iOS - ActivityKit 기반
- **Live Activity**: iOS 16+ ActivityKit 완전 활용
- **Dynamic Island**: iPhone 14 Pro+ Dynamic Island 지원
- **Push Updates**: 원격 푸시 기반 실시간 업데이트
- **Lock Screen Widget**: 잠금 화면 라이브 위젯

#### Android - Ongoing Notifications 기반  
- **Persistent Notifications**: 지속적인 알림 표시
- **Rich Notifications**: 커스텀 레이아웃 및 액션 버튼
- **Foreground Service**: 백그라운드 상태 유지
- **Notification Channels**: 안드로이드 O+ 채널 관리

#### 공통 기능
- **Unified API**: 플랫폼 차이를 추상화한 통합 API
- **TypeScript Support**: 완전한 타입 안전성
- **Real-time Sync**: 실시간 상태 동기화
- **Clean Architecture**: 확장 가능한 아키텍처

## 🏗️ 프로젝트 구조

```
expo-live-activity/
├── src/                              # TypeScript 소스 코드
│   ├── index.ts                      # 메인 엔트리 포인트
│   ├── ExpoLiveActivity.types.ts     # TypeScript 타입 정의
│   ├── ExpoLiveActivityModule.ts     # 네이티브 모듈 인터페이스
│   ├── ExpoLiveActivityModule.web.ts # 웹 플랫폼 구현
│   ├── ExpoLiveActivityView.tsx      # 네이티브 뷰 컴포넌트
│   └── ExpoLiveActivityView.web.tsx  # 웹 뷰 컴포넌트
├── ios/                              # iOS 네이티브 구현
│   ├── ExpoLiveActivity.podspec      # CocoaPods 스펙 파일
│   ├── ExpoLiveActivityModule.swift  # iOS 네이티브 모듈
│   └── ExpoLiveActivityView.swift    # iOS 네이티브 뷰
├── android/                          # Android 네이티브 구현
├── example/                          # 예제 앱
│   ├── App.tsx                       # 예제 앱 메인 컴포넌트
│   ├── ios/                          # iOS 예제 프로젝트
│   └── android/                      # Android 예제 프로젝트
├── expo-module.config.json           # Expo 모듈 설정
├── package.json                      # 패키지 의존성 및 스크립트
└── tsconfig.json                     # TypeScript 설정
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

## 📱 API 사용법 (목표 설계)

### 모듈 임포트

```typescript
import ExpoLiveActivity from 'expo-live-activity';
```

### Live Activity 생명주기 관리

```typescript
// Live Activity 시작
const activity = await ExpoLiveActivity.startActivity({
  id: 'food-delivery-123',
  type: 'foodDelivery',
  title: '음식 배달',
  content: {
    restaurant: '맛있는 식당',
    status: '주문 접수',
    estimatedTime: 25,
    orderItems: ['김치찌개', '공기밥']
  },
  actions: [
    { id: 'cancel', title: '주문 취소', destructive: true },
    { id: 'call', title: '매장 전화', icon: 'phone' }
  ],
  expirationDate: new Date(Date.now() + 60 * 60 * 1000) // 1시간
});

// Live Activity 업데이트
await ExpoLiveActivity.updateActivity('food-delivery-123', {
  content: {
    status: '조리 중',
    estimatedTime: 15
  }
});

// Live Activity 종료
await ExpoLiveActivity.endActivity('food-delivery-123', {
  finalContent: {
    status: '배달 완료',
    message: '맛있게 드세요!'
  }
});
```

### 실시간 이벤트 처리

```typescript
import { useEvent } from 'expo';

function DeliveryTracker() {
  // Activity 상태 변경 이벤트
  const activityUpdate = useEvent(ExpoLiveActivity, 'onActivityUpdate');
  
  // 사용자 액션 이벤트 (버튼 탭 등)
  const userAction = useEvent(ExpoLiveActivity, 'onUserAction');
  
  useEffect(() => {
    if (userAction?.actionId === 'cancel') {
      handleOrderCancel();
    }
  }, [userAction]);
  
  return (
    <View>
      <Text>주문 상태: {activityUpdate?.content?.status}</Text>
      <Text>예상 시간: {activityUpdate?.content?.estimatedTime}분</Text>
    </View>
  );
}
```

### 플랫폼별 고급 기능

```typescript
// iOS Dynamic Island 커스터마이징
await ExpoLiveActivity.updateDynamicIsland('food-delivery-123', {
  compactLeading: { text: '🍕' },
  compactTrailing: { text: '15분' },
  minimal: { text: '🍕' }
});

// Android 알림 채널 설정  
await ExpoLiveActivity.configureNotificationChannel({
  channelId: 'food-delivery',
  name: '음식 배달',
  importance: 'high',
  showBadge: true,
  vibration: true
});
```

## 🔍 타입 정의 (목표 설계)

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

## 📝 참고사항

이 모듈은 현재 기본적인 Expo 모듈 구조를 제공하며, 실제 iOS Live Activity 기능은 아직 구현되지 않았습니다. WebView 기반의 예제 구현을 포함하고 있어 Expo 모듈 개발의 참고 자료로 활용할 수 있습니다.

Live Activity 기능을 실제로 구현하려면 iOS의 ActivityKit 프레임워크를 사용하여 추가 개발이 필요합니다.

## 🔧 기술 스택

이 프로젝트는 다음 도구들을 사용합니다:

- **[Bun](https://bun.sh/)**: 빠른 JavaScript 런타임 및 패키지 매니저
- **[Biome](https://biomejs.dev/)**: 빠르고 현대적인 린터/포매터 (ESLint + Prettier 대체)
- **[Expo Modules API](https://docs.expo.dev/modules/)**: 네이티브 모듈 개발 프레임워크
- **TypeScript**: 정적 타입 검사