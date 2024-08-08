import { message } from 'antd';
import { getUrl } from '../utils';
import useAegis from './useAegis';
import useLanguage from './useLanguage';

export default function useMessage() {
  const [messageApi, contextHolder] = message.useMessage();
  const { reportEvent } = useAegis();
  const { t } = useLanguage();

  const handleCallError = (fun: string, error: any) => {
    reportEvent({
      apiName: `${fun}.fail`,
      content: error
    });
    if (String(error)?.includes('Invalid')) {
      messageApi.error(`${t('The userID you dialed does not exist, please create one')}: ${getUrl()}`, 10);
    } else if (String(error)?.includes('-1002')) {
      messageApi.error(`${t('The current Call uikit package you purchased does not support this feature. We recommend going to the TRTC console to enable it.')}`);
    } else if (String(error)?.includes('NotAllowedError')) {
      messageApi.error(`${t('You have disabled camera/microphone access permission. Please allow the current application to use the camera/microphone.')}`);
    } else if (String(error)?.includes('-1001')) {
      messageApi.error(`${t('You have not purchased the Call UIKit package. Please go to the Tencent RTC console to subscribe.')}`);
    } else {
      messageApi.info(`${t('Please open the browser console to see the failure reason.')}`);
    }
    console.error(`${fun} -- ${error}`);
  }

  return {
    messageApi,
    contextHolder,
    handleCallError,
  }
}

