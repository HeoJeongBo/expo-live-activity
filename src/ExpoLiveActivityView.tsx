import { requireNativeView } from 'expo';
import React from 'react';
import type { StyleProp, ViewStyle } from 'react-native';

import type { ActivityContent, LiveActivityConfig } from './ExpoLiveActivity.types';

/**
 * Props for the Expo Live Activity View component
 */
export interface ExpoLiveActivityViewProps {
  style?: StyleProp<ViewStyle>;
  config?: LiveActivityConfig;
  content?: ActivityContent;
  onLoad?: (event: { nativeEvent: { loaded: boolean } }) => void;
  onActivityAction?: (event: {
    activityId: string;
    actionId: string;
    actionTitle: string;
    timestamp: number;
  }) => void;
}

/**
 * Internal props for the native view
 */
interface NativeViewProps {
  style?: ExpoLiveActivityViewProps['style'];
  onLoad?: ExpoLiveActivityViewProps['onLoad'];
  onActivityAction?: (event: {
    nativeEvent: {
      activityId: string;
      actionId: string;
      actionTitle: string;
      timestamp: number;
    };
  }) => void;
}

interface NativeViewInstance {
  updateActivity?: (config: LiveActivityConfig) => void;
  updateContent?: (content: ActivityContent) => void;
}

const NativeView = requireNativeView('ExpoLiveActivity') as React.ComponentType<
  NativeViewProps & { ref?: React.Ref<NativeViewInstance> }
>;

/**
 * Live Activity Preview View Component
 *
 * Shows a preview of how the Live Activity will appear:
 * - iOS: Shows ActivityKit Live Activity preview
 * - Android: Shows notification-style preview
 * - Web: Shows fallback preview
 */
export default function ExpoLiveActivityView(props: ExpoLiveActivityViewProps) {
  const nativeViewRef = React.useRef<NativeViewInstance | null>(null);

  // Update the native view when config or content changes
  React.useEffect(() => {
    if (props.config && nativeViewRef.current?.updateActivity) {
      nativeViewRef.current.updateActivity(props.config);
    }
  }, [props.config]);

  React.useEffect(() => {
    if (props.content && nativeViewRef.current?.updateContent) {
      nativeViewRef.current.updateContent(props.content);
    }
  }, [props.content]);

  const handleActivityAction = (event: {
    nativeEvent: { activityId: string; actionId: string; actionTitle: string; timestamp: number };
  }) => {
    if (props.onActivityAction) {
      props.onActivityAction(event.nativeEvent);
    }
  };

  // Remove config and content from props passed to native view
  const { config, content, onActivityAction, ...nativeProps } = props;

  const finalProps: NativeViewProps = {
    ...nativeProps,
    onActivityAction: handleActivityAction,
  };

  return <NativeView {...finalProps} ref={nativeViewRef} />;
}
