<template>
  <div class="call-player-wrap">
    <div className="video-wrapper local-user">
      <div className="user-desc">
        <span className="user-type">本地用户</span>
        <span id="localUserRole" className="user-role"></span>
      </div>
      <div class="container">
        <div id="localVideoWrapper" class="localVideoWrapper"></div>
      </div>
    </div>
    <div v-if="callInfoStore.remoteUserList.length > 0" className="video-wrapper remote-user">
      <div className="user-desc">
        <span className="user-type">远程用户</span>
        <div class="container">
          <div
            v-for="(obj, index) in callInfoStore.remoteUserList"
            :id="`remote-view-${obj.userID}`"
            :key="`${obj.userID}-${index}`"
            class="remoteVideoWrapper"
          ></div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { watch } from 'vue';
import { useCallInfoStore } from '@/stores';

const emit = defineEmits(['call-control-event']);

const callInfoStore = useCallInfoStore();

watch(callInfoStore, () => {
  const { remoteUserList } = callInfoStore;
  if (remoteUserList?.length > 0) {
    remoteUserList.forEach(async ({ userID, isVideoAvailable }) => {
      if (isVideoAvailable) {
        emit('call-control-event', {
          key: 'startRemoteView',
          value: { userID, videoViewDomID: `remote-view-${userID}` },
        });
      }
    });
  }
}, {
  flush: 'post',
  immediate: true,
});
</script>

<style lang="less" scoped>
.call-player-wrap {
  width: 40rem;
  margin-top: 6rem;
}
.localVideoWrapper {
  width: 200px;
  height: 200px;
  background-color: #000;
  margin-left: 10px;
  margin-top: 10px;
  border-radius: 8px;
}
.remoteVideoWrapper {
  width: 200px;
  height: 200px;
  background-color: #000;
  border-radius: 8px;
  margin-top: 10px;
  margin-left: 10px;
}
.container {
  width: 100%;
  display: flex;
  flex-wrap: wrap;
}
</style>
