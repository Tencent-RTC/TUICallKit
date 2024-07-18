// Aegis is used for performance analysis and can be deleted if you do not need it
import Aegis from 'aegis-web-sdk';
import { useContext } from 'react';
import { UserInfoContext } from '../context';
import { getLocalStorage, setLocalStorage } from '../utils/index';

interface IAegisReportParams {
  apiName?: string;
  content?: string;
}

export default function useAegis() {
  const { userInfo } = useContext(UserInfoContext);

  const aegis = new Aegis({
    id: 'iHWefAYqhifClbANcI',
    uin: getUIN(),
    reportApiSpeed: false,
    reportAssetSpeed: false,
    spa: false,
    websocketHack: false,
    pagePerformance: false,
    webVitals: false,
    onError: false,
    aid: false,
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
  
  const reportEvent = (params: IAegisReportParams) => {
    const { apiName, content } = params;
    aegis.report({ 
      msg: apiName, 
      level: Aegis.logType.REPORT, 
      ext1: userInfo?.SDKAppID,
      ext2: content,
     });
  }
  const reportError = (params: IAegisReportParams) => {
    const { apiName, content, } = params;
    aegis.report({ 
      msg: apiName, 
      level: Aegis.logType.ERROR, 
      ext1: userInfo?.SDKAppID,
      ext2: content,
     });
  }
  
  function getUIN() {
    if (!getLocalStorage('call-uikit')) {
      setLocalStorage('call-uikit', JSON.stringify(window?.performance.now()));
    }
    return getLocalStorage('call-uikit') || '';
  }

  return {
    reportEvent,
    reportError,
  }
}
