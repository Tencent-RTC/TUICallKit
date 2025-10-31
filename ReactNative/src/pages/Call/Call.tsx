import React, { useState } from 'react';
import {
  View,
  Text,
  TextInput,
  TouchableOpacity,
  StyleSheet,
} from 'react-native';
import { TUICallKit, MediaType } from '@tencentcloud/call-uikit-react-native';

interface CallProps {
  params?: any;
  onGoBack: () => void;
}

export default function Call({ params = {}, onGoBack }: CallProps): React.JSX.Element {
  const [calleeID, setCalleeID] = useState('');
  const { callType = 'video' } = params;

  const call = () => {
    TUICallKit.call(
      {
        userId: calleeID,
        mediaType: callType === 'audio' ? MediaType.Audio : MediaType.Video,
        callParams: {
          offlinePushInfo: {
            title: 'test-title',
            desc: 'test-desc',
          },
        },
      },
      () => {
        console.log('call success');
      },
      () => {
        console.log('call error');
      }
    );
  };

  return (
    <View style={styles.container}>
      <View style={styles.input_box}>
        <Text style={styles.input_box_prefix}> userID </Text>
        <TextInput
          style={styles.input_box_text}
          placeholder="input the userID to Call"
          value={calleeID}
          onChangeText={(value) => setCalleeID(value)}
        />
      </View>
      <TouchableOpacity style={styles.call_btn} onPress={call}>
        <Text style={styles.call_btn_text}> Initiate Call </Text>
      </TouchableOpacity>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    padding: 10,
  },
  input_box: {
    flexDirection: 'row',
    width: '100%',
    height: 55,
    borderRadius: 5,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: '#fff',
  },
  input_box_prefix: {
    borderRadius: 5,
    lineHeight: 55,
    height: '100%',
    backgroundColor: '#fff',
  },
  input_box_text: {
    flex: 1,
    height: '100%',
    backgroundColor: '#fff',
    borderRadius: 5,
  },
  call_btn: {
    width: '100%',
    height: 46,
    borderRadius: 5,
    backgroundColor: '#0c59f2',
    justifyContent: 'center',
    marginTop: 20,
  },
  call_btn_text: {
    color: '#fff',
    fontWeight: 600,
    fontSize: 16,
    textAlign: 'center',
  },
});
