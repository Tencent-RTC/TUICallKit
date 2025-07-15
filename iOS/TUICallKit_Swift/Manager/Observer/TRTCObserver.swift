//
//  TRTCObserver.swift
//  Pods
//
//  Created by vincepzhang on 2025/6/3.
//

import RTCRoomEngine

#if canImport(TXLiteAVSDK_TRTC)
import TXLiteAVSDK_TRTC
#elseif canImport(TXLiteAVSDK_Professional)
import TXLiteAVSDK_Professional
#endif

class TRTCObserver: NSObject, TRTCCloudDelegate {
    func onAudioRouteChanged(_ route: TRTCAudioRoute, from fromRoute: TRTCAudioRoute) {
        guard AudioSessionManager.getIsEnableiOSAvroutePickerViewMode() || route == .modeBluetoothHeadset else { return }
        switch route {
            case .modeEarpiece:
                CallManager.shared.mediaState.audioPlayoutDevice.value = .earpiece
            case .modeSpeakerphone:
                CallManager.shared.mediaState.audioPlayoutDevice.value = .speakerphone
            case .modeBluetoothHeadset:
                CallManager.shared.mediaState.audioPlayoutDevice.value = .bluetooth
            case .modeUnknown:
                break
            case .modeWiredHeadset:
                break
            case .modeSoundCard:
                break
            @unknown default:
                break
        }
    }
        
    func onEnterRoom(_ result: Int) {
        if !AudioSessionManager.getIsEnableiOSAvroutePickerViewMode() { return }
        if CallManager.shared.userState.selfUser.callStatus.value == .none { return }
        if  CallManager.shared.callState.mediaType.value == .video {
            CallManager.shared.selectAudioPlaybackDevice(device: .speakerphone)
        }
    }
}
