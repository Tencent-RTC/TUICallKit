import { toRefs } from "vue";
import { TUICallKitServer } from '@tencentcloud/call-uikit-vue';
// @ts-ignore
import TencentCloudChat from '@tencentcloud/chat';
// @ts-ignore
import * as GenerateTestUserSig from "../../debug/GenerateTestUserSig-es";
import { useMessage, useUserInfo, useMyRouter, useAegis } from "../../hooks";
import { checkUserID, getUrlParams } from "../../utils";


export default function useLogin() {
  const { navigate } = useMyRouter();
  const { reportEvent } = useAegis();
  const userInfo = toRefs(useUserInfo());
  const { handleLoginMessage, handleCallError } = useMessage();

  const login = async (userID: any) => {    
    if (!userID.value) {
      handleLoginMessage('empty');
      userID.value = '';
      return;
    }
    if (!checkUserID(userID.value)) {
      handleLoginMessage('errorFormat');
      userID.value = '';
      return;
    }
    const { SDKAppID, userSig, SecretKey } = GenerateTestUserSig.genTestUserSig({
      userID: userID.value, 
      SDKAppID: userInfo?.SDKAppID.value, 
      SecretKey: userInfo?.SecretKey.value, 
    });
    if (!SDKAppID || !SecretKey) {
      handleLoginMessage('userSig')
      return;
    }
    try {
      const { isChatTestEnv } = getUrlParams(['isChatTestEnv']);
      const options = { SDKAppID, testEnv: isChatTestEnv === 'true' };
      const chat = TencentCloudChat.create(options);

      await TUICallKitServer.init({
        userID: userID.value,
        SDKAppID,
        userSig,
        tim: chat,
      });
      userInfo.userID.value = userID.value;
      userInfo.SDKAppID.value = SDKAppID;
      userInfo.SecretKey.value = SecretKey;
      userInfo.isLogin.value = true;
      userInfo.userSig.value = userSig;
      navigate('/home');
      reportEvent({ 
        apiName: 'login.success',
        content: JSON.stringify(userInfo),
      });
    } catch (error) {
      handleCallError('login', error);
    }
    TUICallKitServer.enableVirtualBackground(true);
  }

  return {
    login,
  }
}

