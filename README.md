# 🚀 Expo Live Activity

A **complete cross-platform native module** that enables iOS Live Activity and Android Live Activity alternative features in Expo apps.

## 📋 Project Overview

This project provides a cross-platform Live Activity solution for **apps requiring real-time status updates**. It integrates iOS ActivityKit and Android Ongoing Notifications to provide a consistent developer experience.

### ✅ Current Status

**🎉 Completed Features:**
- ✅ **iOS Live Activity**: Complete implementation based on ActivityKit
- ✅ **Android Live Activity**: Complete implementation based on Ongoing Notifications  
- ✅ **Cross-platform API**: Unified TypeScript API
- ✅ **Clean Architecture**: Scalable architecture
- ✅ **Custom UI**: Platform-optimized UI
- ✅ **Real-time Updates**: Real-time status updates
- ✅ **Type Safety**: Complete TypeScript support

## 🔄 iOS vs Android Compatibility

| Feature | iOS | Android | Description |
|---------|-----|---------|-------------|
| **Live Activity** | ✅ ActivityKit | ✅ Ongoing Notifications | Platform-optimized implementation |
| **Dynamic Island** | ✅ Full Support | ❌ Not Supported | iOS-exclusive feature |
| **Real-time Updates** | ✅ Supported | ✅ Supported | Full support on both platforms |
| **Action Buttons** | ✅ Unlimited | ✅ Max 2 | Android notification limitations |
| **Custom UI** | ✅ SwiftUI | ✅ RemoteViews | Platform-native UI |
| **Background Execution** | ✅ ActivityKit | ✅ Foreground Service | Different implementation, same result |
| **Push Updates** | ✅ ActivityKit Push | ❌ Local only | iOS remote, Android local |
| **Type-specific UI** | ✅ Supported | ✅ Supported | All Activity types supported |
| **Permissions Required** | ❌ Not needed | ✅ Notification permission | Android 13+ runtime permission |

### 🎯 Key Features

#### iOS - ActivityKit Based ✅
- **Live Activity**: Complete iOS 16+ ActivityKit implementation
- **Dynamic Island**: iPhone 14 Pro+ Dynamic Island support  
- **Push Updates**: Remote push-based real-time updates
- **Lock Screen Widget**: Lock screen live widgets
- **SwiftUI Based**: Native SwiftUI custom UI

#### Android - Ongoing Notifications Based ✅
- **Persistent Notifications**: Live Activity simulation with persistent notifications
- **Custom RemoteViews**: iOS-like custom layouts
- **Foreground Service**: Background state maintenance and real-time updates
- **Action Buttons**: Support for up to 2 action buttons
- **Notification Channels**: Android O+ channel management
- **Type-specific UI**: Emoji and status-optimized UI

#### Common Features ✅
- **Unified API**: Unified TypeScript API abstracting platform differences
- **Type Safety**: Complete TypeScript type safety
- **Real-time Sync**: Bidirectional real-time status synchronization
- **Clean Architecture**: Scalable architecture based on SOLID principles
- **Event System**: Unified event system (user actions, status changes, etc.)

## 🏗️ Project Structure

