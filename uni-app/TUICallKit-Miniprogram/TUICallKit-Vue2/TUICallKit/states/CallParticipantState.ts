import { ref } from '../adapter/vue-demi';
import { TUIStore, StoreName, NAME, CallStatus, CallRole } from './TUICallService/index';

// UI-facing participant model consumed by CallView / GroupCallView.
// Uses id / name / avatarUrl (mapped from the underlying store's
// userId / nick / avatar in the handlers below).
export interface ICallParticipant {
  id: string;
  name?: string;
  avatarUrl?: string;
  remark?: string;
  isMicrophoneOpened?: boolean;
  isCameraOpened?: boolean;
  volume?: number;
}

export interface ICallParticipantInfo {
  selfInfo: Partial<ICallParticipant> & { status?: CallStatus; role?: CallRole };
  // Authoritative caller (inviter) info, mapped from the store's
  // CALLER_USER_INFO. This is resolved directly from the invitation event +
  // profile fetch and does NOT depend on the ordering / async mutations of
  // allParticipants, so it is the reliable source for the callee waiting page.
  callerInfo: Partial<ICallParticipant>;
  allParticipants: ICallParticipant[];
  speakerVolumes: any[];
  networkQualities: any[];
  isGroup: boolean;
}

const callParticipantInfo = ref<ICallParticipantInfo>({
  selfInfo: { status: CallStatus.IDLE },
  callerInfo: {},
  allParticipants: [],
  speakerVolumes: [],
  networkQualities: [],
  isGroup: false,
});

let callTimer: number | null = null;

TUIStore?.watch(StoreName.CALL, {
  [NAME.CALL_ROLE]: _handleCallRoleChange,
  [NAME.CALL_STATUS]: _handleCallStatusChange,
  [NAME.LOCAL_USER_INFO]: _handleLocalUserInfoChange,
  [NAME.REMOTE_USER_INFO_LIST]: _handleRemoteUserInfoListChange,
  [NAME.CALLER_USER_INFO]: _handleCallerUserInfoChange,
  [NAME.IS_GROUP]: _handleIsGroupChange,
});
function _handleCallRoleChange(value: CallRole) {
  callParticipantInfo.value.selfInfo.role = value;
}
function _handleCallStatusChange(value: CallStatus) {
  console.log(`callStatus change: ${value}`);

  callParticipantInfo.value.selfInfo.status = value;
  if (value === CallStatus.IDLE) {
    handleCallStatusToIdle();
  }
  if (value === CallStatus.CALLING || value === CallStatus.CONNECTED) {
    handleCallStatusToCalling();
  }
}
function _handleLocalUserInfoChange(value) {
  // The underlying store already exposes camera / microphone state as
  // isMicrophoneOpened / isCameraOpened (see CallService/utils.ts
  // `setLocalUserInfoAudioVideoAvailable`). Read those directly instead of
  // trying to derive them from the non-existent isAudioAvailable /
  // isVideoAvailable fields.
  const {
    userId,
    nick = '',
    avatar = '',
    remark = '',
    isMicrophoneOpened,
    isCameraOpened,
    volume,
  } = value;
  const selfInfo: ICallParticipant = {
    id: userId || '',
    name: nick,
    avatarUrl: avatar,
    remark: remark,
    isMicrophoneOpened: isMicrophoneOpened,
    isCameraOpened: isCameraOpened,
    volume: volume,
  };

  callParticipantInfo.value.selfInfo = { ...callParticipantInfo.value.selfInfo, ...selfInfo };
}
function _handleRemoteUserInfoListChange(remoteUserInfoList) {
  // Remote entries in the store use the same isMicrophoneOpened /
  // isCameraOpened field names as local (see engineEventHandler
  // `_setRemoteUserInfoAudioVideoAvailable`).
  callParticipantInfo.value.allParticipants = remoteUserInfoList.map((obj: any) => {
    const {
      userId,
      nick = '',
      avatar = '',
      remark = '',
      isMicrophoneOpened,
      isCameraOpened,
    } = obj || {};
    const userInfo: ICallParticipant = {
      id: userId || '',
      name: nick,
      avatarUrl: avatar,
      remark: remark,
      isMicrophoneOpened: isMicrophoneOpened,
      isCameraOpened: isCameraOpened,
    };
    return userInfo;
  });
}
// Map the store's CALLER_USER_INFO (userId / nick / avatar) onto the UI-facing
// caller model (id / name / avatarUrl). This is the authoritative inviter info
// used by the group-call callee waiting page.
function _handleCallerUserInfoChange(value: any) {
  const { userId = '', nick = '', avatar = '', remark = '' } = value || {};
  callParticipantInfo.value.callerInfo = {
    id: userId || '',
    name: nick,
    avatarUrl: avatar,
    remark,
  };
}
function _handleIsGroupChange(value: boolean) {
  callParticipantInfo.value.isGroup = !!value;
}


function getRoute(): string {
  // @ts-ignore
  const pages = getCurrentPages();
  return pages[pages.length - 1].route;
}
function getTargetCallPagePath(): string {
  const isGroup = TUIStore.getData(StoreName.CALL, NAME.IS_GROUP);
  // Group call uses a different page that renders the multi-tile grid layout.
  if (isGroup && wx.$globalGroupCallPagePath) {
    return wx.$globalGroupCallPagePath;
  }
  return wx.$globalCallPagePath || '';
}
function handleCallStatusToCalling(): void {
  const targetPagePath = getTargetCallPagePath();
  if (!targetPagePath || getRoute() === targetPagePath) return;
  wx.navigateTo({
    url: `/${targetPagePath}`,
    success: () => {
      const callStatus = TUIStore.getData(StoreName.CALL, NAME.CALL_STATUS);
      if (callStatus === CallStatus.IDLE) {
        handleCallStatusToIdle();
      }
    },
    fail: () => console.error('navigateTo fail!')
  });
}
function handleCallStatusToIdle(): void {
  const targetPagePath = getTargetCallPagePath();
  if (!targetPagePath || getRoute() !== targetPagePath) return;
  wx.navigateBack({
    fail: () => console.error('navigateBack fail!')
  });
}


function useCallParticipantState() {
  return {
    callParticipantInfo,
  };
}

export { useCallParticipantState };
