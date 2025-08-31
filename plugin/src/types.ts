export interface LiveActivityPluginProps {
  /**
   * Development Team ID for iOS app signing
   * Can be retrieved from Apple Developer Account
   * @example "ABC123DEF4"
   */
  developmentTeam?: string;

  /**
   * Widget Extension Bundle Identifier
   * Should be in format: {app.bundle.id}.{widget-name}
   * @example "com.yourcompany.app.LiveActivityWidget"
   */
  widgetBundleIdentifier?: string;

  /**
   * Widget Extension Display Name
   * @default "LiveActivityWidget" 
   */
  widgetDisplayName?: string;

  /**
   * iOS Deployment Target for Widget Extension
   * @default "16.1"
   */
  iosDeploymentTarget?: string;
}