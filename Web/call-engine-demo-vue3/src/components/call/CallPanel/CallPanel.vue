<template>
  <el-container style="width: 100%;">
    <el-header class="header">
      <div class="icon-wrap" @click="goBack">
        <IconArrowLeftBold style="cursor: pointer;" />
      </div>
      视频通话
    </el-header>
    <el-main style="height: 651px; margin-bottom: 80px;">
      <el-scrollbar style="width: 100%;">
        <el-collapse v-model="activeNames">
          <el-collapse-item title="基本设置" :name="CollapseName.基本设置">
            <el-form
              ref="userInfoformRef"
              :rules="userInfoRules"
              :model="form"
              label-width="120px"
              label-position="left"
              :disabled="isWaiting"
            >
              <el-form-item label="昵称" prop="nickName" trigger="change">
                <el-input v-model="form.nickName" placeholder="请输入昵称">
                  <template #append>
                    <el-button
                      @click="handleChangeNickName"
                    >
                      设置
                    </el-button>
                  </template>
                </el-input>
              </el-form-item>
              <el-form-item label="头像" prop="avatar" trigger="change">
                <el-input v-model="form.avatar" placeholder="请输入头像地址">
                  <template #append>
                    <el-button
                      @click="handleChangeAvatar"
                    >
                      设置
                    </el-button>
                  </template>
                </el-input>
              </el-form-item>
            </el-form>
            <el-form
              ref="basicSettingformRef"
              :model="form"
              :rules="rules"
              label-width="120px"
              label-position="left"
              :disabled="isWaiting"
            >
              <el-form-item v-if="isGroupCall" label="群组ID">
                <el-input v-model="form.groupID" disabled />
              </el-form-item>
              <el-form-item label="被邀请方ID" prop="inviteeId">
                <el-input v-model="form.inviteeId" :placeholder="isGroupCall ? '请输入多个ID，并用‘,’分隔' : '请输入被邀请方userID'" />
              </el-form-item>
              <el-form-item label="媒体类型">
                <el-radio-group v-model.number="form.callType">
                  <el-radio :label="MediaType.AUDIO" size="large">音频通话</el-radio>
                  <el-radio :label="MediaType.VIDEO" size="large">视频通话</el-radio>
                </el-radio-group>
              </el-form-item>
            </el-form>
          </el-collapse-item>
          <el-collapse-item title="通话自定义参数设置" :name="CollapseName.通话自定义参数设置">
            <el-form
              ref="customSettingFormRef"
              :model="form"
              :rules="rules"
              label-width="120px"
              label-position="left"
              :disabled="isConnected"
            >
              <el-form-item label="呼叫超时时间" prop="timeout">
                <el-input v-model.number="form.timeout" type="number" />
              </el-form-item>
              <el-form-item label="扩展信息">
                <el-input v-model="form.userData" />
              </el-form-item>
              <el-form-item label="离线推送消息">
                <el-input
                  v-model="form.offlinePushInfo"
                  :autosize="{ minRows: 2, maxRows: 6 }"
                  type="textarea"
                />
              </el-form-item>
            </el-form>
          </el-collapse-item>
          <el-collapse-item title="视频设置" :name="CollapseName.视频设置">
            <el-form label-width="120px" label-position="left">
              <el-form-item label="分辨率">
                <el-select
                  v-model="videoSetting.resolution"
                  style="width: 100%;"
                  placeholder="请选择分辨率"
                  @change="$emit('call-control-event', { key: 'profile', value: videoSetting.resolution })"
                >
                  <el-option label="480p" :value="VideoResolution['480p']" />
                  <el-option label="720p" :value="VideoResolution['720p']" />
                  <el-option label="1080p" :value="VideoResolution['1080p']" />
                </el-select>
              </el-form-item>
              <el-form-item v-if="shouldRenderSwitchCallTypeItem" label="切换通话类型">
                <el-radio-group
                  v-model="videoSetting.mediaType"
                  @change="$emit('call-control-event', { key: 'switchCallMediaType', value: videoSetting.mediaType })"
                >
                  <el-radio :label="MediaType.AUDIO" size="large">音频通话</el-radio>
                  <el-radio :label="MediaType.VIDEO" size="large">视频通话</el-radio>
                </el-radio-group>
              </el-form-item>
              <el-form-item label="填充模式">
                <el-select
                  v-model="videoSetting.objectFit"
                  style="width: 100%;"
                  placeholder="请选择填充模式"
                  @change="$emit('call-control-event', { key: 'objectFit', value: videoSetting.objectFit })"
                >
                  <el-option label="等比缩放" :value="ObjectFit.Contain" />
                  <el-option label="等比填充" :value="ObjectFit.Cover" />
                  <el-option label="填充" :value="ObjectFit.Fill" />
                </el-select>
              </el-form-item>
              <el-form-item label="摄像头">
                <el-switch
                  v-model="videoSetting.cameraStatus"
                  active-text="打开"
                  inactive-text="关闭"
                  @change="$emit('call-control-event', { key: 'controlCamera', value: videoSetting.cameraStatus })"
                />
              </el-form-item>
              <el-form-item label="麦克风">
                <el-switch
                  v-model="videoSetting.micphoneStatus"
                  active-text="打开"
                  inactive-text="关闭"
                  @change="$emit('call-control-event', { key: 'controlMicphone', value: videoSetting.micphoneStatus })"
                />
              </el-form-item>
              <el-form-item label="切换麦克风">
                <el-select
                  v-model="videoSetting.currentMicrophone"
                  style="width: 100%;"
                  placeholder="请选择麦克风"
                  @change="$emit('call-control-event', {
                    key: 'switchDevice',
                    value: { deviceType: 'audio', deviceId: videoSetting.currentMicrophone }
                  })"
                >
                  <el-option
                    v-for="({ label, deviceId }) of microphones"
                    :key="deviceId"
                    :label="label"
                    :value="deviceId"
                  />
                </el-select>
              </el-form-item>
              <el-form-item label="切换摄像头">
                <el-select
                  v-model="videoSetting.currentCamera"
                  style="width: 100%;"
                  placeholder="请选择摄像头"
                  @change="$emit('call-control-event', {
                    key: 'switchDevice',
                    value: { deviceType: 'video', deviceId: videoSetting.currentCamera }
                  })"
                >
                  <el-option
                    v-for="({ label, deviceId }) of cameras"
                    :key="deviceId"
                    :label="label"
                    :value="deviceId"
                  />
                </el-select>
              </el-form-item>
              <el-form-item label="启动远端渲染">
                <div class="item-wrap">
                  <el-select
                    v-model="videoSetting.startRemoteViewUserId"
                    placeholder="选择远端用户"
                    style="width: 240px"
                  >
                    <el-option
                      v-for="item in remoteUserList"
                      :key="item.userID"
                      :label="item.userID"
                      :value="item.userID"
                    />
                  </el-select>
                  <el-button
                    @click="$emit('call-control-event', {
                      key: 'startRemoteView',
                      value: {
                        userID: videoSetting.startRemoteViewUserId,
                        videoViewDomID: `remote-view-${videoSetting.startRemoteViewUserId}`,
                      }})"
                  >
                    启动
                  </el-button>
                </div>
              </el-form-item>
              <el-form-item label="停止远端渲染">
                <div class="item-wrap">
                  <el-select
                    v-model="videoSetting.stopRemoteViewUserId"
                    placeholder="选择远端用户"
                    style="width: 240px"
                  >
                    <el-option
                      v-for="item in remoteUserList"
                      :key="item.userID"
                      :label="item.userID"
                      :value="item.userID"
                    />
                  </el-select>
                  <el-button
                    @click="$emit('call-control-event', {
                      key: 'stopRemoteView',
                      value: videoSetting.stopRemoteViewUserId
                    })"
                  >
                    停止
                  </el-button>
                </div>
              </el-form-item>
              <el-form-item label="AI降噪">
                <el-switch
                  v-model="videoSetting.AIVoiceStatus"
                  active-text="打开"
                  inactive-text="关闭"
                  @change="$emit('call-control-event', { key: 'enableAIVoice', value: videoSetting.AIVoiceStatus })"
                />
              </el-form-item>
            </el-form>
          </el-collapse-item>
        </el-collapse>
      </el-scrollbar>
    </el-main>
    <el-footer style="position: absolute;bottom: 0px; width: 100%">
      <div class="btn-group">
        <component :is="isConnected ? HangupBtn : CallBtn" :is-loading="isWaiting" class="btn" v-on="handleCall" />
      </div>
    </el-footer>
  </el-container>
