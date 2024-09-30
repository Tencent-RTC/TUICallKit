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
let businessID: Int32 = 0
#else
let businessID: Int32 = 0
#endif

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var deviceToken: Data? = nil
    var unreadNumber: UInt64 = 0
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        /// Configuration Apple Push Notification Service (APNs)
        registerRemoteNotifications(with: application)
        V2TIMManager.sharedInstance().setAPNSListener(self)
        V2TIMManager.sharedInstance().addConversationListener(listener: self)
        
        NotificationCenter.default.addObserver(self, selector: #selector(registerIfLoggedIn(_:)),
                                               name: Notification.Name("TUILoginSuccessNotification"),
                                               object: nil)
        
        return true
    }
    
}

// MARK: - Configuration Apple Push Notification Service (APNs)

extension AppDelegate: V2TIMConversationListener, V2TIMAPNSListener {
    
    // Register Remote Notifications
    func registerRemoteNotifications(with application: UIApplication) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert,.badge,.sound]) { (isGrand, error) in
            if let error = error {
                debugPrint("Error requesting authorization for remote notifications: \(error.localizedDescription)")
            } else {
                DispatchQueue.main.async {
                    application.registerForRemoteNotifications()
                }
            }
        }
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("Register device token success")
        self.deviceToken = deviceToken
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        debugPrint("Failed to register for remote notifications: \(error.localizedDescription)")
    }
    
    @objc func registerIfLoggedIn(_ notification: Notification) {
        DispatchQueue.main.async {
            TUICallKit.createInstance().enableFloatWindow(enable: SettingsConfig.share.floatWindow)
#if canImport(TUICallKit_Swift)
            TUICallKit.createInstance().enableVirtualBackground(enable: SettingsConfig.share.enableVirtualBackground)
            TUICallKit.createInstance().enableIncomingBanner(enable: SettingsConfig.share.enableIncomingBanner)
#endif
        }
        
        let config = V2TIMAPNSConfig()
        config.token = deviceToken
        config.businessID = businessID
        V2TIMManager.sharedInstance()?.setAPNS(config, succ: {
            debugPrint("setAPNS success")
        }, fail: { code, msg in
            debugPrint("setAPNS error code:\(code), error: \(msg ?? "nil")")
        })
    }
    
    // When the unread message count changes, save the new unread message count
    func onTotalUnreadMessageCountChanged(_ totalUnreadCount: UInt64) {
        unreadNumber = totalUnreadCount;
    }
    
    // The app goes to the background and reports the custom unread message count
    func onSetAPPUnreadCount() -> UInt32 {
        // 1. Get the custom badge number
        var customBadgeNumber : UInt64 = 0
        // 2. Add the unread message count of IM
        customBadgeNumber += unreadNumber;
        // 3. Use the IM SDK to report to the IM server
        return UInt32(customBadgeNumber);
    }
    
}
