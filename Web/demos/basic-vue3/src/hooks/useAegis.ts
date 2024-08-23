// Aegis is used for performance analysis and can be deleted if you do not need it
import Aegis from 'aegis-web-sdk';
import useUserInfo from './useUserInfo';
import { getLocalStorage, setLocalStorage } from '../utils/index';

interface IAegisReportParams {
  apiName?: string;
  content?: string;
}

export default function useAegis() {
  const userInfo = useUserInfo();
  const aegis = new Aegis({
    id: 'Dv4zOHEZ7eJ122mloQ',
    hostUrl: 'https://rumt-sg.com',
    uin: getUIN(),
    reportApiSpeed: false,
    reportAssetSpeed: false,
    spa: false,
    websocketHack: false,
    pagePerformance: false,
    webVitals: false,
    onError: false,
    speedSample: false,
    repeat: 1,
    pvUrl: '',
    whiteListUrl: '',
    offlineUrl: '',
    speedUrl: '',
    webVitalsUrl: '',
    api: {
      apiDetail: false,
    },
  });
  
  const reportEvent = (params: IAegisReportParams): void => {
    const { apiName, content } = params;
    try {
      aegis?.report({ 
        msg: apiName, 
        level: Aegis.logType.REPORT, 
        ext1: String(userInfo?.SDKAppID),
        ext2: content,
        ext3: `@tencentcloud/call-uikit-vue`,
      });
    } catch (error) {
      console.log('aegis', error);
    }
  };
  
  function getUIN() {
    if (!getLocalStorage('call-uikit')) {
      setLocalStorage('call-uikit', JSON.stringify(window?.performance.now()));
    }
    return getLocalStorage('call-uikit') || '';
  }

  return {
    reportEvent,
  }
}
