const LOG_PREFIX = 'trtc-callling-webrtc-demo:';

export function isValidatePhoneNum(phoneNum) {
  const reg = new RegExp('^1[0-9]{10}$', 'gi');
  return phoneNum.match(reg);
}
export function isValidateEmail(email) {
  // eslint-disable-next-line
  const reg = new RegExp('^[a-zA-Z0-9._-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$', 'gi');
  return email.match(reg);
}

export function isUserNameValid(username) {
  return username && username.length <= 20;
}

export function setUserLoginInfo(userInfo) {
  localStorage.setItem('userInfo', JSON.stringify(userInfo));
}

export function addToSearchHistory(searchUser) {
  const MAX_HISTORY_NUM = 3;
  let searchUserList = getSearchHistory();
  const found = searchUserList.find(user => user.userID === searchUser.userID);
  if (!found) {
    searchUserList.push(searchUser);
  }
  if (searchUserList.length > MAX_HISTORY_NUM) {
    searchUserList = searchUserList.slice(-MAX_HISTORY_NUM);
  }
  localStorage.setItem('searchHistory', JSON.stringify(searchUserList));
}

export function delSearchHistory() {
  localStorage.removeItem('searchHistory');
}

export function getSearchHistory() {
  try {
    return JSON.parse(localStorage.getItem('searchHistory') || '[]');
  } catch (e) {
    return [];
  }
}

export function getUserLoginInfo() {
  try {
    return JSON.parse(localStorage.getItem('userInfo') || '{}');
  } catch (e) {
    return {};
  }
}

export function log(content) {
  console.log(`${LOG_PREFIX} ${content}`)
}

export const baseURL = 'https://service-c2zjvuxa-1252463788.gz.apigw.tencentcs.com'
export const ENV = 'prod';

export function formateTime(num) {
  if (typeof num === "number") {
    if (num <= 0) {
      return '00:00:00';
    } else {
      let hh = parseInt(num / 3600);
      let shh = num - hh * 3600;
      let ii = parseInt(shh / 60);
      let ss = shh - ii * 60;
      return (hh < 10 ? '0' + hh : hh) + ':' + (ii < 10 ? '0'+ii : ii) +':'+(ss < 10 ? '0'+ss : ss);
		}
  } else {
    return '00:00:00'
  }
}

export function browser() {
  const ua = navigator.userAgent,
    isWindowsPhone = /(?:Windows Phone)/.test(ua),
    isSymbian = /(?:SymbianOS)/.test(ua) || isWindowsPhone,
    isAndroid = /(?:Android)/.test(ua),
    isFireFox = /(?:Firefox)/.test(ua),
    isTablet = /(?:iPad|PlayBook)/.test(ua) || (isAndroid && !/(?:Mobile)/.test(ua)) || (isFireFox && /(?:Tablet)/.test(ua)),
    isPhone = /(?:iPhone)/.test(ua) && !isTablet,
    isPc = !isPhone && !isAndroid && !isSymbian;
  return {
    isTablet: isTablet,
    isPhone: isPhone,
    isAndroid: isAndroid,
    isPC: isPc,
    isH5: isPhone || isAndroid || isTablet,
  };
}
