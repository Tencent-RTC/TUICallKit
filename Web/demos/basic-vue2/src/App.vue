<script lang="ts" setup>
import { ref, onMounted } from "vue";
import { TUICallKit, TUICallKitServer, STATUS } from "@tencentcloud/call-uikit-vue2";
import DeviceDetector from "./components/DeviceDetector/index.vue";
import * as GenerateTestUserSig from "../public/debug/GenerateTestUserSig-es.js";
import TIM from "@tencentcloud/chat";
import copy from "copy-to-clipboard";
import videoBlackSVG from "./assets/videoBlack.svg";
import videoWhiteSVG from "./assets/videoWhite.svg";
import audioWhiteSVG from "./assets/audioWhite.svg";
import audioBlackSVG from "./assets/audioBlack.svg";
import searchSVG from "./assets/search.svg";
import cancelSVG from "./assets/cancel.svg";
import languageSVG from "./assets/language.svg";
import { Message as ElMessage } from "element-ui";
import logReporter from "./utils/aegis";
import { getUrlParam } from "./utils";
import { useI18n } from 'vue-i18n-bridge';
import "./App.css";

const { t, locale } = useI18n();

const SDKAppID = ref<number>(0);
const SecretKey = ref<string>("");
const userID = ref<string>("");
const loginUserID = ref<string>("");
const userList = ref<string[]>([]);
const currentUserID = ref<string>("");
const isLogin = ref<boolean>(false);

const isNewTab = ref<boolean>(false);
const isMinimized = ref<boolean>(false);
const finishedRTCDetectStatus = ref<string>("");
const isSkippedRTCDetect = ref<boolean>(false);
const isLoadCalling = ref<boolean>(false);

const typeString = ref<string>("video");
const isCalling = ref<boolean>(false);
const groupID = ref<string>(""); 
const isGroupCall = ref<boolean>(true);
// eslint-disable-next-line @typescript-eslint/no-explicit-any
let tim: any = null;

onMounted(() => {
  if (!getUrlParam("SDKAppID")) SDKAppID.value = 0;
  else {
    SDKAppID.value = parseInt(getUrlParam("SDKAppID") as string);
    isNewTab.value = true;
  }
  SecretKey.value = getUrlParam("SecretKey") || "";
  TUICallKitServer.setLanguage(locale.value);
  finishedRTCDetectStatus.value = localStorage.getItem("callkit-basic-demo-finish-rtc-detect") || "";
});

async function login() {
  if (!SDKAppID.value || SDKAppID.value === 0) {
    ElMessage.error(t("input-SDKAppID"));
    return;
  }
  if (!SecretKey.value) {
    ElMessage.error(t("input-SecretKey")); 
    return;
  }
  if (!loginUserID.value) {
    ElMessage.error(t("input-userID"));
    return;
  }
  const { userSig } = GenerateTestUserSig.genTestUserSig({
    userID: loginUserID.value,
    SDKAppID: SDKAppID.value,
    SecretKey: SecretKey.value
  });
  tim = TIM.create({
    SDKAppID: SDKAppID.value,
  });
  try {
    await TUICallKitServer.init({
      userID: loginUserID.value,
      userSig,
      SDKAppID: SDKAppID.value,
      tim
    });
    currentUserID.value = loginUserID.value;
    isLogin.value = true;
    if (finishedRTCDetectStatus.value !== "finished" && finishedRTCDetectStatus.value !== "skiped") initNetWorkInfo();
    logReporter.loginSuccess(SDKAppID.value);
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  } catch (error: any) {
    if (error.message) ElMessage.error(`${t("login-failed-message")} ${error.message}`);
    logReporter.loginFailed(SDKAppID.value, error?.message);
  }
}

function switchCallType(type: string) {
  if (isCalling.value) return;
  typeString.value = type;
}

async function startCall(typeString: string) {
  if (!isLogin.value) {
    ElMessage.error(t("not-login"));
    return;
  }
  const type = typeString === "audio" ? 1 : 2;
  if (userList.value.length <= 0) {
    ElMessage.error(t("calling-list-is-empty"));
    return;
  }
  const callType = userList.value.length === 1 ? "call" : "groupCall";
  isLoadCalling.value = true;
  try {
    isCalling.value = true;
    if (callType === "call")
      await TUICallKitServer.call({ userID: userList.value[0], type });
    else {
      // you can use existing groups, no need to create a new group every time
      groupID.value = await createGroup();
      await TUICallKitServer.groupCall({
        userIDList: userList.value,
        type,
        groupID: groupID.value,
      });
    }
    logReporter.callSuccess(SDKAppID.value, callType, typeString);
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  } catch (error: any) {
    isCalling.value = false;
    console.error("startCall", error);
    if (error.message) ElMessage.error(error.message);
    logReporter.callFailed(
      SDKAppID.value,
      callType,
      typeString,
      error?.message
    );
  }
  isLoadCalling.value = false;
}

