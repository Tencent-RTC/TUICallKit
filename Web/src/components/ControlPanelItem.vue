<script setup lang="ts">
import { ref, onMounted, nextTick, withDefaults, toRefs, defineProps } from 'vue';
import TriangleSVG from '../icons/triangle.vue';
import "../style.css";

const openDetail = ref<boolean>(false);
const props = withDefaults(
  defineProps<{
    action: (payload: MouseEvent) => void;
    hasDetail?: boolean;
  }>(),
  {
    hasDetail: false,
  }
);
const { action, hasDetail } = toRefs(props);

onMounted(() => {
  document.documentElement.addEventListener('click', (e) => {
    openDetail.value = false;
  });
});

async function stayFocus() {
  await nextTick();
  const els = document.getElementsByClassName("control-item-detail");
  for (let el of els) {
    el.addEventListener('click', (e) => e.stopPropagation());
  }
}

const toggleDetail = (event: Event) => {
  event.stopPropagation();
  stayFocus();
  openDetail.value = !openDetail.value;
};
</script>

<template>
  <div class="control-item">
    <div class="control-item-icon">
      <div class="control-item-icon-container" @click="action">
        <slot name="icon"> </slot>
      </div>
      <div class="control-item-summary" @click="toggleDetail" v-if="hasDetail">
        <!-- <img :src="triangleSVG" /> -->
        <TriangleSVG />
      </div>
      <div class="control-item-detail" v-show="openDetail">
        <slot name="detail"> </slot>
      </div>
    </div>
    <div class="control-item-text">
      <text>
        <slot name="text"> </slot>
      </text>
    </div>
  </div>
</template>
