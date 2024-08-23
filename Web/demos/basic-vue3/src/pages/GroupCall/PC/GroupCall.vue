<template>
  <div class="group-call-container">
    <CreateUserTip class="group-call-tip">
      {{ t('Create more userIDs to enable group calls') }}
    </CreateUserTip>
    <el-input
      class="group-call-input"
      :placeholder="placeholderText"
      v-model="inputUserID"
      @input="handleInputUserID"
      @change="handleAddGroupCallMember"
    >
      <template #append>
        <Button class="btn-add" :disabled="groupCallMember.length >= 8" > {{ t('Add') }} </Button>
      </template>
    </el-input>
    <p class="title-group-member"> {{ t('Group Members') }} {{`(${groupCallMember.length + 1} ${t('people')} / 9 ${t('people')}) `}}</p>
    <div class="group-member-box">
      <div :class="['card', 'you']">
        <Text :max-width="120"> {{ userInfo?.userID }} </Text>
        {{ `(${t('You')})` }}
      </div>
      <template v-for="(item) in groupCallMember">
        <div class="card">
          <Text :max-width="130"> {{ item }} </Text>
          <Icon :src="ChaSrc" :size="12" @click="() => deleteGroupCallUser(item)" />
        </div>
      </template>
    </div>
    <Button
      class="btn-group-call"
      :disabled="!groupCallMember.length"
      @click="handleGroupCall"
    > {{ t('Initiate Group Call') }} </Button>
  </div>
</template>

<script lang="ts" setup>
import { ref, computed } from 'vue';
import Button from '../../../components/common/Button/Button.vue';
import Icon from '../../../components/common/Icon/Icon.vue';
import CreateUserTip from '../../../components/CreateUserTip/CreateUserTip.vue';
import Text from '../../../components/common/Text/Text.vue';
import ChaSrc from '../../../assets/GroupCall/cha.svg';
import { useLanguage, useUserInfo } from '../../../hooks';
import useGroupCall from '../useGroupCall';

const { t } = useLanguage();
const inputUserID = ref('');
const groupCallMember = ref([]);
const userInfo = useUserInfo();

const { groupCall, inputUserIDHandler, addGroupCallMemberHandler, deleteGroupCallUserHandler } = useGroupCall();

const placeholderText = computed(() => {
  return t('input userID to Add');
})

const handleGroupCall = async () => {
  await groupCall(groupCallMember);
}
const handleInputUserID = () => {
  inputUserIDHandler(inputUserID);
}
const handleAddGroupCallMember = () => {
  addGroupCallMemberHandler(inputUserID, groupCallMember);
}
const deleteGroupCallUser = (userID: string) => {
  deleteGroupCallUserHandler(userID, groupCallMember);
}
</script>

<style lang='scss'>
.el-input__wrapper {
  background: #F0F4FA;
  border-radius: 28px !important;
}
.el-input-group__append {
  border-radius: 28px !important;
}
.el-input-group--append>.el-input__wrapper {
  border-bottom-right-radius: 28px !important;
  border-top-right-radius: 28px !important;
}
</style>

<style lang="scss">
.group-call-container {
  width: 520px;
  height: 350px;
  display: flex;
  flex-direction: column;
  position: relative;

  .group-call-tip {
    margin-top: 20px;
  }

  .group-call-input {
    width: 520px;
    height: 48px;
    margin-top: 12px;
    background: #F0F4FA;
    border-radius: 28px;

    .btn-add {
      height: 48px;
      background: #F0F4FA;
      font-weight: 600;
      color: #1C66E5;
    }
  }

  .title-group-member {
    margin: 24px 0 20px 0;
    font-weight: 500;
    font-size: 14px;
    color: #4F586B;
  }

  .group-member-box {
    display: flex;
    flex-wrap: wrap;
    gap: 12px 20px;

    .card {
      box-sizing: border-box;
      width: 160px;
      height: 30px;
      padding: 4px 10px;
      display: flex;
      justify-content: space-between;
      align-items: center;
      background: #F2F5FC;
      border-radius: 8px;

      img {
        cursor: pointer;
      }
    }

    .you {
      color: #727A8A;
    }
  }

  .btn-group-call {
    // width: 120px;
    height: 40px;
    background: #1C66E5;
    border-radius: 26px !important;

    position: absolute;
    left: 200px;
    bottom: -05px;
  }
}
</style>
