Page({
  TUICallKit: null,
  data: {
    config: {
    },
  },
  async onLoad(option) {
    const config = JSON.parse(option.configData);
    this.setData(
      {
        config: { ...this.data.config, ...config },
      },
      async () => {
        this.TUICallKit = this.selectComponent('#TUICallKit-component');
        try {
          await this.TUICallKit.init(config);
          const event = JSON.parse(option.data);
          wx.$TUICallEngine.TRTCCallingDelegate.onInvited(event.data);
        } catch (error) {
          console.error(error);
        }
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
