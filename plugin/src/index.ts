import {
  type ConfigPlugin,
  withInfoPlist,
  withXcodeProject,
  type InfoPlist,
} from '@expo/config-plugins';
import { LiveActivityPluginProps } from './types';

export { LiveActivityPluginProps };

/**
 * Config plugin to setup Live Activity support for iOS
 */
export const withLiveActivity: ConfigPlugin<LiveActivityPluginProps> = (
  initialConfig,
  props = {}
) => {
  const {
    developmentTeam,
    widgetBundleIdentifier,
    widgetDisplayName = 'LiveActivityWidget',
    iosDeploymentTarget = '16.1',
  } = props;

  // Add Live Activities capability to Info.plist
  const configWithInfoPlist = withInfoPlist(initialConfig, (modifiedConfig) => {
    const infoPlist = modifiedConfig.modResults as InfoPlist;

    // Enable Live Activities
    infoPlist.NSSupportsLiveActivities = true;
    infoPlist.NSSupportsLiveActivitiesFrequentUpdates = true;

    return modifiedConfig;
  });

  // Configure Xcode project for Widget Extension
  const finalConfig = withXcodeProject(configWithInfoPlist, (modifiedConfig) => {
    const xcodeProject = modifiedConfig.modResults;
    const bundleIdentifier = modifiedConfig.ios?.bundleIdentifier || 'com.example.app';
    const finalWidgetBundleId = widgetBundleIdentifier || `${bundleIdentifier}.LiveActivityWidget`;

    // Add Widget Extension target
    try {
      // Check if widget target already exists
      const targets = xcodeProject.getTargets();
      const widgetTargetExists = targets.some((target: { name: string }) => target.name === widgetDisplayName);

      if (!widgetTargetExists) {
        // Add Widget Extension target configuration
        const widgetTargetUuid = xcodeProject.generateUuid();

        // Add widget extension target
        xcodeProject.addTarget(widgetDisplayName, 'app_extension', widgetTargetUuid, {
          bundleId: finalWidgetBundleId,
          deploymentTarget: iosDeploymentTarget,
        });

        // Configure build settings for widget extension
        const buildSettings: Record<string, string> = {
          PRODUCT_BUNDLE_IDENTIFIER: finalWidgetBundleId,
          IPHONEOS_DEPLOYMENT_TARGET: iosDeploymentTarget,
          TARGETED_DEVICE_FAMILY: '"1,2"',
          SWIFT_VERSION: '5.0',
          CLANG_ENABLE_MODULES: 'YES',
          SKIP_INSTALL: 'YES',
        };

        // Add development team if provided
        if (developmentTeam) {
          buildSettings.DEVELOPMENT_TEAM = developmentTeam;
        }

        // Apply build settings to both Debug and Release configurations
        xcodeProject.addBuildSetting(
          'PRODUCT_BUNDLE_IDENTIFIER',
          finalWidgetBundleId,
          'Debug',
          widgetTargetUuid
        );
        xcodeProject.addBuildSetting(
          'PRODUCT_BUNDLE_IDENTIFIER',
          finalWidgetBundleId,
          'Release',
          widgetTargetUuid
        );
        xcodeProject.addBuildSetting(
          'IPHONEOS_DEPLOYMENT_TARGET',
          iosDeploymentTarget,
          'Debug',
          widgetTargetUuid
        );
        xcodeProject.addBuildSetting(
          'IPHONEOS_DEPLOYMENT_TARGET',
          iosDeploymentTarget,
          'Release',
          widgetTargetUuid
        );

        if (developmentTeam) {
          xcodeProject.addBuildSetting(
            'DEVELOPMENT_TEAM',
            developmentTeam,
            'Debug',
            widgetTargetUuid
          );
          xcodeProject.addBuildSetting(
            'DEVELOPMENT_TEAM',
            developmentTeam,
            'Release',
            widgetTargetUuid
          );
        }

        // Add WidgetKit framework
        xcodeProject.addFramework('WidgetKit.framework', {
          target: widgetTargetUuid,
          weak: true,
        });
        xcodeProject.addFramework('SwiftUI.framework', {
          target: widgetTargetUuid,
          weak: true,
        });
        xcodeProject.addFramework('ActivityKit.framework', {
          target: widgetTargetUuid,
          weak: true,
        });
      }
    } catch (error) {
      console.warn(`Failed to configure Widget Extension: ${error}`);
    }

    return modifiedConfig;
  });

  return finalConfig;
};

export default withLiveActivity;