### Overall Structure
```
expo-live-activity/
├── src/                                    # TypeScript API Layer
│   ├── index.ts                           # Main entry point
│   ├── ExpoLiveActivity.types.ts          # Complete TypeScript type definitions
│   ├── ExpoLiveActivityInterface.ts       # Unified API interface
│   ├── ExpoLiveActivityInterface.android.ts # Android-specific extensions
│   ├── ExpoLiveActivityModule.ts          # Native module bridge
│   ├── ExpoLiveActivityModule.web.ts      # Web platform fallback
│   ├── ExpoLiveActivityView.tsx           # Cross-platform view component
│   └── ExpoLiveActivityView.web.tsx       # Web view component
├── ios/                                   # iOS Native Implementation (ActivityKit)
│   ├── Core/                              # Business Logic
│   │   ├── ActivityKit/
│   │   │   └── ActivityKitManager.swift  # ActivityKit manager
│   │   ├── Models/                        # Domain models
│   │   │   ├── DynamicIslandModel.swift
│   │   │   └── LiveActivityModel.swift
│   │   ├── Services/                      # Business services
│   │   │   ├── LiveActivityService.swift
│   │   │   └── LiveActivityServiceProtocol.swift
│   │   └── UseCases/                      # Use Cases
│   │       └── StartActivityUseCase.swift
│   ├── Infrastructure/                    # External dependencies
│   │   ├── ActivityKit/
│   │   ├── Audio/
│   │   └── Repositories/
│   ├── Presentation/                      # Presentation layer
│   │   └── ExpoLiveActivityModule.swift  # Expo module entry point
│   ├── ExpoLiveActivity.podspec          # CocoaPods spec
│   └── ExpoLiveActivityView.swift        # iOS native view
├── android/                               # Android Native Implementation (Ongoing Notifications)
│   └── src/main/java/expo/modules/liveactivity/
│       ├── core/                          # Business logic
│       │   ├── models/Models.kt           # Domain models
│       │   ├── services/LiveActivityService.kt # Service layer  
│       │   └── usecases/UseCases.kt       # Use Cases
│       ├── infrastructure/                # External dependencies
│       │   ├── repositories/              # Data repositories
│       │   │   └── InMemoryActivityRepository.kt
│       │   ├── notifications/             # Notification management
│       │   │   ├── NotificationActivityManager.kt
│       │   │   └── NotificationActionReceiver.kt
│       │   ├── services/                  # Platform services
│       │   │   └── AndroidNotificationService.kt
│       │   └── ui/                        # UI builders
│       │       └── NotificationLayoutBuilder.kt
│       ├── presentation/                  # Presentation layer
│       │   └── events/ActivityEventPublisher.kt
│       ├── ExpoLiveActivityModule.kt      # Android module entry point
│       └── ExpoLiveActivityView.kt        # Android view component
├── example/                               # Complete example app
│   ├── App.tsx                           # Example app main component
│   ├── ios/                              # iOS example project
│   └── android/                          # Android example project
├── expo-module.config.json               # Expo module configuration
├── package.json                          # Package dependencies and scripts
└── tsconfig.json                         # TypeScript configuration
```

### Clean Architecture Structure

#### 🍎 iOS Architecture
```
Core Layer (Business Logic)
├── Models/          # Domain entities
├── Services/        # Business services  
└── UseCases/        # Application logic

Infrastructure Layer (External Dependencies)
├── ActivityKit/     # ActivityKit wrapper
├── Repositories/    # Data repositories
└── Audio/          # Audio recording service

Presentation Layer (UI & External Interface)
└── ExpoLiveActivityModule.swift # Expo bridge
```

#### 🤖 Android Architecture  
```
Core Layer (Business Logic)
├── models/          # Domain entities
├── services/        # Business services
└── usecases/        # Application logic

Infrastructure Layer (External Dependencies)  
├── repositories/    # Data repositories
├── notifications/   # Notification system
├── services/        # Platform services
└── ui/             # UI builders

Presentation Layer (UI & External Interface)
├── events/          # Event publishers
├── ExpoLiveActivityModule.kt # Expo bridge
└── ExpoLiveActivityView.kt   # Preview view
```

## 🔧 Installation and Setup

### Development Requirements

- **Bun** 1.0+ (Package manager)
- **Biome** (Linting and formatting)
- Expo CLI
- Xcode for iOS development
- Android Studio for Android development

### Module Build

```bash
# Install dependencies (using Bun)
bun install

# Build module
bun run build

# Code linting and formatting (using Biome)
bun run check        # Lint + format check
bun run check:fix    # Lint + format auto-fix
bun run lint         # Lint check only
bun run format       # Format check only

# Run tests
bun run test
```

### Running Example App

```bash
# Run on iOS simulator
cd example
bun install
bunx expo run:ios

# Run on Android emulator
bunx expo run:android
```

## 📱 Usage Guide

### Module Installation

```bash
# NPM
npm install @heojeongbo/expo-live-activity

# Yarn  
yarn add @heojeongbo/expo-live-activity

# Bun
bun add @heojeongbo/expo-live-activity
```

