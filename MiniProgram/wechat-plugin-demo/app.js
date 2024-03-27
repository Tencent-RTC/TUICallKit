// app.js
App({
  onLaunch() {
    wx.$globalData = {
      sdkAppID: 0,
      userID: '',
      SecretKey: '',
      callType: 1
    };
  },
})
