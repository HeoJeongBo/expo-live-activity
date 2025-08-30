import React, { useState } from 'react';
import { View, Text, Button, StyleSheet, Alert, TextInput } from 'react-native';
import { startActivity, updateActivity, endActivity, isSupported } from 'expo-live-activity';
import type { LiveActivityConfig } from './LiveActivityTypes';

export default function WidgetExample() {
  const [taskName, setTaskName] = useState('Sample Task');
  const [status, setStatus] = useState('Starting...');
  const [progress, setProgress] = useState(0);
  const [activeActivityId, setActiveActivityId] = useState<string | null>(null);

  const startLiveActivity = async () => {
    if (!isSupported) {
      Alert.alert('Not Supported', 'Live Activities are not supported on this device');
      return;
    }

    try {
      const config: LiveActivityConfig = {
        attributes: {
          name: taskName,
        },
        content: {
          title: taskName,
          status,
          progress: progress / 100,
          timestamp: new Date(),
        },
      };

      const activity = await startActivity({
        id: `widget-${Date.now()}`,
        type: 'widget',
        title: taskName,
        content: config.content,
        config: {
          attributes: config.attributes,
        },
      });

      setActiveActivityId(activity.id);
      Alert.alert('Success', 'Widget Live Activity started!');
    } catch (error) {
      console.error('Failed to start widget activity:', error);
      Alert.alert('Error', `Failed to start activity: ${error}`);
    }
  };

  const updateLiveActivity = async () => {
    if (!activeActivityId) {
      Alert.alert('No Activity', 'No active Live Activity to update');
      return;
    }

    try {
      const newProgress = Math.min(progress + 20, 100);
      setProgress(newProgress);

      await updateActivity(activeActivityId, {
        title: taskName,
        status: newProgress === 100 ? 'Completed!' : 'In Progress...',
        progress: newProgress / 100,
        timestamp: new Date(),
      });

      Alert.alert('Success', 'Live Activity updated!');
    } catch (error) {
      console.error('Failed to update activity:', error);
      Alert.alert('Error', `Failed to update activity: ${error}`);
    }
  };

  const endLiveActivity = async () => {
    if (!activeActivityId) {
      Alert.alert('No Activity', 'No active Live Activity to end');
      return;
    }

    try {
      await endActivity(activeActivityId, {
        finalContent: {
          status: 'Completed',
          message: 'Task finished successfully!',
        },
        dismissalPolicy: 'default',
      });

      setActiveActivityId(null);
      setProgress(0);
      Alert.alert('Success', 'Live Activity ended!');
    } catch (error) {
      console.error('Failed to end activity:', error);
      Alert.alert('Error', `Failed to end activity: ${error}`);
    }
  };

  return (
    <View style={styles.container}>
      <Text style={styles.title}>Widget Live Activity Demo</Text>
      
      <Text style={styles.supportText}>
        Live Activity Support: {isSupported ? '✅ Supported' : '❌ Not Supported'}
      </Text>

      <View style={styles.inputContainer}>
        <Text style={styles.label}>Task Name:</Text>
        <TextInput
          style={styles.input}
          value={taskName}
          onChangeText={setTaskName}
          placeholder="Enter task name"
        />
      </View>

      <View style={styles.inputContainer}>
        <Text style={styles.label}>Status:</Text>
        <TextInput
          style={styles.input}
          value={status}
          onChangeText={setStatus}
          placeholder="Enter status"
        />
      </View>

      <View style={styles.inputContainer}>
        <Text style={styles.label}>Progress: {progress}%</Text>
        <View style={styles.progressContainer}>
          <View style={[styles.progressBar, { width: `${progress}%` }]} />
        </View>
      </View>

      <View style={styles.buttonContainer}>
        <Button
          title="Start Activity"
          onPress={startLiveActivity}
          disabled={!isSupported || activeActivityId !== null}
        />
      </View>

      <View style={styles.buttonContainer}>
        <Button
          title="Update Activity"
          onPress={updateLiveActivity}
          disabled={!isSupported || activeActivityId === null}
        />
      </View>

      <View style={styles.buttonContainer}>
        <Button
          title="End Activity"
          onPress={endLiveActivity}
          disabled={!isSupported || activeActivityId === null}
          color="#ff6b6b"
        />
      </View>

      {activeActivityId && (
        <View style={styles.statusContainer}>
          <Text style={styles.statusText}>
            Active Activity ID: {activeActivityId}
          </Text>
        </View>
      )}
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    padding: 20,
    backgroundColor: '#f5f5f5',
  },
  title: {
    fontSize: 24,
    fontWeight: 'bold',
    textAlign: 'center',
    marginBottom: 20,
    color: '#333',
  },
  supportText: {
    textAlign: 'center',
    fontSize: 16,
    marginBottom: 20,
    padding: 10,
    backgroundColor: '#fff',
    borderRadius: 8,
  },
  inputContainer: {
    marginBottom: 15,
  },
  label: {
    fontSize: 16,
    fontWeight: '500',
    marginBottom: 5,
    color: '#555',
  },
  input: {
    borderWidth: 1,
    borderColor: '#ddd',
    borderRadius: 8,
    paddingHorizontal: 12,
    paddingVertical: 10,
    fontSize: 16,
    backgroundColor: '#fff',
  },
  progressContainer: {
    height: 8,
    backgroundColor: '#ddd',
    borderRadius: 4,
    overflow: 'hidden',
  },
  progressBar: {
    height: '100%',
    backgroundColor: '#007AFF',
    borderRadius: 4,
  },
  buttonContainer: {
    marginVertical: 8,
  },
  statusContainer: {
    marginTop: 20,
    padding: 15,
    backgroundColor: '#e3f2fd',
    borderRadius: 8,
    borderLeftWidth: 4,
    borderLeftColor: '#2196f3',
  },
  statusText: {
    fontSize: 14,
    color: '#1565c0',
  },
});