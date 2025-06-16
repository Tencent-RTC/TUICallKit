<template>
  <view class="defaultStyles"> </view>
</template>
<script lang="uts">
import { CallVideoLayout } from 'TUICallKit_Swift';
import { NAME } from './utils/index.uts';

export default {
	data() {
		return {
		};
	},
	name: "call-view",
	created() {
		console.log(`${NAME["PREFIX"]} CallVideoLayout created`);
	},
	NVBeforeLoad() {
		console.log(`${NAME["PREFIX"]} CallVideoLayout NVBeforeLoad`);
	},
	NVLoad() : CallVideoLayout {

		let callview = new CallVideoLayout();
		console.log(`${NAME["PREFIX"]} CallVideoLayout NVLoad, ${callview}`);
		return callview;
	},
	NVLoaded() {
		console.log(`${NAME["PREFIX"]} CallVideoLayout NVLoaded`);
	},
	NVLayouted() {
		console.log(`${NAME["PREFIX"]} CallVideoLayout NVLayouted`);
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
