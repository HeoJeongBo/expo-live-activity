# Live Activity Config Plugin Usage Guide

This document explains how to use the Config Plugin for the `@heojeongbo/expo-live-activity` package.

## Installation

```bash
npm install @heojeongbo/expo-live-activity
# or
bun add @heojeongbo/expo-live-activity
```

## Basic Configuration

### 1. Add plugin to app.json/app.config.js

```json
{
  "expo": {
    "name": "My App",
    "plugins": [
      "@heojeongbo/expo-live-activity"
    ]
  }
}
```

### 2. Advanced Configuration (Recommended)

```json
{
  "expo": {
    "name": "My App",
    "plugins": [
      [
        "@heojeongbo/expo-live-activity",
        {
          "developmentTeam": "ABC123DEF4",
          "widgetBundleIdentifier": "com.yourcompany.app.LiveActivityWidget",
          "widgetDisplayName": "MyAppWidget",
          "iosDeploymentTarget": "16.1"
        }
      ]
    ]
  }
}
```

## Configuration Options

### developmentTeam (optional)
- **Type**: `string`
- **Description**: Apple Developer Team ID
- **Example**: `"ABC123DEF4"`
- **How to find**:
  1. Login to [Apple Developer Account](https://developer.apple.com/account)
  2. Check Membership > Team ID
  3. Or check in Xcode > Preferences > Accounts

### widgetBundleIdentifier (optional)
- **Type**: `string`
- **Default**: `{app.bundle.id}.LiveActivityWidget`
- **Description**: Widget Extension Bundle Identifier
- **Example**: `"com.yourcompany.app.LiveActivityWidget"`
- **Rules**: App Bundle ID + Widget name combination

### widgetDisplayName (optional)
- **Type**: `string`
- **Default**: `"LiveActivityWidget"`
- **Description**: Widget Extension display name
- **Example**: `"MyAppWidget"`

### iosDeploymentTarget (optional)
- **Type**: `string`
- **Default**: `"16.1"`
- **Description**: Minimum iOS version for Widget Extension
- **Example**: `"16.1"`

## Using Environment Variables

You can manage sensitive information using environment variables:

### .env file
```env
EXPO_DEVELOPMENT_TEAM=ABC123DEF4
EXPO_WIDGET_BUNDLE_ID=com.yourcompany.app.LiveActivityWidget
```

### Usage in app.config.js
```javascript
export default {
  expo: {
    name: "My App",
    plugins: [
      [
        "@heojeongbo/expo-live-activity",
        {
          developmentTeam: process.env.EXPO_DEVELOPMENT_TEAM,
          widgetBundleIdentifier: process.env.EXPO_WIDGET_BUNDLE_ID
        }
      ]
    ]
  }
};
```

## Project Build

After plugin configuration, native code regeneration is required:

```bash
# Expo development build
expo prebuild --clean

# EAS Build
eas build --platform ios --clear-cache
```

## Physical Device Testing Required

⚠️ **Important**: Live Activity does not work on simulator.

- Requires iOS 16.1+ physical device
- Apple Developer Program membership required
- Valid Provisioning Profile required

## Manual Configuration (If Needed)

If the plugin doesn't work completely, manual setup in Xcode:

1. Open project in Xcode
2. Target > Signing & Capabilities
3. Select Team
4. + Capability > App Groups (if needed)
5. Verify Widget Extension Target

## Troubleshooting

### Team ID Error
```
error: No profiles for 'com.yourapp.LiveActivityWidget' were found
```
**Solution**: Set `developmentTeam` or select Team in Xcode

### Bundle Identifier Conflict
```
error: Bundle identifier is already in use
```
**Solution**: Change `widgetBundleIdentifier` to a unique value

### Build Failure
```
error: Widget extension requires iOS 16.1+
```
**Solution**: Set `iosDeploymentTarget` to `"16.1"` or higher

## Example Project

For complete implementation example, see `example/` folder:

```typescript
// App.tsx
import { ExpoLiveActivity } from '@heojeongbo/expo-live-activity';

export default function App() {
  const startActivity = async () => {
    await ExpoLiveActivity.startActivity({
      id: 'test-activity',
      title: 'Test Live Activity',
      content: { status: 'Started' }
    });
  };

  return (
    // UI code
  );
}
```

## Next Steps

1. Write Widget Extension Swift code
2. Integrate ActivityKit
3. Design Live Activity UI
4. Implement push notification-based updates

For more details, see the [main README](./README.md).