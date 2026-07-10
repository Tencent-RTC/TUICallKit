import { ref } from 'vue';
import type { LoginParams, LoginUserInfo, SetSelfInfoParams } from '../types/login';
import TencentCloudChat from '@tencentcloud/lite-chat/basic';
import TUIStore from '../utils/TUIStore';
import { UI_PLATFORM } from '../constants/chat';
import { EVENT } from "../constants/event";
import { TUIBridge } from '../TUIBridge/index';

const loginUserInfo = ref<LoginUserInfo | null>(null);
// We keep the original TencentCloudChat wiring intact — chatCombine reads
// `{ chat, userID, userSig, SDKAppID }` off the LOGIN_SUCCESS event, and
// the engine login throws if `userID` is empty. The chat instance is
// created here so the payload shape stays exactly what chatCombine expects.
async function login(options: LoginParams) {
  console.log('[loginState login] options', options);

  if (!options.userId || !options.userSig || !options.sdkAppId) {
    throw new Error('[loginState login] params error');
  }

  const { userId, userSig, sdkAppId } = options;

  const loginParams = {
    SDKAppID: sdkAppId,
    scene: UI_PLATFORM.UNI_MINI_APP,
  };

  try {
    wx.$chat = TencentCloudChat.create(loginParams);
    await wx.$chat.login({ userID: userId, userSig });

    const params = {
      chat: wx.$chat,
      userID: userId,
      userSig,
      SDKAppID: sdkAppId,
    };
    TUIBridge.notifyEvent({ eventName: EVENT.LOGIN_SUCCESS, params });

    TUIStore.emitEvent(EVENT.LOGIN_SUCCESS);

    await getMyProfile(userId);
  } catch (error) {
    console.error('[loginState login] error', error);
    throw error;
  }
}

async function logout() {
  try {
    console.log('[loginState logout]');
    await wx.$chat.logout();
    TUIBridge.notifyEvent({ eventName: EVENT.LOGOUT_SUCCESS, params: {} });

    await wx.$chat.destroy();
    wx.$chat = null;
  } catch (error) {
    console.error('[loginState logout] error', error);
  }
}

async function getMyProfile(userID: string) {
  const result = await wx.$chat.getUserProfile({ userIDList: [userID] });
  const localUserInfo = result.data[0];
  if (!localUserInfo.value) {
    loginUserInfo.value = {
      userId: localUserInfo.userID,
      userName: localUserInfo.nick,
      avatarUrl: localUserInfo.avatar,
      customInfo: localUserInfo.profileCustomField,
    };
  }
}

async function setSelfInfo(options: SetSelfInfoParams): Promise<void> {
  const currentLoginUserInfo = loginUserInfo.value || {} as LoginUserInfo;
  if (!wx.$chat) {
    throw Error('[loginState setSelfInfo] not login');
  } else {
    const profileCustomField: any[] = [];
    if (options.customInfo) {
      Object.keys(options.customInfo).forEach((key) => {
        let customKey = key;
        if (!key.includes('Tag_Profile_Custom')) {
          customKey = `Tag_Profile_Custom_${key}`;
        }
        profileCustomField.push({
          key: customKey,
          value: options.customInfo?.[key],
        });
      });
    }
    try {
      const res = await wx.$chat.updateMyProfile({
        nick: options.userName,
        avatar: options.avatarUrl,
        profileCustomField,
      });
      loginUserInfo.value = {
        ...currentLoginUserInfo,
        ...options,
      };
      return res;
    } catch (error) {
      console.error('[loginState setSelfInfo] error', error);
      throw error;
    }
  }
}

export function useLoginState() {
  return {
    loginUserInfo,
    login,
    logout,
    setSelfInfo
  };
}


export default useLoginState;
