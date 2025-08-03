import {
  type ActivityUpdateEvent,
  type AudioRecordingEvent,
  type ErrorEvent,
  type LiveActivityInstance,
  type UserActionEvent,
  addActivityUpdateListener,
  addAudioRecordingListener,
  addErrorListener,
  addUserActionListener,
  createAudioRecordingActivity,
  createFoodDeliveryActivity,
  createRideshareActivity,
  createTimerActivity,
  createWorkoutActivity,
  endActivity,
  getActiveActivities,
  isDynamicIslandSupported,
  isSupported,
  startActivity,
  updateActivity,
} from 'expo-live-activity';
import type React from 'react';
import { useEffect, useState } from 'react';
import {
  Alert,
  Button,
  SafeAreaView,
  ScrollView,
  StyleSheet,
  Text,
  TextInput,
  View,
} from 'react-native';

export default function App() {
  const [activeActivities, setActiveActivities] = useState<LiveActivityInstance[]>([]);
  const [status, setStatus] = useState<string>('');
  const [estimatedTime, setEstimatedTime] = useState<string>('25');
  const [isRecording, setIsRecording] = useState<boolean>(false);
  const [recordingDuration, setRecordingDuration] = useState<number>(0);
  const [currentRecordingId, setCurrentRecordingId] = useState<string>('');
  const [audioLevel, setAudioLevel] = useState<number>(0);

  // Event Listeners
  useEffect(() => {
    const updateSubscription = addActivityUpdateListener((event: ActivityUpdateEvent) => {
      console.log('Activity Update:', event);
      if (event.type === 'started') {
        Alert.alert('Activity Started', `Activity ${event.activity?.id} has started`);
      }
      refreshActiveActivities();
    });

    const actionSubscription = addUserActionListener((event: UserActionEvent) => {
      console.log('User Action:', event);
      Alert.alert('User Action', `Action ${event.actionId} was pressed`);
    });

    const errorSubscription = addErrorListener((event: ErrorEvent) => {
      console.error('Activity Error:', event);
      Alert.alert('Error', event.message);
    });

    const audioSubscription = addAudioRecordingListener((event: AudioRecordingEvent) => {
      console.log('Audio Recording Event:', event);
      
      switch (event.type) {
        case 'started':
          setIsRecording(true);
          setCurrentRecordingId(event.sessionId);
          Alert.alert('Recording Started', '녹음이 시작되었습니다!');
          break;
        case 'paused':
          setIsRecording(false);
          Alert.alert('Recording Paused', '녹음이 일시정지되었습니다.');
          break;
        case 'resumed':
          setIsRecording(true);
          Alert.alert('Recording Resumed', '녹음이 재개되었습니다.');
          break;
        case 'stopped':
        case 'completed':
          setIsRecording(false);
          setCurrentRecordingId('');
          setRecordingDuration(0);
          if (event.fileInfo) {
            Alert.alert(
              'Recording Completed', 
              `녹음 완료!\n파일: ${event.fileInfo.uri}\n크기: ${(event.fileInfo.size / 1024 / 1024).toFixed(2)}MB\n시간: ${Math.floor(event.fileInfo.duration / 60)}:${(event.fileInfo.duration % 60).toFixed(0).padStart(2, '0')}`
            );
          }
          break;
        case 'error':
          setIsRecording(false);
          setCurrentRecordingId('');
          Alert.alert('Recording Error', event.error || '녹음 중 오류가 발생했습니다.');
          break;
        case 'audioLevelUpdate':
          setRecordingDuration(event.duration);
          if (event.audioLevel !== undefined) {
            setAudioLevel(event.audioLevel);
          }
          break;
      }
    });

    return () => {
      updateSubscription.remove();
      actionSubscription.remove();
      errorSubscription.remove();
      audioSubscription.remove();
    };
  }, []);

  // Load active activities on app start
  useEffect(() => {
    refreshActiveActivities();
  }, []);

  const refreshActiveActivities = async () => {
    try {
      const activities = await getActiveActivities();
      setActiveActivities(activities);
    } catch (error) {
      console.error('Failed to get active activities:', error);
    }
  };

  const handleStartFoodDelivery = async () => {
    try {
      const config = createFoodDeliveryActivity({
        id: `food-delivery-${Date.now()}`,
        restaurant: '맛있는 식당',
        status: status || '주문 접수',
        estimatedTime: Number.parseInt(estimatedTime) || 25,
        orderItems: ['김치찌개', '공기밥'],
      });

      const activity = await startActivity(config);
      console.log('Food delivery activity started:', activity);
      Alert.alert('Success', '음식 배달 Activity가 시작되었습니다!');
      refreshActiveActivities();
    } catch (error) {
      console.error('Failed to start food delivery activity:', error);
      Alert.alert('Error', `Failed to start activity: ${error}`);
    }
  };

  const handleStartRideshare = async () => {
    try {
      const config = createRideshareActivity({
        id: `rideshare-${Date.now()}`,
        destination: '강남역',
        status: status || '차량 호출 중',
        eta: Number.parseInt(estimatedTime) || 5,
        driver: {
          name: '김기사',
          vehicle: '현대 아반떼',
          rating: 4.8,
        },
      });

      const activity = await startActivity(config);
      console.log('Rideshare activity started:', activity);
      Alert.alert('Success', '차량 호출 Activity가 시작되었습니다!');
      refreshActiveActivities();
    } catch (error) {
      console.error('Failed to start rideshare activity:', error);
      Alert.alert('Error', `Failed to start activity: ${error}`);
    }
  };

  const handleStartWorkout = async () => {
    try {
      const config = createWorkoutActivity({
        id: `workout-${Date.now()}`,
        workoutType: '러닝',
        duration: Number.parseInt(estimatedTime) || 30,
        calories: 150,
        heartRate: 120,
      });

      const activity = await startActivity(config);
      console.log('Workout activity started:', activity);
      Alert.alert('Success', '운동 Activity가 시작되었습니다!');
      refreshActiveActivities();
    } catch (error) {
      console.error('Failed to start workout activity:', error);
      Alert.alert('Error', `Failed to start activity: ${error}`);
    }
  };

  const handleStartTimer = async () => {
    try {
      const totalTime = Number.parseInt(estimatedTime) * 60 || 300; // Convert to seconds
      const config = createTimerActivity({
        id: `timer-${Date.now()}`,
        name: '요리 타이머',
        totalTime: totalTime,
        remainingTime: totalTime,
        isRunning: true,
      });

      const activity = await startActivity(config);
      console.log('Timer activity started:', activity);
      Alert.alert('Success', '타이머 Activity가 시작되었습니다!');
      refreshActiveActivities();
    } catch (error) {
      console.error('Failed to start timer activity:', error);
      Alert.alert('Error', `Failed to start activity: ${error}`);
    }
  };

  const handleUpdateActivity = async (activityId: string) => {
    try {
      const success = await updateActivity(activityId, {
        status: '업데이트됨',
        estimatedTime: Math.max(1, Number.parseInt(estimatedTime) - 5),
        message: '상태가 업데이트되었습니다',
      });

      if (success) {
        Alert.alert('Success', 'Activity가 업데이트되었습니다!');
        refreshActiveActivities();
      }
    } catch (error) {
      console.error('Failed to update activity:', error);
      Alert.alert('Error', `Failed to update activity: ${error}`);
    }
  };

  const handleEndActivity = async (activityId: string) => {
    try {
      const success = await endActivity(activityId, {
        finalContent: {
          status: '완료',
          message: 'Activity가 완료되었습니다!',
        },
        dismissalPolicy: 'default',
      });

      if (success) {
        Alert.alert('Success', 'Activity가 종료되었습니다!');
        refreshActiveActivities();
      }
    } catch (error) {
      console.error('Failed to end activity:', error);
      Alert.alert('Error', `Failed to end activity: ${error}`);
    }
  };

  const handleStartAudioRecording = async () => {
    try {
      const sessionId = `audio-recording-${Date.now()}`;
      const config = createAudioRecordingActivity({
        id: sessionId,
        title: '회의 녹음',
        duration: 0,
        status: 'recording',
        quality: 'high',
        audioLevel: 0,
      });

      const activity = await startActivity(config);
      console.log('Audio recording activity started:', activity);
      setCurrentRecordingId(sessionId);
      refreshActiveActivities();
    } catch (error) {
      console.error('Failed to start audio recording:', error);
      Alert.alert('Error', `Failed to start recording: ${error}`);
    }
  };

  const handleStopAudioRecording = async () => {
    if (currentRecordingId) {
      try {
        const success = await endActivity(`audio-recording-${currentRecordingId}`, {
          finalContent: {
            status: '완료',
            message: '녹음이 완료되었습니다!',
          },
          dismissalPolicy: 'default',
        });

        if (success) {
          setIsRecording(false);
          setCurrentRecordingId('');
          setRecordingDuration(0);
          refreshActiveActivities();
        }
      } catch (error) {
        console.error('Failed to stop recording:', error);
        Alert.alert('Error', `Failed to stop recording: ${error}`);
      }
    }
  };

  const formatRecordingTime = (seconds: number): string => {
    const mins = Math.floor(seconds / 60);
    const secs = Math.floor(seconds % 60);
    return `${mins.toString().padStart(2, '0')}:${secs.toString().padStart(2, '0')}`;
  };

  return (
    <SafeAreaView style={styles.container}>
      <ScrollView style={styles.container}>
        <Text style={styles.header}>Live Activity Demo</Text>

        <Group name="System Info">
          <Text>Live Activity 지원: {isSupported ? '✅' : '❌'}</Text>
          <Text>Dynamic Island 지원: {isDynamicIslandSupported ? '✅' : '❌'}</Text>
        </Group>

        <Group name="Activity Controls">
          <View style={styles.inputContainer}>
            <Text style={styles.inputLabel}>상태:</Text>
            <TextInput
              style={styles.textInput}
              value={status}
              onChangeText={setStatus}
              placeholder="예: 주문 접수, 배달 중..."
            />
          </View>

          <View style={styles.inputContainer}>
            <Text style={styles.inputLabel}>예상 시간 (분):</Text>
            <TextInput
              style={styles.textInput}
              value={estimatedTime}
              onChangeText={setEstimatedTime}
              placeholder="25"
              keyboardType="numeric"
            />
          </View>

          <View style={styles.buttonContainer}>
            <Button
              title="🍕 음식 배달"
              onPress={handleStartFoodDelivery}
              disabled={!isSupported}
            />
            <Button title="🚗 차량 호출" onPress={handleStartRideshare} disabled={!isSupported} />
          </View>

          <View style={styles.buttonContainer}>
            <Button title="💪 운동" onPress={handleStartWorkout} disabled={!isSupported} />
            <Button title="⏰ 타이머" onPress={handleStartTimer} disabled={!isSupported} />
          </View>
        </Group>

        <Group name="🎙️ 오디오 녹음">
          {isRecording && (
            <View style={styles.recordingInfo}>
              <Text style={styles.recordingStatus}>🔴 녹음 중</Text>
              <Text style={styles.recordingTime}>{formatRecordingTime(recordingDuration)}</Text>
              <View style={styles.audioLevelContainer}>
                <Text style={styles.audioLevelLabel}>음성 레벨:</Text>
                <View style={styles.audioLevelBar}>
                  <View 
                    style={[
                      styles.audioLevelFill, 
                      { width: `${audioLevel * 100}%` }
                    ]} 
                  />
                </View>
                <Text style={styles.audioLevelValue}>{Math.round(audioLevel * 100)}%</Text>
              </View>
            </View>
          )}
          
          <View style={styles.buttonContainer}>
            <Button
              title={isRecording ? "🛑 녹음 중지" : "🎙️ 녹음 시작"}
              onPress={isRecording ? handleStopAudioRecording : handleStartAudioRecording}
              disabled={!isSupported}
              color={isRecording ? "#ff6b6b" : "#4CAF50"}
            />
          </View>
        </Group>

        <Group name={`활성 Activities (${activeActivities.length})`}>
          <Button title="새로고침" onPress={refreshActiveActivities} />

          {activeActivities.length === 0 ? (
            <Text style={styles.emptyText}>활성 Activity가 없습니다</Text>
          ) : (
            activeActivities.map((activity) => (
              <View key={activity.id} style={styles.activityCard}>
                <Text style={styles.activityTitle}>{activity.config.title}</Text>
                <Text style={styles.activityType}>타입: {activity.config.type}</Text>
                <Text style={styles.activityStatus}>상태: {activity.config.content.status}</Text>
                <Text style={styles.activityTime}>
                  예상 시간: {activity.config.content.estimatedTime}분
                </Text>

                <View style={styles.activityButtons}>
                  <Button title="업데이트" onPress={() => handleUpdateActivity(activity.id)} />
                  <Button
                    title="종료"
                    onPress={() => handleEndActivity(activity.id)}
                    color="#ff6b6b"
                  />
                </View>
              </View>
            ))
          )}
        </Group>

        {!isSupported && (
          <Group name="Notice">
            <Text style={styles.noticeText}>
              ⚠️ 이 기기는 Live Activity를 지원하지 않습니다. iOS 16.1 이상에서만 사용 가능합니다.
            </Text>
          </Group>
        )}
      </ScrollView>
    </SafeAreaView>
  );
}

