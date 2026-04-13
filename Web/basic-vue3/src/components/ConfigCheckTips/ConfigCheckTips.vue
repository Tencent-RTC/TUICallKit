<template>
  <div class="config-check-tips">
    <div class="tips-content">
      <p class="tips-subtitle">{{ t('Please check the following configuration') }}:</p>
      <div class="tips-list">
        <div class="tip-item" v-for="(tip, index) in tips" :key="index">
          <span class="tip-number">{{ index + 1 }}.</span>
          <span class="tip-text" v-if="index === 1">
            {{ t('config tip 2 prefix') }}
            <a href="https://cloud.tencent.com/document/product/647/104662" target="_blank" class="tip-link">{{ t('config tip 2 link') }}</a>
            {{ t('config tip 2 suffix') }}
          </span>
          <span class="tip-text" v-else>{{ t(tip) }}</span>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { useLanguage } from '../../hooks';

const { t } = useLanguage();

const tips = [
  'config tip 1',
  'config tip 2', 
  'config tip 3',
  'config tip 4',
  'config tip 5'
];
</script>

<style lang="scss" scoped>
.config-check-tips {
  width: 100%;
  background: #f8f9fa;
  border-radius: 8px;
  border: 1px solid #e9ecef;
  margin-bottom: 20px;
}

.tips-content {
  padding: 4px 16px;
}

.tips-subtitle {
  margin: 12px 0 8px 0;
  font-size: 13px;
  color: #666;
  font-weight: 500;
}

.tips-list {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.tip-item {
  display: flex;
  align-items: flex-start;
  font-size: 12px;
  line-height: 1.4;
  font-weight: 500;
  color: red;
}

.tip-number {
  color: red;
  font-weight: 500;
  min-width: 16px;
}

.tip-text {
  flex: 1;
}

.tip-link {
  color: #1C66E5;
  text-decoration: none;
  
  &:hover {
    text-decoration: underline;
  }
}

// H5 适配
@media (max-width: 768px) {
  .config-check-tips {
    max-width: 315px;
  }
  
  .tips-header {
    padding: 10px 12px;
  }
  
  .tips-content {
    padding: 0 12px 12px;
  }
  
  .tip-item {
    font-size: 11px;
  }
}
</style>