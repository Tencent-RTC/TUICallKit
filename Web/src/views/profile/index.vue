<template>
  <div class="user-profile-container">
    <div class="user-profile-title">用户信息</div>
    <el-input
      placeholder="用户名"
      v-model="userName"
      class="phone-num">
    </el-input>
    <div class="action-footer">
      <el-button class="user-login-btn" @click="handleSubmit">
        修改
      </el-button>
      <el-button class="user-login-btn" @click="handleCancel">
        取消
      </el-button>
    </div>

  </div>
</template>

<script>
  import {mapState} from 'vuex';
  import {isUserNameValid} from '../../utils';

  export default {
    name: 'Profile',
    computed: mapState({
      loginUserInfo: state => state.loginUserInfo
    }),
    data() {
      return {
        userName: ''
      }
    },
    mounted() {
      this.userName = this.loginUserInfo.nick;
    },
    methods: {
      handleSubmit: async function() {
        const { nick } = this.loginUserInfo;
        if (!isUserNameValid(this.userName)) {
          this.$message.error('无效用户名');
          return;
        }
        if (nick === this.userName) {
          this.$message.error('用户名未修改');
          return;
        }
        const res =  await this.$tuiCallEngine.setSelfInfo({nickName: this.userName})
        this.$store.commit("setLoginUserInfo", {
          ...this.loginUserInfo,
          nick: res.data.nick
        });
        this.$message.success('名称修改成功');
      },
      handleCancel: function() {
        this.$router.push('/home');
      }
    }
  }
</script>

<style scoped>
  .user-profile-container {
    width: 400px;
    margin: 0 auto;
  }
  .user-profile-title {
    font-size: 20px;
    padding-top: 50px;
    margin-bottom: 20px;
  }
  .action-footer {
    margin-top: 20px;
  }
</style>
