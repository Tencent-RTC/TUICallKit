<template>
  <text class="call-tip"> {{ callTips }} </text>
</template>

<script setup lang="ts">
const props = defineProps({
  callTips: {
    type: String,
    default: "",
  },
  isGroupCall: {
    type: Boolean,
    default: false,
  },
});
</script>

<style scoped>
.call-tip {
  height: 20px;
  font-weight: 500;
  font-size: 14px;
  line-height: 20px;
  color: #ffffff;
}
</style>
