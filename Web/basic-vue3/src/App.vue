<template>
  <TUICallKit :class="callClass"/>
  <template v-if="!isH5">
    <Layout>
      <RouterView />
    </Layout>
  </template>
  <template v-else>
    <RouterView />
  </template>
  <!-- add xxx vue3 -->
</template>

<script setup lang="ts">
import { computed, onMounted, provide, reactive } from 'vue';
import { TUICallKit } from '@tencentcloud/call-uikit-vue';
import { useAegis } from './hooks/index';
import { UserInfoContextKey, IUserInfoContext, UserInfoContextDefaultValue } from './context';
import { isH5 } from './utils';
import Layout from './components/Layout/Layout.vue';

const { reportEvent } = useAegis();

onMounted(() => {
  reportEvent({ apiName: 'run.call.start' });
})

const userInfoValue = reactive<IUserInfoContext>(UserInfoContextDefaultValue);

const callClass = computed(() => {
  return isH5 ? 'call-uikit-h5' : 'call-uikit-pc';
})

provide(UserInfoContextKey, userInfoValue);
</script>

<style lang="scss" scoped>
.call-uikit-pc {
  width: 950px;
  height: 650px;
  position: absolute !important;
  z-index: 100;
  transform: translate(-50%, -50%);
  top: 50%;
  left: 50%;
}
.call-uikit-h5 {
  position: absolute;
  z-index: 200;
}
</style>

