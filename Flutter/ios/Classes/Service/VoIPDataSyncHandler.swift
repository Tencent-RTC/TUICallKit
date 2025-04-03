//
//  VoIPDataSyncHandler.swift
//  Pods
//
//  Created by vincepzhang on 2024/11/25.
//

import Foundation
import TUICore
import RTCRoomEngine
import UIKit
import AVFoundation

protocol VoIPDataSyncHandlerDelegate: NSObject {
    func callMethodVoipChangeMute(mute: Bool)
    func callMethodVoipChangeAudioPlaybackDevice(audioPlaybackDevice: TUIAudioPlaybackDevice)
    func callMethodVoipHangup()
    func callMethodVoipAccept()
}

class VoIPDataSyncHandler: NSObject,TUICallObserver {
    weak var voipDataSyncHandlerDelegate: VoIPDataSyncHandlerDelegate?
    
    override init() {
        super.init()
        TUICallEngine.createInstance().addObserver(self)
    }

    func onCall(_ method: String, param: [AnyHashable : Any]) {
        if method == TUICore_TUICallingService_SetAudioPlaybackDeviceMethod {
            guard let audioPlaybackDevice = param[TUICore_TUICallingService_SetAudioPlaybackDevice_AudioPlaybackDevice]
                    as? TUIAudioPlaybackDevice else { return }
            if self.voipDataSyncHandlerDelegate != nil && ((self.voipDataSyncHandlerDelegate?.responds(to: Selector(("callMethodVoipChangeAudioPlaybackDevice")))) != nil) {
                self.voipDataSyncHandlerDelegate?.callMethodVoipChangeAudioPlaybackDevice(audioPlaybackDevice: audioPlaybackDevice)
            }
        } else if method == TUICore_TUICallingService_SetIsMicMuteMethod {
            guard let isMicMute = param[TUICore_TUICallingService_SetIsMicMuteMethod_IsMicMute]
                    as? Bool else { return }
            if self.voipDataSyncHandlerDelegate != nil && ((self.voipDataSyncHandlerDelegate?.responds(to: Selector(("callMethodVoipChangeMute")))) != nil) {
                self.voipDataSyncHandlerDelegate?.callMethodVoipChangeMute(mute: isMicMute)
            }
        }
        
        else if method == TUICore_TUICallingService_HangupMethod {
            if self.voipDataSyncHandlerDelegate != nil && ((self.voipDataSyncHandlerDelegate?.responds(to: Selector(("callMethodVoipHangup")))) != nil) {
                self.voipDataSyncHandlerDelegate?.callMethodVoipHangup()
            }
        } else if method == TUICore_TUICallingService_AcceptMethod {
            if self.voipDataSyncHandlerDelegate != nil && ((self.voipDataSyncHandlerDelegate?.responds(to: Selector(("callMethodVoipAccept")))) != nil) {
                self.voipDataSyncHandlerDelegate?.callMethodVoipAccept()
            }
        }
    }
    
    func setVoIPMuteForTUICallKitVoIPExtension(_ mute: Bool) {
        TUICore.notifyEvent(TUICore_TUICallKitVoIPExtensionNotify,
                            subKey: mute ? TUICore_TUICore_TUICallKitVoIPExtensionNotify_CloseMicrophoneSubKey :
                                TUICore_TUICore_TUICallKitVoIPExtensionNotify_OpenMicrophoneSubKey,
                            object: nil,
                            param: nil)
    }
    
    func setVoIPMute(_ mute: Bool) {
        TUICore.notifyEvent(TUICore_TUIVoIPExtensionNotify,
                            subKey: TUICore_TUICore_TUIVoIPExtensionNotify_MuteSubKey,
                            object: nil,
                            param: [TUICore_TUICore_TUIVoIPExtensionNotify_MuteSubKey_IsMuteKey: mute])
    }
    
    func closeVoIP() {
        TUICore.notifyEvent(TUICore_TUIVoIPExtensionNotify,
                            subKey: TUICore_TUICore_TUIVoIPExtensionNotify_EndSubKey,
                            object: nil,
                            param: nil)
    }
    
    func connectVoIP() {
        TUICore.notifyEvent(TUICore_TUIVoIPExtensionNotify,
                            subKey: TUICore_TUICore_TUIVoIPExtensionNotify_ConnectedKey,
                            object: nil,
                            param: nil)
    }
    
    func updateVoIPInfo(callerId: String, calleeList: [String], groupId: String, mediaType: TUICallMediaType) {
        TUICore.notifyEvent(TUICore_TUIVoIPExtensionNotify,
                            subKey: TUICore_TUICore_TUIVoIPExtensionNotify_UpdateInfoSubKey,
                            object: nil,
                            param: [TUICore_TUICore_TUIVoIPExtensionNotify_UpdateInfoSubKey_InviterIdKey: callerId,
                                  TUICore_TUICore_TUIVoIPExtensionNotify_UpdateInfoSubKey_InviteeListKey: calleeList,
                                      TUICore_TUICore_TUIVoIPExtensionNotify_UpdateInfoSubKey_GroupIDKey: groupId,
                                    TUICore_TUICore_TUIVoIPExtensionNotify_UpdateInfoSubKey_MediaTypeKey: mediaType.rawValue])
    }
    
//     MARK: TUIObserver
    func onCallReceived(callerId: String, calleeIdList: [String], groupId: String?, callMediaType: TUICallMediaType, userData: String?) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let self = self else { return }
            self.updateVoIPInfo(callerId: callerId, calleeList: calleeIdList, groupId: groupId ?? "", mediaType: callMediaType)
        }
    }
    
    func onCallCancelled(callerId: String) {
        closeVoIP()
    }
    
    func onCallEnd(roomId: TUIRoomId, callMediaType: TUICallMediaType, callRole: TUICallRole, totalTime: Float) {
        closeVoIP()
    }
    
    func onCallBegin(roomId: TUIRoomId, callMediaType: TUICallMediaType, callRole: TUICallRole) {
        connectVoIP()
    }
}
