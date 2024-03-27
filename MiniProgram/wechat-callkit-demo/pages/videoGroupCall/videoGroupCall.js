import { MEDIA_TYPE } from 'tuicall-engine-wx';
import TIM from '@tencentcloud/chat';
import { TUICallKitServer } from "../../TUICallKit/TUICallService/index";

Page({
  TUICallKit: null,
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
    TUICallKitServer.getTim()
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
    // 创建群聊
    await this.createGroup(groupList);
    // 判断groupID是否创建成功
    if (this.data.groupID) {
      // 发起群通话
      TUICallKitServer.groupCall({
        userIDList,
        type: MEDIA_TYPE.VIDEO,
        groupID: this.data.groupID,
      });
      // 重置数据
      this.setData({
        // searchList: [],
        isCheck: true,
      });
    } else {
      wx.showToast({
        icon: 'none',
        title: '群创建失败',
      });
    }
  },

  // 选中
  addUser(event) {
    // 修改数据
    for (let i = 0; i < this.data.searchList.length; i++) {
      if (this.data.searchList[i].userID === event.target.dataset.word.userID) {
        const newlist = this.data.searchList;
        newlist[i].checked = true;
        this.setData({
          searchList: newlist,
        });
      }
    }
  },

  // 取消选中
  removeUser(event) {
    for (let i = 0; i < this.data.searchList.length; i++) {
      if (this.data.searchList[i].userID === event.target.dataset.word.userID) {
        const newlist = this.data.searchList;
        newlist[i].checked = false;
        this.setData({
          searchList: newlist,
        });
      }
    }
  },

  // 全选
  allCheck() {
    const newlist = this.data.searchList;
    // 改变搜索列表
    for (let i = 0;i < newlist.length;i++) {
      newlist[i].checked = true;
    }
    this.setData({
      searchList: newlist,
      isCheck: false,
    });
  },

  // 全部取消
  allCancel() {
    const newlist = this.data.searchList;
    // 改变搜索列表
    for (let i = 0;i < newlist.length;i++) {
      newlist[i].checked = false;
    }
    this.setData({
      searchList: newlist,
      isCheck: true,
    });
  },


  // 创建IM群聊
  createGroup(userIDList) {
    return TUICallKitServer.getTim().createGroup({
      type: TIM.TYPES.GRP_MEETING,
      name: 'WebSDK',
      memberList: userIDList, // 如果填写了 memberList，则必须填写 userID
    })
      .then((imResponse) => { // 创建成功
        this.setData({
          groupID: imResponse.data.group.groupID,
        });
      })
      .catch((imError) => {
        console.warn('createGroup error:', imError); // 创建群组失败的相关信息
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