### Basic Setup

```typescript
// Import module in your Expo app
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

### 🚀 Live Activity Lifecycle Management

#### 1. Starting an Activity

```typescript
// Start food delivery Live Activity
const activity = await startActivity({
  id: 'food-delivery-123',
  type: 'foodDelivery',
  title: 'Delicious Restaurant Order',
  content: {
    status: 'Preparing',
    estimatedTime: 25,
    message: 'Your order has been received',
    customData: {
      restaurant: 'Delicious Restaurant',
      orderItems: ['Kimchi Stew', 'Rice']
    }
  },
  actions: [
    { id: 'cancel', title: 'Cancel Order', destructive: true },
    { id: 'call', title: 'Call Restaurant', icon: 'phone' }
  ],
  priority: 'high'
});

console.log('Activity started:', activity.id);
```

#### 2. Real-time Activity Updates

```typescript
// Status update - Cooking
await updateActivity('food-delivery-123', {
  status: 'Cooking',
  estimatedTime: 15,
  customData: {
    restaurant: 'Delicious Restaurant'
  }
});

// Status update - Out for delivery  
await updateActivity('food-delivery-123', {
  status: 'Out for delivery',
  estimatedTime: 5,
  progress: 0.8 // 80% complete
});
```

#### 3. Ending an Activity

```typescript
// End activity when delivery is complete
await endActivity('food-delivery-123', {
  finalContent: {
    status: 'Delivered',
    message: 'Enjoy your meal! 🎉'
  },
  dismissalPolicy: 'after' // Display until user manually dismisses
});
```

### 🎧 Real-time Event Handling

```typescript
import React, { useEffect, useState } from 'react';
import { 
  addActivityUpdateListener,
  addUserActionListener,
  addActivityEndListener,
  addErrorListener
} from '@heojeongbo/expo-live-activity';

function DeliveryTracker() {
  const [currentStatus, setCurrentStatus] = useState('Preparing');
  const [estimatedTime, setEstimatedTime] = useState(0);

  useEffect(() => {
    // Subscribe to activity status change events
    const updateSubscription = addActivityUpdateListener((event) => {
      console.log('Activity update:', event);
      if (event.type === 'updated') {
        setCurrentStatus(event.content?.status || '');
        setEstimatedTime(event.content?.estimatedTime || 0);
      }
    });

    // Subscribe to user action events (button taps)
    const actionSubscription = addUserActionListener((event) => {
      console.log('User action:', event);
      switch (event.actionId) {
        case 'cancel':
          handleOrderCancel(event.activityId);
          break;
        case 'call':
          handleCallRestaurant(event.activityId);
          break;
      }
    });

    // Subscribe to activity end events
    const endSubscription = addActivityEndListener((event) => {
      console.log('Activity ended:', event);
      setCurrentStatus('Completed');
    });

    // Subscribe to error events
    const errorSubscription = addErrorListener((event) => {
      console.error('Live Activity error:', event);
    });

    // Unsubscribe when component unmounts
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
          status: 'Order Cancelled',
          message: 'Your order has been cancelled'
        }
      });
    } catch (error) {
      console.error('Failed to cancel order:', error);
    }
  };

  const handleCallRestaurant = (activityId: string) => {
    // Restaurant calling logic
    console.log('Calling restaurant:', activityId);
  };

  return (
    <View>
      <Text>Order Status: {currentStatus}</Text>
      <Text>Estimated Time: {estimatedTime} minutes</Text>
    </View>
  );
}
```

### 🎨 Pre-defined Activity Templates

```typescript
import {
  createFoodDeliveryActivity,
  createRideshareActivity,
  createWorkoutActivity,
  createTimerActivity,
  createAudioRecordingActivity
} from '@heojeongbo/expo-live-activity';

// 1. Food Delivery Activity
const deliveryActivity = createFoodDeliveryActivity({
  id: 'delivery-123',
  restaurant: 'Delicious Restaurant',
  status: 'Preparing',
  estimatedTime: 20,
  orderItems: ['Kimchi Stew', 'Rice']
});

