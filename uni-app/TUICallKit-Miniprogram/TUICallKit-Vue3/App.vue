<script setup>
import { genTestUserSig }  from  './debug/GenerateTestUserSig';
import {onLaunch} from '@dcloudio/uni-app';
const TIM = require('tim-wx-sdk');

	const globalData =  {
		SDKAppID: genTestUserSig('').sdkAppID,
		userID: '',
		userSig: ''
	};
	onLaunch(()=> {
		// 重点注意： 为了 uni-app 更好地接入使用 tim，快速定位和解决问题，请勿修改 uni.$TUIKit 命名。
		// 如果您已经接入 tim ，请将 uni.tim 修改为 uni.$TUIKit。
		uni.$TUIKit = TIM.create({
			SDKAppID: globalData.SDKAppID,
		});
		uni.$TIM = TIM
	});
</script>
