export default {
  expo: {
    name: "expo-live-activity-example",
    slug: "expo-live-activity-example",
    version: "1.0.0",
    orientation: "portrait",
    icon: "./assets/icon.png",
    userInterfaceStyle: "light",
    newArchEnabled: true,
    splash: {
      image: "./assets/splash-icon.png",
      resizeMode: "contain",
      backgroundColor: "#ffffff"
    },
    ios: {
      supportsTablet: true,
      bundleIdentifier: "expo.modules.liveactivity.example",
      appleTeamId: process.env.EXPO_DEVELOPMENT_TEAM,
      entitlements: {
        "com.apple.developer.ActivityKit": true,
        "com.apple.security.application-groups": ["group.expo.modules.liveactivity.example"]
      }
    },
    plugins: [
      "@bacons/apple-targets",
      [
        "../plugin/build/index.js",
        {
          developmentTeam: process.env.EXPO_DEVELOPMENT_TEAM,
          widgetBundleIdentifier: process.env.EXPO_WIDGET_BUNDLE_ID || "expo.modules.liveactivity.example.LiveActivityWidget",
          widgetDisplayName: "ExampleWidget",
          iosDeploymentTarget: "16.1"
        }
      ]
    ],
    android: {
      adaptiveIcon: {
        foregroundImage: "./assets/adaptive-icon.png",
        backgroundColor: "#ffffff"
      },
      edgeToEdgeEnabled: true,
      package: "expo.modules.liveactivity.example"
    },
    web: {
      favicon: "./assets/favicon.png"
    }
  }
};