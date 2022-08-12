<template>
  <div class="search-user-container" v-if="callStatus !== 'connected'">
    <div class="search-section">
      <el-input
        class="inline-input"
        v-model="searchInput"
        @change="querySearch"
        placeholder="搜索userID"
      >
        <i slot="prefix" class="el-input__icon el-icon-search"></i>
      </el-input>
      <el-button class="search-user-btn">搜索</el-button>
    </div>
    <div v-if="userList.length > 0 && callStatus !== 'connected'" class="search-user-list">
      <div class="search-user-list-title">{{ searchResultList.length > 0 ? '搜索结果:' : '搜索历史:'}}</div>
      <div class="user-item" v-for="item in userList" :key="item.userId">
        <div class="user-item-info">
          <div class="user-item-avatar-wrapper">
            <img :src="item.avatar" onerror="this.src='https://web.sdk.qcloud.com/component/TUIKit/assets/avatar_21.png'" />
          </div>
          <div class="user-item-username">{{item.nick || item.userID}}</div>
          <div class="user-item-username">（ userID: {{item.userID}} ）</div>
        </div>
        <div
          v-if="callStatus === 'calling' && callUserId === item.userID"
          class="calling-user-footer"
        >
          <el-button class="user-item-join-btn calling">呼叫中...</el-button>
          <el-button class="user-item-cancel-join-btn" @click="handleCancelCallBtnClick">取消</el-button>
        </div>
        <el-button v-else @click="handleCallBtnClick(item.userID)" :class="['user-item-join-btn']" :disabled="!!callUserId" >呼叫</el-button>
      </div>
    </div>
  </div>
</template>

<script>
import { mapState } from "vuex";
import {
  // isValidatePhoneNum,
  addToSearchHistory,
  getSearchHistory
} from "../../utils";

export default {
  name: "SearchUser",
  data() {
    return {
      searchInput: "",
      callUserId: "",
      searchResultList: [],
      searchHistoryUser: [],
    };
  },
  computed: {
    ...mapState({
      loginUserInfo: state => state.loginUserInfo,
      meetingUserIdList: state => state.meetingUserIdList,
      callStatus: state => state.callStatus,
      isAccepted: state => state.isAccepted
    }),
    userList: function() {
      if (this.searchInput === "" && this.searchHistoryUser.length !== 0) {
        return this.searchHistoryUser;
      }
      return this.searchResultList;
    }
  },
  mounted() {
    this.searchHistoryUser = getSearchHistory(this.loginUserInfo.userId)
  },
  watch: {
    callStatus: function(newStatus, oldStatus) {
      if (newStatus !== oldStatus && newStatus === "connected") {
        this.searchInput = "";
        this.searchResultList = [];
      }
      if (newStatus === "idle") {
        this.callUserId = "";
      }
    }
  },
  methods: {
    querySearch: async function() {
      const { userId } = this.loginUserInfo;
      if (this.searchInput === "") {
        this.searchResultList = [];
        return;
      }
      // if (!isValidatePhoneNum(this.searchInput)) {
      //   this.$message.error("无效电话号码");
      //   return;
      // }
      if (userId === this.searchInput) {
        this.$message.warning("不能搜索添加自己");
        return;
      }

      const response = await this.$tim.getUserProfile({userIDList: [this.searchInput]})
      if (response.data.length === 0) {
        return this.$message.warning("该用户不存在");
      } else {
        addToSearchHistory(response.data[0])
        this.searchResultList = [...response.data]
        console.log(this.searchResultList);
      }
      
    },
    handleCallBtnClick: function(userId) {
      this.callUserId = userId;
      this.$emit("callUser", { userId });
    },
    handleCancelCallBtnClick: function() {
      // 对方刚接受邀请，但进房未成功
      if (this.isAccepted && this.callStatus !== "connected") {
        return;
      }
      this.callUserId = "";
      this.$emit("cancelCallUser");
    }
  }
};
</script>

<style scoped>
.search-user-container {
  width: 450px;
  margin: 10px auto 0;
}
.search-section {
  display: flex;
  flex-direction: row;
}
.search-user-btn {
  margin-left: 10px;
}
.search-user-list-title {
  margin-top: 20px;
  font-size: 18px;
  text-align: left;
}
.user-item {
  display: flex;
  flex-direction: row;
  align-items: center;
  justify-content: space-between;
  margin-top: 10px;
}
.user-item-info {
  display: flex;
  flex-direction: row;
  align-items: center;
}
.user-item-avatar-wrapper img {
  width: 50px;
  height: 50px;
  border-radius: 50%;
}
.user-item-username {
  margin-left: 20px;
}
.el-button:disabled {
  background: #DCDFE6 !important;
}
@media screen and (max-width: 767px) {
  .search-user-container {
    width: 90%;
  }
}
</style>
