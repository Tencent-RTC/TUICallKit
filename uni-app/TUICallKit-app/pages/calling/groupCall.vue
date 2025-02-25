<template>
	<view class="container">
		<view class="trtc-calling-index">
			<view class="trtc-calling-index-search">
				<view class="search">
					<view class="input-box">
						<input class="input-search-user" :value="userIDToSearch" maxlength="11" type="text"
							v-on:input="userIDToSearchInput" :placeholder="$t('Search User ID')" />
					</view>
					<view class="btn-search" @click="searchUser">{{ $t('Search') }}</view>
				</view>
				<view class="search-selfInfo">
					<label class="search-selfInfo-label">{{ $t('Your ID') }}</label>
					<view class="search-selfInfo-phone">
						{{ config.userID }}
					</view>

					<view v-if="searchList.length !== 0">
						<view class="allcheck" @click="allCheck" v-if="ischeck">
							{{ $t('Select All') }}
						</view>
						<view class="allcheck" @click="allCancel" v-else>
							{{ $t('Cancel') }}
						</view>
					</view>
				</view>

				<scroll-view v-if="callBtn" scroll-y class="trtc-calling-group-user-list">
					<view>
						<view class="trtc-calling-group-user-row" v-for="(item, index) in searchList" :key="index">
							<view class="trtc-calling-group-user-item">
								<view v-if="!item.checked" class="trtc-calling-group-user-switch" @click="addUser"
									:data-word="item">
								</view>
								<image v-else class="trtc-calling-group-user-checkimg" @click="removeUser"
									:data-word="item" src="../../static/check.png">
								</image>
								<image class="trtc-calling-group-user-avatar userInfo-avatar" :src="item.avatar">{{
										item.userID
								}}</image>
								<view class="trtc-calling-group-user-name">{{ item.userID }}</view>
							</view>
						</view>
					</view>
				</scroll-view>

				<view v-if="callBtn && searchList.length > 0" class="trtc-calling-group-user-callbtn"
					@click='groupCall'>
					{{ $t('Start Call') }}</view>

				<view v-if="!callBtn" class="search-default">
					<view class="search-default-box">
						<image class="search-default-img" src="../../static/search.png" lazy-load="true" />
						<view class="search-default-message">
							{{ $t('initiated a call') }}
						</view>
					</view>
				</view>
			</view>
		</view>
	</view>

</template>

<script>
export default {
	data() {
		return {
			userIDToSearch: '',  // 搜索的结果
			searchList: [],  // 搜索后展示的列表
			callBtn: false,  // 控制呼叫按钮的显示隐藏
			ischeck: true,   // 显示是否全选
			config: {
				sdkAppID: '',
				userID: '',
				userSig: '',
			},
			groupID: '',
		}
	},
	onLoad(option) {
		this.config = {
			sdkAppID: getApp().globalData.SDKAppID,
			userID: getApp().globalData.userID,
			userSig: getApp().globalData.userSig,
			type:Number(option.type)
		}
	},
	methods: {
		userIDToSearchInput(e) {
			this.userIDToSearch = e.detail.value
		},
		searchUser() {
			// 去掉前后空格
			const newSearch = this.userIDToSearch.trim();
			this.userIDToSearch = newSearch;
			// 不能呼叫自身
			if (this.userIDToSearch === getApp().globalData.userID) {
				uni.showToast({
					icon: 'none',
					title: this.$t('Do not call local'),
				});
				return;
			}
			// 最大呼叫人数为九人(含自己)
			if (this.searchList.length > 7) {
				uni.showToast({
					icon: 'none',
					title: this.$t('Supports up to 9 calls'),
				});
				return;
			}
			for (let i = 0; i < this.searchList.length; i++) {
				if (this.searchList[i].userID === this.userIDToSearch) {
					uni.showToast({
						icon: 'none',
						title: this.$t('The userId already exists'),
					});
					return;
				}
			}
			uni.$TUIKit.getUserProfile({ userIDList: [this.userIDToSearch] })
				.then((imResponse) => {
					if (imResponse.data.length === 0) {
						wx.showToast({
							title: this.$t('User not found'),
							icon: 'none',
						});
						return;
					}
					const list = {
						userID: this.userIDToSearch,
						nick: imResponse.data[0].nick,
						avatar: imResponse.data[0].avatar,
						checked: false,
					};
					this.searchList.push(list);
					this.searchList = this.searchList;
					this.callBtn = true;
					this.userIDToSearch = '';

				});
		},

		// 群通话
		async groupCall() {
			// 将需要呼叫的用户从搜索列表中过滤出来
			const newList = this.searchList.filter(item => item.checked);
			const userIDList = newList.map(item => item.userID);
			// 未选中用户无法发起群通话
			if (userIDList.length === 0) {
				uni.showToast({
					icon: 'none',
					title: this.$t('No call user is selected'),
				});
				return;
			}
			// type：通话的媒体类型，比如：语音通话(callMediaType = 1)、视频通话(callMediaType = 2)
			uni.$TUICallKit.calls({
				userIDList: userIDList,
				callMediaType: this.config.type,
				// callParams: {
						// roomID: 0,
						// timeout:30,
						// offlinePushInfo: {
						// 	title: "test-title",
						// 	description: "you have a call",
						// 	androidSound: "rain",
						// 	iOSSound: "rain.mp3",
						// },
					// }
				},
				res => {
					console.log(JSON.stringify(res));
				}
			);
			// 重置数据
			this.ischeck= true;
			// searchList: [],
		},

		// 选中
		addUser(event) {
			// 修改数据
			for (let i = 0; i < this.searchList.length; i++) {
				if (this.searchList[i].userID === event.target.dataset.word.userID) {
					const newlist = this.searchList;
					newlist[i].checked = true;
					this.searchList=newlist
				}
			}
		},

		// 取消选中
		removeUser(event) {
			for (let i = 0; i < this.searchList.length; i++) {
				if (this.searchList[i].userID === event.target.dataset.word.userID) {
					const newlist = this.searchList;
					newlist[i].checked = false;
					this.searchList = newlist;
				}
			}
		},

		// 全选
		allCheck() {
			const newlist = this.searchList;
			// 改变搜索列表
			for (let i = 0; i < newlist.length; i++) {
				newlist[i].checked = true;
			}
			this.searchList = newlist;
			this.ischeck = false
		},

		// 全部取消
		allCancel() {
			const newlist = this.searchList;
			// 改变搜索列表
			for (let i = 0; i < newlist.length; i++) {
				newlist[i].checked = false;
			}
			this.searchList=newlist;
				this.ischeck= true
		},
	}
}
</script>