function Group(props: { name: string; children: React.ReactNode }) {
  return (
    <View style={styles.group}>
      <Text style={styles.groupHeader}>{props.name}</Text>
      {props.children}
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#f5f5f5',
  },
  header: {
    fontSize: 28,
    fontWeight: 'bold',
    margin: 20,
    textAlign: 'center',
    color: '#333',
  },
  group: {
    margin: 15,
    backgroundColor: '#fff',
    borderRadius: 12,
    padding: 20,
    shadowColor: '#000',
    shadowOffset: {
      width: 0,
      height: 2,
    },
    shadowOpacity: 0.1,
    shadowRadius: 3.84,
    elevation: 5,
  },
  groupHeader: {
    fontSize: 18,
    fontWeight: '600',
    marginBottom: 15,
    color: '#333',
  },
  inputContainer: {
    marginBottom: 15,
  },
  inputLabel: {
    fontSize: 16,
    fontWeight: '500',
    marginBottom: 5,
    color: '#555',
  },
  textInput: {
    borderWidth: 1,
    borderColor: '#ddd',
    borderRadius: 8,
    paddingHorizontal: 12,
    paddingVertical: 10,
    fontSize: 16,
    backgroundColor: '#f9f9f9',
  },
  buttonContainer: {
    flexDirection: 'row',
    justifyContent: 'space-around',
    marginVertical: 10,
  },
  activityCard: {
    backgroundColor: '#f8f9fa',
    borderRadius: 8,
    padding: 15,
    marginVertical: 8,
    borderLeftWidth: 4,
    borderLeftColor: '#007AFF',
  },
  activityTitle: {
    fontSize: 16,
    fontWeight: '600',
    color: '#333',
    marginBottom: 5,
  },
  activityType: {
    fontSize: 14,
    color: '#666',
    marginBottom: 3,
  },
  activityStatus: {
    fontSize: 14,
    color: '#666',
    marginBottom: 3,
  },
  activityTime: {
    fontSize: 14,
    color: '#666',
    marginBottom: 10,
  },
  activityButtons: {
    flexDirection: 'row',
    justifyContent: 'space-around',
  },
  emptyText: {
    textAlign: 'center',
    color: '#999',
    fontStyle: 'italic',
    marginVertical: 20,
  },
  noticeText: {
    color: '#ff6b6b',
    textAlign: 'center',
    fontSize: 16,
    lineHeight: 24,
  },
  recordingInfo: {
    backgroundColor: '#fff5f5',
    borderRadius: 8,
    padding: 15,
    marginBottom: 15,
    borderLeftWidth: 4,
    borderLeftColor: '#ff6b6b',
  },
  recordingStatus: {
    fontSize: 18,
    fontWeight: '600',
    color: '#d63031',
    textAlign: 'center',
    marginBottom: 10,
  },
  recordingTime: {
    fontSize: 24,
    fontWeight: 'bold',
    color: '#2d3436',
    textAlign: 'center',
    marginBottom: 15,
    fontFamily: 'monospace',
  },
  audioLevelContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
  },
  audioLevelLabel: {
    fontSize: 14,
    color: '#636e72',
    marginRight: 8,
  },
  audioLevelBar: {
    flex: 1,
    height: 8,
    backgroundColor: '#ddd',
    borderRadius: 4,
    marginHorizontal: 8,
    overflow: 'hidden',
  },
  audioLevelFill: {
    height: '100%',
    backgroundColor: '#00b894',
    borderRadius: 4,
  },
  audioLevelValue: {
    fontSize: 12,
    color: '#636e72',
    minWidth: 35,
    textAlign: 'right',
  },
});
