/** @type {import('@bacons/apple-targets/app.plugin').ConfigFunction} */
module.exports = (_config) => ({
  type: 'widget',
  frameworks: ['SwiftUI', 'ActivityKit', 'WidgetKit'],
  entitlements: {
    'com.apple.developer.activity-push-to-update': true,
    'com.apple.security.application-groups': ['group.expo.modules.liveactivity.example'],
  },
  deploymentTarget: '16.0',
});
