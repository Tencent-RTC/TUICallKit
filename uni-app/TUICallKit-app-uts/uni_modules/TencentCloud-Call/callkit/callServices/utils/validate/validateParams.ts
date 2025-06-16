import {
  getType,
  isArray,
  isString,
  isUndefined,
  isNumber,
  modifyObjectKey,
} from "../common";
import { NAME } from "../../const/index";
const PREFIX = NAME.PREFIX + "API";

export function paramValidate(config: any) {
  return function (
    target,
    propertyName: string,
    descriptor: PropertyDescriptor
  ) {
    let method = descriptor.value;
    descriptor.value = function (...args) {
      doValidate.call(this, config, args, propertyName);
      return method.apply(this, args);
    };
    return descriptor;
  };
}
function doValidate(config, args, name) {
  try {
    // 兼容 init 方法中： SDKAppID sdkAppID 两种写法的参数校验判断
    if (!args[0].SDKAppID) {
      config = modifyObjectKey(config, "SDKAppID", "sdkAppID");
    }
    if (isArray(config)) {
      for (let i = 0; i < config.length; i++) {
        check.call(this, {
          ...config[i],
          value: args[i],
          name,
        });
      }
    } else {
      for (const key in config) {
        if (config.hasOwnProperty(key)) {
          check.call(this, {
            ...config[key],
            value: args[0][key],
            name,
            key,
          });
        }
      }
    }
  } catch (error) {
    console.error(error);
    throw error;
  }
}
function check({ required, rules, range, value, allowEmpty, name, key }) {
  // 用户没传指定参数
  if (isUndefined(value)) {
    // 检查必填参数, 若配置是必填则报错
    if (required) {
      throw new Error(`${PREFIX}<${name}>: ${key} is required.`);
    } else {
      return;
    }
  }
  // 判断参数类型是否正确
  const result = rules.some((item) => item === getType(value));
  let type = "";
  if (!result) {
    for (let i = 0; i < rules.length; i++) {
      let str = rules[i];
      str = str.replace(str[0], str[0].toUpperCase());
      type += `${str}/`;
    }
    type = type.substring(0, type.length - 1);
    throw new Error(
      `${PREFIX}<${name}>: ${key} must be ${type}, current ${key} is ${typeof value}.`
    );
  }
  // 不允许传空值, 例如: '', '  '
  if (allowEmpty === false) {
    const isEmptyString = isString(value) && value.trim() === "";
    if (isEmptyString) {
      throw new Error(`${PREFIX}<${name}>: ${key} is blank.`);
    }
  }
  // 判断是否符合限制条件
  if (isArray(range)) {
    if (range && range.indexOf(value) === -1) {
      throw new Error(
        `${PREFIX}<${name}>: ${key} error, only be ${range}, current ${key} is ${value}.`
      );
    }
  }
  // 取值范围, 前闭后闭
  if (isString(range) && range.indexOf("~") !== -1) {
    const valueList = range.split("~");
    if (
      value < +valueList[0] ||
      value > +valueList[1] ||
      (isNumber(value) && Number.isNaN(value))
    ) {
      throw new Error(
        `${PREFIX}<${name}>: ${key} error, only be ${range}, current ${key} is ${value}.`
      );
    }
  }
}
