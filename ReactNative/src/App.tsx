import React, { useState, useMemo } from 'react';
import { Platform, PermissionsAndroid, View, Text, TouchableOpacity, StyleSheet } from 'react-native';
import { UserInfoContext } from './context/index';
import type { IUserInfo } from './interface/index';
import Login from './pages/Login/Login';
import Home from './pages/Home/Home';
import Call from './pages/Call';
import GroupCall from './pages/GroupCall';

function App(): React.JSX.Element {
  const [userInfo, setUserInfo] = useState<IUserInfo>({
    userID: '',
    SDKAppID: 0,
    SecretKey: '',
    userSig: '',
    isLogin: false,
    currentPage: 'Login',
    isCall: false,
  });

  const [navParams, setNavParams] = useState<any>({});

  const UserInfoContextValue = useMemo(
    () => ({
      userInfo,
      setUserInfo,
    }),
    [userInfo, setUserInfo]
  );

  async function initInfo() {
    if (Platform.OS === 'android') {
      await PermissionsAndroid.requestMultiple([
        PermissionsAndroid.PERMISSIONS
          .RECORD_AUDIO as 'android.permission.RECORD_AUDIO',
        PermissionsAndroid.PERMISSIONS.CAMERA as 'android.permission.CAMERA',
      ]);
      console.log('platform android');
    }
  }

  React.useEffect(() => {
    initInfo();
  }, []);

  const navigate = (page: string, params: any = {}) => {
    setUserInfo(prev => ({ ...prev, currentPage: page }));
    setNavParams(params);
  };

  const goBack = () => {
    setUserInfo(prev => ({ ...prev, currentPage: 'Home' }));
  };

  const renderPage = () => {
    const currentPage = userInfo.currentPage;

    switch (currentPage) {
      case 'Login':
        return <Login onNavigate={navigate} />;
      case 'Home':
        return <Home onNavigate={navigate} />;
      case 'Call':
        return <Call params={navParams} onGoBack={goBack} />;
      case 'GroupCall':
        return <GroupCall params={navParams} onGoBack={goBack} />;
      default:
        return <Login onNavigate={navigate} />;
    }
  };

  return (
    <UserInfoContext.Provider value={UserInfoContextValue}>
      <View style={styles.container}>
        {userInfo.currentPage !== 'Login' && userInfo.currentPage !== 'Home' && (
          <View style={styles.header}>
            <TouchableOpacity onPress={goBack} style={styles.backButton}>
              <Text style={styles.backText}>← Back</Text>
            </TouchableOpacity>
            <Text style={styles.title}>{userInfo.currentPage}</Text>
            <View style={styles.placeholder} />
          </View>
        )}
        {renderPage()}
      </View>
    </UserInfoContext.Provider>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  header: {
    height: 50,
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    paddingHorizontal: 10,
    backgroundColor: '#f0f0f0',
    borderBottomWidth: 1,
    borderBottomColor: '#ddd',
  },
  backButton: {
    padding: 5,
  },
  backText: {
    fontSize: 16,
    color: '#007AFF',
  },
  title: {
    fontSize: 18,
    fontWeight: 'bold',
  },
  placeholder: {
    width: 60,
  },
});

export default App;
