import { genTestUserSig } from '../../debug/GenerateTestUserSig';
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

  login() {
    if (!this.data.userID) {
      wx.showToast({
        title: '名称不能为空',
        icon: 'error',
      });
    } else {
      wx.$globalData.userID = this.data.userID;
      const { userSig } = genTestUserSig(wx.$globalData.userID);
      wx.$globalData.userSig = userSig;
      wx.CallManager.init({
        sdkAppID: wx.$globalData.sdkAppID,
        userID: wx.$globalData.userID,
        userSig: wx.$globalData.userSig,
        globalCallPagePath: 'TUICallKit/TUICallKit/pages/globalCall/globalCall',
      });
      wx.switchTab({
        url: '../index/index',
      });
    }
  },
});
