<template>
  <el-container>
    <el-header height="70px" class="layout-header">
      <Space size="12px">
        <LanguageSwitch />
        <DeviceCheck />
        <RunGuide />
      </Space>
    </el-header>
    <el-main class="layout-main">
      <Logo/>
      <Container>
        <slot />
      </Container>
      <QuickLink />
    </el-main>
    <el-footer height="70px" class="layout-footer">
      <Instruction />
    </el-footer>
  </el-container>
</template>

<script lang="ts" setup>
import LanguageSwitch from '../../LanguageSwitch/LanguageSwitch.vue';
import DeviceCheck from '../../DeviceCheck/DeviceCheck.vue';
import RunGuide from '../../RunGuide/RunGuide.vue';
import Instruction from '../Instruction/Instruction.vue';
import QuickLink from '../../QuickLink/QuickLink.vue';
import Logo from '../Logo/Logo.vue';
import Container from '../Container/Container.vue';
import Space from '../../common/Space/Space.vue';

</script>

<style lang="scss" scoped>
.layout-header {
  display: flex;
  justify-content: end;
  align-items: end;
}
.layout-main {
  height: calc(100vh - 140px);
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
}
.layout-footer {
  display: flex;
  justify-content: center;
  align-items: start;
}
</style>
