import { CallMediaType, CameraPosition } from '@trtc/call-engine-lite-wx';
import { CallStatus, CallRole, ICustomUIConfig } from '../const/index';
import { IUserInfo, INetWorkQuality } from './index';

export interface IToastInfo {
  text: string;
  type?: string; // 默认 info 通知, 取值: 'info' | 'warn' | 'success' | 'error'
}
export interface ICallStore {
  callStatus: CallStatus; // 当前的通话状态, 默认: 'idle'
  callRole: CallRole; // 通话角色, 默认: 'callee'
  callMediaType: CallMediaType; // 通话类型
  localUserInfo: IUserInfo; // 自己的信息, 默认: { userId: '' }
  localUserInfoExcludeVolume: IUserInfo; // 不包含音量的当前用户信息
  remoteUserInfoList: Array<IUserInfo>; // 远端用户信息列表, 默认: []
  remoteUserInfoExcludeVolumeList: Array<IUserInfo>; // 不包含音量的远端用户信息列表
  // 被叫在未接通时，展示主叫的 userId、头像。但是如果主叫进入通话后再挂断，此时被叫无法知道主叫的信息了。
  // 因为目前 store 中仅提供了 remoteUserInfoList 数据，主叫离开后，被叫就没有主叫的信息了。因此考虑在 store 中增加 callerUserInfo 字段。
  callerUserInfo: IUserInfo;
  isGroup: boolean; // 是否是群组通话, 默认: false
  duration: number; // 通话时长, 默认: 0
  callTips: string; // 通话提示的信息. 例如: '等待谁接听', 'xxx 拒绝通话', 'xxx 挂断通话'
  toastInfo: IToastInfo; // 远端用户挂断、拒绝、超时、忙线等的 toast 提示信息
  isMinimized: boolean; // 当前是否悬浮窗模式, 默认: false
  enableFloatWindow: boolean, // 开启/关闭悬浮窗功能，默认: false
  bigScreenUserId: string, // 当前大屏幕显示的 userID 用户
  language: string; // 当前语言
  isClickable: boolean; // 按钮是否可点击（呼叫后, '挂断' 按钮不可点击, 发送信令后才可以点击）
  showPermissionTip: boolean; // 设备权限弹窗是否展示（如果有麦克风权限为 false，如果没有麦克风也没有摄像头权限为 true）
  netWorkQualityList: Array<INetWorkQuality>; // 通话中用户的网络状态
  // deviceList: TDeviceList;
  callID: string; // callEngine v3.1 support
  groupID: string;
  roomID: number | string;
  cameraPosition: CameraPosition; // 前置或后置，值为front, back
  isMuteSpeaker: boolean;
  // 小程序相关属性
  isEarPhone: boolean; // 是否是听筒, 默认: false
  pusherId: string;    // 重新渲染 live-Pusher 的标识位, 必须, 接通前如果没有权限, 授权后需要用新的 pusher, 否则进不了房间
  // translate function
  translate: Function,

  callInfo: Object;
  // Custom UI config: hidden buttons, view background images, layout mode.
  customUIConfig: ICustomUIConfig;
}
