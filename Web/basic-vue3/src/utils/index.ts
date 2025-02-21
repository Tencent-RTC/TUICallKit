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

export function getUrlParams(keyList: string[]) {
  const url = window?.location?.href;
  const params = new URLSearchParams(new URL(url).search);
  const result: any = {};

  keyList.forEach(key => {
    result[key] = params.get(key);
  });

  return result;
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
