import { CallMediaType } from '@trtc/call-engine-lite-wx';
import { TUICallKitAPI } from "../../TUICallKit/TUICallService/index";

Page({
  data: {
    userIDToSearch: '',  // 搜索的结果
    searchList: [],  // 搜索后展示的列表
    callBtn: false,  // 控制呼叫按钮的显示隐藏
    isCheck: true,   // 显示是否全选
    groupID: '',
    userID:''
  },

  // 监听输入框
  userIDToSearchInput(e) {
    this.setData({
      userIDToSearch: e.detail.value,
    });
  },

  // 搜索
  searchUser() {
    // 去掉前后空格
    const newSearch = this.data.userIDToSearch.trim();
    this.setData({
      userIDToSearch: newSearch,
    });

    // 不能呼叫自身
    if (this.data.userIDToSearch === wx.$globalData.userID) {
      wx.showToast({
        icon: 'none',
        title: '不能呼叫本机',
      });
      return;
    }
    // 最大呼叫人数为九人(含自己)
    if (this.data.searchList.length > 7) {
      wx.showToast({
        icon: 'none',
        title: '暂支持最多9人通话。如需多人会议，请使用TUIRoom',
      });
      return;
    }
    for (let i = 0; i < this.data.searchList.length; i++) {
      if (this.data.searchList[i].userID === this.data.userIDToSearch) {
        wx.showToast({
          icon: 'none',
          title: 'userId已存在，请勿重复添加',
        });
        return;
      }
    }
    TUICallKitAPI.getTim()
      .getUserProfile({ userIDList: [this.data.userIDToSearch] })
      .then((imResponse) => {
        if (imResponse.data.length === 0) {
          wx.showToast({
            title: '未查询到此用户',
            icon: 'none',
          });
          return;
        }
        const list = {
          userID: this.data.userIDToSearch,
          nick: imResponse.data[0].nick,
          avatar: imResponse.data[0].avatar,
          checked: false,
        };
        this.data.searchList.push(list);
        this.setData({
          searchList: this.data.searchList,
          callBtn: true,
          userIDToSearch: '',
        });
      });
  },

  // 群通话
  async groupCall() {
    // 将需要呼叫的用户从搜索列表中过滤出来
    const newList = this.data.searchList.filter(item => item.checked);
    const userIDList = newList.map(item => item.userID);
    // 未选中用户无法发起群通话
    if (userIDList.length === 0) {
      wx.showToast({
        icon: 'none',
        title: '未选择呼叫用户',
      });
      return;
    }
    // 处理数据
    const groupList = JSON.parse(JSON.stringify(userIDList));
    // 将本机userID插入群成员中
    groupList.unshift(wx.$globalData.userID);
    for (let i = 0; i < groupList.length; i++) {
      const user = {
        userID: groupList[i],
      };
      groupList[i] = user;
    }
    // 发起群通话
    TUICallKitAPI.calls({
      userIDList,
      type: CallMediaType.AUDIO,
    });
    // 重置数据
    this.setData({
      // searchList: [],
      isCheck: true,
    });
  },

  // 选中
  addUser(event) {
    // 修改数据
    for (let i = 0; i < this.data.searchList.length; i++) {
      if (this.data.searchList[i].userID === event.target.dataset.word.userID) {
        const newList = this.data.searchList;
        newList[i].checked = true;
        this.setData({
          searchList: newList,
        });
      }
    }
  },

  // 取消选中
  removeUser(event) {
    for (let i = 0; i < this.data.searchList.length; i++) {
      if (this.data.searchList[i].userID === event.target.dataset.word.userID) {
        const newList = this.data.searchList;
        newList[i].checked = false;
        this.setData({
          searchList: newList,
        });
      }
    }
  },

  // 全选
  allCheck() {
    const newList = this.data.searchList;
    // 改变搜索列表
    for (let i = 0;i < newList.length;i++) {
      newList[i].checked = true;
    }
    this.setData({
      searchList: newList,
      isCheck: false,
    });
  },

  // 全部取消
  allCancel() {
    const newList = this.data.searchList;
    // 改变搜索列表
    for (let i = 0;i < newList.length;i++) {
      newList[i].checked = false;
    }
    this.setData({
      searchList: newList,
      isCheck: true,
    });
  },

  onBack() {
    wx.navigateBack({
      delta: 1,
    });
  },

  onLoad() {
    this.setData({
      userID:wx.$globalData.userID 
    })
  },
});
