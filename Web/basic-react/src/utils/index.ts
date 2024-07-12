import AntdConfig from './antd-config';
import QuickLinkObj from './quick-link';

export const BASE_URL = 'https://web.sdk.qcloud.com/component/TUICallKit/basic-react/index.html';

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

export function getUrlParams() {
  const search = window.location?.search?.slice(1).split('&');
  const params: any = {};
  search.forEach((item) => {
    const [key, value] = item.split('=');
    params[key] = value;
  });
  return params;
}

export function getBrowserLanguage() {
  return navigator.language || 'en';
}

export {
  AntdConfig,
  QuickLinkObj,
}
