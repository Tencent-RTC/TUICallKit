<script setup lang="ts">
import { isFromGroup, remoteList, callType, profile, status, t } from '../store/index';
import { onUpdated, ref, watch, nextTick, watchEffect } from "vue";
import MicrophoneIcon from "./MicrophoneIcon.vue";
import { TUICallKitServer } from '../index';
import { RemoteUser } from "../interface";
import { CALL_TYPE_STRING, STATUS } from '../constants';
import LeftSVG from "../icons/left.vue";
import RightSVG from "../icons/right.vue";
import MicrophoneClosedSVG from '../icons/microphoneClosed.vue';
import '../style.css';

const currentPage = ref<number>(1);
const currentPageRemoteList = ref<RemoteUser[]>([]);
const groupUserViewClass = ref<string>("group-user-view");
const groupCallingContainerClass = ref<string>("group-calling-container");
const userViewUserId = ref<string>("user-view-user-id");

watch(currentPageRemoteList, async () => {
  const userViewCount = currentPageRemoteList.value.length + 1;
  await nextTick();
  groupUserViewClass.value = `group-user-view group-user-view-${userViewCount}`;
  groupCallingContainerClass.value = `group-calling-container group-calling-container-${userViewCount}`;
  userViewUserId.value = `user-view-user-id user-view-user-id-${userViewCount}`;
});

watchEffect(() => {
  refreshCurrentPageRemoteList();
});

onUpdated(() => {
  if (status.value === STATUS.DIALING_GROUP) return;
  renderUserView();
});

function refreshCurrentPageRemoteList() {
  let newPageList: RemoteUser[] = [];
  for (let i = (currentPage.value - 1) * 8; i < (currentPage.value) * 8 && i < remoteList.value.length; i++) {
    newPageList.push(remoteList.value[i]);
  }
  currentPageRemoteList.value = newPageList;
}

async function renderUserView() {
  await nextTick();
  TUICallKitServer.startLocalView('local');
  currentPageRemoteList.value.forEach((remoteUserItem: RemoteUser) => {
    if (remoteUserItem.isEntered) {
      TUICallKitServer.startRemoteView(remoteUserItem.userID);
    }
  })
}

function pageReduce() {
  if (currentPage.value > 1) {
    currentPage.value--;
  }
}

function pageIncrease() {
  if (currentPage.value < Math.floor((remoteList.value.length - 1) / 8 + 1)) {
    currentPage.value++;
  }
}

</script>

<template>
  <div class="calling-wrapper">
    <template v-if="remoteList.length > 8">
      <div class="page-turn left" @click="pageReduce">
        <div class="turn-icon-container">
          <!-- <img :src="leftSVG" /> -->
          <LeftSVG />
        </div>
      </div>
      <div class="page-turn right" @click="pageIncrease">
        <div class="turn-icon-container">
          <!-- <img :src="rightSVG" /> -->
          <RightSVG />
        </div>
      </div>
    </template>
    <div :class="groupCallingContainerClass">
      <div id="local" :class="groupUserViewClass">
        <span class="tag">
          <div class="microphone-icon-container">
            <MicrophoneIcon :volume="profile?.volume" v-if="profile?.microphone" />
            <!-- <img :src="microphoneClosedSVG" v-if="!profile?.microphone" /> -->
            <MicrophoneClosedSVG v-else />
          </div>
          {{ `${profile.userID} ${t('me')}` }}
        </span>
      </div>
      <template v-for='remoteUserItem in currentPageRemoteList' :key='remoteUserItem.userID'>
        <div :class="groupUserViewClass" :id='remoteUserItem.userID'>
          <template v-if="!remoteUserItem.isEntered || (isFromGroup && callType === CALL_TYPE_STRING.AUDIO)">
            <div class="user-view-text-container">
              <div :class="userViewUserId"> {{ remoteUserItem.userID }} </div>
              <div class="user-view-info"> {{ remoteUserItem.isEntered ? t('already-enter') : t('waiting') }} </div>
            </div>
          </template>
          <span class="tag">
            <div class="microphone-icon-container">
              <MicrophoneIcon :volume="remoteUserItem?.volume" v-if="remoteUserItem?.microphone" />
              <!-- <img :src="microphoneClosedSVG" v-if="!remoteUserItem?.microphone" /> -->
              <MicrophoneClosedSVG v-else />
            </div>
            {{ remoteUserItem.userID }}
          </span>
        </div>
      </template>
    </div>
  </div>
</template>