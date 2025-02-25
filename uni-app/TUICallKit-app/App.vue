<script>
import TIM from '@tencentcloud/chat';
import { genTestUserSig } from './debug/GenerateTestUserSig.js';

// 首先需要通过 uni.requireNativePlugin("ModuleName") 获取 module
const TUICallKit = uni.requireNativePlugin('TencentCloud-TUICallKit');
console.error(TUICallKit, 'TencentCloud-TUICallKit ｜ ok');
const TUICallKitEvent = uni.requireNativePlugin('globalEvent');
const TUICallEngine = uni.requireNativePlugin('TencentCloud-TUICallKit-TUICallEngine');

export default {
	globalData: {
		SDKAppID: genTestUserSig('').sdkAppID,
		userID: '',
		userSig: ''
	},
  onLaunch() {
		uni.$TUIKit = TIM.create({
			SDKAppID: this.globalData.SDKAppID
		});
    // 将原生插件挂载在 uni 上
    uni.$TUICallKit = TUICallKit;
    uni.$TUICallKitEvent = TUICallKitEvent;
	  uni.$TUICallEngine = TUICallEngine;
  },
  onShow() {
    console.log('App Show');
  },
  onHide() {
    console.log('App Hide');
  }
};
</script>

<style>
/*每个页面公共css */
</style>
