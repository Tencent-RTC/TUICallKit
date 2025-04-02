//
//  CallEngineManager.swift
//  TUICallKit
//
//  Created by vincepzhang on 2023/1/6.
//

import Foundation
import TUICore
import RTCRoomEngine
import RTCCommon

#if canImport(TXLiteAVSDK_TRTC)
import TXLiteAVSDK_TRTC
#elseif canImport(TXLiteAVSDK_Professional)
import TXLiteAVSDK_Professional
#endif

class CallManager {
    static let shared = CallManager()
    private init() {}
    
    var callingVibratorFeature: CallingVibratorFeature?
    var callingBellFeature: CallingBellFeature?
    let voipDataSyncHandler = VoIPDataSyncHandler()
    let globalState = GlobalState()
    let callState = CallState()
    let mediaState = MediaState()
    let viewState = ViewState()
    let userState = UserState()
    
    func resetState() {
        callState.reset()
        mediaState.reset()
        viewState.reset()
        userState.reset()
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: EVENT_CLOSE_TUICALLKIT_VIEWCONTROLLER), object: nil)
    }
    
    func setSelfInfo(nickname: String, avatar: String, succ: @escaping TUICallSucc, fail: @escaping TUICallFail) {
        TUICallEngine.createInstance().setSelfInfo(nickname: nickname, avatar: avatar) { [weak self] in
            guard let self = self else { return }
            userState.selfUser.avatar.value = avatar
            userState.selfUser.nickname.value = nickname
            succ()
        } fail: { code, message in
            fail(code, message)
        }
    }
    
    func call(userId: String, callMediaType: TUICallMediaType, params: TUICallParams, succ: @escaping TUICallSucc, fail: @escaping TUICallFail) {
        
        TUICallEngine.createInstance().call(userId: userId, callMediaType: callMediaType, params: params) { [weak self] in
            guard let self = self else { return }

            self.callState.mediaType.value = callMediaType
            CallManager.shared.viewState.callingViewType.value = .one2one
            self.userState.selfUser.callRole.value = TUICallRole.call
            self.userState.selfUser.callStatus.value = TUICallStatus.waiting
            
            if callMediaType == .audio {
                self.mediaState.audioPlayoutDevice.value = TUIAudioPlaybackDevice.earpiece
                self.mediaState.isCameraOpened.value = false
            } else if callMediaType == .video {
                self.mediaState.audioPlayoutDevice.value = TUIAudioPlaybackDevice.speakerphone
                self.mediaState.isCameraOpened.value = true
            }

            let remoteUser = User()
            remoteUser.id.value = userId
            remoteUser.callStatus.value = .waiting
            remoteUser.callRole.value = .called
            self.userState.remoteUserList.value.append(remoteUser)
            
            UserManager.getUserInfosFromIM(userIDs: [userId]) { [weak self]  mInviteeList in
                guard let self = self else { return }
                for remoteUser in self.userState.remoteUserList.value {
                    for imUserInfo in mInviteeList {
                        if remoteUser.id.value == imUserInfo.id.value {
                            remoteUser.nickname.value = imUserInfo.nickname.value
                            remoteUser.remark.value = imUserInfo.remark.value
                            remoteUser.avatar.value = imUserInfo.avatar.value
                        }
                    }
                }
                
                if CallManager.shared.userState.selfUser.callStatus.value != .none {
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: EVENT_SHOW_TUICALLKIT_VIEWCONTROLLER), object: nil)
                }
            }
            
            succ()
        } fail: { code, message in
            fail(code,message)
        }
    }
    
    func calls(userIdList: [String],
               callMediaType: TUICallMediaType,
               params: TUICallParams,
               succ: @escaping TUICallSucc,
               fail: @escaping TUICallFail) {
        TUICallEngine.createInstance().calls(userIdList: userIdList,
                                         callMediaType: callMediaType,
                                         params: params) { [weak self] in
            guard let self = self else { return }
            CallManager.shared.callState.groupId = params.chatGroupId
            self.callState.mediaType.value = callMediaType
            if userIdList.count == 1 {
                self.viewState.callingViewType.value = .one2one
            } else {
                self.viewState.callingViewType.value = .multi
            }
            if !params.chatGroupId.isEmpty {
                self.viewState.callingViewType.value = .multi
            }
            self.userState.selfUser.callRole.value = TUICallRole.call
            self.userState.selfUser.callStatus.value = TUICallStatus.waiting
            
            if callMediaType == .audio {
                self.mediaState.audioPlayoutDevice.value = TUIAudioPlaybackDevice.earpiece
                self.mediaState.isCameraOpened.value = false
            } else if callMediaType == .video {
                self.mediaState.audioPlayoutDevice.value = TUIAudioPlaybackDevice.speakerphone
                self.mediaState.isCameraOpened.value = true
            }
            
            for userId in userIdList {
                let remoteUser = User()
                remoteUser.id.value = userId
                remoteUser.callStatus.value = .waiting
                remoteUser.callRole.value = .called
                self.userState.remoteUserList.value.append(remoteUser)
            }
            
            UserManager.getUserInfosFromIM(userIDs: userIdList) { [weak self]  mInviteeList in
                guard let self = self else { return }
                for remoteUser in self.userState.remoteUserList.value {
                    for imUserInfo in mInviteeList {
                        if remoteUser.id.value == imUserInfo.id.value {
                            remoteUser.nickname.value = imUserInfo.nickname.value
                            remoteUser.remark.value = imUserInfo.remark.value
                            remoteUser.avatar.value = imUserInfo.avatar.value
                        }
                    }
                }
                
                if CallManager.shared.userState.selfUser.callStatus.value != .none {
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: EVENT_SHOW_TUICALLKIT_VIEWCONTROLLER), object: nil)
                }
            }
            succ()
        } fail: { code, message in
            fail(code, message)
        }
    }

    func groupCall(groupId: String,
                   userIdList: [String],
                   callMediaType: TUICallMediaType,
                   params: TUICallParams,
                   succ: @escaping TUICallSucc,
                   fail: @escaping TUICallFail) {
        TUICallEngine.createInstance().groupCall(groupId: groupId,
                                                 userIdList: userIdList,
                                                 callMediaType: callMediaType,
                                                 params: params) { [weak self] in
            guard let self = self else { return }

            self.callState.groupId = groupId
            self.callState.mediaType.value = callMediaType
            CallManager.shared.viewState.callingViewType.value = .multi

            self.userState.selfUser.callRole.value = TUICallRole.call
            self.userState.selfUser.callStatus.value = TUICallStatus.waiting
            
            if callMediaType == .audio {
                self.mediaState.audioPlayoutDevice.value = TUIAudioPlaybackDevice.earpiece
                self.mediaState.isCameraOpened.value = false
            } else if callMediaType == .video {
                self.mediaState.audioPlayoutDevice.value = TUIAudioPlaybackDevice.speakerphone
                self.mediaState.isCameraOpened.value = true
            }
            
            for userId in userIdList {
                let remoteUser = User()
                remoteUser.id.value = userId
                remoteUser.callStatus.value = .waiting
                remoteUser.callRole.value = .called
                self.userState.remoteUserList.value.append(remoteUser)
            }
            
            UserManager.getUserInfosFromIM(userIDs: userIdList) { [weak self] mInviteeList in
                guard let self = self else { return }
                for remoteUser in self.userState.remoteUserList.value {
                    for imUserInfo in mInviteeList {
                        if remoteUser.id.value == imUserInfo.id.value {
                            remoteUser.nickname.value = imUserInfo.nickname.value
                            remoteUser.remark.value = imUserInfo.remark.value
                            remoteUser.avatar.value = imUserInfo.avatar.value
                        }
                    }
                }
                if CallManager.shared.userState.selfUser.callStatus.value != .none {
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: EVENT_SHOW_TUICALLKIT_VIEWCONTROLLER), object: nil)
                }
            }
            succ()
        } fail: { code, message in
            fail(code, message)
        }
    }
    
    func joinInGroupCall(roomId: TUIRoomId,
                         groupId: String,
                         callMediaType: TUICallMediaType,
                         succ: @escaping TUICallSucc,
                         fail: @escaping TUICallFail) {
        TUICallEngine.createInstance().joinInGroupCall(roomId: roomId, groupId: groupId, callMediaType: callMediaType) { [weak self] in
            guard let self = self else { return }
            
            CallManager.shared.viewState.callingViewType.value = .multi
            self.callState.mediaType.value = callMediaType
            self.callState.groupId = groupId
            
            self.userState.selfUser.callRole.value = TUICallRole.called
            self.userState.selfUser.callStatus.value = TUICallStatus.accept
            
            if callMediaType == .audio {
                self.mediaState.audioPlayoutDevice.value = TUIAudioPlaybackDevice.earpiece
                self.mediaState.isCameraOpened.value = false
            } else if callMediaType == .video {
                self.mediaState.audioPlayoutDevice.value = TUIAudioPlaybackDevice.speakerphone
                self.mediaState.isCameraOpened.value = true
            }
            
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: EVENT_SHOW_TUICALLKIT_VIEWCONTROLLER), object: nil)
            succ()
        } fail: { code, message in
            fail(code, message)
        }
    }
    
    func join(callId: String,
              succ: @escaping TUICallSucc,
              fail: @escaping TUICallFail) {
        TUICallEngine.createInstance().join(callId: callId) {
            CallManager.shared.callState.mediaType.value = .audio
            CallManager.shared.viewState.callingViewType.value = .multi
            CallManager.shared.userState.selfUser.callRole.value = TUICallRole.called
            CallManager.shared.userState.selfUser.callStatus.value = TUICallStatus.accept
            CallManager.shared.mediaState.audioPlayoutDevice.value = TUIAudioPlaybackDevice.earpiece
            CallManager.shared.mediaState.isCameraOpened.value = false
            
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: EVENT_SHOW_TUICALLKIT_VIEWCONTROLLER), object: nil)
            succ()
        } fail: { code, message in
            fail(code, message)
        }
    }
    
    func hangup() {
        TUICallEngine.createInstance().hangup {
        } fail: { code, message in
        }
        resetState()
    }
    
    func accept() {
        TUICallEngine.createInstance().accept {
        } fail: { code, message in
        }
    }
    
    func reject() {
        TUICallEngine.createInstance().reject {
        } fail: { code, message in
        }
        resetState()
    }
    
    func muteMic() {
        if mediaState.isMicrophoneMuted.value == true {
            TUICallEngine.createInstance().openMicrophone { [weak self] in
                guard let self = self else { return }
                mediaState.isMicrophoneMuted.value = false
                self.voipDataSyncHandler.setVoIPMute(false)
            } fail: { code , message  in
            }
        } else {
            TUICallEngine.createInstance().closeMicrophone()
            mediaState.isMicrophoneMuted.value = true
            voipDataSyncHandler.setVoIPMute(true)
        }
    }
    
    func openMicrophone(_ notifyEvent: Bool = true) {
        if userState.selfUser.callStatus.value != .none {
            TUICallEngine.createInstance().openMicrophone { [weak self] in
                guard let self = self else { return }
                mediaState.isMicrophoneMuted.value = false
                if (notifyEvent) {
                    self.voipDataSyncHandler.setVoIPMute(false)
                }
            } fail: { code , message  in
            }
        }
    }
    
    func closeMicrophone(_ notifyEvent: Bool = true) {
        TUICallEngine.createInstance().closeMicrophone()
        mediaState.isMicrophoneMuted.value = true
        if (notifyEvent) {
            voipDataSyncHandler.setVoIPMute(true)
        }
    }
    
    func changeSpeaker() {
        if mediaState.audioPlayoutDevice.value == TUIAudioPlaybackDevice.speakerphone {
            selectAudioPlaybackDevice(device: .earpiece)
        } else {
            selectAudioPlaybackDevice(device: .speakerphone)
        }
    }
    
    func selectAudioPlaybackDevice(device: TUIAudioPlaybackDevice) {
        TUICallEngine.createInstance().selectAudioPlaybackDevice(device)
        mediaState.audioPlayoutDevice.value = device
    }
    
    func switchCamera() {
        if mediaState.isFrontCamera.value == true {
            TUICallEngine.createInstance().switchCamera(.back)
            mediaState.isFrontCamera.value = false
        } else {
            TUICallEngine.createInstance().switchCamera(.front)
            mediaState.isFrontCamera.value = true
        }
    }
    
    func closeCamera() {
        TUICallEngine.createInstance().closeCamera()
        mediaState.isCameraOpened.value = false
        userState.selfUser.videoAvailable.value = false
    }
    
    func openCamera(videoView: UIView) {
        TUICallEngine.createInstance().openCamera(mediaState.isFrontCamera.value == true ? .front : .back, videoView: videoView) { [weak self] in
            guard let self = self else { return }
            self.mediaState.isCameraOpened.value = true
            self.userState.selfUser.videoAvailable.value = true
        } fail: { code, message in
        }
    }
    
    func startRemoteView(user: User, videoView: UIView){
        TUICallEngine.createInstance().startRemoteView(userId: user.id.value, videoView: videoView) { userId in
        } onLoading: { userId in
        } onError: { userId, code, message in
        }
    }
    
    func stopRemoteView(user: User) {
        TUICallEngine.createInstance().stopRemoteView(userId: user.id.value)
    }
    
    func setAudioPlaybackDevice(device: TUIAudioPlaybackDevice) {
        TUICallEngine.createInstance().selectAudioPlaybackDevice(device)
    }
    
    func switchToAudio() {
        TUICallEngine.createInstance().switchCallMediaType(.audio)
    }
    
    func inviteUser(userIds: [String]) {
        let callParams = TUICallParams()
        callParams.offlinePushInfo = OfflinePushInfoConfig.createOfflinePushInfo()
        callParams.timeout = TUI_CALLKIT_SIGNALING_MAX_TIME
        
        TUICallEngine.createInstance().inviteUser(userIdList: userIds, params: callParams) { userIds in
            UserManager.getUserInfosFromIM(userIDs: userIds) { [weak self] newRemoteUsers in
                guard let self = self else { return }
                for newUser in newRemoteUsers {
                    newUser.callStatus.value = TUICallStatus.waiting
                    newUser.callRole.value = TUICallRole.called
                    self.userState.remoteUserList.value.append(newUser)
                }
            }
        } fail: { code, message in
        }
    }
    
    func addObserver(_ observer: TUICallObserver) {
        TUICallEngine.createInstance().addObserver(observer)
    }
    
    func removeObserver(_ observer: TUICallObserver) {
        TUICallEngine.createInstance().removeObserver(observer)
    }
    
    func initEngine(sdkAppId: Int32, userId: String, userSig: String, succ: @escaping TUICallSucc, fail: @escaping TUICallFail) {
        TUICallEngine.createInstance().`init`(sdkAppId, userId: userId, userSig: userSig) { [weak self] in
            guard let self = self else { return }
            
            let videoEncoderParams = TUIVideoEncoderParams()
            videoEncoderParams.resolution = ._1280_720
            videoEncoderParams.resolutionMode = .portrait
            CallManager.shared.setVideoEncoderParams(params: videoEncoderParams)  {} fail: { Int32errCode, errMessage in }
            
            let videoRenderParams = TUIVideoRenderParams()
            videoRenderParams.fillMode = .fill
            videoRenderParams.rotation = ._0
            CallManager.shared.setVideoRenderParams(userId: TUILogin.getUserID() ?? "",
                                                            params: videoRenderParams) {} fail: { Int32errCode, errMessage in }
            let beauty = CallManager.shared.getTRTCCloudInstance().getBeautyManager()
            beauty.setBeautyStyle(.nature)
            beauty.setBeautyLevel(6.0)
            
            self.callingVibratorFeature = self.callingVibratorFeature ?? CallingVibratorFeature()
            self.callingBellFeature = self.callingBellFeature ?? CallingBellFeature()

            succ()
        } fail: { code, message in
            fail(code, message)
        }
    }
    
    func enableMuteMode(enable: Bool) {
        UserDefaults.standard.set(enable, forKey: ENABLE_MUTEMODE_USERDEFAULT)
    }
    
    func enableFloatWindow(enable: Bool) {
        CallManager.shared.globalState.enableFloatWindow = enable
    }
        
    func enableVirtualBackground (enable: Bool) {
        CallManager.shared.globalState.enableVirtualBackgroud = enable
        CallManager.shared.reportOnlineLog(enable)
    }
    
    func enableIncomingBanner (enable: Bool) {
        CallManager.shared.globalState.enableIncomingbanner = enable
    }
    
    func setVideoEncoderParams(params: TUIVideoEncoderParams, succ: @escaping TUICallSucc, fail: @escaping TUICallFail) {
        TUICallEngine.createInstance().setVideoEncoderParams(params) {
            succ()
        } fail: { code, message in
            fail(code, message)
        }
    }
    
    func setVideoRenderParams(userId: String, params: TUIVideoRenderParams, succ: @escaping TUICallSucc, fail: @escaping TUICallFail) {
        TUICallEngine.createInstance().setVideoRenderParams(userId: userId, params: params) {
            succ()
        } fail: { code, message in
            fail(code, message)
        }
    }
    
    func getTRTCCloudInstance() -> TRTCCloud {
        return TUICallEngine.createInstance().getTRTCCloudInstance()
    }
    
    func setFramework() {
        var jsonParams: [String: Any]
        if TUICore.getService(TUICore_TUIChatService) == nil {
            jsonParams = ["api": "setFramework",
                          "params": ["component": 14,
                                     "language": 3,],]
        } else {
            jsonParams = ["api": "setFramework",
                          "params": ["component": 15,
                                     "language": 3,],]
        }
        
        guard let data = try? JSONSerialization.data(withJSONObject: jsonParams,
                                                     options: JSONSerialization.WritingOptions(rawValue: 0)) else {
            return
        }
        guard let paramsString = NSString(data: data, encoding: String.Encoding.utf8.rawValue) as? String else {
            return
        }
        
        TUICallEngine.createInstance().callExperimentalAPI(jsonObject: paramsString)
    }
    
    func setExcludeFromHistoryMessage() {
        if TUICore.getService(TUICore_TUIChatService) == nil {
            return
        }
        
        let jsonParams: [String: Any] = ["api": "setExcludeFromHistoryMessage",
                                         "params": ["excludeFromHistoryMessage": false,],]
        guard let data = try? JSONSerialization.data(withJSONObject: jsonParams,
                                                     options: JSONSerialization.WritingOptions(rawValue: 0)) else {
            return
        }
        guard let paramsString = NSString(data: data, encoding: String.Encoding.utf8.rawValue) as? String else {
            return
        }
        
        TUICallEngine.createInstance().callExperimentalAPI(jsonObject: paramsString)
    }
    
    func setBlurBackground() {
        let currentEnable = viewState.isVirtualBackgroundOpened.value
        let level = !currentEnable ? 3 : 0
        viewState.isVirtualBackgroundOpened.value = !currentEnable
        TUICallEngine.createInstance().setBlurBackground(level) { code, message in
        }
    }
    
    func reportOnlineLog(_ enableVirtualBackground: Bool) {
        let msgDic: [String: Any] = ["enablevirtualbackground": enableVirtualBackground,
                                     "version": TUICALL_VERSION,
                                     "platform": "iOS",
                                     "framework": "native",
                                     "sdk_app_id": TUILogin.getSdkAppID(),]
        guard let msgData = try? JSONSerialization.data(withJSONObject: msgDic,
                                                        options: JSONSerialization.WritingOptions(rawValue: 0)) else {
            return
        }
        guard let msgString = NSString(data: msgData, encoding: String.Encoding.utf8.rawValue) as? String else {
            return
        }
        let jsonParams: [String: Any] = ["api": "reportOnlineLog",
                                         "params": ["level": 1,
                                                    "msg":msgDic,
                                                    "more_msg":"TUICallkit"],]
        guard let data = try? JSONSerialization.data(withJSONObject: jsonParams,
                                                     options: JSONSerialization.WritingOptions(rawValue: 0)) else {
            return
        }
        guard let paramsString = NSString(data: data, encoding: String.Encoding.utf8.rawValue) as? String else {
            return
        }
        TUICallEngine.createInstance().getTRTCCloudInstance().callExperimentalAPI(paramsString)
    }
    
    func closeVoIP() {
        voipDataSyncHandler.closeVoIP()
    }
    
    func callBegin() {
        voipDataSyncHandler.callBegin()
    }
    
    func updateVoIPInfo(callerId: String, calleeList: [String], groupId: String, mediaType: TUICallMediaType) {
        voipDataSyncHandler.updateVoIPInfo(callerId: callerId, calleeList: calleeList, groupId: groupId, mediaType: mediaType)
    }
    
    func destroyInstance() {
        TUICallEngine.destroyInstance()
    }
    
    func initSelfUser() {
        UserManager.getSelfUserInfo(response: { selfUser in
            CallManager.shared.userState.selfUser.id.value = selfUser.id.value
            CallManager.shared.userState.selfUser.nickname.value = selfUser.nickname.value
            CallManager.shared.userState.selfUser.avatar.value = selfUser.avatar.value
        })
    }
        
    func showIMErrorMessage(code: Int32, message: String?) {
        let errorMessage = TUITool.convertIMError(Int(code), msg: convertCallKitError(code: code, message: message))
        Toast.showToast(errorMessage ?? "")
    }
        
    private func convertCallKitError(code: Int32, message: String?) -> String {
        var errorMessage: String? = message
        if code == ERROR_PACKAGE_NOT_PURCHASED {
            errorMessage = TUICallKitLocalize(key: "TUICallKit.purchased")
        } else if code == ERROR_PACKAGE_NOT_SUPPORTED {
            errorMessage = TUICallKitLocalize(key: "TUICallKit.support")
        } else if code == ERR_SVR_MSG_IN_PEER_BLACKLIST.rawValue {
            errorMessage = TUICallKitLocalize(key: "TUICallKit.ErrorInPeerBlacklist")
        } else if code == ERROR_INIT_FAIL {
            errorMessage = TUICallKitLocalize(key: "TUICallKit.ErrorInvalidLogin")
        } else if code == ERROR_PARAM_INVALID {
            errorMessage = TUICallKitLocalize(key: "TUICallKit.ErrorParameterInvalid")
        } else if code == ERROR_REQUEST_REFUSED {
            errorMessage = TUICallKitLocalize(key: "TUICallKit.ErrorRequestRefused")
        } else if code == ERROR_REQUEST_REPEATED {
            errorMessage = TUICallKitLocalize(key: "TUICallKit.ErrorRequestRepeated")
        } else if code == ERROR_SCENE_NOT_SUPPORTED {
            errorMessage = TUICallKitLocalize(key: "TUICallKit.ErrorSceneNotSupport")
        }
        return errorMessage ?? ""
    }
}