// eslint-disable-next-line @typescript-eslint/no-explicit-any
function beforeCalling(type: string, error: any) {
  console.log("basic demo beforeCalling", type, error);
  if (!error) isCalling.value = true;
  else {
    console.error("basic demo beforeCalling", error);
    ElMessage.error(`${error.type}: ${error.message}`);
  }
}

function afterCalling() {
  userList.value = [];
  isCalling.value = false;
  isMinimized.value = false;
}

function onMinimized(oldStatus: boolean, newStatus: boolean) {
  console.log("onMinimized: " + oldStatus + " -> " + newStatus);
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
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  const memberList: any[] = [];
  userList.value.forEach((user: string) => {
    memberList.push({ userID: user });
  });
  let res = await tim.createGroup({
    type: TIM.TYPES.GRP_PUBLIC,
    name: "group-call",
    memberList,
  });
  return res.data.group.groupID;
}

// eslint-disable-next-line @typescript-eslint/no-explicit-any
function newTab(event: any) {
  event.stopPropagation();
  window.open(
    `/?SDKAppID=${SDKAppID.value}&SecretKey=${SecretKey.value}`,
    "_blank"
  );
}

function copyUserID() {
  const isSuccessCopy = copy(currentUserID.value);
  if (isSuccessCopy) {
    ElMessage.success(t("copied"));
  } else {
    ElMessage.warning(t("copy-failed-message"));
  }
}

function handleClose() {
  showDeviceDetector.value = false;
  isSkippedRTCDetect.value = true;
  ElMessage.warning(t("skip-device-detector"));
  localStorage.setItem("callkit-basic-demo-finish-rtc-detect", "skiped");
}

function handleFinishDetect() {
  showDeviceDetector.value = false;
  finishedRTCDetectStatus.value = "finished";
  localStorage.setItem("callkit-basic-demo-finish-rtc-detect", "finished");
}

const networkDetectInfo = ref();
const showDeviceDetector = ref<boolean>(false);

const initNetWorkInfo = async () => {
  if (!SDKAppID.value || !SecretKey.value) {
    ElMessage.error(t("please-input-param"));
    return;
  }
  const status = localStorage.getItem("callkit-basic-demo-finish-rtc-detect");
  if (status === "finished") return;
  const uplinkUserId = currentUserID.value + "_uplink_test";
  const downlinkUserId = currentUserID.value + "_downlink_test";
  const roomId = 999999;

  const uplinkUserSig = GenerateTestUserSig.genTestUserSig({
    userID: uplinkUserId,
    SDKAppID: SDKAppID.value,
    SecretKey: SecretKey.value
  }).userSig;
  tim = TIM.create({
    SDKAppID: SDKAppID.value,
  });
  const downlinkUserSig = GenerateTestUserSig.genTestUserSig({
    userID: downlinkUserId,
    SDKAppID: SDKAppID.value,
    SecretKey: SecretKey.value
  }).userSig;
  networkDetectInfo.value = {
    sdkAppId: SDKAppID,
    roomId,
    uplinkUserInfo: {
      uplinkUserId,
      uplinkUserSig,
    },
    downlinkUserInfo: {
      downlinkUserId,
      downlinkUserSig,
    },
  };
  showDeviceDetector.value = true;
};

function switchLanguage() {
  switch (locale.value) {
    case "zh-cn":
      locale.value = "en";
      localStorage.setItem("basic-demo-language", "en");
      TUICallKitServer.setLanguage("en");
      break;
    case "en":
    default:
      locale.value = "zh-cn";
      localStorage.setItem("basic-demo-language", "zh-cn");
      TUICallKitServer.setLanguage("zh-cn");
      break;
  }
}

function handleKickedOut() {
  console.error("The user has been kicked out");
  isLogin.value = false;
}

