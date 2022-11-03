<script lang="ts" setup>
import { ref, onMounted, onUnmounted } from "vue";
import { TUICallKit, TUICallKitServer, TUICallKitMini } from "../../..";
import * as GenerateTestUserSig from "../public/debug/GenerateTestUserSig.js";
import TIM from "tim-js-sdk";
import { copyText } from "vue3-clipboard";
import videoBlackSVG from "./assets/videoBlack.svg";
import videoWhiteSVG from "./assets/videoWhite.svg";
import audioWhiteSVG from "./assets/audioWhite.svg";
import audioBlackSVG from "./assets/audioBlack.svg";
import searchSVG from "./assets/search.svg";
import cancelSVG from "./assets/cancel.svg";
import { ElMessage } from 'element-plus';
import "./App.css";

const SDKAppID = ref<number>(0);
const SecretKey = ref<string>("");
const userID = ref<string>("");
const loginUserID = ref<string>("");
const userList = ref<string[]>([]);
const currentUserID = ref<string>("未登录");

const debugDisplayStyle = ref<string>("");
const isNewTab = ref<boolean>(false);
const isMinimized = ref<boolean>(false);
const lang = ref<string>("zh-cn");

const typeString = ref<string>("video");
const isCalling = ref<boolean>(false);
const groupID = ref<string>("");
let tim: any = null;

onMounted(() => {
  if (getQueryVariable("SDKAppID") === false) SDKAppID.value = 0;
  else {
    SDKAppID.value = parseInt(getQueryVariable("SDKAppID") as string);
    isNewTab.value = true;
  }
  SecretKey.value = getQueryVariable("SecretKey") || "";
});

onUnmounted(() => {
  TUICallKitServer.destroyed();
})

async function login() {
  if (!SDKAppID.value || SDKAppID.value === 0) {
    alert("请填写 SDKAppID");
    return;
  }
  if (!SecretKey.value) {
    alert("请填写 SecretKey");
    return;
  }
  if (!loginUserID.value) {
    alert("请填写 userID");
    return;
  }
  const { userSig } = GenerateTestUserSig.genTestUserSig(
    loginUserID.value,
    SDKAppID.value,
    SecretKey.value
  );
  tim = TIM.create({
    SDKAppID: SDKAppID.value,
  });
  try {
    await TUICallKitServer.init({
      userID: loginUserID.value,
      userSig,
      SDKAppID: SDKAppID.value,
      tim,
    });
    currentUserID.value = loginUserID.value;
    debugDisplayStyle.value = "display: none;";
  } catch (error: any) {
    if (error.message) ElMessage.error(`登录失败，请检查 SDKAppID 与 SecretKey 是否正确 ${error.message}`);
  }
}

function switchCallType(type: string) {
  if (isCalling.value) return;
  typeString.value = type;
}

async function startCall(typeString: string) {
  if (currentUserID.value === "未登录") {
    alert("未登录");
    return;
  }
  const type = typeString === "audio" ? 1 : 2;
  if (userList.value.length <= 0) return;
  try {
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
  } catch (error: any) {
    if (error.message) ElMessage.error(error.message);
  }
}

function beforeCalling(type: string, error: any) {
  console.log("basic demo beforeCalling", type, error);
  if (!error) isCalling.value = true;
  else {
    console.warn("basic demo beforeCallingbasic demo beforeCalling");
    ElMessage.error(`${error.type}: ${error.message}`);
  }
}

function afterCalling() {
  userList.value = [];
  isCalling.value = false;
  isMinimized.value = false;
}

