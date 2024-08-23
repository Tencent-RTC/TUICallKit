<template>
  <div class="group-call-h5">
    <div class="header">
      <Icon :src="LeftArrowSrc" @click="goHome"/>
      <p> {{ t('Group Call') }} </p>
    </div>
    <div class="content">
      <div class="title-panel">
        <span> {{ t('Group Members') }} </span>
        <span> 
          {{`(${groupCallMember.length + 1} ${t('people')} / 9 ${t('people')}) `}}
        </span>
      </div>
      <div class="member-box">
        <div :class="['card', 'you']">
          <Text :max-width="60"> {{ userInfo?.userID }} </Text>
          <span> {{ `(${t('You')})` }} </span>
        </div>
        <template v-for="(item) in groupCallMember">
        <div class="card">
          <Text :max-width="80"> {{ item }} </Text>
          <Icon
            :src="ChaSrc"
            :size="12"
            @click="() => deleteGroupCallUser(item)"
          />
        </div>
      </template>
      </div>
      <p class="line"></p>
      <el-input
        class="call-input"
        v-model="inputUserID"
        :placeholder="placeholderText"
        @input="handleInputUserID"
        @change="handleAddGroupCallMember"
      >
        <template #append>
          <span class="add-btn"> {{ t('Add') }} </span>
        </template>
      </el-input>
    </div>
    <div
      class="call-btn"
      @click="handleGroupCall"
    > 
      {{ t('Initiate Group Call') }}
    </div>
  </div>
</template>

<script lang="ts" setup>
import { ref, computed } from 'vue';
import { useLanguage, useUserInfo, useMyRouter } from '../../../hooks';
import useGroupCall from '../useGroupCall';
import Text from '../../../components/common/Text/Text.vue';
import Icon from '../../../components/common/Icon/Icon.vue';
import LeftArrowSrc from '../../../assets/Call/left-arrow.svg';
import ChaSrc from '../../../assets/GroupCall/cha.svg';

const { t } = useLanguage();
const { navigate } = useMyRouter();
const inputUserID = ref('');
const groupCallMember = ref([]);
const userInfo = useUserInfo();
const { groupCall, inputUserIDHandler, addGroupCallMemberHandler, deleteGroupCallUserHandler } = useGroupCall();

const placeholderText = computed(() => {
  return t('input userID to Add');
})

const goHome = () => {
  navigate('/home');
}

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

<style lang="scss" scoped>
@import './GroupCall.scss';
</style>