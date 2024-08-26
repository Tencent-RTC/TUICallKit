<template>
  <img :src="src" :width="size" :height="size"/>
</template>

<script lang="ts" setup>
defineProps({
  src: {
    type: String
  },
  size: {
    type: Number,
  }
})
</script>
