import { NAME } from "../const/index";

export const isUndefined = function (input: any) {
  return typeof input === NAME.UNDEFINED;
};

export const isPlainObject = function (input: any) {
  // 注意不能使用以下方式判断，因为IE9/IE10下，对象的__proto__是 undefined
  // return isObject(input) && input.__proto__ === Object.prototype;
  if (typeof input !== NAME.OBJECT || input === null) {
    return false;
  }
  const proto = Object.getPrototypeOf(input);
  if (proto === null) {
    // edge case Object.create(null)
    return true;
  }
  let baseProto = proto;
  while (Object.getPrototypeOf(baseProto) !== null) {
    baseProto = Object.getPrototypeOf(baseProto);
  }
  // 原型链第一个和最后一个比较
  return proto === baseProto;
};

export const isArray = function (input: any) {
  if (typeof Array.isArray === NAME.FUNCTION) {
    return Array.isArray(input);
  }
  return (
    (Object as any).prototype.toString
      .call(input)
      .match(/^\[object (.*)\]$/)[1]
      .toLowerCase() === NAME.ARRAY
  );
};

export const isString = function (input: any) {
  return typeof input === NAME.STRING;
};

export const isBoolean = function (input: any) {
  return typeof input === NAME.BOOLEAN;
};

export const isNumber = function (input: any) {
  return (
    // eslint-disable-next-line
    input !== null &&
    ((typeof input === NAME.NUMBER && !isNaN(input - 0)) ||
      (typeof input === NAME.OBJECT && input.constructor === Number))
  );
};

export const isFunction = function (input: any) {
  return typeof input === NAME.FUNCTION;
};

export const getType = function (input) {
  return Object.prototype.toString
    .call(input)
    .match(/^\[object (.*)\]$/)[1]
    .toLowerCase();
};

export function modifyObjectKey(obj, oldKey, newKey) {
  if (!obj.hasOwnProperty(oldKey)) {
    return obj;
  }
  const newObj = {};
  Object.keys(obj).forEach((key) => {
    if (key === oldKey) {
      newObj[newKey] = obj[key];
    } else {
      newObj[key] = obj[key];
    }
  });
  return newObj;
}

export function deepClone(obj) {
  if (typeof obj !== "object" || obj === null) {
    return obj;
  }

  let clone = Array.isArray(obj) ? [] : {};

  for (let key in obj) {
    if (obj.hasOwnProperty(key)) {
      clone[key] = deepClone(obj[key]);
    }
  }

  return clone;
}

// uni 获取手机系统语言 目前支持 zh-cn 和 en
export const getLanguage = () => {
  let lang: string = "zh-cn";
  uni.getSystemInfo({
    success: (res) => {
      console.log(`${NAME.PREFIX} getLanguage: ${res.appLanguage}`);
      if (res.appLanguage.includes("zh")) {
        lang = "zh-cn";
      } else if (res.appLanguage.includes("en")) {
        lang = "en";
      }
    },
  });
  return lang;
};

/**
 * interpolate function
 * @param {string} str - 'hello {{name}}'
 * @param {object} data - { name: 'sam' }
 * @returns {string} 'hello sam'
 *
 */
export function interpolate(str, data) {
  return str.replace(/{{\s*(\w+)(\s*,\s*[^}]+)?\s*}}/g, (match, p1) => {
    const key = p1.trim();

    return data[key] !== undefined ? String(data[key]) : match;
  });
}

/*
 * 获取向下取整的 performance.now() 值
 * 在不支持 performance.now 的浏览器中，使用 Date.now(). 例如 ie 9，ie 10，避免加载 sdk 时报错
 * @export
 * @return {Number}
 */
export function performanceNow() {
  return Date.now();
}

export function formatTime(secondTime: number): string {
  const hours: number = Math.floor(secondTime / 3600);
  const minutes: number = Math.floor((secondTime % 3600) / 60);
  const seconds: number = Math.floor(secondTime % 60);
  let callDurationStr: string = hours > 9 ? `${hours}` : `0${hours}`;
  callDurationStr += minutes > 9 ? `:${minutes}` : `:0${minutes}`;
  callDurationStr += seconds > 9 ? `:${seconds}` : `:0${seconds}`;
  return callDurationStr;
}
