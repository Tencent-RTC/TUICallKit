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

/// 若使用 TUICallKit_Swift,  需要设置预编译宏， 设置方法如下：
///   1. 选中 target ---> Build Settings ---> 搜索 Swift Compiler - Custom Flags
///   2. 展开 “Other Swift Flags” 设置 “USE_TUICALLKIT_SWIFT”，需要这样写：“-D” 、“TEST”，填完后是 “-D” 和 “USE_TUICALLKIT_SWIFT” 分成两行的，
#if USE_TUICALLKIT_SWIFT
import TUICallKit_Swift
#else
import TUICallKit
#endif

/// 若使用 TXLiteAVSDK_Professional,  需要设置预编译宏， 设置方法如下：
///   1. 选中 target ---> Build Settings ---> 搜索 Swift Compiler - Custom Flags
///   2. 展开 “Other Swift Flags” 设置 “USE_PRODESSIONAL”，需要这样写：“-D” 、“TEST”，填完后是 “-D” 和 “USE_PRODESSIONAL” 分成两行的，
#if USE_PRODESSIONAL
import TXLiteAVSDK_Professional
#else
import TXLiteAVSDK_TRTC
#endif

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    let LICENCEURL = ""
    let LICENCEKEY = ""
    
    func setLicence() {
        TXLiveBase.setLicenceURL(LICENCEURL, key: LICENCEKEY)
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        registerRemoteNotifications(with: application)
        
        // 监听推送
        V2TIMManager.sharedInstance().setAPNSListener(self)
        // 监听会话的未读数
        V2TIMManager.sharedInstance().addConversationListener(listener: self)
        // 设置 SDK 的 Licence 下载 url 和 key
        setLicence()
        
        return true
    }
    
    // MARK: UISceneSession Lifecycle
    func application(_ application: UIApplication,
                     configurationForConnecting connectingSceneSession: UISceneSession,
                     options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running,
        // this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    func showMainController() {
        let mainViewController = MainViewController()
        let rootVC = UINavigationController(rootViewController: mainViewController)

        if let keyWindow = SceneDelegate.getKeyWindow() {
            keyWindow.rootViewController = rootVC
            keyWindow.makeKeyAndVisible()
        } else {
            debugPrint("window show MainViewController error")
        }
    }
    
    func showLoginViewController() {
        let loginVC = LoginViewController()
        let nav = UINavigationController(rootViewController: loginVC)
        
        if let keyWindow = SceneDelegate.getKeyWindow() {
            keyWindow.rootViewController = nav
            keyWindow.makeKeyAndVisible()
        } else {
            debugPrint("window show LoginViewController error")
        }
    }
    
    // MARK: - 注册远程推送 DeviceToken
    func registerRemoteNotifications(with application: UIApplication) {
        if #available(iOS 10, *) {
            let notificationCenter = UNUserNotificationCenter.current()
            notificationCenter.requestAuthorization(options: [.alert,.badge,.sound]) { (isGrand, error) in
                DispatchQueue.main.async {
                    if error == nil && isGrand {
                        print("用户允许了推送权限")
                    }else{
                        print("用户拒绝了推送权限")
                    }
                }
            }
        } else {
            UIApplication.shared.registerUserNotificationSettings(.init(types:[.alert,.badge,.sound], categories:nil))
        }
        
        // 注册远程通知，获得device Token
        UIApplication.shared.registerForRemoteNotifications()
    }
    
    // MARK: - <UIApplicationDelegate>
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("didRegisterForRemoteNotificationsWithDeviceToken success")
        AppUtils.shared.deviceToken = deviceToken
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("didFailToRegisterForRemoteNotificationsWithError-error = \(error)")
    }
    
    // MARK: 当用户点击通知时，会触发
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        completionHandler()
    }
    
    // MARK: iOS10以前的设备 registerUserNotificationSettings会触发notificationSettings
    @available(iOS, introduced: 8.0, deprecated: 11.0)
    func application(_ application: UIApplication, didRegister notificationSettings: UIUserNotificationSettings) {
        if notificationSettings.types.isEmpty {
            print("用户拒绝了推送权限")
        }else{
            print("用户允许了推送权限")
        }
    }
    
    // MARK: 适配iOS10之前的设备 didReceiveRemoteNotification 当用户点击通知时，会触发
    @available(iOS, introduced: 8.0, deprecated: 11.0)
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        if application.applicationState == .inactive {
            print("点击推送唤起APP userInfo=\(userInfo)")
        }else{
            print("前台收到推送 userInfo=\(userInfo)")
        }
    }
}

extension AppDelegate: V2TIMConversationListener {
    // 会话未读总数变更通知, 可以在此处自定义处理逻辑
    func onTotalUnreadMessageCountChanged(_ totalUnreadCount: UInt64) {
    }
}

extension AppDelegate: V2TIMAPNSListener {
    // 程序进后台后，自定义 APP 的未读数，如果不处理，APP 未读数默认为所有会话未读数之和
    func onSetAPPUnreadCount() -> UInt32 {
        return 0
    }
}
