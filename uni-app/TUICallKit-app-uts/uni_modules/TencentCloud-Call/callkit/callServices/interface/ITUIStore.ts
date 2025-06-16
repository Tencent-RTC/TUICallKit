import { StoreName } from "../const/index";

// 此处 Map 的 value = 1 为占位作用
export type Task = Record<
  StoreName,
  Record<string, Map<(data?: unknown) => void, 1>>
>;

export interface IOptions {
  [key: string]: (newData?: any) => void;
}

/**
 * @class TUIStore
 * @property {ICustomStore} customStore 自定义 store，可根据业务需要通过以下 API 进行数据操作。
 */
export interface ITUIStore {
  task: Task;

  /**
   * UI 组件注册监听
   * @function
   * @param {StoreName} storeName store 名称
   * @param {IOptions} options UI 组件注册的监听信息
   * @param {Object} params 扩展参数
   * @param {String} params.notifyRangeWhenWatch 注册时监听时的通知范围
   * @example
   * // UI 层监听会话列表更新通知
   * let onConversationListUpdated = function(conversationList) {
   *   console.warn(conversationList);
   * }
   * TUIStore.watch(StoreName.CONV, {
   *   conversationList: onConversationListUpdated,
   * })
   */
  watch(storeName: StoreName, options: IOptions, params?: any): void;

  /**
   * UI 组件取消监听回调
   * @function
   * @param {StoreName} storeName store 名称
   * @param {IOptions} options 监听信息，包含需要取消的回调等
   * @example
   * // UI 层取消监听会话列表更新通知
   * TUIStore.unwatch(StoreName.CONV, {
   *   conversationList: onConversationListUpdated,
   * })
   */
  unwatch(storeName: StoreName, options: IOptions | string): void;

  /**
   * 获取 store 中的上一个状态
   * @function
   * @param {StoreName} storeName store 名称
   * @param {String} key 需要获取的 key
   * @private
   */
  getPrevData(storeName: StoreName, key: string): any;

  /**
   * 获取 store 中的数据
   * @function
   * @param {StoreName} storeName store 名称
   * @param {String} key 需要获取的 key
   * @private
   */
  getData(storeName: StoreName, key: string): any;

  /**
   * 更新 store
   * - 需要使用自定义 store 时可以用此 API 更新自定义数据
   * @function
   * @param {StoreName} storeName store 名称
   * @param {String} key 需要更新的 key
   * @example
   * // UI 层更新自定义 Store 数据
   * TUIStore.update(StoreName.CUSTOM, 'customKey', 'customData')
   */
  update(storeName: StoreName, key: string, data: unknown): void;

  /**
   * 重置 store 内数据
   * @function
   * @param {StoreName} storeName store 名称
   * @param {Array<string>} keyList 需要 reset 的 keyList
   * @param {boolean} isNotificationNeeded 是否需要触发更新
   * @private
   */
  reset: (
    storeName: StoreName,
    keyList?: Array<string>,
    isNotificationNeeded?: boolean
  ) => void;

  /**
   * 修改多个 key-value
   * @param {Object} params 多个 key-value 组成的 object
   * @param {StoreName} storeName store 名称
   */
  updateStore: (params: any, name?: StoreName) => void;
}
