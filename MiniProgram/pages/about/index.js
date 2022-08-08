// pages/about/index.js
Page({

  /**
   * 页面的初始数据
   */
  data: {
    list: [
      {
        name: '应用版本',
        value: wx.getAccountInfoSync().miniProgram.version,
      },
      {
        name: '注销账户',
        path: '../cancellation/index',
      },
    ],
  },

  /**
   * 生命周期函数--监听页面加载
   */
  onLoad() {
    console.log(this.data.list);
    console.log('获取当前版本', wx.getAccountInfoSync());
  },

  /**
   * 生命周期函数--监听页面初次渲染完成
   */
  onReady() {

  },

  /**
   * 生命周期函数--监听页面显示
   */
  onShow() {

  },

  /**
   * 生命周期函数--监听页面隐藏
   */
  onHide() {

  },

  /**
   * 生命周期函数--监听页面卸载
   */
  onUnload() {

  },

  /**
   * 页面相关事件处理函数--监听用户下拉动作
   */
  onPullDownRefresh() {

  },

  /**
   * 页面上拉触底事件的处理函数
   */
  onReachBottom() {

  },

  /**
   * 用户点击右上角分享
   */
  onShareAppMessage() {

  },
  onBack() {
    wx.navigateBack({
      delta: 1,
    });
  },
  // 路由跳转
  handleRouter(e) {
    const data = e.currentTarget.dataset.item;
    if (data.path) {
      wx.navigateTo({ url: `${data.path}` });
    }
  },
});
