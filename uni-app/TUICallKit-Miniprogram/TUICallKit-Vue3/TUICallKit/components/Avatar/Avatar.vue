<template>
  <image
    class="avatar"
    :src="displaySrc"
    :style="avatarStyle"
    mode="aspectFill"
    @error="onError"
  />
</template>

<script lang="ts" setup>
import { ref, computed, watch } from '../../adapter/vue-demi';
import IMG_DEFAULT_AVATAR from '../../assets/base/default-avatar.png';

const props = defineProps({
  src: { type: String, default: '' },
  // Accept a CSS string (preferred) so the `:style` binding renders correctly
  // on both the uni-app Vue 2 and Vue 3 mini-program builds. Object is kept for
  // backward compatibility, but callers should pass a string.
  avatarStyle: { type: [String, Object], default: '' },
});

// Track load failures so a broken avatar URL falls back to the default image
// instead of showing a blank / broken image.
const hasError = ref(false);

// Reset the error flag whenever a new src comes in, giving the fresh URL a
// chance to load before deciding to fall back.
watch(
  () => props.src,
  () => {
    hasError.value = false;
  },
);

// Fall back to the default avatar when the src is empty OR failed to load.
const displaySrc = computed(() => {
  if (hasError.value || !props.src) {
    return IMG_DEFAULT_AVATAR;
  }
  return props.src;
});

function onError() {
  hasError.value = true;
}
</script>

<style lang="scss" scoped>
.avatar {
  display: block;
  background-color: #F0F2F7;
}
</style>
