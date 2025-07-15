//
//  MediaState.swift
//  Pods
//
//  Created by vincepzhang on 2025/2/6.
//

import RTCCommon
import RTCRoomEngine

enum AudioPlaybackDevice: UInt {
    case speakerphone = 0
    case earpiece = 1
    case bluetooth = 2
}

class MediaState: NSObject {
    
    let isCameraOpened: Observable<Bool> = Observable(false)
    
    let isFrontCamera: Observable<Bool> = Observable(true)

    let isMicrophoneMuted: Observable<Bool> = Observable(false)
    
    let audioPlayoutDevice: Observable<AudioPlaybackDevice> = Observable(AudioPlaybackDevice.earpiece)
    
    func reset() {
        isCameraOpened.value = false
        isFrontCamera.value = true
        isMicrophoneMuted.value = false
        audioPlayoutDevice.value = .earpiece
    }
}
