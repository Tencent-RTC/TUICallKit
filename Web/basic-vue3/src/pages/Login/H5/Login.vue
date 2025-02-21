<template>
  <Layout>
    <div class="login-h5">
      <el-input
        class="login-input"
        v-model="userID"
        :placeholder="placeholderText"
        @input="handleInputUserID"
        @keyup.enter="handleLogin"
      />
      <p class="login-tip"> {{ t('userID Limit') }}</p>
      <Button
        class="login-btn"
        @click="handleLogin"
      > 
        {{ t('Create / Log in userID') }}
      </Button>
    </div>
  </Layout>
</template>

<script lang="ts" setup>
import { computed, ref } from 'vue'
import { useLanguage } from '../../../hooks/index';
import useLogin from '../useLogin';
import { trim } from '../../../utils';
import Layout from '../../../components/Layout/Layout.vue';
import Button from '../../../components/common/Button/Button.vue';

const userID = ref('');
const { t } = useLanguage();
const { login } = useLogin();

const placeholderText = computed(() => {
  return t('Please enter the userID to create or log in');
})

const handleLogin = async () => {
  await login(userID);
}

const handleInputUserID = () => {
  userID.value = trim(userID.value);
}
</script>

<style lang="scss" scoped>
@import './Login.scss';
</style>