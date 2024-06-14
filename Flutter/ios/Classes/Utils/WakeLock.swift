//
//  WakeLock.swift
//  tencent_calls_uikit
//
//  Created by vincepzhang on 2024/5/17.
//

import Foundation
import UIKit

class WakeLock {
    
    private static let instance = WakeLock()
    
    private init() {}
    
    static func shareInstance() -> WakeLock {
        return instance
    }
    
    private var isEnable = false
    private var isIdleTimerDisabled = false
    
    func enable() {
        if isEnable { return }
        isEnable = true
        isIdleTimerDisabled = UIApplication.shared.isIdleTimerDisabled
        
        if !isIdleTimerDisabled {
            UIApplication.shared.isIdleTimerDisabled = true
        }
    }

    func disable() {
        if !isEnable { return }
        isEnable = false
        if !isIdleTimerDisabled {
            UIApplication.shared.isIdleTimerDisabled = false
        }
    }
}