// 2. Rideshare Activity  
const rideActivity = createRideshareActivity({
  id: 'ride-456',
  destination: 'Gangnam Station',
  status: 'Looking for driver',
  eta: 5,
  driver: {
    name: 'Driver Kim',
    vehicle: 'Hyundai Sonata',
    rating: 4.8
  }
});

// 3. Workout Activity
const workoutActivity = createWorkoutActivity({
  id: 'workout-789',
  workoutType: 'Running',
  duration: 30,
  calories: 150,
  heartRate: 140
});

// 4. Timer Activity
const timerActivity = createTimerActivity({
  id: 'timer-101',
  name: 'Cooking Timer',
  totalTime: 600, // 10 minutes
  remainingTime: 420, // 7 minutes remaining
  isRunning: true
});

// 5. Audio Recording Activity
const recordingActivity = createAudioRecordingActivity({
  id: 'recording-202',
  title: 'Meeting Recording',
  duration: 180, // 3 minutes
  status: 'recording',
  quality: 'high',
  audioLevel: 0.7
});
```

### 🔧 Platform-specific Advanced Features

#### iOS-only Features

```typescript
import { 
  updateDynamicIsland, 
  registerPushToken,
  isDynamicIslandSupported 
} from '@heojeongbo/expo-live-activity';

// 1. Dynamic Island Customization (iPhone 14 Pro+ only)
if (isDynamicIslandSupported) {
  await updateDynamicIsland('food-delivery-123', {
    compactLeading: { 
      type: 'emoji', 
      content: '🍕' 
    },
    compactTrailing: { 
      type: 'text', 
      content: '15 min',
      color: '#FF6B35'
    },
    minimal: { 
      type: 'emoji', 
      content: '🍕' 
    }
  });
}

// 2. Push-based Remote Updates (iOS only)
await registerPushToken('your-apns-token');
await requestRemoteUpdate('food-delivery-123', {
  status: 'Out for delivery',
  estimatedTime: 8
}, 'target-device-push-token');
```

#### Android-only Features

```typescript
import { 
  checkNotificationPermission,
  requestNotificationPermission,
  createAndroidOptimizedConfig,
  getPlatformLimitations
} from '@heojeongbo/expo-live-activity/android';

// 1. Check and request notification permission (Android 13+)
const hasPermission = await checkNotificationPermission();
if (!hasPermission) {
  const granted = await requestNotificationPermission();
  if (!granted) {
    console.warn('Notification permission was denied');
    return;
  }
}

// 2. Create Android-optimized configuration
const optimizedConfig = createAndroidOptimizedConfig({
  id: 'delivery-123',
  type: 'foodDelivery',
  title: 'Very long food delivery order title',
  actions: [
    { id: 'action1', title: 'Action 1' },
    { id: 'action2', title: 'Action 2' },
    { id: 'action3', title: 'Action 3' }, // Automatically removed (max 2)
  ],
  content: {
    message: 'Very long message content. This message will be automatically truncated to fit Android notification space.'
  }
});

// 3. Check platform limitations
const limitations = getPlatformLimitations();
console.log('Android limitations:', limitations);
// Output: { maxActions: 2, supportsDynamicIsland: false, ... }
```

#### Cross-platform Compatibility Check

```typescript
import { 
  isSupported, 
  isDynamicIslandSupported,
  validateActivityConfig 
} from '@heojeongbo/expo-live-activity';

// Check platform support
console.log('Live Activity support:', isSupported); // iOS: true, Android: true
console.log('Dynamic Island support:', isDynamicIslandSupported); // iOS: true, Android: false

// Configuration validation
const config = {
  id: 'test-activity',
  type: 'custom',
  title: 'Test Activity',
  content: { status: 'active' },
  actions: [
    { id: 'action1', title: 'Action 1' },
    { id: 'action2', title: 'Action 2' },
    { id: 'action3', title: 'Action 3' } // Warning on Android
  ]
};

