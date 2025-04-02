//
//  TUICallKitImpl.swift
//  TUICallKit
//
//  Created by vincepzhang on 2023/1/4.
//

import Foundation
import TUICore
import UIKit
import RTCRoomEngine
import RTCCommon

#if canImport(TXLiteAVSDK_TRTC)
import TXLiteAVSDK_TRTC
#elseif canImport(TXLiteAVSDK_Professional)
import TXLiteAVSDK_Professional
#endif

class TUICallKitImpl: TUICallKit {
    static let instance = TUICallKitImpl()
    private let callStatusObserver = Observer()
    
    override init() {
        super.init()
        registerNotifications()
    }
    
    deinit {
        unregisterNotifications()
    }
    
    // MARK: Implementation of external interface for TUICallKit
    override func setSelfInfo(nickname: String, avatar: String, succ: @escaping TUICallSucc, fail: @escaping TUICallFail) {
        CallManager.shared.setSelfInfo(nickname: nickname, avatar: avatar) {
            succ()
        } fail: { code, message in
            fail(code,message)
        }
    }
    
    override func call(userId: String, callMediaType: TUICallMediaType) {
        call(userId: userId, callMediaType: callMediaType, params: getCallParams()) {
            
        } fail: { errCode, errMessage in
            
        }
    }
    
    override func call(userId: String, callMediaType: TUICallMediaType, params: TUICallParams,
                       succ: @escaping TUICallSucc, fail: @escaping TUICallFail) {
        if TUILogin.getUserID() == nil {
            fail(ERROR_INIT_FAIL, "call failed, please login")
            return
        }
        
        if userId == TUILogin.getUserID() {
            Toast.showToast(TUICallKitLocalize(key: "TUICallKit.calNotCallYourself"))
            fail(ERROR_INIT_FAIL, "call failed, not to call self")
            return
        }
        
        if  userId.count <= 0 || userId == TUILogin.getUserID() {
            fail(ERROR_PARAM_INVALID, "call failed, invalid params 'userId'")
            return
        }
        
        
        if callMediaType == .unknown {
            fail(ERROR_PARAM_INVALID, "call failed, callMediaType is Unknown")
            return
        }
        
        if !Permission.hasPermissison(callMediaType: callMediaType, fail: fail) { return }

        CallManager.shared.call(userId: userId, callMediaType: callMediaType, params: params) {
            succ()
        } fail: { [weak self] code, message in
            guard let self = self else { return }
            CallManager.shared.showIMErrorMessage(code: code, message: message)
            fail(code, message)
        }
    }
    
    override func calls(userIdList: [String], callMediaType: TUICallMediaType, params: TUICallParams?,
                        succ: @escaping TUICallSucc, fail: @escaping TUICallFail) {
        if TUILogin.getUserID() == nil {
            fail(ERROR_INIT_FAIL, "call failed, please login")
            return
        }
        
        if userIdList.count == 1 && userIdList.first == TUILogin.getUserID() {
            Toast.showToast(TUICallKitLocalize(key: "TUICallKit.calNotCallYourself"))
            fail(ERROR_INIT_FAIL, "call failed, not to call self")
            return
        }
        
        let userIdList = userIdList.filter { $0 != TUILogin.getUserID() }
        
        if userIdList.isEmpty {
            fail(ERROR_PARAM_INVALID, "call failed, invalid params 'userIdList'")
            return
        }
        
        if userIdList.count >= MAX_USER {
            fail(ERROR_PARAM_INVALID, "groupCall failed, currently supports call with up to 9 people")
            Toast.showToast(TUICallKitLocalize(key: "TUICallKit.User.Exceed.Limit"))
            return
        }
                
        if callMediaType == .unknown {
            fail(ERROR_PARAM_INVALID, "call failed, callMediaType is Unknown")
            return
        }
        
        if !Permission.hasPermissison(callMediaType: callMediaType, fail: fail) { return }
        
        CallManager.shared.calls(userIdList: userIdList, callMediaType: callMediaType, params: params ?? getCallParams()) {
            succ()
        } fail: { [weak self] code, message in
            guard let self = self else { return }
            CallManager.shared.showIMErrorMessage(code: code, message: message)
            fail(code,message)
        }
    }
    
    override func groupCall(groupId: String, userIdList: [String], callMediaType: TUICallMediaType) {
        groupCall(groupId: groupId, userIdList: userIdList, callMediaType: callMediaType, params: getCallParams()) {
            
        } fail: { code, message in
            
        }
    }
    
    override func groupCall(groupId: String, userIdList: [String], callMediaType: TUICallMediaType, params: TUICallParams,
                            succ: @escaping TUICallSucc, fail: @escaping TUICallFail) {
        if TUILogin.getUserID() == nil {
            fail(ERROR_INIT_FAIL, "call failed, please login")
            return
        }
        
        let userIdList = userIdList.filter { $0 != TUILogin.getUserID() }
        
        if userIdList.isEmpty {
            fail(ERROR_PARAM_INVALID, "call failed, invalid params 'userIdList'")
            return
        }
        
        if userIdList.count >= MAX_USER {
            fail(ERROR_PARAM_INVALID, "groupCall failed, currently supports call with up to 9 people")
            Toast.showToast(TUICallKitLocalize(key: "TUICallKit.User.Exceed.Limit"))
            return
        }
                
        if callMediaType == .unknown {
            fail(ERROR_PARAM_INVALID, "call failed, callMediaType is Unknown")
            return
        }
        
        if !Permission.hasPermissison(callMediaType: callMediaType, fail: fail) { return }

        CallManager.shared.groupCall(groupId: groupId, userIdList: userIdList, callMediaType: callMediaType, params: params) {
            succ()
        } fail: { [weak self] code, message in
            guard let self = self else { return }
            CallManager.shared.showIMErrorMessage(code: code, message: message)
            fail(code,message)
        }
    }
    