function onMinimized(oldStatus: boolean, newStatus: boolean) {
  console.warn("onMinimized: " + oldStatus + " -> " + newStatus);
  if (newStatus === true) {
    isMinimized.value = true;
  } else {
    isMinimized.value = false;
  }
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

function getQueryVariable(variable: string) {
  let query = window.location.search.substring(1);
  let vars = query.split("&");
  for (let i = 0; i < vars.length; i++) {
    var pair = vars[i].split("=");
    if (pair[0] == variable) {
      return pair[1];
    }
  }
  return false;
}

function newTab(event: any) {
  event.stopPropagation();
  window.open(
    `/?SDKAppID=${SDKAppID.value}&SecretKey=${SecretKey.value}`,
    "_blank"
  );
}

function copyUserID() {
  copyText(currentUserID.value, undefined, (error: any) => {
    if (error) {
      ElMessage.warning(`复制失败，请手动填写`);
    } else {
      ElMessage.success(`已复制`);
    }
  });
}
</script>

<template>
  <div class="wrapper">
    <div class="switch">
      <div
        class="switch-btn"
        :class="typeString === 'video' ? 'switch-select' : ''"
        :style="isCalling ? 'cursor: not-allowed' : 'cursor: pointer'"
        @click="switchCallType('video')"
      >
        <img
          :src="typeString === 'video' ? videoWhiteSVG : videoBlackSVG"
          class="icon"
        />
        <span class="switch-name"> 视频通话 </span>
      </div>
      <div
        class="switch-btn"
        :class="typeString === 'audio' ? 'switch-select' : ''"
        :style="isCalling ? 'cursor: not-allowed' : 'cursor: pointer'"
        @click="switchCallType('audio')"
      >
        <img
          :src="typeString === 'audio' ? audioWhiteSVG : audioBlackSVG"
          class="icon"
        />
        <span class="switch-name"> 音频通话 </span>
      </div>
    </div>
    <div class="call-kit-container">
      <div class="hover" v-show="isCalling && isMinimized">
        已进入最小化模式
      </div>
      <div class="search" v-show="!isCalling || isMinimized">
        <div class="search-window search-left">
          <div class="search-title">
            {{ typeString === "video" ? "视频通话" : "音频通话" }}
            <span
              v-if="currentUserID !== '未登录'"
              class="user-id"
              @click="copyUserID"
            >
              userID: {{ currentUserID }}
              <button @click="(event) => newTab(event)" v-if="!isNewTab">
                登录其他 UserID
                <svg width="16" height="16" viewBox="0 0 16 16">
                  <path
                    fill="currentColor"
                    fill-rule="evenodd"
                    d="M10.75 1a.75.75 0 0 0 0 1.5h1.69L8.22 6.72a.75.75 0 0 0 1.06 1.06l4.22-4.22v1.69a.75.75 0 0 0 1.5 0V1h-4.25ZM2.5 4v9a.5.5 0 0 0 .5.5h9a.5.5 0 0 0 .5-.5V8.75a.75.75 0 0 1 1.5 0V13a2 2 0 0 1-2 2H3a2 2 0 0 1-2-2V4a2 2 0 0 1 2-2h4.25a.75.75 0 0 1 0 1.5H3a.5.5 0 0 0-.5.5Z"
                    clip-rule="evenodd"
                  />
                </svg>
              </button>
              <span v-else>
                <svg width="16" height="16" viewBox="0 0 24 24">
                  <g fill="none">
                    <path d="M0 0h24v24H0z" />
                    <path
                      fill="currentColor"
                      d="M19 2a2 2 0 0 1 2 2v12a2 2 0 0 1-2 2h-2v2a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V8a2 2 0 0 1 2-2h2V4a2 2 0 0 1 2-2h10Zm-4 6H5v12h10V8Zm-5 7a1 1 0 1 1 0 2H8a1 1 0 1 1 0-2h2Zm9-11H9v2h6a2 2 0 0 1 2 2v8h2V4Zm-7 7a1 1 0 0 1 .117 1.993L12 13H8a1 1 0 0 1-.117-1.993L8 11h4Z"
                    />
                  </g>
                </svg>
              </span>
            </span>
          </div>
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
              <img
                :src="cancelSVG"
                class="checkbox cancel"
                @click="removeUser(item)"
              />
            </div>
          </div>
          <div class="call-btn" @click="startCall(typeString)">通话</div>
        </div>
      </div>
      <TUICallKit
        v-show="isCalling"
        :beforeCalling="beforeCalling"
        :afterCalling="afterCalling"
        :onMinimized="onMinimized"
        :allowedMinimized="true"
        :allowedFullScreen="true"
        :lang="lang"
      />
      <TUICallKitMini />
    </div>
  </div>

  <div id="debug" :style="debugDisplayStyle">
    <div>
      <span>Debug Panel</span><br />
      目前 userID: <span>({{ currentUserID }})</span>
    </div>
    <span>SDKAppID: </span>
    <input
      v-model="SDKAppID"
      placeholder="SDKAppID"
      type="number"
      style="width: 100px"
    />
    <br />
    <span>SecretKey: </span>
    <input v-model="SecretKey" placeholder="SecretKey" style="width: 500px" />
    <div style="font-size: 12px">
      注意️：本 Debug Panel 仅用于调试，正式上线前请将 UserSig
      计算代码和密钥迁移到您的后台服务器上，以避免加密密钥泄露导致的流量盗用。
      <a
        href="https://cloud.tencent.com/document/product/647/17275"
        target="_blank"
        >查看文档</a
      >
    </div>
    <span>UserID: </span> <input v-model="loginUserID" placeholder="UserID" />
    <br />
    <button @click="login()">登录</button>
  </div>
</template>
