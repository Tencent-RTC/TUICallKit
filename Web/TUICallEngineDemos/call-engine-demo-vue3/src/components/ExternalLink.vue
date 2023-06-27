<template>
  <div class="external-link">
    <el-divider>快速访问</el-divider>
    <el-row :gutter="20">
      <el-col :lg="6" :md="12" class="link-col">
        <el-link type="primary" :underline="false" @click="() => handleRedirect('https://cloud.tencent.com/document/product/647/78742')">套餐购买</el-link>
      </el-col>
      <el-col :lg="6" :md="12" class="link-col">
        <el-link type="primary" :underline="false" @click="() => handleRedirect('https://cloud.tencent.com/document/product/647/78731')">快速接入</el-link>
      </el-col>
      <el-col :lg="6" :md="12" class="link-col">
        <el-link type="primary" :underline="false" @click="() => handleRedirect('https://cloud.tencent.com/document/product/647/78757')">API文档</el-link>
      </el-col>
      <el-col :lg="6" :md="12" class="link-col">
        <el-link type="primary" :underline="false" @click="() => handleRedirect('https://cloud.tencent.com/document/product/647/78769')">常见问题</el-link>
      </el-col>
    </el-row>
  </div>
</template>

<script lang="ts" setup>
const handleRedirect = (url: string) => {
  window.open(url);
};
</script>

<style lang="less" scope>
.external-link {
  width: 60%;
  margin: 0 auto;
  .link-col {
    text-align: center;
  }
}
</style>
