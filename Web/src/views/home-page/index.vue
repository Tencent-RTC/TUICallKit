<template>
  <div class="home-page-container">
    <div class="home-page-header">
      Welcome {{loginUserInfo && (loginUserInfo.nick || loginUserInfo.userId)}}
      <span
        v-if="enableEditName"
        class="change-name"
        @click="goto('profile')">
        改名
      </span>
    </div>
    <div>
      <label>userID:</label>
      <span>{{loginUserInfo.userId}}</span>
    </div>
    <div class="home-page-section-list">
      <div class="home-page-section" v-for="(item, index) of list" :key="index" @click="goto('call', item.query)">
        {{item.label}}
      </div>
    </div>
  </div>
</template>

<script>
  import {mapState} from 'vuex';

  export default {
    name: 'HomePage',
    computed: mapState({
      loginUserInfo: state => state.loginUserInfo
    }),
    data() {
      return {
        enableEditName: true,
        list: [
          {
            label: "视频通话",
            query: {
              type: this.TUICallType.VIDEO_CALL
            }
          },
          {
            label: "语音通话",
            query: {
              type: this.TUICallType.AUDIO_CALL
            }
          }
        ]
      }
    },
    methods: {
      goto: function(name, query) {
        const options = {
          name: name
        }
        if (query) {
          options.query = query
        }
        this.$router.push(options);
      }
    }
  }
</script>

<style scoped>
  .home-page-header {
    padding: 30px 0 10px;
    font-size: 24px;
  }
  /* .home-page-section-list {
    display: flex;
    flex-wrap: wrap;
  } */
  .home-page-section {
    background-image: linear-gradient(155deg, #0D2C5B 7%, #122755 93%);
    border-radius: 6px;
    color: #ffffff;
    width: 300px;
    height: 100px;
    margin: 10px auto;
    display: flex;
    align-items: center;
    justify-content: center;
  }
  .home-page-section:hover {
    cursor: pointer;
  }
  .change-name {
    margin-left: 10px;
    text-decoration: underline;
    color: #5f6368;
    font-size: 16px;
    cursor: pointer;
  }
</style>
