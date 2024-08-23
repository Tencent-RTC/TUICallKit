<template>
  <Card @click="handleIsShowPanel">
    <icon :src="DeviceCheckSrc" />
    {{  t('Device Detection') }}
  </Card>
  <DeviceCheckPanelVue @closePanel="handleIsShowPanel" v-if="isShowPanel" />
</template>

<script lang="ts" setup>
import { useLanguage } from '../../hooks';
import DeviceCheckSrc from '../../assets/DeviceCheck/device-check.svg';
import Card from '../common/Card/Card.vue';
import Icon from '../common/Icon/Icon.vue';
import DeviceCheckPanelVue from './DeviceCheckPanel/DeviceCheckPanel.vue';
import { ref } from 'vue';

const { t } = useLanguage();
const isShowPanel = ref(false);

const handleIsShowPanel = () => {
  isShowPanel.value = !isShowPanel.value;
}
</script>

<style lang="scss">

</style>