//
//  NotificationService.swift
//  APNsExtension
//
//  Created by vincepzhang on 2025/3/12.
//

import UserNotifications

class NotificationService: UNNotificationServiceExtension {

    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?

    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
                
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        if let bestAttemptContent = bestAttemptContent {
            
            registerObserver()
            RingingFeature.shared.start()
                        
            ///Create a local push to display the push content.
            ///If contentHandler is called, the Extension lifecycle will end prematurely, and long-term ringing and vibration will not be possible.
            sendLocalNotification(identifier: request.identifier, body: bestAttemptContent.body)
//            bestAttemptContent.title = "\(bestAttemptContent.title) [modified]"
//            contentHandler(bestAttemptContent)
        }
    }
    
    override func serviceExtensionTimeWillExpire() {
        if let contentHandler = contentHandler, let bestAttemptContent =  bestAttemptContent {
            
            /// If there is no response for more than 30 seconds, the vibration and ringing function will be turned off.
            RingingFeature.shared.stop()
            
            contentHandler(bestAttemptContent)
        }
    }
    
    private func sendLocalNotification(identifier: String, body: String?) {
        let content = UNMutableNotificationContent()
        content.body = body ?? ""
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request)
    }
    
    func registerObserver() {
        CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(),
                                        Unmanaged.passUnretained(self).toOpaque(), { center, pointer, name, _, userInfo in
            RingingFeature.shared.stop()
        }, "APNsStopRinging" as CFString, nil, .deliverImmediately)
    }
}
