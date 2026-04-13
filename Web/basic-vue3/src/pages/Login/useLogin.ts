import { toRefs } from "vue";
import { TUICallKitAPI } from '@trtc/calls-uikit-vue';
// @ts-ignore
import TencentCloudChat from '@tencentcloud/lite-chat/basic';
// @ts-ignore
import * as GenerateTestUserSig from "../../debug/GenerateTestUserSig-es";
import { useMessage, useUserInfo, useMyRouter, useAegis } from "../../hooks";
// @ts-ignore
import { checkUserID, getUrlParam } from "../../utils";


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
    const sdkAppId = getUrlParam('sdkAppId') || '';
    const secretKey = getUrlParam('secretKey');
    const { SDKAppID, userSig, SecretKey } = GenerateTestUserSig.genTestUserSig({
      userID: userID.value, 
      SDKAppID: userInfo?.SDKAppID.value || +sdkAppId, 
      SecretKey: userInfo?.SecretKey.value || secretKey, 
    });
    if (!SDKAppID || !SecretKey) {
      handleLoginMessage('userSig')
      return;
    }
    try {
      const isTestEnv = getUrlParam('isTestEnv');
      const isDevMode = getUrlParam('isDevMode');
      const options = {
        SDKAppID,
        testEnv: isTestEnv === 'true',
        devMode: isDevMode === 'true',
      };
      const chat = TencentCloudChat.create(options);

      // 虚拟背景需要设置 assetsPath
      let assetsPath = 'xxx'; // 例如: https://web.sdk.qcloud.com/trtc/call/rg-test/4.4.2/virtualBackground/assets
      // @ts-ignore
      const params = {
        api: 'setAssetsPath',
        params: {
          assetsPath, // 资源文件存放地址
        }
      };
      TUICallKitAPI?.callExperimentalAPI(JSON.stringify(params));

      await TUICallKitAPI.init({
        userID: userID.value,
        SDKAppID,
        userSig,
        tim: chat,
      });
      TUICallKitAPI.enableAITranscriber(true);
      userInfo.userID.value = userID.value;
      userInfo.SDKAppID.value = SDKAppID;
      userInfo.SecretKey.value = SecretKey;
      userInfo.isLogin.value = true;
      userInfo.userSig.value = userSig;

      const hashList = window.location.hash.split('?');
      const queryParamStr = hashList.length > 1 ? hashList[1] : '';
      navigate(`/home?${queryParamStr}`);
      reportEvent({ 
        apiName: 'login.success',
        content: JSON.stringify(userInfo),
      });
    } catch (error) {
      handleCallError('login', error);
    }
    TUICallKitAPI.enableVirtualBackground(true);
  }

  return {
    login,
  }
}

