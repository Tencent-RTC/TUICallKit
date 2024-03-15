<script setup lang="ts">
const props = defineProps(['src']);
</script>

<template>
  <div class="logo-container">
    <img alt="Vue logo" class="logo-main" :src="props.src" />
  </div>
</template>

<style lang="less" scope>
.logo-container {
  width: 36rem;
  .logo-main {
    display: block;
    width: 100%;
    margin: 15rem 0 0 0;
  }
}
</style>
