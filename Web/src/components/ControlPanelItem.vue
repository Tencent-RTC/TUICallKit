<script setup lang="ts">
import { ref, onMounted, nextTick } from 'vue';
import triangleSVG from '../assets/triangle.svg';
import "../style.css";

const openDetail = ref<boolean>(false);
const { action, hasDetail } = withDefaults(defineProps<{
  action: (payload: MouseEvent) => void,
  hasDetail?: boolean,
}>(), {
  hasDetail: false
});

onMounted(() => {
  document.documentElement.addEventListener('click', (e) => {
    openDetail.value = false;
  });
});

async function stayFocus() {
  await nextTick();
  const els = document.getElementsByClassName("control-item-detail");
  for (let el of els) {
    el.addEventListener("click", e => e.stopPropagation());
  }
}

const toggleDetail = (event: Event) => {
  event.stopPropagation();
  stayFocus();
  openDetail.value = !openDetail.value;
}

</script>

<template>
  <div class="control-item">
    <div class="control-item-icon">
      <div class="control-item-icon-container" @click="action">
          <slot name="icon"> </slot>
      </div>
      <div class="control-item-summary" @click="toggleDetail" v-if="hasDetail">
        <img :src="triangleSVG" />
      </div>
      <div class="control-item-detail" v-show="openDetail">
          <slot name="detail"> </slot>
      </div>
    </div>
    <div class="control-item-text"> <text>
        <slot name="text"> </slot>
      </text>
    </div>
  </div>
</template>