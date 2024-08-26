<template>
  <el-button
    :color="color"
    :disabled="disabled"
    :style="[ButtonStyle]"
    :class="ButtonClassName"
  >
    <slot />
  </el-button>
</template>

<script setup lang="ts">
import { computed } from 'vue';
import { isH5, classNames } from '../../../utils';
import { ButtonProps } from './Button';

const props = defineProps(ButtonProps);

const ButtonClassName = classNames([
  { h5: isH5 },
  { pc: !isH5 },
])

const ButtonStyle = computed(() => ({
  width: props.width + 'px',
  height: props.height + 'px',
}));

</script>

<style lang="scss" scoped>
.pc {
  border-radius: 27px;
  font-weight: 500;
  color: #FFFFFF;
}

.h5 {
  border-radius: 10px;
  font-weight: 500;
  font-size: 16px;
  color: #FFFFFF;
}
</style>