    override func joinInGroupCall(roomId: TUIRoomId, groupId: String, callMediaType: TUICallMediaType) {
        if !Permission.hasPermissison(callMediaType: callMediaType, fail: nil) { return }

        CallManager.shared.joinInGroupCall(roomId: roomId, groupId: groupId, callMediaType: callMediaType) {
            
        } fail: { [weak self] code, message in
            guard let self = self else { return }
            CallManager.shared.showIMErrorMessage(code: code, message: message)
        }
    }
    
    override public func join(callId: String) {
        CallManager.shared.join(callId: callId) {
            
        } fail: { [weak self] code, message in
            guard let self = self else { return }
            CallManager.shared.showIMErrorMessage(code: code, message: message)
        }
    }
    
    override func setCallingBell(filePath: String) {
        if filePath.hasPrefix("http") {
            let session = URLSession.shared
            guard let url = URL(string: filePath) else { return }
            let downloadTask = session.downloadTask(with: url) { location, response, error in
                if error != nil {
                    return
                }
                
                if location != nil {
                    if let oldBellFilePath = UserDefaults.standard.object(forKey: TUI_CALLING_BELL_KEY) as? String {
                        do {
                            try FileManager.default.removeItem(atPath: oldBellFilePath)
                        } catch let error {
                            debugPrint("FileManager Error: \(error)")
                        }
                    }
                    guard let location = location else { return }
                    guard let dstDocPath = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).last else { return }
                    let dstPath = dstDocPath + "/" + location.lastPathComponent
                    do {
                        try FileManager.default.moveItem(at: location, to: URL(fileURLWithPath: dstPath))
                    } catch let error {
                        debugPrint("FileManager Error: \(error)")
                    }
                    UserDefaults.standard.set(dstPath, forKey: TUI_CALLING_BELL_KEY)
                    UserDefaults.standard.synchronize()
                }
            }
            downloadTask.resume()
        } else {
            UserDefaults.standard.set(filePath, forKey: TUI_CALLING_BELL_KEY)
            UserDefaults.standard.synchronize()
        }
    }
    
    override func enableMuteMode(enable: Bool) {
        CallManager.shared.enableMuteMode(enable: enable)
    }
    
    override func enableFloatWindow(enable: Bool) {
        CallManager.shared.enableFloatWindow(enable: enable)
    }
        
    override func enableVirtualBackground (enable: Bool) {
        CallManager.shared.enableVirtualBackground(enable: enable)
    }
    
    override func enableIncomingBanner (enable: Bool) {
        CallManager.shared.enableIncomingBanner(enable: enable)
    }

    // MARK: Notifications
    func registerNotifications() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(loginSuccess),
                                               name: NSNotification.Name.TUILoginSuccess,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(logoutSuccess),
                                               name: NSNotification.Name.TUILogoutSuccess,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(showCallKitViewController),
                                               name: NSNotification.Name(EVENT_SHOW_TUICALLKIT_VIEWCONTROLLER),
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(closeCallKitViewController),
                                               name: NSNotification.Name(EVENT_CLOSE_TUICALLKIT_VIEWCONTROLLER),
                                               object: nil)
        
        CallManager.shared.userState.selfUser.callStatus.addObserver(callStatusObserver) { [weak self] newValue, _ in
            guard let self = self else { return }
            if newValue == .accept && CallManager.shared.viewState.router.value == .banner {
                self.showCallKitViewController()
            }
        }
    }
    
    func unregisterNotifications() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.TUILoginSuccess, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.TUILogoutSuccess, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(EVENT_SHOW_TUICALLKIT_VIEWCONTROLLER), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(EVENT_CLOSE_TUICALLKIT_VIEWCONTROLLER), object: nil)
        CallManager.shared.userState.selfUser.callStatus.removeObserver(callStatusObserver)
    }
    
    @objc func loginSuccess() {
        CallManager.shared.initSelfUser()
        CallManager.shared.initEngine(sdkAppId:TUILogin.getSdkAppID(),
                                      userId: TUILogin.getUserID() ?? "",
                                      userSig: TUILogin.getUserSig() ?? "") {
            
        } fail: { Int32errCode, errMessage in
            
        }
        CallManager.shared.addObserver(CallEngineObserver.shared)
        CallManager.shared.setFramework()
        CallManager.shared.setExcludeFromHistoryMessage()
    }
    
    @objc func logoutSuccess() {
        CallManager.shared.hangup()
        CallManager.shared.destroyInstance()
    }
    
    @objc func showCallKitViewController() {
        if CallManager.shared.globalState.enableIncomingbanner == true && CallManager.shared.userState.selfUser.callRole.value == .called &&
            CallManager.shared.userState.selfUser.callStatus.value == .waiting {
            WindowManager.shared.showIncomingBannerWindow()
            return
        }
        WindowManager.shared.showCallingWindow()
    }
    
    @objc func closeCallKitViewController() {
        WindowManager.shared.closeWindow()
        VideoFactory.shared.removeAllVideoView()
    }
    
    // MARK: other private
    private func getCallParams() -> TUICallParams {
        let offlinePushInfo = OfflinePushInfoConfig.createOfflinePushInfo()
        let callParams = TUICallParams()
        callParams.offlinePushInfo = offlinePushInfo
        callParams.timeout = TUI_CALLKIT_SIGNALING_MAX_TIME
        return callParams
    }
}
