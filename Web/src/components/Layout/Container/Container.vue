<template>
  <div class="container">
    <div class="container-header">
      <div
        class="title"
        v-show="userInfo?.currentPage.value === 'login'"
      >
        {{ t('Create / Log in userID') }}
      </div>
      <Segmented v-show="userInfo?.currentPage.value === 'home'" />
      <Return v-show="isShowReturn" />
      <ShowUserID />
    </div>
    <div class="container-content">
      <slot />
    </div>
  </div>
</template>

<script lang="ts" setup>
import { computed, toRefs } from 'vue';
import { useLanguage, useUserInfo } from '../../../hooks/index';
import Segmented from '../../common/Segmented/Segmented.vue';
import Return from '../../common/Return/Return.vue';
import ShowUserID from '../ShowUserID/ShowUserID.vue';

const { t } = useLanguage();
const userInfo = toRefs(useUserInfo());
const isShowReturn = computed(() => {
  return userInfo?.currentPage.value === 'call' || userInfo?.currentPage.value === 'groupCall'
});

</script>

<style lang="scss">
.container {
  width: 680px;
  height: 450px;
  margin-top: 35px;
  margin-bottom: 20px;

  background: #FFFFFF;
  box-shadow: 0px 2px 3px rgba(197, 210, 230, 0.3), 0px 8px 30px rgba(197, 210, 229, 0.3);
  border-radius: 24px;

  .container-header {
    height: 64px;
    padding: 0 36px;
    display: flex;
    justify-content: space-between;
    align-items: center;
    border-bottom: 1px solid rgba(228, 232, 238, 0.6);
    border-radius: 24px 24px 0 0;
    background: rgba(240, 244, 250, 0.3);

    .title {
      font-weight: 500;
      color: #4F586B;
    }
    .icon-copy {
      display: flex;
      gap: 0 4px;
      align-items: center;
      justify-content: center;
      cursor: pointer;
    }
  }

  .container-content {
    display: flex;
    justify-content: center;
  }
}
</style>