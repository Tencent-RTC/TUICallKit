<template>
  <span class="text" :style="TextStyle">
    <slot />
  </span>
</template>

<script lang="ts" setup>
import { computed } from 'vue';

const props = defineProps({
  maxWidth: {
    type: Number,
    default: 80,
  }
})
const TextStyle = computed(() => {
  return { maxWidth: props.maxWidth + 'px' };
});
</script>

<style scoped lang="scss">
.text {
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}
</style>