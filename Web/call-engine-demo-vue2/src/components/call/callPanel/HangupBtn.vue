<template>
  <el-button
    class="danger"
    @click="$emit('hangup')"
  >
    挂断
  </el-button>
</template>

<script setup lang="ts">
defineEmits(['hangup']);
</script>

<style lang="less" scoped>
.danger {
  background: linear-gradient(315deg, #ff0000 0%, #f41414 98.81%) !important;
}
</style>
