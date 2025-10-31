import React, { useState } from 'react';
import {
  View,
  Text,
  TextInput,
  TouchableOpacity,
  StyleSheet,
} from 'react-native';
import { TUICallKit, MediaType } from '@tencentcloud/call-uikit-react-native';

interface GroupCallProps {
  params?: any;
  onGoBack: () => void;
}

export default function GroupCall({ params = {}, onGoBack }: GroupCallProps): React.JSX.Element {
  const [calleeID, setCalleeID] = useState('');
  const { callType = 'video' } = params;

  const groupCall = () => {
    const userIDList = calleeID.split(',');
    TUICallKit.groupCall(
      {
        userIdList: userIDList,
        mediaType: callType === 'audio' ? MediaType.Audio : MediaType.Video,
        groupId: '@TGS#2VWQGGHOE',
      },
      (res) => {
        console.log('groupCall success', res);
      },
      (errCode, errMsg) => {
        console.log('groupCall error', errCode, errMsg);
      }
    );
  };

  return (
    <View style={styles.container}>
      <View style={styles.input_box}>
        <Text style={styles.input_box_prefix} > userID </Text>
        <TextInput
          style={styles.input_box_text}
          placeholder="Enter the group call userIDList, eg: user1,user2"
          value={calleeID}
          onChangeText={(value) => setCalleeID(value)}
        />
      </View>
      <TouchableOpacity style={styles.call_btn} onPress={groupCall}>
        <Text style={styles.call_btn_text}> Initiate Group Call </Text>
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
