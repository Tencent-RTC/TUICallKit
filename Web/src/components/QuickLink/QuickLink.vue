<template>
  <Space size="10px" spacer="/" class="quick-link">
      <el-link
        v-for="(item) in QuickLinkObj"
        :href="item[lang]"
        target="_blank"
        :underline="false"
      >
        {{ t(item.label) }}
      </el-link>
  </Space>

</template>

<script lang="ts" setup>
import { computed } from 'vue';
import Space from '../common/Space/Space.vue';
import { QuickLinkObj } from '../../utils';
import { useLanguage } from '../../hooks';

const { t, language } = useLanguage();

const lang = computed(() => {
  return language.value.includes('zh_CN') ? 'zh_CN' : 'en';
})
</script>

<style scoped>
.quick-link {
  font-weight: 500;
  font-size: 14px;
  line-height: 20px;
  color: #596B91;
}
</style>