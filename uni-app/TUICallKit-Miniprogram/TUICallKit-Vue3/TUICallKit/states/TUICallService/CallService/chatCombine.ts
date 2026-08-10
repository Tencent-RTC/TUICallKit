import { TUIBridge } from '../../../TUIBridge/index';
import { LOG_LEVEL } from '@trtc/call-engine-lite-wx';
import { COMPONENT, NAME, EVENT } from '../const/index';

export default class ChatCombine {
  static instance: ChatCombine;
  private _callService: any;

  constructor(options) {
    this._callService = options.callService;

    TUIBridge.registerEvent(EVENT.LOGIN_SUCCESS, this);
    TUIBridge.registerEvent(EVENT.LOGOUT_SUCCESS, this);
    TUIBridge.registerEvent(EVENT.ON_CALLS, this);
  }

  static getInstance(options) {
    if (!ChatCombine.instance) {
      ChatCombine.instance = new ChatCombine(options);
    }
    return ChatCombine.instance;
  }
  /**
   * tuicore notify event manager
   * @param {String} eventName event name
   * @param {String} subKey sub key
   * @param {Any} options tuicore event parameters
   */
  public async onNotifyEvent(options?: any) {
    try {
      if (options?.eventName === EVENT.LOGIN_SUCCESS) {
        const { chat, userID, userSig, SDKAppID } = options?.params || {};
        await this._callService?.init({ tim: chat, userID, userSig, sdkAppID: SDKAppID, isFromChat: true, component: COMPONENT.TIM_CALL_KIT });
        this._callService?.setIsFromChat(true);
        this._callService?.setLogLevel(LOG_LEVEL.NONE);
      }
      if (options?.eventName === EVENT.LOGOUT_SUCCESS) {
        await this._callService?.destroyed();
      }
      if (options?.eventName === EVENT.ON_CALLS) {
        options?.params && this._callService.calls(options.params);
      }
    } catch (error) {
      console.error(`${NAME.PREFIX}TUICore onNotifyEvent failed, error: ${error}.`);
    }
  }
}
