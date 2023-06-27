<template>
  <el-container style="width: 100%;">
    <el-header class="card-header">
    </el-header>
    <el-main class="card-main">
      <div class="logo">
        <img alt="Vue logo" class="logo" src="@/assets/logo.png" width="264.41" />
        <span>版本：1.0.0</span>
      </div>
      <div class="content">
        <el-input v-model="userId" placeholder="请输入userid" />
        <el-button
          type="primary"
          @click="userIdLogin"
          class="btn"
          :loading="loading"
        >
          登录
        </el-button>
      </div>
    </el-main>
    <div class="card-footer">
      <ExternalLink />
    </div>
  </el-container>
</template>

<script setup lang="ts">
import { ref } from 'vue';
import trim from 'lodash-es/trim';
import ExternalLink from './ExternalLink.vue';

defineProps<{ loading: boolean }>();
const emit = defineEmits<{(e: 'login', userId: string): void}>();

const userId = ref('');

const userIdLogin = async () => {
  const content = trim(userId.value);
  emit('login', content);
};
</script>

<style lang="less" scoped>
.card-wrap {
  width: 100%;
}
.card-header {
  display: flex;
  height: 12% !important;
}
.card-main {
  padding: 0;
  .logo {
    display: flex;
    flex-direction: column;
    align-items: center;
    img {
      width: 52%;
    }
  }
  .content {
    width: 60%;
    margin: 9.8rem auto 0 auto;
    .btn {
      width: 100%;
      margin-top: 1.2rem;
      background-color: #006EFF;
    }
  }
}
.card-footer {
  position: absolute;
  bottom: 5.3rem;
  width: 100%;
}
.login-header {
  display: flex;
  flex-direction: column;
  align-items: center;
  margin-top: 7rem;
  img {
    width: 52%;
  }
}
</style>