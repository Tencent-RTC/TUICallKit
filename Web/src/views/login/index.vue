<template>
  <div class="user-login">
    <el-input placeholder="User ID" v-model="UserID" maxlength="11" class="phone-num" :disabled="isLogin"></el-input>
    <footer>
      <el-button class="user-login-btn" @click="handleLogin">Log in</el-button>
      <el-button  v-if="isLogin" class="user-login-btn" @click="handleLogout">Logout</el-button>
    </footer>
  </div>
</template>

<script>
import { genTestUserSig } from "../../../public/debug/GenerateTestUserSig";
import { getUserLoginInfo, setUserLoginInfo } from '../../utils'

export default {
  name: "Login",
  data() {
    return {
      UserID: "",
      userSig: "",
      verifyCode: "",
      disableFetchCodeBtn: false,
      isLogin: false
    };
  },
  mounted() {
    const userInfo = getUserLoginInfo();
    if (userInfo?.userId) {
      this.UserID = userInfo.userId;
      this.handleLoginCalling();
      this.isLogin = true;
    }
  },
  methods: {
    handleLogin: async function() {
      if (!this.UserID) {
        this.$message.error("Enter a user ID");
        return;
      }
      if (!this.isLogin) {
        await this.handleLoginCalling();
      }
      const userInfo = await this.$tuiCallEngine.tim.getMyProfile();
      const config = {
        userId: this.UserID,
        userSig: this.userSig,
        nick: userInfo.data.nick,
        avatar: userInfo.data.avatar,
      }
      this.$store.commit("setLoginUserInfo", config);
      setUserLoginInfo(config);
      this.$router.push('/home')
    },
    async handleLoginCalling() {
      this.userSig = genTestUserSig(this.UserID).userSig;
      this.$store.commit("userLoginSuccess");
      // 登录 trtcCalling
      await this.$tuiCallEngine.login({
        userID: this.UserID,
        userSig: this.userSig
      });
    },
    handleLogout() {
      this.UserID = "";
      this.isLogin = false;
      this.$tuiCallEngine.destroyInstance();
      this.$store.commit("setLoginUserInfo", {});
      setUserLoginInfo({});
    },
  }
};
</script>

<style scoped>
.user-login {
  font-size: 16px;
  width: 400px;
  margin: 0 auto;
  padding-top: 50px;
}
footer {
  display: flex;
}
.phone-num {
  margin-bottom: 5px;
}
.user-login-btn {
  margin-top: 10px;
  width: 100%;
}
@media screen and (max-width: 767px) {
  .user-login {
    font-size: 16px;
    width: 90%;
    min-width: 300px;
    margin: 0 auto;
    padding-top: 50px;
  }
}
</style>
