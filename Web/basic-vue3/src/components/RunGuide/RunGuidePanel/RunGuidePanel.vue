<template>
  <div class="run-guide-box">
    <div class="header">
      <p> {{ t('Run Demo Guide') }} </p>
      <Icon :src="ChaSrc" :size="16" @click="$emit('closePanel')"  style="cursor: pointer;"/>
    </div>
    <p></p>
    <div>
      <el-tree
        :data="treeData"
        node-key="id"
        :default-expanded-keys="[4, 7]"
      />
    </div>
    
  </div>
</template>

<script lang='ts' setup>
import { useLanguage } from '../../../hooks';
import Icon from '../../common/Icon/Icon.vue';
import ChaSrc from '../../../assets/GroupCall/cha.svg';
// import GreenRightSrc from '../../../../assets/RunGuide/green-right.svg';
const { t } = useLanguage();

const treeData = [
  { 
    id: 1,
    label: t('Create / Log in userID'),
  },
  {
    id: 2,
    label: `${t('Complete Device Detection')}`,
  },
  {
    id: 3,
    label: `${t('Choose Video Call/Voice Call')}`,
  },
  { 
    id: 4,
    label: `${t('Initiate One-on-One Call')}`, 
    children: [
      {
        id: 5,
        label: `${t('Copy the link of this page to create a new user, or use your phone to scan the QR code')}`,
      },
      {
        id: 6,
        label: `${t('input the userID and initiate a one-on-one call')}`,
      },
    ]
  },
  { 
    id: 7,
    label: `${t('Initiate Group Call')}`, 
    children: [
      {
        id: 8,
        label: `${t('Copy the link of this page to create multiple users')}`,
      },
      {
        id: 9,
        label: `${t('Enter the userID and add up to 9 group members')}`,
      },
      {
        id: 10,
        label: `${t('Initiate Group Call')}`, 
      },
    ]
  },
];


</script>

<style lang="scss" scoped>
.run-guide-box {
  box-sizing: border-box;
  width: 308px;
  padding: 20px;
  background: #FFFFFF;
  box-shadow: 0px 3px 8px #E9F0FB;
  border-radius: 12px;
  position: absolute;
  z-index: 100;
  top: 80px;
  right: 20px;
  display: flex;
  flex-direction: column;
  gap: 16px 0;
  .header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    p {
      font-weight: 600;
      font-size: 16px;
    }
  }

  &>p {
    width: 268px;
    height: 0px;
    border: 1px solid rgba(228, 232, 238, 0.6);
  }
}
</style>