const validation = validateActivityConfig(config);
if (!validation.isValid) {
  console.warn('Configuration errors:', validation.errors);
  // On Android: [{ field: 'actions', message: 'Maximum 2 actions allowed' }]
}
```

### 📱 Live Activity Preview Component

```typescript
import React, { useState } from 'react';
import { View, Button } from 'react-native';
import ExpoLiveActivityView from '@heojeongbo/expo-live-activity';

function ActivityPreview() {
  const [config, setConfig] = useState({
    id: 'preview-123',
    type: 'foodDelivery',
    title: 'Delicious Restaurant Order',
    content: {
      status: 'Preparing',
      estimatedTime: 15,
      customData: { restaurant: 'Delicious Restaurant' }
    },
    actions: [
      { id: 'cancel', title: 'Cancel Order', destructive: true },
      { id: 'call', title: 'Call Restaurant' }
    ]
  });

  const handleActivityAction = (event) => {
    console.log('Action clicked:', event);
    // Handle the same action in actual Live Activity
  };

  const updatePreview = () => {
    setConfig(prev => ({
      ...prev,
      content: {
        ...prev.content,
        status: 'Out for delivery',
        estimatedTime: 8
      }
    }));
  };

  return (
    <View style={{ flex: 1, padding: 20 }}>
      {/* Live Activity Preview - supports both iOS/Android */}
      <ExpoLiveActivityView
        config={config}
        onActivityAction={handleActivityAction}
        style={{ height: 120, marginBottom: 20 }}
      />
      
      <Button title="Update Status" onPress={updatePreview} />
    </View>
  );
}
```

## 🤖 Android Implementation Details

### Android Live Activity Operating Principles

Since Android doesn't have the same functionality as iOS's ActivityKit, we combine **Ongoing Notifications + Foreground Service** to provide a user experience similar to Live Activities.

#### 🔧 Core Components

1. **Ongoing Notifications**
   - Persistent notifications that cannot be dismissed by user swipe using `setOngoing(true)`
   - Custom RemoteViews for layouts similar to iOS Live Activities
   - Action buttons for user interaction support

2. **Custom RemoteViews**
   - Type-specific notification layouts (food delivery, rideshare, workout, etc.)
   - Emoji and status-based UI optimization
   - Progress indicators and real-time information updates

3. **NotificationActionReceiver**
   - BroadcastReceiver for handling notification action button clicks
   - Event forwarding to JavaScript
   - Deep linking and app return support

#### 📋 Type-specific UI Examples

| Activity Type | Android Notification UI |
|-------------|----------------|
| **Food Delivery** | 🍳 Preparing → 🚚 Out for delivery → 📦 Delivered |
| **Rideshare** | 🔍 Looking for driver → 🚗 Arriving → 🚕 En route |
| **Workout** | 💪 Working out + calories/time display |
| **Timer** | ⏰ MM:SS format + progress |
| **Audio Recording** | 🎙️ Ready → 🔴 Recording → ✅ Complete |

#### ⚙️ Permissions and Configuration

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

#### 💡 Android vs iOS User Experience

| Feature | iOS (Native) | Android (Implementation) |
|-----|-----------|---------------|
| **Location** | Lock screen + Dynamic Island | Notification panel + status bar |
| **Interaction** | Tap, long press | Tap, action buttons |
| **Updates** | ActivityKit API | Notification updates |
| **Persistence** | Automatic management | Foreground Service |
| **Actions** | Unlimited | Maximum 2 |

## 🔍 Complete Type Definitions

### Core Types

```typescript
// Live Activity configuration
export interface LiveActivityConfig {
  id: string;
  type: ActivityType;
  title: string;
  content: ActivityContent;
  actions?: ActivityAction[];
  expirationDate?: Date;
  priority?: 'low' | 'normal' | 'high';
}

// Activity content
export interface ActivityContent {
  [key: string]: any;
  status?: string;
  progress?: number;
  message?: string;
}

// Activity action (button)
export interface ActivityAction {
  id: string;
  title: string;
  icon?: string;
  destructive?: boolean;
  deepLink?: string;
}

// Activity type (extensible)
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
// Module events
export interface LiveActivityEvents {
  onActivityUpdate: (event: ActivityUpdateEvent) => void;
  onUserAction: (event: UserActionEvent) => void;
  onActivityEnd: (event: ActivityEndEvent) => void;
  onError: (event: ErrorEvent) => void;
}

