//
//  CallingVibrator.swift
//  Pods
//
//  Created by vincepzhang on 2024/10/15.
//

import AudioToolbox

class CallingVibrator {

    private static var isVibrating = false;

    static func startVibration() {
        isVibrating = true
        DispatchQueue.global().async {
            while isVibrating {
                AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
                Thread.sleep(forTimeInterval: 1)
            }
        }
    }

    static func stopVirbration() {
        isVibrating = false;
    }
}

