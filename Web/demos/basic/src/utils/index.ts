/**
 * get key-value from window.location.href 
 * @param {*} key the param key
 * @returns window.location.href the value of the key
 * @example
 * const value = getUrlParam(key);
 */
export function getUrlParam(key: string): string {
  const url = decodeURI(window.location.href.replace(/^[^?]*\?/, ""));
  const regexp = new RegExp(`(^|&)${key}=([^&#]*)(&|$|)`, "i");
  const paramMatch = url.match(regexp);

  return paramMatch ? paramMatch[2] : "";
}

/**
 * Get language
 * @returns language
 */
export function getLanguage(): string {
  let language =
    localStorage.getItem("basic-demo-language") ||
    getUrlParam("lang") ||
    navigator.language ||
    "zh-cn";
  language = language.replace(/_/, "-").toLowerCase();
  return language;
}

export const getParamKey: any = (key: string) => {
  if (getUrlParam(key)) {
    return getUrlParam(key);
  }
  switch (key) {
    case "userId":
      return `user_${Math.floor(Math.random() * 100000000)}`;
    case "roomId":
      return Math.floor(Math.random() * 100000);
    case "sdkAppId":
      return undefined;
    case "secretKey":
      return undefined;
    default:
      return undefined;
  }
};

/**
 * Judge mobile device
 */
export const isMobile: boolean =
  /Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(
    navigator.userAgent
  );
