//
//  VibratorFeature.swift
//  TUICallKit-Swift
//
//  Created by iveshe on 2024/12/31.
//

import AudioToolbox

class VibratorFeature {
    static let shared = VibratorFeature()
    
    static func start() {
        VibratorFeature.shared.startVibration()
    }

    static  func stop() {
        VibratorFeature.shared.stopVibration()
    }

    // MARK: Private
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
}
