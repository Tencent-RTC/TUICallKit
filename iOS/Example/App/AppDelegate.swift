//
//  AppDelegate.swift
//  TUICallKitApp
//
//  Created by adams on 2021/5/7.
//  Copyright © 2021 Tencent. All rights reserved.
//

import UIKit
import UserNotifications
import ImSDK_Plus
import TIMPush

#if canImport(TUICallKit_Swift)
import TUICallKit_Swift
#elseif canImport(TUICallKit)
import TUICallKit
#endif

#if canImport(TXLiteAVSDK_TRTC)
import TXLiteAVSDK_TRTC
#elseif canImport(TXLiteAVSDK_Professional)
import TXLiteAVSDK_Professional
#endif

/// You need to register a developer certificate with Apple, download and generate the certificate (P12 file) in their developer accounts, and upload the generated P12 file to the Tencent certificate console.
/// The console will automatically generate a certificate ID and pass it to the `businessID` parameter.
#if DEBUG
let business_id: Int32 = 0
#else
let business_id: Int32 = 0
#endif

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        NotificationCenter.default.addObserver(self, selector: #selector(configIfLoggedIn(_:)),
                                               name: Notification.Name("TUILoginSuccessNotification"),
                                               object: nil)
        sendStopRingingToExtension()
        return true
    }
    
    @objc func configIfLoggedIn(_ notification: Notification) {
        DispatchQueue.main.async {
            TUICallKit.createInstance().enableFloatWindow(enable: SettingsConfig.share.floatWindow)
#if canImport(TUICallKit_Swift)
            TUICallKit.createInstance().enableVirtualBackground(enable: SettingsConfig.share.enableVirtualBackground)
            TUICallKit.createInstance().enableIncomingBanner(enable: SettingsConfig.share.enableIncomingBanner)
#endif
        }
    }
    
    func sendStopRingingToExtension() {
        CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(),
                                             CFNotificationName("APNsStopRinging" as CFString), nil, nil, true)
    }
}

// MARK: - Configuration Apple Push Notification Service (APNs)

extension AppDelegate: TIMPushDelegate {
    func businessID() -> Int32 {
        return business_id;
    }
    
    //    func applicationGroupID() -> String {
    //        return "";
    //    }
    //
    //    func onRemoteNotificationReceived(_ notice: String?) -> Bool {
    //
    //    }
}
