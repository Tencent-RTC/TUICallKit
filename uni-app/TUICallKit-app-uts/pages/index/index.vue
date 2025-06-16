<template>
  <view class="container">
    <view class="guide-box">
      <view
        class="single-box"
        v-for="(item, index) in entryInfos"
        :key="index"
        :id="index"
        @click="handleEntry"
      >
        <image
          class="icon"
          mode="aspectFit"
          :src="item.icon"
          role="img"
        ></image>
        <view class="single-content">
          <view class="label">{{ item.title }}</view>
          <view class="desc">{{ item.desc }}</view>
        </view>
      </view>
      <button class="loginBtn" @click="logoutHandler">{{ "Logout" }}</button>
    </view>
  </view>
</template>

<script>
export default {
  data() {
    return {
      template: "1v1",
      entryInfos: [
        {
          icon: "https://web.sdk.qcloud.com/component/miniApp/resources/audio-card.png",
          title: "Voice Call",
          desc: "a 70% packet loss rate",
          navigateTo: "../call/call?type=1",
        },
        {
          icon: "https://web.sdk.qcloud.com/component/miniApp/resources/video-card.png",
          title: "Video Call",
          desc: "a 50% packet loss rate",
          navigateTo: "../call/call?type=2",
        },
        {
          icon: "https://web.sdk.qcloud.com/component/miniApp/resources/audio-card.png",
          title: "Multi-Person Voice Call",
          desc: "a 70% packet loss rate",
          navigateTo: "../groupCall/groupCall?type=1",
        },
        {
          icon: "https://web.sdk.qcloud.com/component/miniApp/resources/video-card.png",
          title: "Multi-Person Video Call",
          desc: "a 50% packet loss rat",
          navigateTo: "../groupCall/groupCall?type=2",
        },
      ],
    };
  },
  methods: {
    joinAPI() {
      uni.$TUICallKit.join({
        callId: "xxx",
      });
    },
    logoutHandler() {
      // IM 登出
      uni.$TUIKit.logout();
      uni.$TUICallKit.enableVirtualBackground(false);
      // 登出 原生插件
      uni.$TUICallKit.logout({
        success: () => {
          console.log("logout success");
        },
        fail: (errCode, errMsg) => {
          console.log(`logout fail, errCode = ${errCode}, errMsg = ${errMsg}`);
        },
      });
      uni.redirectTo({
        url: "/pages/login/login",
      });
    },
    handleEntry(e) {
      const url = this.entryInfos[e.currentTarget.id].navigateTo;
      uni.navigateTo({
        url,
      });
    },
  },
};
</script>

<style>
.container {
  /* background-image: url(https://mc.qcloudimg.com/static/img/7da57e0050d308e2e1b1e31afbc42929/bg.png); */
  background: #f4f5f9;
  background-repeat: no-repeat;
  background-size: cover;
  width: 100vw;
  height: 100vh;
  display: flex;
  flex-direction: column;
  align-items: center;
  box-sizing: border-box;
}

.container .title {
  position: relative;
  width: 100vw;
  font-size: 18px;
  color: #000000;
  letter-spacing: 0;
  text-align: center;
  line-height: 28px;
  font-weight: 600;
  background: #ffffff;
  margin-top: 3.8vh;
  padding: 1.2vh 0;
}

.tips {
  color: #ffffff;
  font-size: 12px;
  text-align: center;
}

.guide-box {
  width: 100vw;
  box-sizing: border-box;
  padding: 16px;
  display: flex;
  flex-direction: column;
}

.single-box {
  flex: 1;
  border-radius: 10px;
  background-color: #ffffff;
  margin-bottom: 16px;
  display: flex;
  align-items: center;
}

.icon {
  display: block;
  width: 180px;
  height: 144px;
}

.single-content {
  padding: 36px 30px 36px 20px;
  color: #333333;
}

.label {
  display: block;
  font-size: 18px;
  color: #333333;
  letter-spacing: 0;
  font-weight: 500;
}

.desc {
  display: block;
  font-size: 14px;
  color: #333333;
  letter-spacing: 0;
  font-weight: 500;
}

.logo-box {
  position: absolute;
  width: 100vw;
  bottom: 36rpx;
  text-align: center;
}

.logo {
  width: 160rpx;
  height: 44rpx;
}
</style>
