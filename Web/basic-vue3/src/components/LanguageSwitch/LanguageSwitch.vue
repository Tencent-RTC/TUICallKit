<template>
  <el-dropdown
    placement="top-start"
    @command="handleCommand"
  >
    <Card>
      <Icon :src="LanguageSwitchSrc" :width="16"/>
      {{ showLang }}
    </Card>
    <template #dropdown>
      <el-dropdown-menu>
        <el-dropdown-item command="en"> English </el-dropdown-item>
        <el-dropdown-item command="zh_CN"> 简体中文 </el-dropdown-item>
        <el-dropdown-item command="ja"> 日本語 </el-dropdown-item>
      </el-dropdown-menu>
    </template>
  </el-dropdown>
</template>

<script lang="ts" setup>
import { computed, onMounted } from 'vue';
import { TUICallKitServer } from '@tencentcloud/call-uikit-vue';
import Card from '../common/Card/Card.vue';
import Icon from '../common/Icon/Icon.vue';
import LanguageSwitchSrc from '../../assets/LanguageSwitch/language-swtich.svg';
import { useLanguage } from '../../hooks';

const { language, changeLanguage } = useLanguage();

const LanguageType = {
  'en': 'English',
  'zh_CN': '简体中文',
  'ja': '日本語',
} as { [key: string]: string };

const showLang = computed(() => LanguageType[language.value])

const LanguageTypeObj = {
  'en': 'en',
  'zh_CN': 'zh-cn',
  'ja': 'ja_JP',
} as { [key: string]: string };

const handleCommand = (command: string) => {
  changeLanguage(command);
  TUICallKitServer.setLanguage(LanguageTypeObj[language.value]);
}

onMounted(() => {
  TUICallKitServer.setLanguage(LanguageTypeObj[language.value]);
})

</script>
