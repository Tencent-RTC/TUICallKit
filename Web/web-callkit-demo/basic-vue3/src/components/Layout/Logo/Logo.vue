<template>
  <Icon :src="src" :width="220"/>
</template>

<script lang="ts" setup>
import Icon from '../../common/Icon/Icon.vue';
import zhLogoSrc from '../../../assets/Layout/logo-zh.png';
import enLogoSrc from '../../../assets/Layout/logo-en.png';
import { computed } from 'vue';
import { useLanguage } from '../../../hooks/index';
const { language } = useLanguage();

const src = computed(() => {
  return language.value === 'zh' ? zhLogoSrc : enLogoSrc;
})
</script>