<template>
  <LayoutPC v-if="!isH5">
    <slot />
  </LayoutPC>
  <LayoutH5 v-else>
    <slot />
  </LayoutH5>
</template>

<script lang="ts" setup>
import { isH5 } from '../../utils';
import LayoutPC from './PC/Layout.vue';
import LayoutH5 from './H5/Layout.vue';

</script>
