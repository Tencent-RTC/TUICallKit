<template>
	<view class="container">
		<view class='guide-box'>
			<view class="single-box" v-for="(item, index) in entryInfos" :key="index" :id="index" @click='handleEntry'>
				<image class="icon" mode="aspectFit" :src="item.icon" role="img"></image>
				<view class="single-content">
					<view class="label">{{ item.title }}</view>
					<view class="desc">{{ item.desc }}</view>
				</view>
			</view>
		</view>
		<view class="login" style="width: 70%; margin: 0 auto 0;"><button class="loginBtn"
				@click="logoutHandler">登出</button></view>
<!-- 		<view style="width: 70%; margin: 15px auto 0;" @click="setNickHandler">设置昵称</view>
		<view style="width: 70%; margin: 15px auto 0;" @click="setUserAvatarHandler">设置头像</view>
		<view style="width: 70%; margin: 15px auto 0;" @click="setCallingBellHandler">设置铃声</view> -->
	</view>
</template>

<script>
	export default {
		data() {
			return {
				template: '1v1',
				entryInfos: [{
						icon: 'https://web.sdk.qcloud.com/component/miniApp/resources/audio-card.png',
						title: '语音通话',
						desc: '丢包率70%仍可正常语音通话',
						navigateTo: '../calling/call?type=1',
					},
					{
						icon: 'https://web.sdk.qcloud.com/component/miniApp/resources/video-card.png',
						title: '视频通话',
						desc: '丢包率50%仍可正常视频通话',
						navigateTo: '../calling/call?type=2',
					},
					{
						icon: 'https://web.sdk.qcloud.com/component/miniApp/resources/audio-card.png',
						title: '多人语音通话',
						desc: '丢包率70%仍可正常语音通话',
						navigateTo: '../calling/groupCall?type=1',
					},
					{
						icon: 'https://web.sdk.qcloud.com/component/miniApp/resources/video-card.png',
						title: '多人视频通话',
						desc: '丢包率50%仍可正常视频通话',
						navigateTo: '../calling/groupCall?type=2',
					},
				],
			}
		},
		methods: {
			logoutHandler() {
				// IM 登出
				uni.$TUIKit.logout();
				// 登出 原生插件
				uni.$TUICallKit.logout((res) => {
					console.log('logout response = ', JSON.stringify(res));
				});
				uni.navigateTo({
					url: './login'
				});
			},
			handleEntry(e) {
				const url = this.entryInfos[e.currentTarget.id].navigateTo;
				uni.navigateTo({
					url,
				});
			},
			setNickHandler() {
				console.error('--linda')
				uni.$TUICallKit.setSelfInfo({
					nickName: '小橙子'
				}, (res) => {
					uni.showToast({
						title: res.msg,
						icon: 'none'
					});
					console.log(JSON.stringify(res))
				})
			},
			setUserAvatarHandler() {
				uni.$TUICallKit.setSelfInfo({
					avatar: 'https://liteav.sdk.qcloud.com/app/res/picture/voiceroom/avatar/user_avatar7.png'
				}, (res) => {
					uni.showToast({
						title: res.msg,
						icon: 'none'
					});
					console.log(JSON.stringify(res))
				})
			},
			setCallingBellHandler() {
				const ringtone = '/sdcard/android/data/uni.UNI03400CB/rain.mp3'; // android
				// const ringtone = '/sdcard/android/data/uni.UNI03400CB/rain.mp3'; // ios
				uni.$TUICallKit.setCallingBell(ringtone, (res) => {
					uni.showToast({
						title: res.msg,
						icon: 'none'
					});
					console.log(JSON.stringify(res))
				});
			}
		},
		onLoad() {
			uni.$TUICallKitEvent.addEventListener('onError', (code, msg) => {
				console.log('onError', code, msg);
			});
			uni.$TUICallKitEvent.addEventListener('onCallReceived', (res) => {
				console.log('onCallReceived', JSON.stringify(res));
			});
			uni.$TUICallKitEvent.addEventListener('onCallCancelled', (callerId) => {
				console.log('onCallCancelled', callerId);
			});
			uni.$TUICallKitEvent.addEventListener('onCallBegin', (res) => {
				console.log('onCallBegin', JSON.stringify(res));
			});
			uni.$TUICallKitEvent.addEventListener('onCallEnd', (res) => {
				console.log('onCallEnd', JSON.stringify(res));
			});


		},
		created() {

		}
	}
</script>

<style>
	.container {
		/* background-image: url(https://mc.qcloudimg.com/static/img/7da57e0050d308e2e1b1e31afbc42929/bg.png); */
		background: #F4F5F9;
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
		background: #FFFFFF;
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