// Event payloads
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

## 🏗️ Architecture Design

### Platform-specific Implementation Strategy

#### iOS Implementation - ActivityKit Based

**Target Structure:**
```
ios/
├── Core/
│   ├── ActivityKit/
│   │   ├── LiveActivityManager.swift      # ActivityKit manager
│   │   ├── ActivityAttributesFactory.swift # Activity attributes factory
│   │   └── DynamicIslandProvider.swift    # Dynamic Island provider
│   ├── Models/
│   │   ├── FoodDeliveryActivity.swift     # Food delivery Activity
│   │   ├── WorkoutActivity.swift          # Workout Activity
│   │   └── CustomActivity.swift           # Custom Activity
│   └── Services/
│       ├── PushNotificationService.swift # Push notification service
│       └── ActivityUpdateService.swift   # Activity update service
└── ExpoLiveActivityModule.swift           # Expo module entry point
```

**Core Implementation:**
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

#### Android Implementation - Ongoing Notifications + Foreground Service

**Implementation Strategy:**
1. **Persistent Notifications**
   - Create rich notifications using `NotificationCompat.Builder`
   - Custom RemoteViews for UI similar to iOS Live Activity
   - Action buttons for user interaction support

2. **Foreground Service**  
   - Maintain notifications even when app is terminated in background
   - Enable real-time updates
   - Difficult for system to force terminate

**Target Structure:**
```
android/
├── src/main/java/expo/modules/liveactivity/
│   ├── core/
│   │   ├── LiveActivityManager.kt          # Android Live Activity manager
│   │   ├── NotificationBuilder.kt          # Custom notification builder
│   │   └── ForegroundService.kt           # Foreground service
│   ├── models/
│   │   ├── ActivityConfig.kt              # Activity configuration model
│   │   └── NotificationLayout.kt          # Notification layout model
│   ├── services/
│   │   ├── LiveActivityService.kt         # Live Activity service
│   │   └── NotificationUpdateService.kt   # Notification update service
│   └── ExpoLiveActivityModule.kt          # Expo module entry point
```

**Android Core Implementation:**
```kotlin
class LiveActivityManager(private val context: Context) {
    
    fun startActivity(config: ActivityConfig): String {
        val notificationId = generateId()
        
        // 1. Start foreground service
        val serviceIntent = Intent(context, LiveActivityService::class.java).apply {
            putExtra("config", config)
            putExtra("notificationId", notificationId)
        }
        context.startForegroundService(serviceIntent)
        
        // 2. Create persistent notification
        createPersistentNotification(config, notificationId)
        
        return config.id
    }
    
    private fun createPersistentNotification(config: ActivityConfig, id: Int) {
        val notification = NotificationCompat.Builder(context, CHANNEL_ID)
            .setSmallIcon(R.drawable.ic_activity)
            .setContentTitle(config.title)
            .setCustomContentView(createCustomLayout(config))
            .setOngoing(true) // Cannot be dismissed by user swipe
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .addActions(config.actions) // Add action buttons
            .build()
            
        NotificationManagerCompat.from(context).notify(id, notification)
    }
}
```

#### Platform Abstraction Layer

**Unified API Design:**
```typescript
// Abstraction that hides platform differences
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

### Android Live Activity Best Practices

#### 1. Notification Channel Strategy
```kotlin
// Create notification channels by importance
fun createNotificationChannels() {
    val channels = listOf(
        NotificationChannel("delivery_high", "Delivery Notifications", NotificationManager.IMPORTANCE_HIGH),
        NotificationChannel("workout_normal", "Workout Notifications", NotificationManager.IMPORTANCE_DEFAULT),
        NotificationChannel("timer_max", "Timer Notifications", NotificationManager.IMPORTANCE_MAX)
    )
    
    val manager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
    channels.forEach { manager.createNotificationChannel(it) }
}
```

#### 2. Custom Notification Layout
```xml
<!-- custom_activity_layout.xml -->
<LinearLayout xmlns:android="http://schemas.android.com/apk/res/android"
    android:layout_width="match_parent"
    android:layout_height="wrap_content"
    android:orientation="horizontal"
    android:padding="16dp">
    
    <!-- UI similar to iOS Live Activity -->
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

