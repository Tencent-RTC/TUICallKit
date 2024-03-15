<template>
  <div class="btn-wrap">
    <el-button
      class="btn"
      type="primary"
      @click="handleClick"
    >
      <i :class="icon"></i>
      {{ text }}
    </el-button>
  </div>
</template>

<script setup lang="ts">
interface IconBtnProps {
  icon: string;
  text: string;
  handleClick: Function
}

const { handleClick } = defineProps<IconBtnProps>();
</script>

<style lang="less" scoped>
.btn-wrap {
  width: 100%;
  .btn {
    width: 100%;
    height: 60px;
    margin-top: 20px;
    font-size: 20px;
    background: linear-gradient(315deg, #006EFF 0%, #0C59F2 98.81%);
    box-shadow: 0px 2px 4px rgba(0, 0, 0, 0.2);
    border-radius: 8px;
  }
}
</style>