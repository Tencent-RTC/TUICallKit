import { genTestUserSig } from '../../debug/GenerateTestUserSig';
import {  MEDIA_TYPE } from '../../TUICallEngine/tuicall-engine-wx.js';

Page({
  TUICallKit: null,
  data: {
    userIDToSearch: '',
    searchResultShow: false,
    invitee: null,
    config: {
      sdkAppID: wx.$globalData.sdkAppID,
      userID: wx.$globalData.userID,
      userSig: wx.$globalData.userSig,
      type: MEDIA_TYPE.AUDIO,
      tim: null,
    },
  },

  userIDToSearchInput(e) {
    this.setData({
      userIDToSearch: e.detail.value,
    });
  },

  searchUser() {
    this.data.invitee = {
      userID: this.data.userIDToSearch,
    };
    this.TUICallKit.getTim()
      .getUserProfile({ userIDList: [this.data.userIDToSearch] })
      .then((imResponse) => {
        console.log('获取getUserProfile', imResponse.data);
        if (imResponse.data.length === 0) {
          wx.showToast({
            title: '未查询到此用户',
            icon: 'none',
          });
          return;
        }
        this.setData({
          invitee: { ...imResponse.data[0] },
          searchResultShow: true,
        });
      });
  },

  async call() {
    if (this.data.config.userID === this.data.invitee.userID) {
      wx.showToast({
        icon: 'none',
        title: '不可呼叫本机',
      });
      return;
    }

    try {
      await this.TUICallKit.call({
        userID: this.data.invitee.userID,
        type: MEDIA_TYPE.AUDIO,
      });
    } catch (error) {
      wx.showModal({
        icon: 'none',
        title: 'error',
        content: error.message,
        showCancel: false,
      });
    }
  },

  onBack() {
    wx.navigateBack({
      delta: 1,
    });
  },

  onLoad() {
    const Signature = genTestUserSig(wx.$globalData.userID);
    const config = {
      sdkAppID: wx.$globalData.sdkAppID,
      userID: wx.$globalData.userID,
      userSig: Signature.userSig,
    };
    this.setData(
      {
        config: { ...this.data.config, ...config },
      },
      () => {
        this.TUICallKit = this.selectComponent('#TUICallKit-component');
        this.TUICallKit.init();
      },
    );
  },
  /**
   * 生命周期函数--监听页面卸载
   */
  onUnload() {
    this.TUICallKit.destroyed();
  },

  onShow() {},
});
