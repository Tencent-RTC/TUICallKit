<template>
  <view class="defaultStyles"> </view>
</template>
<script lang="uts">
import CallVideoLayout from 'com.tencent.qcloud.tuikit.tuicallkit.view.component.videolayout.CallVideoLayout';
import { NAME } from './utils/index.uts';

export default {
	name: "call-view",
	created() {
		console.log(`${NAME["PREFIX"]} CallVideoLayout created`);
	},
	NVLoad() : CallVideoLayout {
		let callview = new CallVideoLayout($androidContext!)
		console.log(`${NAME["PREFIX"]} CallVideoLayout NVLoad, ${callview}`);
		return callview;
	},
	NVLoaded() {
		console.log(`${NAME["PREFIX"]} CallVideoLayout NVLoaded, ${UTSAndroid.devicePX2px(1080)}`);
	},
	NVLayouted() {
		console.log(`${NAME["PREFIX"]} CallVideoLayout NVLayouted`);
	},
	NVUpdateStyles(styles : Map<String, any>) {
		console.log(`${NAME["PREFIX"]} CallVideoLayout NVUpdateStyles, ${styles}`);
	},
	NVBeforeUnload() {
		console.log(`${NAME["PREFIX"]} CallVideoLayout NVBeforeUnload`);
	},
	NVUnloaded() {
		console.log(`${NAME["PREFIX"]} CallVideoLayout NVUnloaded`);
	},
	unmounted() {
		console.log(`${NAME["PREFIX"]} CallVideoLayout unmounted`);
	}
}
</script>

<style>
/* 定义默认样式值, 组件使用者没有配置时使用 */
.defaultStyles {
  background-color: white;
}
</style>
