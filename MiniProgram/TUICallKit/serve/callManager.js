
import { TIM } from '../../TUICallEngine/libSrcConfig.js';
import TUICallEngine, { EVENT } from '../../TUICallEngine/tuicall-engine-wx.js';

/**
   * @param sdkAppID      用户的sdkAppID           必传
   * @param userID        用户的userID             必传
   * @param userSig       用户的userSig            必传
   * @param globalCallPagePath  跳转的路径                必传
   * @param tim           tim实例                 非必传
   */
export class CallManager {
  sdkAppID = 0
  userID = ''
  userSig = ''
  tim = null
  globalCallPagePath = []
  constructor() {
  }
  async init(params) {
    const { sdkAppID, SDKAppID, userID, tim, globalCallPagePath, userSig } = params;
    this.sdkAppID = sdkAppID || SDKAppID;
    this.userID = userID;
    this.userSig = userSig;
    this.globalCallPagePath = globalCallPagePath;
    this.tim = tim;
    // 挂载全局变量
    wx.$globalCallSign = true;
    // 设置标志位 用于移除监听
    wx.$CallManagerInstance = this;

    if (!this.tim) {
      this.tim = TIM.create({
        SDKAppID: this.sdkAppID,
      });
    }

    // 创建 TUICallEngine 实例
    wx.$TUICallEngine = TUICallEngine.createInstance({
      sdkAppID: this.sdkAppID,
      tim: this.tim,
    });
    // 调用 init 方法
    await  wx.$TUICallEngine.init({
      userID: this.userID,
      userSig: this.userSig,
    });
    // 监听 TUICallEngine 内部的 TSignaling 事件
    this.addEngineInvite();
  };

  addEngineInvite() {
    wx.$TUICallEngine.on(EVENT.INVITED, this.handleNewInvitationReceived, this);
  };

  addEngineCallEnd() {
    // 通话被取消
    wx.$TUICallEngine.on(EVENT.CALLING_CANCEL, this.handleCallEnd, this);
    // 通话结束
    wx.$TUICallEngine.on(EVENT.CALL_END, this.handleCallEnd, this);
  }

  removeEngineInvite() {
    wx.$TUICallEngine.off(EVENT.INVITED, this.handleNewInvitationReceived, this);
    this.removeEngineCallEnd();
  }

  removeEngineCallEnd() {
    // 若当前已在globalCall页面 则无需处理
    if (this.getRoute().route === this.globalCallPagePath) {
      return;
    }
    // 通话被取消
    wx.$TUICallEngine.off(EVENT.CALLING_CANCEL, this.handleCallEnd, this);
    // 通话结束
    wx.$TUICallEngine.off(EVENT.CALL_END, this.handleCallEnd, this);
  }


  handleNewInvitationReceived(event) {
    // 若当前已在globalCall页面 则无需处理
    if (this.getRoute().route === this.globalCallPagePath) {
      return;
    }

    // 监听 TUICallEngine 自身的通话结束事件
    this.addEngineCallEnd();
    const configData = {
      sdkAppID: this.sdkAppID,
      userID: this.userID,
      userSig: this.userSig,
    };
    wx.navigateTo({
      url: `/${this.globalCallPagePath}?data=${JSON.stringify(event)}&configData=${JSON.stringify(configData)}`,
    });
  };

  handleCallEnd() {
    wx.$TUICallEngine._resetTUICallEngine();
    wx.navigateBack({
      success: () => {
      },
      fail: () => {
      },
      complete: () => {
        wx.$TUICallEngine.off(EVENT.CALLING_CANCEL, this.handleCallEnd, this);
        wx.$TUICallEngine.off(EVENT.CALL_END, this.handleCallEnd, this);
      },
    });
  }

  // 获取当前的页面地址
  getRoute() {
    const pages = getCurrentPages();
    const currentPage = pages[pages.length - 1];
    return currentPage;
  }

  // 卸载 callManger
  destroyed() {
    this.removeEngineInvite();
    this.reset();
    wx.$globalCallSign = false;
  }
  reset() {
    this.sdkAppID = 0;
    this.userID = '';
    this.userSig = '';
    this.tim = null;
    this.globalCallPagePath = '';
  }
};


