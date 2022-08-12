<template>
  <div class="header-nav">
    <div class="header-nav-left">
      <img src="../../assets/logo.png" @click="gotoHomePage" alt="">
      <!-- <div class="header-nav-homepage" @click="gotoHomePage">首页</div> -->
    </div>
    <div class="header-nav-title">腾讯云TUICallEngine实时互动</div>
    <div class="header-nav-help">
       <el-button type="text" v-if="!isLogin" @click="handleCommand('command-knowledge')">更多了解</el-button>
      <el-dropdown v-else @command="handleCommand">
        <span class="el-dropdown-link">
          <span class="el-dropdown-name">
            <img :src="loginUserInfo?.avatar" onerror="this.src='https://web.sdk.qcloud.com/component/TUIKit/assets/avatar_21.png'" >
          </span>
          <!-- <i class="el-icon-arrow-down el-icon--right"></i> -->
        </span>
        <el-dropdown-menu slot="dropdown">
          <el-dropdown-item command="command-knowledge">更多了解</el-dropdown-item>
          <el-dropdown-item v-if="isLogin" command="command-logout">退出</el-dropdown-item>
        </el-dropdown-menu>
      </el-dropdown>
    </div>
  </div>
</template>

<script>
import { setUserLoginInfo, delSearchHistory } from "../../utils";
import { mapState } from "vuex";
export default {
  name: "HeaderNav",
  computed:{
    ...mapState(['isLogin','loginUserInfo'])
  },
  destroyed() {
   if (this.$route.name==="login") {
     console.log('destoryed','loginUserInfo');
   }
  },
  methods: {
    handleCommand(command) {
      if (command === "command-knowledge") {
        window.open(
          "https://cloud.tencent.com/document/product/647/49796",
          "__blank"
        );
        return;
      }

      if (command === "command-logout") {
        this.$tuiCallEngine.logout();
        this.$store.commit("userLogoutSuccess");
        setUserLoginInfo({
          token: "",
          userId: ""
        });
        delSearchHistory();
        this.$router.push("/");
      }
    },
    gotoHomePage() {
      console.log(this.$router.currentRoute);
      if (this.$router.currentRoute.fullPath !== "/") {
        this.$router.push("/");
      }
    }
  }
};
</script>

<style scoped>
.header-nav {
  background: #231f20;
  height: 80px;
  display: flex;
  padding: 0 20px;
  justify-content: space-between;
  color: #ffffff;
}
.header-nav-left{
  display: flex;
  align-items: center;
  cursor: pointer;
}
.header-nav-title {
  font-size: 20px;
  display: flex;
  align-items: center;
}
.header-nav-homepage {
  margin-left: 50px;
  font-size: 20px;
  display: flex;
  align-items: center;
  cursor: pointer;
}
.header-nav-help {
  font-size: 20px;
  display: flex;
  align-items: center;
}
.el-dropdown-link {
  color: #ffffff;
  font-size: 20px;
  cursor: pointer;
}
.el-dropdown-name {
  display: inline-block;
  width: 30px;
  height: 30px;
}
.el-dropdown-name img{
  width: 100%;
  border-radius: 100%;
}
@media screen and (max-width: 767px) {
  /* .header-nav {
    padding: 0;
  } */
  .header-nav-left img{
    /* justify-content: space-around;
    width: 75%; */
    display: none;
  }
  .el-dropdown-name {
    display: none;
  }
  /* .header-nav-title,
  .el-dropdown-link {
    font-size: 18px;
  }
  .header-nav-homepage {
    font-size: 18px;
    margin-left: 10px;
  } */
}
</style>
