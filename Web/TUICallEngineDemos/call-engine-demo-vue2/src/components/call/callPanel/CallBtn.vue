<template>
  <el-button
    :loading="isLoading"
    @click="$emit('call')"
  >
    发起通话
  </el-button>
</template>

<script setup lang="ts">
defineProps<{ isLoading: boolean }>();
defineEmits(['call']);
</script>
