import { toRefs } from 'vue';
import { TUICallKitServer, TUICallType } from '@tencentcloud/call-uikit-vue';
import { useAegis, useUserInfo, useMessage, useLanguage } from "../../hooks";
import { trim, checkUserID } from "../../utils";

export default function useCall() {
  const { t } = useLanguage();
  const { reportEvent } = useAegis();
  const userInfo = toRefs(useUserInfo());
  const { handleCallError, handleLoginMessage, showMessage } = useMessage();

  const call = async (calleeUserID: any) => {
    reportEvent({ apiName: 'call.start' });
    if (!checkUserID(calleeUserID.value)) {
      handleLoginMessage('errorFormat');
      calleeUserID.value = '';
      return;
    }
    if (calleeUserID.value === userInfo.userID.value) {
      showMessage({
        message: `${t('You cannot make a call to yourself')}`,
        type: 'error',
      });
      calleeUserID.value = '';
      return;
    }
    userInfo.isCall.value = true;

    try {
      await TUICallKitServer.calls({
        userIDList: [calleeUserID.value],
        type: userInfo.currentCallType.value === 'video' ? TUICallType.VIDEO_CALL : TUICallType.AUDIO_CALL,
      })
      reportEvent({ apiName: 'call.success' });
      calleeUserID.value = '';
    } catch (error: any) {
      userInfo.isCall.value = false;
      handleCallError('call', error);
      return true;
    }
  }

  const handleCallUserID = (calleeUserID: any) => {
    calleeUserID.value = trim(calleeUserID.value)
  }

  return {
    call,
    handleCallUserID,
  }
}