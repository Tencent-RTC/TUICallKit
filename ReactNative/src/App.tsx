import React, { useState, useMemo } from 'react';
import { NavigationContainer } from '@react-navigation/native';
import { createNativeStackNavigator } from '@react-navigation/native-stack';
import { UserInfoContext } from './context/index';
import Login from './pages/Login/Login';
import Home from './pages/Home/Home';
import Call from './pages/Call';
import GroupCall from './pages/GroupCall';

function App(): React.JSX.Element {
  const Stack = createNativeStackNavigator();

  const [userInfo, setUserInfo] = useState({
    userID: '',
    SDKAppID: 0,
    SecretKey: '',
    userSig: '',
    isLogin: false,
    currentPage: 'home',
    isCall: false,
  });
  const UserInfoContextValue = useMemo(
    () => ({
      userInfo,
      setUserInfo,
    }),
    [userInfo, setUserInfo]
  );

  return (
    <UserInfoContext.Provider value={UserInfoContextValue}>
      <NavigationContainer>
        <Stack.Navigator
          initialRouteName="Login"
          screenOptions={{
            headerTitleAlign: 'center',
          }}
        >
          <Stack.Screen
            name="Login"
            component={Login}
            options={{ headerShown: false }}
          />
          <Stack.Screen
            name="Home"
            component={Home}
            options={{ headerShown: false }}
          />
          <Stack.Screen
            name="Call"
            component={Call}
            options={{
              title: '1v1 Call',
              headerBackVisible: true,
            }}
          />
          <Stack.Screen
            name="GroupCall"
            component={GroupCall}
            options={{ title: 'Group Call' }}
          />
        </Stack.Navigator>
      </NavigationContainer>
    </UserInfoContext.Provider>
  );
}

export default App;
