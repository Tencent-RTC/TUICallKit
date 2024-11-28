import React, { useState, useContext } from 'react';
import { useNavigation } from '@react-navigation/native';
import {
  View,
  Text,
  Image,
  ImageBackground,
  StyleSheet,
  TextInput,
  TouchableOpacity,
} from 'react-native';
import { TUICallEvent, TUICallKit } from '@tencentcloud/call-uikit-react-native';
import Chat from '@tencentcloud/chat';
import { UserInfoContext } from '../../context';
import { genTestUserSig } from '../../debug/GenerateTestUserSig-es';

const LOGO_EN_SRC = require('../../assets/logo-en.png');
const BG_SRC = require('../../assets/bg.png');

export default function Login(): React.JSX.Element {
  const { userInfo, setUserInfo } = useContext(UserInfoContext);
  const navigation: any = useNavigation();
  const [userID, setUserID] = useState('');

  function onRtcListener(type: TUICallEvent, params: any) {
    if (type === TUICallEvent.onCallBegin) {
      console.log('==onCallBegin params:', params);
    }
    if (type === TUICallEvent.onCallBegin) {
      console.log('==onCallBegin params:', params);
    }
    if (type === TUICallEvent.onCallEnd) {
      console.log('==onCallEnd');
    }
    if (type === TUICallEvent.onCallCancelled) {
      console.log('==onCallCancelled params:', params);
    }
    if (type === TUICallEvent.onError) {
      console.log('==onError');
    }
    if (type === TUICallEvent.onCallReceived) {
      console.log('==onCallReceived');
    }
    if (type === TUICallEvent.onUserJoin) {
      console.log('==onUserJoin');
    }
  }

  const handleLogin = async () => {
    const { SDKAppID, userSig } = genTestUserSig({ userID });

    TUICallKit.login(
      {
        sdkAppId: Number(SDKAppID),
        userId: String(userID),
        userSig,
      },
      (res) => {
        console.log('login success', res);
      },
      (errCode, errMsg) => {
        console.log('login error', errCode, errMsg, SDKAppID, userID, userSig);
      }
    );
    const chat = Chat.create({ SDKAppID });
    await chat.login({ userID: String(userID), userSig });
    
    TUICallKit.on(onRtcListener);
    setUserInfo({
      ...userInfo,
      userID,
      currentPage: 'login',
      SDKAppID,
      userSig,
      chat,
    });

    navigation.navigate('Home');
  };

  return (
    <View style={styles.container}>
      <ImageBackground
        style={styles.img_bg}
        source={BG_SRC}
        resizeMode="stretch"
      >
        <Image style={styles.img_logo} source={LOGO_EN_SRC} />
      </ImageBackground>
      <View style={styles.box_login}>
        <TextInput
          style={styles.input_userID}
          onChangeText={(value) => setUserID(String(value))}
          value={userID}
          placeholder="Please enter the userID to create or log in"
        />
        <Text style={styles.text_login_tip}>32 Char Limit,A-Z a-z 0-9 _ -</Text>
        <TouchableOpacity
          style={{
            backgroundColor: '#0070f0',
            width: '100%',
            height: 60,
            flexDirection: 'row',
            alignItems: 'center',
            justifyContent: 'center',
            borderRadius: 10,
          }}
          onPress={handleLogin}
        >
          <Text style={{ color: '#fff' }}> Create / Log in </Text>
        </TouchableOpacity>
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    width: '100%',
    height: '100%',
    backgroundColor: '#fff',
  },
  img_bg: {
    height: 300,
    alignItems: 'center',
  },
  img_logo: {
    width: 250,
    height: 50,
    marginTop: 100,
  },
  box_login: {
    padding: 20,
    rowGap: 20,
  },
  input_userID: {
    height: 52,
    padding: 10,
    borderWidth: 1,
    borderRightColor: '#E7ECF6',
    borderRadius: 5,
    backgroundColor: '#fff',
  },
  text_login_tip: {
    color: '#99a2b2',
    marginTop: -10,
  },
});
