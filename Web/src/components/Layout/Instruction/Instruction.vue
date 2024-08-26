<template>
  <Space size="12px">
    <Card> 
      <Icon :src="WarningSrc" />
      {{ t('Sensitive links/QR') }}
    </Card>
    <Card>
      <Icon :src="HelpSrc" />
      {{ t('Any problems in running') }}
      <el-link
        :href="link"
        target="_blank"
        style="margin-left: 77px; color: #1C66E5;"
        :underline="false"
      >
        {{ t('Get tech support') }}
        <Icon :src="RightArrowSrc" :size="16"/>
      </el-link>
    </Card>
  </Space>
</template>

<script lang="ts" setup>
import { useLanguage } from '../../../hooks';
import Icon from '../../common/Icon/Icon.vue';
import Card from '../../common/Card/Card.vue';
import Space from '../../common/Space/Space.vue';
import WarningSrc from '../../../assets/Layout/warning.svg';
import HelpSrc from '../../../assets/Layout/help.svg';
import RightArrowSrc from '../../../assets/Layout/right-arrow.svg';
import { computed } from 'vue';

const { t, language } = useLanguage();
const link = computed(() => {
  return language.value.includes('zh')
    ? 'https://zhiliao.qq.com/'
    : 'https://t.me/+EPk6TMZEZMM5OGY1'
})

</script>