<style>
.container {
	width: 100vw;
	height: 100vh;
	overflow: hidden;
	/* background-image: url(https://mc.qcloudimg.com/static/img/7da57e0050d308e2e1b1e31afbc42929/bg.png); */
	margin: 0;
}

.trtc-calling-group-container {
	height: 30%;
	color: #000000;
	padding: 0 16px;
}

.trtc-calling-group-title {
	font-weight: bold;
	font-size: 18px;
	display: inline-block;
}

.trtc-calling-group-confirm {
	float: right;
	color: #0A6CFF;
	font-size: 14px;
}

.trtc-calling-group-user-list {
	height: 62%;
}

.trtc-calling-group-user-row {
	display: flex;
	align-items: center;
}

.trtc-calling-group-user-item {
	display: flex;
	align-items: center;
	flex: 1;
	margin-top: 10px;
}

.trtc-calling-group-user-checkimg {
	width: 6.4vw;
	height: 6.4vw;
	margin: 0px 20px;
	border: 2px solid;
}

.trtc-calling-group-user-name {
	font-family: PingFangSC-Regular;
	font-weight: 400;
	font-size: 14px;
	color: #666666;
	letter-spacing: 0;
}

.trtc-calling-group-user-switch {
	width: 6.4vw;
	height: 6.4vw;
	border: 2px solid #C7CED7;
	margin: 0px 20px;
	border-radius: 50%
}




.trtc-calling-group-user-avatar {
	width: 17vw;
	height: 17vw;
	border-radius: 20px;
	margin: 10px 20px 10px 0px;
}

.trtc-calling-group-user-callbtn {
	position: absolute;
	bottom: 12%;
	left: 31.5%;
	width: 37vw;
	text-align: center;
	height: 13.5vw;
	background-color: #006eff;
	border-radius: 50px;
	color: white;
	font-size: 18px;
	line-height: 13.5vw;
}

.trtc-calling-index {
	width: 100vw;
	height: 100vh;
	color: white;
	display: flex;
	flex-direction: column;
}

.trtc-calling-index-title {
	position: relative;
	display: flex;
	width: 100%;
	margin-top: 3.8vh;
	justify-content: center;
}



.trtc-calling-index-title .title {
	margin: 0;
	font-family: PingFangSC-Regular;
	font-size: 16px;
	color: #000000;
	letter-spacing: 0;
	line-height: 36px;
	padding: 1.2vh;
}

