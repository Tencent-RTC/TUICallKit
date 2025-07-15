//
//  AudioSessionManager.swift
//  Pods
//
//  Created by vincepzhang on 2025/5/22.
//

import AVFAudio
import RTCRoomEngine

class AudioSessionManager {
    static private var isEnableiOSAvroutePickerViewMode = false
    
    static func isBluetoothHeadsetConnected() -> Bool {
        let audioSession = AVAudioSession.sharedInstance()
        do {
           let currentRoute = audioSession.currentRoute
           for output in currentRoute.outputs {
               if output.portType == .bluetoothA2DP ||
                  output.portType == .bluetoothLE ||
                  output.portType == .bluetoothHFP {
                   return true
               }
           }
           let availableInputs = try audioSession.availableInputs ?? []
           for input in availableInputs {
               if input.portType == .bluetoothA2DP ||
                  input.portType == .bluetoothLE ||
                  input.portType == .bluetoothHFP {
                   return true
               }
            }
            return false
        } catch {
            return false
        }
   }
    
    static func isBluetoothHeadsetActive() -> Bool {
        let audioSession = AVAudioSession.sharedInstance()
        let currentRoute = audioSession.currentRoute
        for output in currentRoute.outputs {
            switch output.portType {
            case .bluetoothA2DP, .bluetoothLE, .bluetoothHFP:
                return true
            default:
                continue
            }
        }
        return false
    }

    static func getCurrentOutputDeviceName() -> String? {
        let audioSession = AVAudioSession.sharedInstance()
        let currentRoute = audioSession.currentRoute
        if let currentOutput = currentRoute.outputs.first {
            return currentOutput.portName
        }
        return nil
    }
    
    static func enableiOSAvroutePickerViewMode(_ enable: Bool) {
        if isEnableiOSAvroutePickerViewMode == enable { return }
        isEnableiOSAvroutePickerViewMode = enable
        
        let jsonParams: [String: Any] = [
            "api": "setPrivateConfig",
            "params": [
                "configs": [
                    [ "key": "Liteav.Audio.ios.enable.ios.avroute.picker.view.compatible.mode",
                        "default": "0",
                        "value": enable ? "1" : "0",
                    ]
                ]
            ]
        ]
        guard let data = try? JSONSerialization.data(withJSONObject: jsonParams,
                                                     options: JSONSerialization.WritingOptions(rawValue: 0)) else {
            return
        }
        guard let paramsString = NSString(data: data, encoding: String.Encoding.utf8.rawValue) as? String else {
            return
        }
        
        if !enable {
            CallManager.shared.selectAudioPlaybackDevice(device: TUIAudioPlaybackDevice(rawValue: CallManager.shared.mediaState.audioPlayoutDevice.value.rawValue) ?? .earpiece)
        }
        TUICallEngine.createInstance().getTRTCCloudInstance().callExperimentalAPI(paramsString)
    }
    
    static func getIsEnableiOSAvroutePickerViewMode() -> Bool {
        return isEnableiOSAvroutePickerViewMode;
    }
}
