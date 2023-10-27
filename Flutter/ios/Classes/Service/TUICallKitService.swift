//
//  Created by vincepzhang on 2023/4/20.
//

import Foundation
import TUICore
import TUICallEngine
import UIKit

protocol TUICallKitServiceDelegate: NSObject {
    func callMethodHandleLoginSuccess(sdkAppID: Int, userId: String, userSig: String)
    func callMethodHandleLogoutSuccess()
    func callMethodCall(userId: String, callMediaType: TUICallMediaType)
    func callMethodGroupCall(groupId: String, userIdList: [String], callMediaType: TUICallMediaType)
    func callMethodEnabelFloatWindow(enable: Bool)
    func callMethodVoipChangeMute(mute: Bool)
    func callMethodVoipChangeAudioPlaybackDevice(audioPlaybackDevice: TUIAudioPlaybackDevice)
}


class TUICallKitService: NSObject, TUIServiceProtocol {
    static let instance = TUICallKitService()
    
    weak var callKitServiceDelegate: TUICallKitServiceDelegate?

    override init() {
        super.init()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(loginSuccessNotification),
                                               name: NSNotification.Name.TUILoginSuccess,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(logoutSuccessNotification),
                                               name: NSNotification.Name.TUILogoutSuccess,
                                               object: nil)
    }
    
    @objc func loginSuccessNotification(noti: Notification) {
        let sdkAppId = Int(TUILogin.getSdkAppID())
        guard let userId = TUILogin.getUserID() else { return }
        guard let userSig = TUILogin.getUserSig() else { return }
        if self.callKitServiceDelegate != nil && ((self.callKitServiceDelegate?.responds(to: Selector(("callMethodHandleLoginSuccess")))) != nil) {
            self.callKitServiceDelegate?.callMethodHandleLoginSuccess(sdkAppID: sdkAppId, userId: userId, userSig: userSig)
        }
        setExcludeFromHistoryMessage()
    }
    
    @objc func logoutSuccessNotification(noti: Notification) {
        if self.callKitServiceDelegate != nil && ((self.callKitServiceDelegate?.responds(to: Selector(("callMethodHandleLogoutSuccess")))) != nil) {
            self.callKitServiceDelegate?.callMethodHandleLogoutSuccess()
        }
    }
    
    func setExcludeFromHistoryMessage() {
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

    func startCall(groupID: String, userIDs: [String], callingType: TUICallMediaType) {
        let selector = NSSelectorFromString("setOnlineUserOnly")
        if TUICallEngine.createInstance().responds(to: selector) {
            TUICallEngine.createInstance().perform(selector, with: 0)
        }
        
        if groupID.isEmpty {
            guard let userID = userIDs.first else { return }
            if self.callKitServiceDelegate != nil && ((self.callKitServiceDelegate?.responds(to: Selector(("callMethodCall")))) != nil) {
                self.callKitServiceDelegate?.callMethodCall(userId: userID, callMediaType: callingType)
            }
        } else {
            if self.callKitServiceDelegate != nil && ((self.callKitServiceDelegate?.responds(to: Selector(("callMethodGroupCall")))) != nil) {
                self.callKitServiceDelegate?.callMethodGroupCall(groupId: groupID, userIdList: userIDs, callMediaType: callingType)
            }
        }
    }
}

extension TUICallKitService {
    //MARK: TUIServiceProtocol
    func onCall(_ method: String, param: [AnyHashable : Any]?) -> Any? {
        guard let param = param else { return nil }
        if param.isEmpty {
            return nil
        }
        
        if method == TUICore_TUICallingService_EnableFloatWindowMethod {
            let key = TUICore_TUICallingService_EnableFloatWindowMethod_EnableFloatWindow
            guard let enableFloatWindow = param[key] as? Bool else { return nil }
            if self.callKitServiceDelegate != nil && ((self.callKitServiceDelegate?.responds(to: Selector(("callMethodEnabelFloatWindow")))) != nil) {
                self.callKitServiceDelegate?.callMethodEnabelFloatWindow(enable: enableFloatWindow)
            }
        } else if method == TUICore_TUICallingService_ShowCallingViewMethod {
            guard let userIDs = param[TUICore_TUICallingService_ShowCallingViewMethod_UserIDsKey] as? [ String] else { return nil }
            guard let mediaTypeIndex = param[TUICore_TUICallingService_ShowCallingViewMethod_CallTypeKey] as? Int else { return nil }
            var mediaType: TUICallMediaType = .unknown
            if mediaTypeIndex == 0 {
                mediaType = .audio
            } else if mediaTypeIndex == 1 {
                mediaType = .video
            }
            
            var groupId = ""
            if let groupIdTemp = param[TUICore_TUICallingService_ShowCallingViewMethod_GroupIDKey] as? String {
                groupId = groupIdTemp
            }
            
            startCall(groupID: groupId, userIDs: userIDs, callingType: mediaType)
            
        } else if method == TUICore_TUICallingService_ReceivePushCallingMethod {
            guard let signalingInfo = param[TUICore_TUICallingService_ShowCallingViewMethod_SignalingInfo] as? V2TIMSignalingInfo else { return nil }
            let groupID = signalingInfo.groupID
            
            var selector = NSSelectorFromString("onReceiveGroupCallAPNs")
            
            if TUICallEngine.createInstance().responds(to: selector) {
                TUICallEngine.createInstance().perform(selector, with: signalingInfo)
            }
            
        } else if method == TUICore_TUICallingService_EnableMultiDeviceAbilityMethod {
            guard let enableMultiDeviceAbility = param[TUICore_TUICallingService_EnableMultiDeviceAbilityMethod_EnableMultiDeviceAbility]
                    as? Bool else { return nil }
            
            TUICallEngine.createInstance().enableMultiDeviceAbility(enable: enableMultiDeviceAbility) {
                
            } fail: { code, message in
                
            }
        } else if method == TUICore_TUICallingService_SetAudioPlaybackDeviceMethod {
            guard let audioPlaybackDevice = param[TUICore_TUICallingService_SetAudioPlaybackDevice_AudioPlaybackDevice]
                    as? TUIAudioPlaybackDevice else { return nil }
            if self.callKitServiceDelegate != nil && ((self.callKitServiceDelegate?.responds(to: Selector(("callMethodVoipChangeAudioPlaybackDevice")))) != nil) {
                self.callKitServiceDelegate?.callMethodVoipChangeAudioPlaybackDevice(audioPlaybackDevice: audioPlaybackDevice)
            }
        } else if method == TUICore_TUICallingService_SetIsMicMuteMethod {
            guard let isMicMute = param[TUICore_TUICallingService_SetIsMicMuteMethod_IsMicMute]
                    as? Bool else { return nil }
            if self.callKitServiceDelegate != nil && ((self.callKitServiceDelegate?.responds(to: Selector(("callMethodVoipChangeMute")))) != nil) {
                self.callKitServiceDelegate?.callMethodVoipChangeMute(mute: !isMicMute)
            }
        }
        return nil
    }
}
