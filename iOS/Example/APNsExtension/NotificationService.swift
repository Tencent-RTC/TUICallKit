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
                   contentHandler(bestAttemptContent)
        }

        registerObserver()
        VibratorFeature.start()
    }
        
    override func serviceExtensionTimeWillExpire() {
        if let contentHandler = contentHandler, let bestAttemptContent =  bestAttemptContent {
            VibratorFeature.stop()
            contentHandler(bestAttemptContent)
        }
    }
    
    func registerObserver() {
        CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(),
                                        Unmanaged.passUnretained(self).toOpaque(), { center, pointer, name, _, userInfo in
            VibratorFeature.stop()
        }, "APNsStopRinging" as CFString, nil, .deliverImmediately)
    }
}
