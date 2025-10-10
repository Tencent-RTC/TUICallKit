import { toRefs } from "vue";
import type { Ref } from 'vue'
import { TUICallKitAPI, TUICallType } from '@trtc/calls-uikit-vue';
import { trim, checkUserID } from "../../utils";
import { useLanguage, useMessage, useUserInfo, useAegis, useChat } from "../../hooks";

export default function useGroupCall() {
  const { t } = useLanguage();
  const { reportEvent } = useAegis();
  // @ts-ignore
  const { createGroupID } = useChat();
  const { showMessage, handleCallError } = useMessage();
  const userInfo = toRefs(useUserInfo());

  TUICallKitAPI.setLogLevel(0)

  const groupCall = async (groupCallMember: Ref<string[]>) => {
    reportEvent({ apiName: 'groupCall.start' });
    if (groupCallMember.value.length < 1) {
      showMessage({
        message: `${t('Please add at least one member')}`,
        type: 'error',
      })
      return;
    }
    userInfo.isCall.value = true;
    try {
      // const groupID = await createGroupID(groupCallMember.value);
      await TUICallKitAPI.calls({
        userIDList: groupCallMember.value, 
        type: userInfo?.currentCallType.value === 'video' ? TUICallType.VIDEO_CALL : TUICallType.AUDIO_CALL,
      })
      reportEvent({ apiName: 'groupCall.success'});
    } catch (error) {
      userInfo.isCall.value = false;
      handleCallError('groupCall', error);
    }
  }

  const inputUserIDHandler = (inputUserID: Ref<string>) => {
    inputUserID.value = trim(inputUserID.value);
  }

  const addGroupCallMemberHandler = (inputUserID: Ref<string>, groupCallMember: Ref<string[]>) => {
    if (!inputUserID.value) return;
    if (!checkUserID(inputUserID.value)) {
      showMessage({
        message: `${t('Please input the correct userID')}`,
        type: 'error',
      })
      return;
    }
    if (groupCallMember.value.includes(inputUserID.value)) {
      showMessage({
        message: `${t('The user already exists')}`,
        type: 'error',
      })
      return;
    }
    if (inputUserID.value === userInfo?.userID.value) {
      showMessage({
        message: `${t("You can't add yourself")}`,
        type: 'error',
      })
      inputUserID.value = '';
      return;
    }
    if (groupCallMember.value.length < 8) {
      groupCallMember.value = [...groupCallMember.value, inputUserID.value]
    } else {
      showMessage({
        message: `${t("The group is full")}`,
        type: 'error',
      })
    }
    inputUserID.value = '';
  }

  const deleteGroupCallUserHandler = (userID: string, groupCallMember: Ref<string[]>) => {
    groupCallMember.value = groupCallMember.value.filter(item => item !== userID);
  }

  return {
    groupCall,
    inputUserIDHandler,
    addGroupCallMemberHandler,
    deleteGroupCallUserHandler,
  }
}