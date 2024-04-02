// index.js
Page({
  data: {
    template: '1v1',
    entryInfos: [
      {
        icon: 'https://web.sdk.qcloud.com/component/miniApp/resources/audio-card.png',
        title: '语音通话',
        desc: '丢包率70%仍可正常语音通话',
        callType: 1,
        navigateTo: '../call/call',
      },
      {
        icon: 'https://web.sdk.qcloud.com/component/miniApp/resources/video-card.png',
        title: '视频通话',
        desc: '丢包率50%仍可正常视频通话',
        callType: 2,
        navigateTo: '../call/call',
      },
      {
        icon: 'https://web.sdk.qcloud.com/component/miniApp/resources/audio-card.png',
        title: '多人语音通话',
        desc: '丢包率70%仍可正常语音通话',
        callType: 1,
        navigateTo: '../groupCall/groupCall',
      },
      {
        icon: 'https://web.sdk.qcloud.com/component/miniApp/resources/video-card.png',
        title: '多人视频通话',
        desc: '丢包率50%仍可正常视频通话',
        navigateTo: '../groupCall/groupCall',
      },
    ],
  },

  selectTemplate(event) {
    this.setData({
      template: event.detail.value,
    });
  },
  handleEntry(e) {
    const url = this.data.entryInfos[e.currentTarget.id].navigateTo;
    wx.$globalData.callType = this.data.entryInfos[e.currentTarget.id].callType;
    wx.navigateTo({
      url,
    });
  },

  onShow() {
    if (typeof this.getTabBar === 'function' && this.getTabBar()) {
      this.getTabBar().setData({ selected: 0 });
    }
  },
});