</template>

<script setup lang="ts">
import { computed, reactive, ref } from 'vue';
import IconArrowLeftBold from '@/components/icons/IconArrowLeftBold.vue';
import { CallState, CallTypeDesc, MediaType, ObjectFit, VideoResolution } from '@/constants';
import { useRoute, useRouter } from '@/router';
import { useUserInfoStore, useCallInfoStore } from '@/stores';
import { storeToRefs } from 'pinia';
import { CallBtn, HangupBtn } from './index';
import { isEmpty } from 'lodash';

const emit = defineEmits(['call-control-event']);

enum CollapseName {
  '基本设置',
  '通话自定义参数设置',
  '视频设置',
}

const callInfoStore = useCallInfoStore();
const userInfoStore = useUserInfoStore();
const router = useRouter();
const route = useRoute();
const { nickName, avatar } = storeToRefs(userInfoStore);
const {
  groupID,
  microphones,
  cameras,
  remoteUserList,
  callType,
  callState,
  currentCamera,
  currentMicrophone,
} = storeToRefs(callInfoStore);
const activeNames = ref([CollapseName.基本设置, CollapseName.视频设置]);

const isGroupCall = computed(() => (route.params.callType === CallTypeDesc.GROUP_CALL));
const isConnected = computed(() => (CallState.CONNECTED === callState.value));
const isWaiting = computed(() => (CallState.CALLING === callState.value));
// 呼叫信息相关状态
const form = reactive({
  nickName,
  avatar,
  callType,
  groupID,
  inviteeId: '',
  userData: null,
  timeout: null,
  isGroupCall,
  remoteUserIdList: [],
  offlinePushInfo: '',
});