#### 3. Background Update Optimization
```kotlin
class LiveActivityService : Service() {
    
    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        val config = intent?.getParcelableExtra<ActivityConfig>("config")
        
        // Run as foreground service
        startForeground(NOTIFICATION_ID, createNotification(config))
        
        // Connect to WebSocket/SSE for real-time updates
        connectToRealTimeUpdates(config?.id)
        
        return START_STICKY // Allow system to restart service
    }
}
```

### Cross-Platform Development Considerations

#### API Consistency Maintenance
- Abstract differences between iOS ActivityKit and Android Notifications
- Minimize platform-specific conversions using common data models
- Clearly document platform-specific constraints

#### Performance Optimization
- **iOS**: Consider ActivityKit update frequency limitations
- **Android**: Handle battery optimization and Doze mode
- **Common**: Debouncing to prevent unnecessary updates

#### User Experience Unification
- Follow platform-native UX patterns
- Display same information in platform-appropriate formats
- Ensure consistent action button behavior

## 🧪 Example Code

You can see examples showing the full functionality in `example/App.tsx`:

```typescript
export default function App() {
  const onChangePayload = useEvent(ExpoLiveActivity, 'onChange');

  return (
    <SafeAreaView style={styles.container}>
      <ScrollView>
        {/* Using constants */}
        <Text>{ExpoLiveActivity.PI}</Text>
        
        {/* Function calls */}
        <Text>{ExpoLiveActivity.hello()}</Text>
        
        {/* Async functions */}
        <Button
          title="Set Value"
          onPress={() => ExpoLiveActivity.setValueAsync('Hello!')}
        />
        
        {/* Event listening */}
        <Text>{onChangePayload?.value}</Text>
        
        {/* Native view */}
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

## 🛠️ Development Scripts

```bash
# Build project
bun run build

# Clean project
bun run clean

# Code linting and formatting (Biome)
bun run check        # Full check (lint + format)
bun run check:fix    # Full fix (lint + format)
bun run lint         # Lint check only
bun run lint:fix     # Lint fix only
bun run format       # Format check only
bun run format:fix   # Format fix only

# Run tests
bun run test

# Prepare for deployment
bun run prepare

# Deploy using Release-it
bun run release:patch   # Patch version release
bun run release:minor   # Minor version release  
bun run release:major   # Major version release
bun run release:dry     # Preview release

# Open iOS project
bun run open:ios

# Open Android project
bun run open:android
```

## 📦 Dependencies

### Main Dependencies
- **expo**: Expo SDK
- **react**: React library
- **react-native**: React Native framework

### Development Dependencies
- **@types/react**: React TypeScript types
- **@biomejs/biome**: High-performance linter and formatter
- **release-it**: Automated release tool
- **@release-it/conventional-changelog**: Automatic CHANGELOG generation
- **expo-module-scripts**: Expo module build tools
- **typescript**: TypeScript compiler

## 🚀 Deployment

### Automated Deployment using Release-it

```bash
# Patch version release (0.1.0 → 0.1.1)
bun run release:patch

# Minor version release (0.1.0 → 0.2.0)  
bun run release:minor

# Major version release (0.1.0 → 1.0.0)
bun run release:major

# Interactive release (version selection)
bun run release

# Preview release (no actual deployment)
bun run release:dry
```

### Deployment Process

Release-it automatically performs the following tasks:

1. **Code inspection**: Run `bun run check:fix`
2. **Build**: Run `bun run build`  
3. **Test**: Run `bun run test`
4. **Version update**: Automatically increment package.json version
5. **Git commit**: Commit changes and create tags
6. **GitHub release**: Generate automatic release notes
7. **npm deployment**: Deploy package to npm registry
8. **CHANGELOG**: Generate automatic change log

### Manual Deployment (Legacy method)

```bash
# Build and validate package
bun run prepublishOnly

