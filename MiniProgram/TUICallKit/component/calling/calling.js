// components/tui-calling/TUICalling/component/calling.js
Component({
  /**
   * 组件的属性列表
   */
  properties: {
    isSponsor: {
      type: Boolean,
      value: false,
    },
    pusher: {
      type: Object,
    },
    callType: {
      type: Number,
    },
    remoteUsers: {
      type: Array,
    },
    isGroup: {
      type: Boolean,
    },
  },
  /**
   * 组件的初始数据
   */
  data: {
    isClick: true,
  },

  /**
   * 生命周期方法
   */
  lifetimes: {
    created() {

    },
    attached() {
    },
    ready() {
    },
    detached() {
    },
    error() {
    },
  },

  /**
   * 组件的方法列表
   */
  methods: {
    async handleCheckAuthor(e) {
      const type =this.data.callType;
      wx.getSetting({
        success: async (res) => {
          const isRecord = res.authSetting['scope.record'];
          const isCamera = res.authSetting['scope.camera'];
          if (!isRecord && type === 1) {
            const title = '麦克风权限授权';
            const content = '使用语音通话，需要在设置中对麦克风进行授权允许';
            try {
              await wx.authorize({ scope: 'scope.record' });
              this.accept(e);
            } catch (e) {
              this.handleShowModal(title, content);
            }
            return;
          }
          if ((!isRecord || !isCamera) && type === 2) {
            const title = '麦克风、摄像头权限授权';
            const content = '使用视频通话，需要在设置中对麦克风、摄像头进行授权允许';
            try {
              await wx.authorize({ scope: 'scope.record' });
              await wx.authorize({ scope: 'scope.camera' });
              this.accept(e);
            } catch (e) {
              this.handleShowModal(title, content);
            }
            return;
          }
          this.accept(e);
        },
      });
    },
    handleShowModal(title, content) {
      wx.showModal({
        title,
        content,
        confirmText: '去设置',
        success: (res) => {
          if (res.confirm) {
            wx.openSetting();
          }
        },
      });
    },
    accept(event) {
      this.setData({
        isClick: false,
      });
      const data = {
        name: 'accept',
        event,
      };
      this.triggerEvent('callingEvent', data);
    },
    hangup(event) {
      const data = {
        name: 'hangup',
        event,
      };
      this.triggerEvent('callingEvent', data);
    },
    reject(event) {
      const data = {
        name: 'reject',
        event,
      };
      this.triggerEvent('callingEvent', data);
    },
    handleErrorImage(e) {
      const { id } = e.target;
      const remoteUsers = this.data.remoteUsers.map((item) => {
        if (item.userID === id) {
          item.avatar = '../../static/default_avatar.png';
        }
        return item;
      });
      this.setData({
        remoteUsers,
      });
    },
    toggleSwitchCamera(event) {
      const data = {
        name: 'toggleSwitchCamera',
        event,
      };
      this.triggerEvent('callingEvent', data);
    },
    switchAudioCall(event) {
      const data = {
        name: 'switchAudioCall',
        event,
      };
      this.triggerEvent('callingEvent', data);
    },
  },
});
