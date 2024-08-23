import { TUICallKitServer } from "@tencentcloud/call-uikit-vue";
import useAegis from "./useAegis";

export interface IMemberList {
  userID: string;
}

export default function useChat() {
  const { reportEvent } = useAegis();
  const chat = TUICallKitServer?.getTUICallEngineInstance()?.tim;

  const createGroupID = async (groupCallMember: string[]) => {
    const memberList: IMemberList[] = groupCallMember.map(userID => ({ userID }));
    const res = await chat?.createGroup({
      type: "Public", // Chat.TYPES.GRP_PUBLIC
      name: 'WebSDK',
      memberList
    });
    reportEvent({
      apiName: 'createGroupID.start',
      content: res.data.group.groupID,
    });

    return res.data.group.groupID;
  }

  return {
    createGroupID,
  };
}
