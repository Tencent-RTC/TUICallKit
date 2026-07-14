import { CallMediaType } from '@trtc/call-engine-lite-wx';
import { NAME, StoreName } from '../const/index';
import { handleNoDevicePermissionError } from '../utils/common-utils';
import { IUserInfo } from '../interface/ICallService';
import { ITUIStore } from '../interface/ITUIStore';
import { CallTips, t } from '../locales/index';
import TuiStore from '../TUIStore/tuiStore';
// @ts-ignore
const TUIStore: ITUIStore = TuiStore.getInstance();

// 设置默认的 UserInfo 信息
export function setDefaultUserInfo(userId: string, domId?: string): IUserInfo {
  const userInfo: IUserInfo = {
    userId,
    nick: '',
    avatar: '',
    remark: '',
    displayUserInfo: '',
    isMicrophoneOpened: false,
    isCameraOpened: false,
    isEnter: false,
    domId: domId || userId,
  };
  return domId ? userInfo : { ...userInfo, isEnter: false }; // localUserInfo 没有 isEnter, remoteUserInfoList 有 isEnter
}
// Fetch the local user's own IM profile (nick / avatar) and merge it into the
// LOCAL_USER_INFO store entry. Without this, LOCAL_USER_INFO only carries the
// userId plus camera/mic flags, so the self tile has an empty avatar and falls
// back to the default image - while remote peers (populated via
// getRemoteUserProfile) render this same user with their real IM avatar. That
// mismatch is why a camera-off user looks different locally vs. remotely.
// We merge onto the current store snapshot so concurrent camera/mic toggles
// that happened during login are preserved.
export async function getMyProfile(myselfUserId: string, tim: any): Promise<void> {
  try {
    if (!tim) return;
    let profile: any = null;
    // Prefer getMyProfile when the SDK exposes it; otherwise fall back to
    // getUserProfile with the local userId (lite-chat supports the latter).
    if (typeof tim.getMyProfile === 'function') {
      const res = await tim.getMyProfile();
      if (res?.code === 0) profile = res.data;
    }
    if (!profile && typeof tim.getUserProfile === 'function') {
      const res = await tim.getUserProfile({ userIDList: [myselfUserId] });
      if (res?.code === 0) profile = (res.data || [])[0];
    }
    if (!profile) return;

    const currentLocalUserInfo = TUIStore?.getData(StoreName.CALL, NAME.LOCAL_USER_INFO) || {};
    const localUserInfo = {
      ...currentLocalUserInfo,
      userId: profile.userID || currentLocalUserInfo.userId || myselfUserId,
      nick: profile.nick || currentLocalUserInfo.nick || '',
      avatar: profile.avatar || currentLocalUserInfo.avatar || '',
      displayUserInfo: profile.nick || profile.userID || myselfUserId,
    };
    TUIStore.update(StoreName.CALL, NAME.LOCAL_USER_INFO, localUserInfo);
    TUIStore.update(StoreName.CALL, NAME.LOCAL_USER_INFO_EXCLUDE_VOLUMN, localUserInfo);
  } catch (error) {
    console.error(`${NAME.PREFIX}getMyProfile failed, error: ${error}.`);
  }
}
// 获取远端用户列表信息
export async function getRemoteUserProfile(userIdList: Array<string>, tim: any): Promise<any> {
  let remoteUserInfoList: IUserInfo[] = userIdList.map((userId: string) => setDefaultUserInfo(userId));
  try {
    if (!tim) return remoteUserInfoList;

    // Prefer getFriendProfile when available so we honor the local user's
     // remark for friends; fall back to getUserProfile for non-friends so we
     // still populate nick/avatar. Both branches merge results back into the
     // current store snapshot to preserve concurrent updates (e.g. camera /
     // mic toggles that arrived while the profile request was in flight).
    const currentRemoteUserInfoList: IUserInfo[]
      = TUIStore?.getData(StoreName.CALL, NAME.REMOTE_USER_INFO_LIST) || [];

    if (tim?.getFriendProfile) {
      let friendList: any[] = [];
      let failureUserIDList: any[] = [];
      try {
        const res = await tim.getFriendProfile({ userIDList: userIdList });
        if (res?.code === 0) {
          friendList = res.data?.friendList || [];
          failureUserIDList = res.data?.failureUserIDList || [];
        }
      } catch (e) {
        console.warn(`${NAME.PREFIX}getFriendProfile failed:`, e);
      }

      // For userIds that are not friends, fetch their public profile so we
      // still get nick / avatar to render in the UI.
      let unFriendList: any[] = [];
      const nonFriendIds = failureUserIDList
        .map((obj: any) => (typeof obj === 'string' ? obj : obj?.userID))
        .filter(Boolean);
      if (nonFriendIds.length > 0 && tim?.getUserProfile) {
        try {
          const userRes = await tim.getUserProfile({ userIDList: nonFriendIds });
          if (userRes?.code === 0) unFriendList = userRes.data || [];
        } catch (e) {
          console.warn(`${NAME.PREFIX}getUserProfile (non-friends) failed:`, e);
        }
      }

      remoteUserInfoList = userIdList.map((userId: string) => {
        const defaultUserInfo: IUserInfo = setDefaultUserInfo(userId);
        const existing = currentRemoteUserInfoList.find(u => u.userId === userId) || {};

        const friend = friendList.find((f: any) => f?.userID === userId);
        const unFriend = unFriendList.find((u: any) => u?.userID === userId);

        const remark = friend?.remark || '';
        const nick = friend?.profile?.nick || unFriend?.nick || '';
        const avatar = friend?.profile?.avatar || unFriend?.avatar || '';
        const displayUserInfo = remark || nick || userId;

        return {
          ...defaultUserInfo,
          ...existing,
          remark,
          nick,
          avatar,
          displayUserInfo,
        };
      });
      return remoteUserInfoList;
    }

    const res = await tim.getUserProfile({ userIDList: userIdList });
    remoteUserInfoList = userIdList.map((userId: string) => {
      const defaultUserInfo: IUserInfo = setDefaultUserInfo(userId);
      const existing = currentRemoteUserInfoList.find(u => u.userId === userId) || {};
      const userData = (res?.data || []).find((obj: any) => obj.userID === userId) || {};

      return {
        ...defaultUserInfo,
        ...existing,
        nick: userData?.nick || '',
        displayUserInfo: userData?.nick || userId,
        avatar: userData?.avatar || '',
      };
    });
    return remoteUserInfoList;
  } catch (error) {
    console.error(`${NAME.PREFIX}getRemoteUserProfile failed, error: ${error}.`);
    return remoteUserInfoList;
  }
}
// 获取群组[offset, count + offset]区间成员
// export async function getGroupMemberList(groupID: string, tim: any, count, offset) {
//   let groupMemberList = [];
//   try {
//     const res = await tim.getGroupMemberList({ groupID, count, offset });
//     if (res.code === 0) {
//       return res.data.memberList || groupMemberList;
//     }
//   } catch(error) {
//     console.error(`${NAME.PREFIX}getGroupMember failed, error: ${error}.`);
//     return groupMemberList;
//   }
// }
// 获取 IM 群信息
// export async function getGroupProfile(groupID: string, tim: any): Promise<any> {
//   let groupProfile = {};
//   try {
//     const res = await tim.getGroupProfile({ groupID });
//     return res.data.group || groupProfile;
//   } catch(error) {
//     console.warn(`${NAME.PREFIX}getGroupProfile failed, error: ${error}.`);
//     return groupProfile;
//   }
// }
/**
 * web and miniProgram call engine throw event data structure are different
 * @param {any} event call engine throw out data
 * @returns {any} data
 */
