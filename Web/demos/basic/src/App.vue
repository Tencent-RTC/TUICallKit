<script lang="ts" setup>
import { ref } from "vue";
import { TUICallKit, TUICallKitServer } from "../../../src/index";
import * as GenerateTestUserSig from "../public/debug/GenerateTestUserSig.js";
import TIM from "tim-js-sdk";
import videoBlackSVG from "./assets/videoBlack.svg";
import videoWhiteSVG from "./assets/videoWhite.svg";
import audioWhiteSVG from "./assets/audioWhite.svg";
import audioBlackSVG from "./assets/audioBlack.svg";
import searchSVG from "./assets/search.svg";
import cancelSVG from "./assets/cancel.svg";
import "./App.css";

const SDKAppID = ref<number>(0);
const SecretKey = ref<string>("");
const userID = ref<string>("");
const userList = ref<string[]>([]);
const loginStatus = ref<string>("未登录");

const typeString = ref<string>("video");
const isCalling = ref<boolean>(false);
const groupID = ref<string>("");
let tim: any = null;

async function login(currentUserID?: string) {
  if (!currentUserID) currentUserID = userID.value;
  else userID.value = currentUserID;
  const { userSig } = GenerateTestUserSig.genTestUserSig(
    currentUserID,
    SDKAppID.value,
    SecretKey.value
  );
  tim = TIM.create({
    SDKAppID: SDKAppID.value,
  });
  TUICallKitServer.init({
    userID: currentUserID,
    userSig,
    SDKAppID: SDKAppID.value,
    tim,
  });
  loginStatus.value = userID.value;
  userID.value = "";
}

function switchCallType(type: string) {
  if (isCalling.value) return;
  typeString.value = type;
}

async function startCall(typeString: string) {
  if (loginStatus.value === "未登录") {
    alert("未登录");
    return;
  }
  let type = 0;
  if (typeString === "audio") type = 1;
  else if (typeString === "video") type = 2;
  if (userList.value.length <= 0) return;
  if (userList.value.length === 1)
    await TUICallKitServer.call({ userID: userList.value[0], type });
  else {
    // 此处可直接使用已存在的群组，不需要每次创建新群组
    groupID.value = await createGroup();
    await TUICallKitServer.groupCall({
      userIDList: userList.value,
      type,
      groupID: groupID.value,
    });
  }
}

function beforeCalling() {
  isCalling.value = true;
}

function afterCalling() {
  userList.value = [];
  isCalling.value = false;
}

function addUser(userIDParam: string) {
  if (!userIDParam) return;
  let index = userList.value.indexOf(userIDParam);
  index < 0 && userList.value.push(userIDParam);
  userID.value = "";
}

function removeUser(userID: string) {
  let index = userList.value.indexOf(userID);
  index > -1 && userList.value.splice(index, 1);
}

async function createGroup() {
  const memberList: any[] = [];
  userList.value.forEach((user: string) => {
    memberList.push({ userID: user });
  });
  console.warn(memberList);
  let res = await tim.createGroup({
    type: TIM.TYPES.GRP_PUBLIC,
    name: "group-call",
    memberList,
  });
  return res.data.group.groupID;
}
</script>

<template>
  <div class="wrapper">
    <div class="switch">
      <div class="switch-btn" :class="typeString === 'video' ? 'switch-select' : ''"
        :style="isCalling ? 'cursor: not-allowed' : 'cursor: pointer'" @click="switchCallType('video')">
        <img :src="typeString === 'video' ? videoWhiteSVG : videoBlackSVG" class="icon" />
        <span class="switch-name"> 视频通话 </span>
      </div>
      <div class="switch-btn" :class="typeString === 'audio' ? 'switch-select' : ''"
        :style="isCalling ? 'cursor: not-allowed' : 'cursor: pointer'" @click="switchCallType('audio')">
        <img :src="typeString === 'audio' ? audioWhiteSVG : audioBlackSVG" class="icon" />
        <span class="switch-name"> 音频通话 </span>
      </div>
    </div>
    <div class="call-kit-container">
      <div class="search" v-show="!isCalling">
        <div class="search-window search-left">
          <div class="search-title">{{ typeString === "video" ? "视频通话" : "音频通话" }}</div>
          <div class="search-input-container">
            <img :src="searchSVG" class="icon-search" />
            <input class="search-input" type="text" v-model="userID" />
          </div>
          <div class="add-btn" @click="addUser(userID)">添加到拨打列表</div>
        </div>
        <div class="search-window search-right">
          <div class="selected-title">拨打列表</div>
          <div class="search-results">
            <div class="result-item" v-for="item in userList" v-bind:key="item">
              <div class="user-item">
                <div class="userID">{{ item }}</div>
                <div class="user-email">{{ item }}</div>
              </div>
              <img :src="cancelSVG" class="checkbox cancel" @click="removeUser(item)" />
            </div>
          </div>
          <div class="call-btn" @click="startCall(typeString)">通话</div>
        </div>
      </div>
      <TUICallKit v-show="isCalling" :beforeCalling="beforeCalling" :afterCalling="afterCalling" />
    </div>
  </div>

  <div id="debug">
    <div>
      <span>Debug Panel</span><br />
      目前 userID: <span>({{ loginStatus }})</span>
    </div>
    <span>SDKAppID: </span>
    <input v-model="SDKAppID" placeholder="SDKAppID" type="number" style="width: 100px" />
    <br />
    <span>SecretKey: </span>
    <input v-model="SecretKey" placeholder="SecretKey" style="width: 500px" />
    <div style="font-size: 12px">
      注意️：本 Debug Panel 仅用于调试，正式上线前请将 UserSig
      计算代码和密钥迁移到您的后台服务器上，以避免加密密钥泄露导致的流量盗用。
      <a href="https://cloud.tencent.com/document/product/647/17275" target="_blank">查看文档</a>
    </div>
    <span>UserID: </span> <input v-model="userID" placeholder="UserID" />
    <br />
    <button @click="login()">登录</button>
    <button>
      <a href="/" target="_blank">打开新窗口登录其他 UserID</a>
    </button>
  </div>
</template>
