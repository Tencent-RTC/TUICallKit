<template>
  <div v-for="(index) in volume" className='volume-bar-fill' :key="index" />
  <div v-for="(index) in diff" className='volume-bar' :key="index" />
</template>

<script lang="ts" setup>
import { ref } from 'vue';

const props = defineProps({
  volume: {
    type: Number,
    default: 0,
  }
});
const diff = ref(20 - props?.volume);

</script>

<style lang="scss" scoped>
.volume-bar {
  width: 6px;
  height: 16px;
  background: #F0F0F0;
  border-radius: 27px;
}
.volume-bar-fill {
  width: 6px;
  height: 16px;
  background: #146EFA;
  border-radius: 27px;
}
.volume-box {
  width: 300px;
}
</style>