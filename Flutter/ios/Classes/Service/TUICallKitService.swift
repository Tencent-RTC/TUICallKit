//
//  Created by vincepzhang on 2023/4/20.
//

import Foundation
import TUICore
import TUICallEngine
import UIKit

protocol TUICallKitServiceDelegate: NSObject {
    func callMethodVoipChangeMute(mute: Bool)
    func callMethodVoipChangeAudioPlaybackDevice(audioPlaybackDevice: TUIAudioPlaybackDevice)
}

class TUICallKitService: NSObject, TUIServiceProtocol {
    static let instance = TUICallKitService()
    weak var callKitServiceDelegate: TUICallKitServiceDelegate?
}

extension TUICallKitService {
    //MARK: TUIServiceProtocol
    func onCall(_ method: String, param: [AnyHashable : Any]?) -> Any? {
        guard let param = param else { return nil }
        if param.isEmpty {
            return nil
        }
        
        if method == TUICore_TUICallingService_SetAudioPlaybackDeviceMethod {
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