export function analyzeEventData(event: any): any {
  return event || {};
}
/**
 * delete user from remoteUserInfoList
 * @param {string[]} userIdList to be deleted userIdList
 * @param {ITUIStore} TUIStore TUIStore instance
 */
export function deleteRemoteUser(userIdList: string[]): void {
  if (userIdList.length === 0) return;
  let remoteUserInfoList = TUIStore.getData(StoreName.CALL, NAME.REMOTE_USER_INFO_LIST);
  userIdList.forEach((userId) => {
    remoteUserInfoList = remoteUserInfoList.filter((obj: IUserInfo) => obj.userId !== userId);
  });
  TUIStore.update(StoreName.CALL, NAME.REMOTE_USER_INFO_LIST, remoteUserInfoList);
  TUIStore.update(StoreName.CALL, NAME.REMOTE_USER_INFO_EXCLUDE_VOLUMN_LIST, remoteUserInfoList);
}
/**
 * update the no device permission toast
 * @param {any} error error
 * @param {CallMediaType} type call midia type
 * @param {any} tuiCallEngine TUICallEngine instance
 */
export function noDevicePermissionToast(error, type: CallMediaType, tuiCallEngine: any) {
  let toastInfoKey = '';
  if (handleNoDevicePermissionError(error)) {
    if (type === CallMediaType.AUDIO) {
      toastInfoKey = CallTips.NO_MICROPHONE_DEVICE_PERMISSION;
    }
    if (type === CallMediaType.VIDEO) {
      toastInfoKey = CallTips.NO_CAMERA_DEVICE_PERMISSION;
    }

    toastInfoKey && TUIStore.update(StoreName.CALL, NAME.TOAST_INFO, { content: toastInfoKey, type: NAME.ERROR });
    console.error(`${NAME.PREFIX}call failed, error: ${error.message}.`);
  }
}
/**
 * set localUserInfo audio/video available
 * @param {boolean} isAvailable is available
 * @param {string} type callMediaType 'audio' | 'video'
 * @param {ITUIStore} TUIStore TUIStore instance
 */
export function setLocalUserInfoAudioVideoAvailable(isAvailable: boolean, type: string) {
  let localUserInfo = TUIStore.getData(StoreName.CALL, NAME.LOCAL_USER_INFO);
  if (type === NAME.AUDIO) {
    localUserInfo = { ...localUserInfo, isMicrophoneOpened: isAvailable };
  }
  if (type === NAME.VIDEO) {
    localUserInfo = { ...localUserInfo, isCameraOpened: isAvailable };
  }
  TUIStore.update(StoreName.CALL, NAME.LOCAL_USER_INFO, localUserInfo);
  TUIStore.update(StoreName.CALL, NAME.LOCAL_USER_INFO_EXCLUDE_VOLUMN, localUserInfo);
}
