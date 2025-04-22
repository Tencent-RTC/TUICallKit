import { MEDIA_TYPE } from "@tencentcloud/call-engine-wx";
import { TUICallKitServer } from "../../TUICallKit/TUICallService/index";

Page({
  data: {
    userIDToSearch: "",
    searchResultShow: false,
    invitee: null,
    userID: '',
  },

  userIDToSearchInput(e) {
    this.setData({
      userIDToSearch: e.detail.value,
    });
  },

  searchUser() {
    // 去掉前后空格
    const newSearch = this.data.userIDToSearch.trim();
    this.setData({
      userIDToSearch: newSearch,
    });
    this.data.invitee = {
      userID: this.data.userIDToSearch,
    };
    TUICallKitServer.getTim()
      .getUserProfile({ userIDList: [this.data.userIDToSearch] })
      .then((imResponse) => {
        if (imResponse.data.length === 0) {
          wx.showToast({
            title: "未查询到此用户",
            icon: "none",
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
    if (this.data.userID === this.data.invitee.userID) {
      wx.showToast({
        icon: "none",
        title: "不可呼叫本机",
      });
      return;
    }
    try {
      await TUICallKitServer.call({
        userID: this.data.invitee.userID,
        type: MEDIA_TYPE.AUDIO,
      });
    } catch (error) {
      wx.showModal({
        icon: "none",
        title: "error",
        content: error.message,
        showCancel: false,
      });
    }
  },

  onLoad() {
    this.setData({
      userID:wx.$globalData.userID 
    })
  },

  onBack() {
    wx.navigateBack({
      delta: 1,
    });
  },
});
