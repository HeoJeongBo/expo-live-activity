export interface LiveActivityAttributes {
  name: string;
}

export interface LiveActivityContentState {
  title: string;
  status: string;
  progress: number;
  timestamp: Date;
}

export interface LiveActivityConfig {
  attributes: LiveActivityAttributes;
  content: LiveActivityContentState;
  pushType?: 'token' | 'none';
}
