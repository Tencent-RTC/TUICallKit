import React, { useState, useContext } from 'react';
import { View, Text, Image, TouchableOpacity, StyleSheet } from 'react-native';
import { UserInfoContext } from '../../context';

const LOGO_EN_SRC = require('../../assets/logo-en.png');
const CALL_SVG_SRC = require('../../assets/call.png');
const GROUP_CALL_SVG_SRC = require('../../assets/group-call.png');

interface HomeProps {
  onNavigate: (page: string, params?: any) => void;
}

export default function Home({ onNavigate }: HomeProps): React.JSX.Element {
  const { userInfo } = useContext(UserInfoContext);
  const [callType, setCallType] = useState('video');

  const goCall = () => {
    onNavigate('Call', { callType: callType });
  };
  const goGroupCall = () => {
    onNavigate('GroupCall', { callType: callType });
  };

  return (
    <View style={styles.container}>
      <Text> userID: {userInfo.userID}</Text>
      <Image style={styles.img_logo} source={LOGO_EN_SRC} />
      <View style={styles.segmented_box}>
        <TouchableOpacity
          style={[callType === 'video' && styles.segmented_content_active]}
          onPress={() => setCallType('video')}
        >
          <Text
            style={[
              callType === 'video'
                ? styles.segmented_text_active
                : styles.segmented_text,
            ]}
          >
            Video Call
          </Text>
        </TouchableOpacity>
        <TouchableOpacity
          style={[callType === 'audio' && styles.segmented_content_active]}
          onPress={() => setCallType('audio')}
        >
          <Text
            style={[
              callType === 'audio'
                ? styles.segmented_text_active
                : styles.segmented_text,
            ]}
          >
            Voice Call
          </Text>
        </TouchableOpacity>
      </View>
      <View
        style={{
          marginTop: 200,
          height: 150,
          justifyContent: 'space-between',
        }}
      >
        <TouchableOpacity style={styles.btn_box} onPress={goCall}>
          <Image style={styles.btn_box_icon} source={CALL_SVG_SRC} />
          <Text style={styles.btn_box_text}> 1v1 Call </Text>
        </TouchableOpacity>
        <TouchableOpacity style={styles.btn_box} onPress={goGroupCall}>
          <Image style={styles.btn_box_icon} source={GROUP_CALL_SVG_SRC} />
          <Text style={styles.btn_box_text}> Group Call </Text>
        </TouchableOpacity>
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    width: '100%',
    height: '100%',
    padding: 20,
    backgroundColor: '#fff',
    alignContent: 'center',
  },
  img_logo: {
    width: 250,
    height: 50,
    marginTop: 100,
    marginLeft: 'auto',
    marginRight: 'auto',
  },
  segmented_box: {
    width: 170,
    height: 36,
    paddingLeft: 5,
    paddingRight: 5,
    borderRadius: 24,
    backgroundColor: '#EAEEF6',
    alignItems: 'center',
    flexDirection: 'row',
    justifyContent: 'space-between',
    marginLeft: 'auto',
    marginRight: 'auto',
    marginTop: 20,
  },
  segmented_content_active: {
    width: 80,
    height: 30,
    borderRadius: 24,
    alignItems: 'center',
    justifyContent: 'center',
    backgroundColor: '#fff',
  },
  segmented_text_active: {
    color: '#1C66E5',
  },
  segmented_text: {
    color: '#8F9AB2',
  },
  btn_box: {
    backgroundColor: '#0070f0',
    width: '100%',
    height: 60,
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    borderRadius: 10,
  },
  btn_box_icon: {
    width: 20,
    height: 24,
  },
  btn_box_text: {
    color: '#fff',
  },
});