const shouldRenderSwitchCallTypeItem = computed(() => !isGroupCall.value && callType.value === MediaType.VIDEO);
const basicSettingformRef = ref();
const customSettingFormRef = ref();
const userInfoformRef = ref();

const userInfoRules = reactive({
  nickName: [{ required: true, message: '昵称不能为空', trigger: 'change' }],
  avatar: [{ required: true, message: '头像地址不能为空', trigger: 'change' }],
});
const rules = reactive({
  inviteeId: [{ required: true, message: '请输入用户id' }],
  timeout: [
    { type: 'number', message: '请输入数字' },
  ],
});

// 视频设置相关状态
const videoSetting = reactive({
  resolution: VideoResolution['480p'],
  objectFit: ObjectFit.Cover,
  cameraStatus: true,
  micphoneStatus: true,
  AIVoiceStatus: false,
  currentMicrophone,
  currentCamera,
  offlinePushInfo: '',
  mediaType: MediaType.VIDEO,
  startRemoteViewUserId: null,
  stopRemoteViewUserId: null,
});
const handleCall =  {
  async call() {
    const rs = await Promise.all([
      basicSettingformRef.value,
      customSettingFormRef.value,
    ].map(formEl => formEl.validate()));

    const finalForm = {};
    Object.keys(form).forEach((key) => {
      if (form[key]) {
        finalForm[key] = form[key];
      }
    });
    if (!rs.includes(false)) {
      emit('call-control-event', { key: 'call', value: finalForm });
    }
  },
  async hangup() {
    emit('call-control-event', { key: 'hangup' });
  },
};
const goBack = async () => {
  // 只处于通话中或者呼叫等待中才进行挂断
  if ([CallState.CALLING, CallState.CONNECTED].includes(callInfoStore.callState)) {
    emit('call-control-event', { key: 'hangup' });
  }
  router.back();
};
const handleChangeNickName = async () => {
  userInfoformRef.value.validateField('nickName', (errMsg) => {
    console.log(errMsg);
    if (isEmpty(errMsg)) {
      emit('call-control-event', { key: 'nickName', value: form.nickName });
    }
  });
};
const handleChangeAvatar = async () => {
  userInfoformRef.value.validateField('avatar', (errMsg) => {
    if (isEmpty(errMsg)) {
      emit('call-control-event', { key: 'avatar', value: form.avatar });
    }
  });
};
</script>

<style lang="less" scoped>
.header {
  display: flex;
  width: 100%;
  height: 65px;
  align-items: center;
  font-size: 20px;
  .icon-wrap {
    display: flex;
    margin-right: 3px;
  }
}
.btn-group {
  display: flex;
  justify-content: space-between;
  .btn {
    width: 100%;
    height: 44px;
    background: linear-gradient(315deg, #006EFF 0%, #0C59F2 98.81%);
    border-radius: 8px;
    font-family: 'PingFang SC';
    font-style: normal;
    font-weight: 500;
    font-size: 16px;
    line-height: 22px;
    color: #FFFFFF;
  }
}
.item-wrap {
  width: 100%;
  display: flex;
  justify-content: space-between;
}
</style>
