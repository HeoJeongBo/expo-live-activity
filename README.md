# Expo Live Activity

Expo Live Activity는 iOS Live Activity 기능을 Expo 앱에서 사용할 수 있도록 하는 네이티브 모듈입니다.

## 📋 프로젝트 개요

이 프로젝트는 iOS의 Live Activity 기능을 React Native/Expo 앱에서 사용할 수 있도록 하는 Expo 모듈입니다. 현재는 기본적인 모듈 구조와 WebView 기반의 뷰 컴포넌트를 제공합니다.

### 주요 기능

- **네이티브 모듈**: iOS Swift로 구현된 네이티브 모듈
- **WebView 컴포넌트**: URL을 로드할 수 있는 네이티브 뷰 컴포넌트
- **이벤트 시스템**: JavaScript와 네이티브 간 이벤트 통신
- **크로스 플랫폼 지원**: iOS, Android, Web 플랫폼 지원

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

## 📱 API 사용법

### 모듈 임포트

```typescript
import ExpoLiveActivity, { ExpoLiveActivityView } from 'expo-live-activity';
```

### 기본 함수 사용

```typescript
// 상수 접근
console.log(ExpoLiveActivity.PI); // 3.141592653589793

// 동기 함수 호출
const greeting = ExpoLiveActivity.hello();
console.log(greeting); // "Hello world! 👋"

// 비동기 함수 호출
await ExpoLiveActivity.setValueAsync('Hello from JavaScript!');
```

### 이벤트 리스닝

```typescript
import { useEvent } from 'expo';

function MyComponent() {
  const onChangePayload = useEvent(ExpoLiveActivity, 'onChange');
  
  return (
    <Text>{onChangePayload?.value}</Text>
  );
}
```

### 네이티브 뷰 컴포넌트 사용

```typescript
<ExpoLiveActivityView
  url="https://www.example.com"
  onLoad={({ nativeEvent: { url } }) => {
    console.log(`페이지 로드됨: ${url}`);
  }}
  style={{
    flex: 1,
    height: 200,
  }}
/>
```

## 🔍 타입 정의

### 주요 타입들

```typescript
// 이벤트 페이로드 타입
export type OnLoadEventPayload = {
  url: string;
};

export type ChangeEventPayload = {
  value: string;
};

// 모듈 이벤트 타입
export type ExpoLiveActivityModuleEvents = {
  onChange: (params: ChangeEventPayload) => void;
};

// 뷰 컴포넌트 Props 타입
export type ExpoLiveActivityViewProps = {
  url: string;
  onLoad: (event: { nativeEvent: OnLoadEventPayload }) => void;
  style?: StyleProp<ViewStyle>;
};
```

## 🏗️ 아키텍처

### iOS 네이티브 구현

- **ExpoLiveActivityModule.swift**: 메인 모듈 클래스
  - 상수 정의 (`PI`)
  - 동기 함수 (`hello`)
  - 비동기 함수 (`setValueAsync`)
  - 이벤트 발송 (`onChange`)

- **ExpoLiveActivityView.swift**: 네이티브 뷰 컴포넌트
  - WKWebView 기반 구현
  - URL 로딩 기능
  - 로드 완료 이벤트 발송

### JavaScript 레이어

- **ExpoLiveActivityModule.ts**: 네이티브 모듈 인터페이스
- **ExpoLiveActivityView.tsx**: React 컴포넌트 래퍼
- **ExpoLiveActivity.types.ts**: TypeScript 타입 정의

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