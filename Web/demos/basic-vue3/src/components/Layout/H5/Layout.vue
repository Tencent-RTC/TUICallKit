<template>
  <div class="layout-h5">
    <div class="header">
      <ShowUserID />
      <LanguageSwitch />
    </div>
    <Logo class="logo"/>
    <div class="content">
      <slot />
    </div>
    <QuickLink class="quick-link" />
  </div>
</template>

<script lang="ts" setup>
import LanguageSwitch from '../../LanguageSwitch/LanguageSwitch.vue';
import Logo from '../Logo/Logo.vue'
import QuickLink from '../../QuickLink/QuickLink.vue';
import ShowUserID from '../ShowUserID/ShowUserID.vue';

</script>

<style lang="scss" scoped>
@import './Layout.scss';
</style>
