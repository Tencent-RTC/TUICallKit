<template>
  <image class="avatar" :src="src" :onerror="handleError" />
</template>

<script setup lang="ts">
import { ref, computed } from 'vue';

const defaultAvatar = 'https://liteav.sdk.qcloud.com/app/res/picture/voiceroom/avatar/user_avatar1.png';

interface Props {
  imgSrc?: string | undefined;
}
const props = defineProps<Props>();
const src = computed(() => {
  if (isError.value) {
    return defaultAvatar;
  }
  return props.imgSrc || defaultAvatar;
});
const isError = ref(false);
function handleError() {
  isError.value = true;
}
</script>

<style lang="scss" scoped>
.avatar {
	width: 50px;
	height: 50px;
	border-radius: 50px;
}
</style>
