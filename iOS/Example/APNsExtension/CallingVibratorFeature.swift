//
//  CallingVibrator.swift
//  TUICallKit-Swift
//
//  Created by iveshe on 2024/12/31.
//

import AudioToolbox

class RingingFeature {
    static let shared = RingingFeature()
    
    func start() {
        startVibration()
        startAudioWork()
    }

    func stop() {
        stopVibration()
        stopAudioWork()
    }

    // MARK: Private
    private var soundID: SystemSoundID = 0
    private var isVibrating = false
    private init() {}

    private func startVibration() {
        isVibrating = true
        vibrate()
    }

    private func stopVibration() {
        isVibrating = false;
    }
    
    private func vibrate() {
        guard isVibrating else { return }
        
        AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
        DispatchQueue.global().asyncAfter(deadline: .now() + 1) { [weak self] in
            guard let self = self else { return }
            self.vibrate()
        }
    }

    private func startAudioWork() {
        let audioPath = Bundle.main.path(forResource: "phone_ringing", ofType: "mp3")
        let fileUrl = URL(string: audioPath ?? "")
        AudioServicesCreateSystemSoundID(fileUrl! as CFURL, &soundID)
        AudioServicesPlayAlertSound(soundID)
        AudioServicesAddSystemSoundCompletion(soundID, nil, nil, {sound, clientData in
            AudioServicesPlayAlertSound(sound)
        }, nil)
    }

    private func stopAudioWork() {
        AudioServicesRemoveSystemSoundCompletion(soundID)
        AudioServicesDisposeSystemSoundID(soundID)
    }
}
