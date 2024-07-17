// Aegis is used for performance analysis and can be deleted if you do not need it
import Aegis from 'aegis-web-sdk';
import { useContext } from 'react';
import { UserInfoContext } from '../context';

interface IAegisReportParams {
  apiName?: string;
  content?: string;
  userID?: string;
  SDKAppID?: number;
}

export default function useAegis() {
  const { userInfo } = useContext(UserInfoContext);
  const aegis = new Aegis({
    id: 'iHWefAYqhifClbANcI',
    reportApiSpeed: false,
    reportAssetSpeed: false,
    spa: false,
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

  return {
    reportEvent,
    reportError,
  }
}
