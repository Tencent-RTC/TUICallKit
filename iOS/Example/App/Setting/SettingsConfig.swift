//
//  SettingsConfig.swift
//  TUICallKitApp
//
//  Created by vincepzhang on 2023/5/10.
//

import Foundation
import TUICore
import TUICallEngine

#if canImport(TUICallKit_Swift)
import TUICallKit_Swift
#elseif canImport(TUICallKit)
import TUICallKit
#endif

public let TUI_CALL_DEFAULT_AVATAR: String = "https://imgcache.qq.com/qcloud/public/static//avatar1_100.20191230.png"
public let PURCHASE_URL = "https://cloud.tencent.com/document/product/1640/79968"
public let ACCESS_URL = "https://cloud.tencent.com/document/product/1640/81131"
public let API_URL = "https://cloud.tencent.com/document/product/1640/79996"
public let PROBLEM_URL = "https://cloud.tencent.com/document/product/1640/81148"
public let IM_GROUP_MANAGER = "https://cloud.tencent.com/document/product/269/75394#.E5.88.9B.E5.BB.BA.E7.BE.A4.E7.BB.84"

class SettingsConfig {
    
    static let share = SettingsConfig()
    
    var userId = ""
    var avatar = ""
    var name = ""
    var ringUrl = ""
    
    var mute: Bool = false
    var floatWindow: Bool = true
    var enableVirtualBackground: Bool = true
    var EnableIncomingBanner: Bool = true
    var intRoomId: UInt32 = 0
    var strRoomId: String = ""
    var timeout: Int = 30
    var userData: String = ""
    let pushInfo: TUIOfflinePushInfo = {
        let pushInfo: TUIOfflinePushInfo = TUIOfflinePushInfo()
        pushInfo.title = ""
        pushInfo.desc = ""
        // iOS push type: if you want user VoIP, please modify type to TUICallIOSOfflinePushTypeVoIP
        pushInfo.iOSPushType = .apns
        pushInfo.ignoreIOSBadge = false
        pushInfo.iOSSound = "phone_ringing.mp3"
        pushInfo.androidSound = "phone_ringing"
        // OPPO must set a ChannelID to receive push messages. This channelID needs to be the same as the console.
        pushInfo.androidOPPOChannelID = "tuikit"
        // FCM channel ID, you need change PrivateConstants.java and set "fcmPushChannelId"
        pushInfo.androidFCMChannelID = "fcm_push_channel"
        // VIVO message type: 0-push message, 1-System message(have a higher delivery rate)
        pushInfo.androidVIVOClassification = 1
        // HuaWei message type: https://developer.huawei.com/consumer/cn/doc/development/HMSCore-Guides/message-classification-0000001149358835
        pushInfo.androidHuaWeiCategory = "IM"
        return pushInfo
    }()
    var resolution: TUIVideoEncoderParamsResolution = ._960_540
    var resolutionMode: TUIVideoEncoderParamsResolutionMode = .portrait
    var rotation: TUIVideoRenderParamsRotation = ._0
    var fillMode: TUIVideoRenderParamsFillMode = .fill
    var beaurtLevel: Int = 6
}
