<template>
  <div class="home-container">
    <div class="home-card" @click="goCall">
      <div class="card-title-box">
        <p class="card-title"> {{ t('1v1 Call') }} </p>
        <div class="card-arrow">
          <Icon :src="RightArrowSrc"  :size="14"/>
        </div>
      </div>
      <p class="card-sub-title"> {{ t('the call') }} </p>
      <Icon 
        width="183"
        :src="CallSrc" />
    </div>

    <div class="home-card" @click="goGroupCall">
      <div class="card-title-box">
        <p class="card-title"> {{ t('Group Call') }} </p>
        <div class="card-arrow">
          <Icon :src="RightArrowSrc"  :size="14"/>
        </div>
      </div>
      <p class="card-sub-title"> {{ t('the groupCall') }} </p>
      <Icon 
        width="183"
        :src="GroupCallSrc" />
    </div>
  </div>
</template>

<script lang="ts" setup>
import { useLanguage, useMyRouter } from '../../../hooks';
import Icon from '../../../components/common/Icon/Icon.vue';
import CallSrc from '../../../assets/Home/call.png';
import GroupCallSrc from '../../../assets/Home/group-call.png';
import RightArrowSrc from '../../../assets/Home/right-arrow.svg';

const { t } = useLanguage();
const { navigate } = useMyRouter();

const goCall = () => {
  navigate('/call');
}
const goGroupCall = () => {
  navigate('/groupCall');
}
</script>


<style lang="scss">
.home-container {
  margin: 36px;
  display: flex;
  gap: 0 20px;

  .home-card {
    box-sizing: border-box;
    width: 294px;
    height: 314px;
    padding: 25px;
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    background: #F0F4FA;
    border-radius: 12px;
    cursor: pointer;

    .card-title-box {
      display: flex;
      gap: 0 8px;
      align-items: center;

      .card-title {
        font-weight: 600;
        font-size: 20px;
        color: #000000;
      }

      .card-arrow {
        width: 40px;
        height: 24px;
        display: flex;
        align-items: center;
        justify-content: center;
        background: #1C66E5;
        border-radius: 12px;
      }
    }

    .card-sub-title {
      margin: 16px 0 27px 0;
      font-weight: 400;
      font-size: 14px;
      line-height: 22px;
      text-align: center;
      color: #747F99;
    }
  }
}

</style>
