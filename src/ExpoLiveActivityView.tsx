import { requireNativeView } from 'expo';
import type * as React from 'react';

import type { ExpoLiveActivityViewProps } from './ExpoLiveActivity.types';

const NativeView: React.ComponentType<ExpoLiveActivityViewProps> =
  requireNativeView('ExpoLiveActivity');

export default function ExpoLiveActivityView(props: ExpoLiveActivityViewProps) {
  return <NativeView {...props} />;
}
