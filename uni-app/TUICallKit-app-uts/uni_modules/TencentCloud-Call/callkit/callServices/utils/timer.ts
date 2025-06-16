/* eslint-disable */
import { isPlainObject, isFunction } from "./common";
import { NAME } from "../const/index";

/**
 * 定时器，功能：
 * 1. 支持定时执行回调 [1,n] 次，用于常规延迟、定时操作
 * @example
 * // 默认嵌套执行，count=0 无限次
 * timer.run(callback, {delay: 2000});
 * // count=1 等同于 原始setTimeout
 * timer.run(callback, {delay: 2000, count:0});
 * 2. 支持 RAF 执行回调，用于小流渲染，audio音量获取等任务，需要渲染频率稳定，支持页面退后台后，用 setTimeout 接管，最短 1s 执行一次
 * @example
 * // 默认60fps，可以根据单位时长换算，默认开启后台执行
 * timer.run('raf', callback, {fps: 60});
 * // 设置执行次数
 * timer.run('raf', callback, {fps: 60, count: 300, backgroundTask: false});
 * 3. 支持空闲任务执行回调, requestIdleCallback 在帧渲染的空闲时间执行任务，可以用于 storage 写入等低优先级的任务
 * @example
 * // 支持原生setInterval 但不推荐使用，定时任务推荐用 timeout
 * timer.run('interval', callback, {delay:2000, count:10})
 */

export class Timer {
  static taskMap = new Map();
  static currentTaskID = 1;
  static generateTaskID() {
    return this.currentTaskID++;
  }
  /**
   *
   * @param {string} taskName 'interval' 'timeout'
   * @param {function} callback
   * @param {object} options include:
   * @param {number} options.delay millisecond
   * @param {number} options.count 定时器回调执行次数，0 无限次 or n次
   * @param {boolean} options.backgroundTask 在页面静默后是否继续执行定时器
   */
  static run(taskName = NAME.TIMEOUT, callback: any, options: any) {
    // default options
    if (taskName === NAME.INTERVAL) {
      options = {
        ...{ delay: 2000, count: 0, backgroundTask: true },
        ...options,
      };
    } else {
      options = {
        ...{ delay: 2000, count: 0, backgroundTask: true },
        ...options,
      };
    }
    // call run(function, {...})
    if (isPlainObject(callback)) {
      options = { ...options, ...callback };
    }
    if (isFunction(taskName)) {
      callback = taskName;
      taskName = NAME.TIMEOUT;
    }
    // 1. 创建 taskID，作为 timer task 的唯一标识，在本函数执行完后返回，用于在调用的地方实现互斥逻辑
    // 2. 根据 taskName 执行相应的函数
    const taskItem = {
      taskID: this.generateTaskID(),
      loopCount: 0,
      intervalID: null,
      timeoutID: null,
      taskName,
      callback,
      ...options,
    };
    this.taskMap.set(taskItem.taskID, taskItem);
    // console.log(`timer run task:${taskItem.taskName}, task queue size: ${this.taskMap.size}`);
    if (taskName === NAME.INTERNAL) {
      this.interval(taskItem);
    } else {
      this.timeout(taskItem);
    }
    return taskItem.taskID;
  }

  /**
   * 定时循环执行回调函数
   * 可以指定循环的时间间隔
   * 可以指定循环次数
   * @param {object} taskItem
   * @param {function} callback
   * @param {*} delay
   * @param {*} count
   * @returns ID
   */
  static interval(taskItem: any) {
    // setInterval 缺点，浏览器退后台会降频，循环执行间隔时间不可靠
    // 创建进入定时器循环的任务函数,函数内：1. 判断是否满足执行条件，2.执行 callback
    // 通过 setInterval 执行任务函数
    // 将 intervalID 记录到 taskMap 对应的 item
    const task = () => {
      taskItem.callback();
      taskItem.loopCount += 1;
      if (this.isBreakLoop(taskItem)) {
        return;
      }
    };
    return (taskItem.intervalID = setInterval(task, taskItem.delay));
  }
  /**
   * 延迟执行回调
   * count = 0,循环
   * count = n, 执行n次
   * @param {object} taskItem
   *
   */
  static timeout(taskItem: any) {
    // setTimeout 浏览器退后台，延迟变为至少1s
    const task: any = () => {
      // 执行回调
      taskItem.callback();
      taskItem.loopCount += 1;
      if (this.isBreakLoop(taskItem)) {
        return;
      }
      // 不修正延迟，每次callback间隔平均
      return (taskItem.timeoutID = setTimeout(task, taskItem.delay));
    };
    return (taskItem.timeoutID = setTimeout(task, taskItem.delay));
  }

  static hasTask(taskID: any) {
    return this.taskMap.has(taskID);
  }

  static clearTask(taskID: any) {
    // console.log('timer clearTask start', `| taskID:${taskID} | size:${this.taskMap.size}`);
    if (!this.taskMap.has(taskID)) {
      return true;
    }
    const { intervalID, timeoutID, onVisibilitychange } =
      this.taskMap.get(taskID);
    if (intervalID) {
      clearInterval(intervalID);
    }
    if (timeoutID) {
      clearTimeout(timeoutID);
    }
    if (onVisibilitychange) {
      document.removeEventListener("visibilitychange", onVisibilitychange);
    }
    this.taskMap.delete(taskID);
    // console.log('timer clearTask end  ', `| size:${this.taskMap.size}`);
    return true;
  }
  /**
   * 1. 如果已移除出定时队列，退出当前任务
   * 2. 如果当前任务已满足次数限制，则退出当前任务
   * @param {object} taskItem
   * @returns
   */
  static isBreakLoop(taskItem: any) {
    if (!this.taskMap.has(taskItem.taskID)) {
      return true;
    }
    if (taskItem.count !== 0 && taskItem.loopCount >= taskItem.count) {
      this.clearTask(taskItem.taskID);
      return true;
    }
    return false;
  }
}
