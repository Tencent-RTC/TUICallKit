<script>
import TIM from '@tencentcloud/chat';
import Aegis from 'aegis-weex-sdk';
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
    const projectName = 'uniappTUICallKitExt';
    uni.$aegis = new Aegis({
      id: 'iHWefAYqzwvFsESvCj',
      spa: true,
      reportApiSpeed: true,
      reportAssetSpeed: true, 
      pagePerformance: true,
      hostUrl: 'https://tamaegis.com',
    });
    uni.$uploadToTAM = (eventString, sdkAppId) => {
      uni.$aegis.reportEvent({
        name: eventString.split('#')[0] || '',
        ext1: eventString,
        ext2: projectName,
        ext3: sdkAppId,
      });
    };
    uni.$login = sdkAppId => uni.$uploadToTAM('login', sdkAppId);
    uni.$onErrorUpload = (sdkAppId = this.globalData.SDKAppID, errorMsg) => uni.$uploadToTAM(`onError-failed#error: ${errorMsg}`, sdkAppId);

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
