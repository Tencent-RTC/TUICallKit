import { NAME } from '../const/index';

export const isPlainObject = function (input: any) {
  // 注意不能使用以下方式判断，因为IE9/IE10下，对象的__proto__是 undefined
  // return isObject(input) && input.__proto__ === Object.prototype;
  if (typeof input !== NAME.OBJECT || input === null) {
    return false;
  }
  const proto = Object.getPrototypeOf(input);
  if (proto === null) { // edge case Object.create(null)
    return true;
  }
  let baseProto = proto;
  while (Object.getPrototypeOf(baseProto) !== null) {
    baseProto = Object.getPrototypeOf(baseProto);
  }
  // 原型链第一个和最后一个比较
  return proto === baseProto;
};
/**
 * 检测input类型是否为string
 * @param {*} input 任意类型的输入
 * @returns {Boolean} true->string / false->not a string
 */
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
    ((typeof input === NAME.NUMBER && !isNaN(input - 0)) || (typeof input === NAME.OBJECT && input.constructor === Number))
  );
};

// /**
//  * 节流函数（目前 TUICallKit 增加防重调用装饰器，该方法可删除）
//  * @param {Function} func 传入的函数
//  * @param {wait} time 间隔时间（ms）
//  */
// export const throttle = (func: Function, wait: number) => {
//   let previousTime = 0;
//   return function () {
//     const now = Date.now();
//     const args = [...arguments];
//     if (now - previousTime > wait) {
//       func.apply(this, args);
//       previousTime = now;
//     }
//   };
// }

/**
 * web call engine 重复调用时的错误, 这种错误在 TUICallKit 应该忽略
 * @param {any} error 错误信息
 * @returns {Boolean}
 */
export function handleRepeatedCallError(error: any) {
  if (error?.message?.indexOf('is ongoing, please avoid repeated calls') !== -1) {
    return true;
  }
  return false;
}
/**
 * 设备无权限时的错误处理
 * @param {any} error 错误信息
 * @returns {Boolean}
 */
export function handleNoDevicePermissionError(error: any) {
  const { message } = error;
  if (message?.indexOf('NotAllowedError: Permission denied') !== -1) {
    return true;
  }
  return false;
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
/**
 * 检测input类型是否为function
 * @param {*} input 任意类型的输入
 * @returns {Boolean} true->input is a function
 */
export const isFunction = function (input: any) {
  return typeof input === NAME.FUNCTION;
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

export function deepClone(obj) {
  if (typeof obj !== 'object' || obj === null) {
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