let TUICallKitStatus: string = STATUS.IDLE;
function handleStatusChanged(args: { oldStatus: string; newStatus: string; }) {
  const { oldStatus, newStatus } = args;
  console.log("通话状态变更: " + oldStatus + " -> " + newStatus);
  TUICallKitStatus = newStatus;
}

async function accept() {
  try {
    if (TUICallKitStatus === STATUS.BE_INVITED) {
      await TUICallKitServer.accept();
      ElMessage.warning("已自动接听");
    }
  } catch (error: any) {
    alert(`自动接听失败，原因：${error}`);
  }
}

async function reject() {
  try {
    if (TUICallKitStatus === STATUS.BE_INVITED) {
      await TUICallKitServer.reject();
      ElMessage.warning("已自动拒绝");
    }
  } catch (error: any) {
    alert(`自动拒绝失败，原因：${error}`);
  }
}

async function hangup() {
  try {
    if (TUICallKitStatus === STATUS.CALLING_C2C_AUDIO || TUICallKitStatus === STATUS.CALLING_C2C_VIDEO || TUICallKitStatus === STATUS.CALLING_GROUP_AUDIO || TUICallKitStatus === STATUS.CALLING_GROUP_VIDEO) {
      await TUICallKitServer.hangup();
      ElMessage.warning("已自动挂断");
    }
  } catch (error: any) {
    alert(`自动挂断失败，原因：${error}`);
  }
}

</script>

<template>
  <div class="wrapper">
    <DeviceDetector
      :visible="showDeviceDetector"
      :onClose="handleClose"
      :onFinish="handleFinishDetect"
      :networkDetectInfo="networkDetectInfo"
    >
    </DeviceDetector>
    <div style="display: flex; align-items: center">
      <!-- <button @click="accept"> accept </button>
      <button @click="reject"> reject </button>
      <button @click="hangup"> hangup </button> -->
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
          <span class="switch-name"> {{ t("video-call") }} </span>
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
          <span class="switch-name"> {{ t("voice-call") }} </span>
        </div>
      </div>
    </div>
    <div class="switch-language" @click="switchLanguage()">
      <img :src="languageSVG" class="icon" />
      <div class="language-name">
        {{ locale == "en" ? "简体中文" : "English" }}
      </div>
    </div>
    <div class="call-kit-container">
      <div class="search" v-show="!isCalling || isMinimized">
        <div class="search-window search-left">
          <div class="search-title">
            {{ typeString === "video" ? t("video-call") : t("voice-call") }}
            <span
              v-if="isLogin"
              class="user-id"
              @click="copyUserID"
            >
              userID: {{ currentUserID }}
              <button @click="(event) => newTab(event)" v-if="!isNewTab">
                {{ t("login-other") }} UserID
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
          <div class="add-btn" @click="addUser(userID)">{{t("add-to-calling-list")}}</div>
        </div>
        <div class="search-window search-right">
          <div class="selected-title">{{t("calling-list")}}</div>
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
          <div class="call-buttons">
            <div class="rtc-detector-starter" @click="initNetWorkInfo()" v-show="isLogin">{{ t("start-to-detector") }}</div>
            <div :class="!isLoadCalling ? 'call-btn' : 'call-btn-gray'" @click="startCall(typeString)" :disabled="isLoadCalling">
              <img v-show="isLoadCalling" src="./assets/loading.png" class="loading-img" />
              {{ t("call") }}
            </div>
          </div>
        </div>
      </div>
      <TUICallKit
        :beforeCalling="beforeCalling"
        :afterCalling="afterCalling"
        :onMinimized="onMinimized"
        :allowedMinimized="true"
        :allowedFullScreen="true"
        :kickedOut="handleKickedOut"
        :statusChanged="handleStatusChanged"
      />
    </div>
    <div id="debug" v-show="!isLogin">
      <div>
        <b>Debug Panel</b>
      </div>
      <span>SDKAppID: </span>
      <input
        v-model.number="SDKAppID"
        placeholder="SDKAppID"
        type="number"
        style="width: 100px"
      />
      <br />
      <span>SecretKey: </span>
      <input v-model="SecretKey" placeholder="SecretKey" style="width: 500px" />
      <div style="font-size: 12px">
        {{ t("alert") }}
        <a
          :href="t('url')"
          target="_blank"
          >{{t("view-documents")}}</a
        >
      </div>
      <span>UserID: </span>
      <input v-model="loginUserID" placeholder="UserID" />
      <br />
      <button @click="login()">{{t("login")}}</button>
    </div>
  </div>
</template>
