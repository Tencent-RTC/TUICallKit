import { IUrlPrams } from '../interface';
import { classNames } from './class-names';
import QuickLinkObj from './quick-link';

export const BASE_URL = 'https://web.sdk.qcloud.com/component/TUICallKit/basic-vue3/index.html';

export const isH5 = /Android|webOS|iPhone|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent);

export function checkUserID(userID: string) {
  const regex = /^[a-zA-Z0-9_-]{1,32}$/;
  return regex.test(userID);
}

export function trim(str: string) {
  return str.replace(/\s/g, "");
}

export function getUrl() {
  return window?.location.href;
}

export function getUrlParams() {
  const search = window.location?.href?.split('?')[1]?.split('&') || [];
  const params: IUrlPrams = {
    SDKAppID: 0,
    SecretKey: '',
  };
  search.forEach((item) => {
    const [key, value] = item.split('=');
    if (key === 'SDKAppID') {
      params[key] = Number(value);  
    }
    // @ts-ignore
    params[key] = value;
  });
  return params;
}

export function setLocalStorage(key: string, value: string) {
  localStorage.setItem(key, value);
}

export function getLocalStorage(key: string) {
  return localStorage.getItem(key);
}

export {
  classNames,
  QuickLinkObj,
}
