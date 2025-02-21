<template>
  <div class="login-container">
    <el-input 
      class="login-input"
      :placeholder=placeholderText
      v-model="userID"
      @input="handleInputUserID"
      @keyup.enter="handleLogin"
    />
    <p class="login-tip"> {{ t('userID Limit') }}</p>
    <Button 
      color="#1C66E5" 
      :width="200"
      :height="40"
      class="login-btn"
      @click="handleLogin"
    > 
      {{ t('Create / Log in userID') }}
    </Button>
  </div>
</template>

<script lang="ts" setup>
import { computed, ref } from 'vue'
import { useLanguage } from '../../../hooks/index';
import useLogin from '../useLogin';
import { trim } from '../../../utils';
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
.login-container {
  margin: 130px 140px;
  display: flex;
  flex-direction: column;

  .login-input {
    width: 400px;
    height: 48px;
    padding: 12px 20px;

    display: flex;
    flex-direction: row;
    align-items: center;

    background: #F9FAFC;
    border: 1px solid #E7ECF6;
    border-radius: 8px;
  }
  .login-tip {
    height: 24px;
    margin-top: 5px;
    font-weight: 400;
    font-size: 12px;
    line-height: 24px;
    color: #99A2B2;
  }
  .login-btn {
    margin: 0 auto;
    margin-top: 11px;
  }
}

</style>