<template>
  <div class="space-container" :style="[SpaceStyle]">
    <component v-for="(child, index) in spacedChildren" :is="child" :key="index" />
  </div>
</template>

<script lang="ts" setup>
import { useSlots, computed, createTextVNode } from 'vue';
import { SpaceProps } from './Space';

const slots = useSlots();
const props = defineProps(SpaceProps);
const SpaceStyle = { columnGap: `${props.size}` };

const spacedChildren = computed(() => {
  
  const parent = slots.default ? slots.default() : [];
  const quickLink = slots?.default?.()[0].children?.length === 4 ? slots.default()[0].children : undefined;
  // @ts-ignore
  const children: any[] = quickLink || parent;
  const spacedChildren = [];
  
  for (let i = 0; i < children?.length; i ++) {
    spacedChildren.push(children[i]);
    if (i !== children.length - 1) {
      spacedChildren.push(createTextVNode(props.spacer));
    }
  }
  
  return spacedChildren;
});

</script>

<style>
.space-container {
  display: flex;
  flex-wrap: nowrap;
  justify-content: flex-start;
  gap: 0 10px;
}
</style>