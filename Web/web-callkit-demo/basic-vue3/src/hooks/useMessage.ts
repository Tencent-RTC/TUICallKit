import { ElMessage } from "element-plus";
import useLanguage from "./useLanguage";
import { getUrl } from "../utils";
import useAegis from "./useAegis";

type TMessageType = 'success' | 'warning' | 'info' | 'error';

interface IShowMessageParams {
  message: string;
  type?: TMessageType;
  duration?: number;
}

export default function useMessage() {
  const { t } = useLanguage();
  const { reportEvent } = useAegis();

  const showMessage = (params: IShowMessageParams) => {
    ElMessage(params);
  }

  const handleLoginMessage = (type: string) => {
    if (type === 'empty') {
      showMessage({
        message: `${t('The userID is empty')}`,
        type: 'error',
      });
    } else if (type === 'errorFormat') {
      showMessage({
        message: `${t('Please input the correct userID')}`,
        type: 'error',
      });
    } else if (type === 'userSig') {
      showMessage({
        message: `${t('Please fill SDKAppID and SecretKey:')} 'src/debug/GenerateTestUserSig-es.js'`,
        type: 'error',
      });
    }
  }

  const handleCallError = (fun: string, error: any) => {
    reportEvent({
      apiName: `${fun}.fail`,
      content: error
    });

    if (String(error)?.includes('Invalid')) {
      showMessage({
        message: `${t('The userID you dialed does not exist, please create one')}: ${getUrl()}`,
        type: 'success',
      });
    } else if (String(error)?.includes('-1002')) {
      showMessage({
        message: `${t('The current Call uikit package you purchased does not support this feature. We recommend going to the TRTC console to enable it.')}`,
        type: 'error',
      });
    } else if (String(error)?.includes('NotAllowedError')) {
      showMessage({
        message: `${t('You have disabled camera/microphone access permission. Please allow the current application to use the camera/microphone.')}`,
        type: 'error',
      });
    } else if (String(error)?.includes('-1001')) {
      showMessage({
        message: `${t('You have not purchased the Call UIKit package. Please go to the Tencent RTC console to subscribe.')}`,
        type: 'error',
      });
    } else {
      showMessage({
        message: `${error}`,
        type: 'error',
      });
    }
    console.error(`${fun} -- ${error}`);
  }

  return {
    showMessage,
    handleLoginMessage,
    handleCallError,
  }
}
