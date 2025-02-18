import AntdConfig from './antd-config';
import QuickLinkObj from './quick-link';
import ClassNames from './class-names';

export const NAME = {
  "smallDeviceHeight": 667,
}

export const BASE_URL = 'https://web.sdk.qcloud.com/component/TUICallKit/basic-react/index.html';

export const isH5 = /Android|webOS|iPhone|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent);

export function checkUserID(userID: string) {
  const regex = /^[a-zA-Z0-9_-]{1,32}$/;
  return regex.test(userID);
}

export function trim(str: string) {
  return str.replace(/\s/g, "");
}

export const checkLocation = () => {
  const protocol = window.location.protocol;
  const host = window.location.hostname;

  if (protocol === 'http:' && host === 'localhost') {
    return true;
  } else if (protocol === 'https:') {
    return true;
  } else {
    return false;
  }
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

export function getBrowserLanguage() {
  return navigator.language || 'en';
}

export function initViewport() {
  const width = 375;
  const scale = window.innerWidth / width;
  let meta = document.querySelector('meta[name=viewport]')
  const content = `width=${width}, init-scale=${scale}, user-scalable=no`
  if(!meta) {
      meta = document.createElement('meta')
      meta.setAttribute('name', 'viewport')
      document.head.appendChild(meta)
  }
  meta.setAttribute('content', content);
}

export function getClientSize() {
  const width = window.screen.width;
  const height =  window.screen.height;

  return { width, height };
}

export function setLocalStorage(key: string, value: string) {
  localStorage.setItem(key, value);
}

export function getLocalStorage(key: string) {
  return localStorage.getItem(key);
}

export {
  AntdConfig,
  QuickLinkObj,
  ClassNames,
}
