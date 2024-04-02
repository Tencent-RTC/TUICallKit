const plugin = requirePlugin('TUICallKit-plugin')
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
      const UserSigConfig = {
        userID: this.data.userID,
        SDKAppID: wx.$globalData.sdkAppID,
        SecretKey: wx.$globalData.SecretKey
      }
      const { userSig } = plugin.genTestUserSig(UserSigConfig);
      plugin.getTUICallKitServer().init({
        sdkAppID: wx.$globalData.sdkAppID,
        userID: this.data.userID,
        userSig: userSig
      });
      wx.$globalData.userID = this.data.userID;
      wx.navigateTo({
        url: '../index/index',
      });
    }
  },
});
