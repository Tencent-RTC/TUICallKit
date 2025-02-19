<template>
  <view class="container">
    <view class="trtc-calling-index">
      <view class="trtc-calling-index-search">
        <view class="search">
          <view class="input-box">
            <input
              class="input-search-user"
              :value="data.userIDToSearch"
              maxlength="11"
              type="text"
              v-on:input="userIDToSearchInput"
              placeholder="搜索用户ID"
            />
          </view>
          <view class="btn-search" @click="searchUser">搜索</view>
        </view>
        <view class="search-selfInfo">
          <label class="search-selfInfo-label">您的ID</label>
          <view class="search-selfInfo-phone">
            {{ data.userID }}
          </view>

          <view v-if="data.searchList.length !== 0">
            <view class="allcheck" @click="allCheck" v-if="data.ischeck">
              全选
            </view>
            <view class="allcheck" @click="allCancel" v-else> 取消 </view>
          </view>
        </view>
        <scroll-view scroll-y class="trtc-calling-group-user-list">
          <view
            class="trtc-calling-group-user-row"
            v-for="(item, index) in data.searchList"
            :key="index"
          >
            <view class="trtc-calling-group-user-item">
              <view
                v-if="!item.checked"
                class="trtc-calling-group-user-switch"
                @click="addUser"
                :data-word="item"
              >
              </view>
              <image
                v-else
                class="trtc-calling-group-user-checkimg"
                @click="removeUser"
                :data-word="item"
                src="../../static/check.png"
              >
              </image>
              <image
                class="trtc-calling-group-user-avatar userInfo-avatar"
                :src="item.avatar"
                >{{ item.userID }}</image
              >
              <view class="trtc-calling-group-user-name">{{
                item.userID
              }}</view>
            </view>
          </view>
        </scroll-view>
        <view
          v-if="data.callBtn"
          class="trtc-calling-group-user-callbtn"
          @click="groupCall"
        >
          开始通话</view
        >
      </view>
    </view>
  </view>
</template>

<script setup>
import { nextTick, shallowRef, ref, reactive } from "vue";
import { onUnload, onLoad } from "@dcloudio/uni-app";
import { TUICallKitServer } from "../../TUICallKit/src/index";
import Chat from '@tencentcloud/chat';
const data = reactive({
  searchList: [],
  callBtn: false,
  ischeck: true,
  userID: "",
  type: 1,
  userIDToSearch: "",
  groupID: "",
});

// 监听输入框
const userIDToSearchInput = (e) => {
  data.userIDToSearch = e.detail.value;
};

// 搜索
const searchUser = () => {
  // 去掉前后空格
  data.userIDToSearch = data.userIDToSearch.trim();
  // 不能呼叫自身
  if (data.userIDToSearch === getApp().globalData.userID) {
    uni.showToast({
      icon: "none",
      title: "不能呼叫本机",
    });
    return;
  }
  // 最大呼叫人数为九人(含自己)
  if (data.searchList.length > 7) {
    uni.showToast({
      icon: "none",
      title: "暂支持最多9人通话。如需多人会议，请使用TUIRoom",
    });
    return;
  }
  for (let i = 0; i < data.searchList.length; i++) {
    if (data.searchList[i].userID === data.userIDToSearch) {
      uni.showToast({
        icon: "none",
        title: "userId已存在,请勿重复添加",
      });
      return;
    }
  }
  TUICallKitServer.getTim()
    .getUserProfile({ userIDList: [data.userIDToSearch] })
    .then((imResponse) => {
      if (imResponse.data.length === 0) {
        wx.showToast({
          title: "未查询到此用户",
          icon: "none",
        });
        return;
      }
      const list = {
        userID: data.userIDToSearch,
        nick: imResponse.data[0].nick,
        avatar: imResponse.data[0].avatar,
        checked: false,
      };
      data.searchList.push(list);
      data.callBtn = true;
      data.userIDToSearch = "";
    });
};

function beforeCalling() {
  data.callBtn = false;
}

function afterCalling() {
  data.callBtn = true;
}

// 群通话
const groupCall = async () => {
  // 将需要呼叫的用户从搜索列表中过滤出来
  const newList = data.searchList.filter((item) => item.checked);
  const userIDList = newList.map((item) => item.userID);
  // 未选中用户无法发起群通话
  if (userIDList.length === 0) {
    uni.showToast({
      icon: "none",
      title: "未选择呼叫用户",
    });
    return;
  }
  // 处理数据
  const groupList = JSON.parse(JSON.stringify(userIDList));
  // 将本机userID插入群成员中
  groupList.unshift(getApp().globalData.userID);
  for (let i = 0; i < groupList.length; i++) {
    const user = {
      userID: groupList[i],
    };
    groupList[i] = user;
  }
  // 创建群聊
  // await createGroup(groupList);
  // 发起群通话
  TUICallKitServer.calls({
    userIDList,
    type: data.type,
    // groupID: data.groupID,
  });
  // 重置数据
  data.callBtn = false;
  data.ischeck = true;
};

// 选中
const addUser = (event) => {
  // 修改数据
  for (let i = 0; i < data.searchList.length; i++) {
    if (data.searchList[i].userID === event.target.dataset.word.userID) {
      data.searchList[i].checked = true;
    }
  }
};

// 取消选中
const removeUser = (event) => {
  for (let i = 0; i < data.searchList.length; i++) {
    if (data.searchList[i].userID === event.target.dataset.word.userID) {
      data.searchList[i].checked = false;
    }
  }
};

// 全选
const allCheck = () => {
  const newlist = data.searchList;
  // 改变搜索列表
  for (let i = 0; i < newlist.length; i++) {
    newlist[i].checked = true;
  }
  data.searchList = newlist;
  data.ischeck = false;
};

// 全部取消
const allCancel = () => {
  const newlist = data.searchList;
  // 改变搜索列表
  for (let i = 0; i < newlist.length; i++) {
    newlist[i].checked = false;
  }
  data.searchList = newlist;
  data.ischeck = true;
};

// 创建IM群聊
const createGroup = (userIDList) => {
  return TUICallKitServer.getTim()
    .createGroup({
      type: Chat.TYPES.GRP_PUBLIC,
      name: "call 测试",
      memberList: userIDList, // 如果填写了 memberList，则必须填写 userID
    })
    .then((imResponse) => {
      // 创建成功
      data.groupID = imResponse.data.group.groupID;
    })
    .catch((imError) => {
      console.warn("createGroup error:", imError); // 创建群组失败的相关信息
    });
};

onLoad((option) => {
  data.userID = getApp().globalData.userID;
  data.type = Number(option.type);
});
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
  color: #0a6cff;
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
  border: 2px solid #c7ced7;
  margin: 0px 20px;
  border-radius: 50%;
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

.trtc-calling-index-search > .search {
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
  background: #0a6cff;
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
  background: #f4f5f9;
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
  color: #8a898e;
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

.userInfo-box > .userInfo-avatar {
  width: 64px;
  height: 64px;
  border-radius: 10px;
}

.userInfo-box > .userInfo-name {
  padding-left: 8px;
}

.btn-userinfo-call {
  background-color: #0a6cff;
  color: #ffffff;
  padding: 4px 10px;
  border-radius: 6px;
  font-size: 14px;
}

.user-to-call > image {
  height: 50px;
  line-height: 50px;
  border-radius: 50px;
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
  background: #9a9a9a;
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
  color: #97989c;
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
  color: #8a898e;
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
  line-height: 18px;
}
</style>