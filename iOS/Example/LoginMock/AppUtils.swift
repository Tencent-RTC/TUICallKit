//
//  AppUtils.swift
//  TUICallKitApp
//
//  Created by xcoderliu on 12/24/19.
//  Copyright © 2019 xcoderliu. All rights reserved.
//
// 用于TRTC_SceneDemo

import UIKit
import TUICallKit
import ImSDK_Plus
#if DEBUG
let APNSBusiId: Int32 = 0
#else
let APNSBusiId: Int32 = 0
#endif

class AppUtils: NSObject {
    @objc static let shared = AppUtils()
    private override init() {}
    
    var deviceToken: Data? = nil
    
    @objc var appDelegate: AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
    
    // MARK: - UI
    @objc func showMainController() {
        appDelegate.showMainViewController()
    }
    
    @objc func alertUserTips(_ vc: UIViewController) {
        // 提醒用户不要用Demo App来做违法的事情
        // 外发代码不需要提示
    }
}

extension AppUtils {
    
    public class func reportAPNSDeviceToken() {
        let config = V2TIMAPNSConfig()
        config.token = AppUtils.shared.deviceToken
        config.businessID = APNSBusiId
        V2TIMManager.sharedInstance()?.setAPNS(config, succ: {
            debugPrint("setAPNS success")
        }, fail: { code, msg in
            debugPrint("setAPNS error code:\(code), error: \(msg ?? "nil")")
        })
    }
    
}