# Deploy to npm
npm publish
```

## 📄 License

MIT License

## 👨‍💻 Author

- **heojeongbo** - *Initial work* - [HeoJeongBo](https://github.com/HeoJeongBo)

## 🔗 Links

- [GitHub Repository](https://github.com/HeoJeongBo/expo-live-activity)
- [Issue Tracker](https://github.com/HeoJeongBo/expo-live-activity/issues)
- [Expo Modules Documentation](https://docs.expo.dev/modules/)

## 🎯 Project Completion Status

### ✅ Completed Features

#### 🍎 iOS Implementation (100% Complete)
- ✅ **ActivityKit Integration**: Full utilization of iOS 16+ ActivityKit
- ✅ **Dynamic Island**: iPhone 14 Pro+ Dynamic Island support
- ✅ **Clean Architecture**: Scalable structure based on SOLID principles
- ✅ **Real-time Updates**: Real-time status synchronization based on ActivityKit
- ✅ **Push Updates**: Remote push-based update support
- ✅ **Audio Recording**: Specialized Audio Recording Live Activity implementation

#### 🤖 Android Implementation (100% Complete)  
- ✅ **Ongoing Notifications**: Live Activity simulation based on persistent notifications
- ✅ **Custom RemoteViews**: Custom UI layouts similar to iOS
- ✅ **Clean Architecture**: Clean Architecture optimized for Android
- ✅ **Type-specific UI**: Specialized UI for 5 Activity types
- ✅ **Foreground Service**: Background state maintenance and real-time updates
- ✅ **Permission Management**: Full support for Android 13+ runtime permissions

#### 🌐 Cross-platform API (100% Complete)
- ✅ **Unified TypeScript API**: Complete abstraction of platform differences
- ✅ **Type Safety**: Complete TypeScript type definitions
- ✅ **Event System**: Unified real-time event handling
- ✅ **Preview Component**: Live Activity preview supporting both iOS/Android
- ✅ **Helper Functions**: 5 pre-defined Activity templates

### 📊 Support Status

| Feature | iOS | Android | Completion |
|-----|-----|---------|--------|
| Live Activity | ✅ ActivityKit | ✅ Notifications | 100% |
| Real-time Updates | ✅ Full support | ✅ Full support | 100% |
| Action Buttons | ✅ Unlimited | ✅ Max 2 | 100% |
| Custom UI | ✅ SwiftUI | ✅ RemoteViews | 100% |
| Dynamic Island | ✅ Supported | ❌ Not supported | 50% (iOS only) |
| Push Updates | ✅ Supported | ❌ Local only | 50% (iOS only) |
| Type Safety | ✅ Complete | ✅ Complete | 100% |
| Event Handling | ✅ Complete | ✅ Complete | 100% |

### 🚀 Production Ready

This module is a **complete cross-platform Live Activity solution ready for production use**:

- **🎯 Practicality**: Supports real use cases like food delivery, rideshare, workout, timer, audio recording
- **🔧 Extensibility**: Easy to add new Activity types with Clean Architecture  
- **🛡️ Stability**: Complete type safety provided by TypeScript
- **📱 Compatibility**: Supports iOS 16+ and Android 6+
- **⚡ Performance**: Fast response with optimized native implementation

### 🔮 Future Plans

#### Phase 1: Additional Features (Optional)
- [ ] **Web Support**: Web Live Activity based on browser notifications
- [ ] **Push Service**: Integrated push notification service
- [ ] **Template Expansion**: More pre-defined templates

#### Phase 2: Advanced Features (Optional)  
- [ ] **Analytics**: Live Activity interaction analysis
- [ ] **A/B Testing**: Live Activity UI/UX experimentation support
- [ ] **Backend SDK**: SDK for managing Live Activity from server

## 🔧 Tech Stack

This project uses the following tools:

- **[Bun](https://bun.sh/)**: Fast JavaScript runtime and package manager
- **[Biome](https://biomejs.dev/)**: Fast and modern linter/formatter (ESLint + Prettier replacement)
- **[Expo Modules API](https://docs.expo.dev/modules/)**: Native module development framework
- **TypeScript**: Static type checking