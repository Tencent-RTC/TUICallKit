<template>
  <Card @click="handleIsShowPanel">
    <Icon :src="RunGuideSrc" />
    {{ t('Onboard Guide') }}
  </Card>
  <RunGuidePanel @closePanel="handleIsShowPanel" v-if="isShowPanel" />
</template>

<script lang="ts" setup>
import { ref } from 'vue';
import Icon from '../common/Icon/Icon.vue';
import Card from '../common/Card/Card.vue';
import RunGuidePanel from './RunGuidePanel/RunGuidePanel.vue';
import { useLanguage } from '../../hooks';
import RunGuideSrc from '../../assets/RunGuide/run-guide.svg';

const { t } = useLanguage();

const isShowPanel = ref(false);

const handleIsShowPanel = () => {
  isShowPanel.value = !isShowPanel.value;
}

</script>

<style lang="scss">

</style>