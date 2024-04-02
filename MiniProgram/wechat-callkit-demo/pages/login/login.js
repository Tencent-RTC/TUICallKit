import { genTestUserSig } from '../../debug/GenerateTestUserSig';
import { CallManager } from '../../TUICallKit/TUICallService/serve/callManager'
wx.CallManager = new CallManager();
Page({
  data: {
    userID: '',
  },

  onLoad() {

  },

  onShow() {

  },

  onBack() {
    wx.navigateBack({
      delta: 1,
    });
  },

  bindInputUserID(e) {
    this.setData({
      userID: e.detail.value,
    });
  },

  async login() {
    if (!this.data.userID) {
      wx.showToast({
        title: '名称不能为空',
        icon: 'error',
      });
    } else {
      wx.$globalData.userID = this.data.userID;
      const { userSig } = genTestUserSig(wx.$globalData.userID);
      wx.$globalData.userSig = userSig;
      await wx.CallManager.init({
        sdkAppID: wx.$globalData.sdkAppID,
        userID: wx.$globalData.userID,
        userSig: wx.$globalData.userSig,
        globalCallPagePath: 'TUICallKit/pages/globalCall/globalCall',
      });
      wx.switchTab({
        url: '../index/index',
      });
    }
  },
});