.btn-goback {
	position: absolute;
	left: 2vw;
	top: 1.2vh;
	width: 8vw;
	height: 8vw;
	z-index: 9;
}

.trtc-calling-index-search {
	flex: 1;
	margin: 0;
	display: flex;
	flex-direction: column;
}

.trtc-calling-index-search>.search {
	width: 100%;
	display: flex;
	justify-content: space-between;
	align-items: center;
	box-sizing: border-box;
	padding: 16px;
}

.btn-search {
	text-align: center;
	width: 60px;
	height: 40px;
	line-height: 40px;
	background: #0A6CFF;
	border-radius: 20px;
}

.search-result {
	width: 90%;
	height: 40px;
	margin-left: 5%;
}

.input-box {
	flex: 1;
	box-sizing: border-box;
	margin-right: 20px;
	height: 40px;
	background: #F4F5F9;
	color: #666666;
	border-radius: 20px;
	padding: 9px 16px;
	display: flex;
	align-items: center;
}

.icon-right {
	width: 8px;
	height: 12px;
	margin: 0 4px;
}

.input-search-user {
	flex: 1;
	box-sizing: border-box;
}

.input-label {
	display: flex;
	align-items: center;
}

.input-label-plus {
	padding-bottom: 3px;
}

.input-search-user[placeholder] {
	font-family: PingFangSC-Regular;
	font-size: 16px;
	color: #8A898E;
	letter-spacing: 0;
	font-weight: 400;
}

.user-to-call {
	display: flex;
	justify-content: space-between;
	width: 100%;
	margin: 0;
	padding: 16px 0;
	align-items: center;
}

.userInfo-box {
	display: flex;
	align-items: center;
	font-size: 12px;
	color: #333333;
	letter-spacing: 0;
	font-weight: 500;
}

.userInfo-box>.userInfo-avatar {
	width: 64px;
	height: 64px;
	border-radius: 10px;
}

.userInfo-box>.userInfo-name {
	padding-left: 8px;
}

.btn-userinfo-call {
	/* width: 60px;
	height: 40px;
	text-align: center;
	background: #0A6CFF;
	border-radius: 20px;
	line-height: 40px;
	margin: 10px 0;
	color: rgba(255, 255, 255); */
	background-color: #0A6CFF;
	color: #ffffff;
	padding: 4px 10px;
	border-radius: 6px;
	font-size: 14px;
}

.user-to-call>image {
	height: 50px;
	line-height: 50px;
	border-radius: 50px
}

.search-selfInfo {
	position: relative;
	display: flex;
	align-items: center;
	padding: 0 28px;
	font-family: PingFangSC-Regular;
	font-size: 14px;
	color: #333333;
	letter-spacing: 0;
	font-weight: 400;
}

.search-selfInfo::before {
	position: absolute;
	content: "";
	width: 4px;
	height: 12px;
	background: #9A9A9A;
	border: 1px solid #979797;
	border-radius: 2px;
	margin: auto 0;
	left: 16px;
	top: 0;
	bottom: 0;
}

.search-selfInfo-phone {
	padding-left: 8px;
}


.incoming-call {
	width: 100vw;
	height: 100vh;
}

.btn-operate {
	display: flex;
	justify-content: space-between;
	position: absolute;
	bottom: 5vh;
	width: 100%;
}

.call-operate {
	width: 15vw;
	height: 15vw;
	border-radius: 15vw;
	padding: 5px;
	margin: 0 15vw;
}

.tips {
	width: 100%;
	height: 40px;
	line-height: 40px;
	text-align: center;
	font-size: 20px;
	color: #333333;
	letter-spacing: 0;
	font-weight: 500;
}

.tips-subtitle {
	height: 20px;
	font-family: PingFangSC-Regular;
	font-size: 14px;
	color: #97989C;
	letter-spacing: 0;
	font-weight: 400;
	text-align: center;
}


.search-default {
	flex: 1;
	display: flex;
	align-items: center;
	justify-content: center;
}

.search-default-box {
	display: flex;
	flex-direction: column;
	align-items: center;
	justify-content: center;
}

.search-default-img {
	width: 64px;
	height: 66px;
}

.search-default-message {
	width: 126px;
	padding: 16px;
	font-family: PingFangSC-Regular;
	font-size: 14px;
	color: #8A898E;
	letter-spacing: 0;
	text-align: center;
	font-weight: 400;
}

/* 全选 */
.allcheck {
	position: absolute;
	right: 28px;
	font-family: PingFangSC-Regular;
	font-weight: 400;
	font-size: 14px;
	color: #666666;
	letter-spacing: 0;
	line-height: 18px
}
</style>