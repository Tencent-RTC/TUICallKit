//
//  TUICallKitManager.swift
//  tuicall_kit
//
//  Created by aby on 2022/11/1.
//
// Copyright (c) 2021 Tencent. All rights reserved.
// Author: abyyxwang

import Foundation
import TUICallKit
import Flutter
import TUICore

class TUICallKitManager {
    static let shared = TUICallKitManager.init()
    private init() {}
    
    private let callkit: TUICallKit = TUICallKit.createInstance()
    
    func setSelfInfo(call: FlutterMethodCall, result: @escaping FlutterResult) {
        let nickNameKey = "nickname"
        guard let nickName = MethodUtils.getMethodParams(call: call, key: nickNameKey, resultType: String.self) else {
            FlutterResultUtils.handleMethod(code: .paramNotFound, methodName: "setSelfInfo", paramKey: nickNameKey, result: result)
            return
        }
        let avatarKey = "avatar"
        guard let avatar = MethodUtils.getMethodParams(call: call, key: avatarKey, resultType: String.self) else {
            FlutterResultUtils.handleMethod(code: .paramNotFound ,methodName: "setSelfInfo", paramKey: avatarKey, result: result)
            return
        }
        callkit.setSelfInfo(nickname: nickName, avatar: avatar) {
            result(NSNumber(value: 0))
        } fail: { code, message in
            let error = FlutterError(code: "\(code)", message: message, details: nil)
            result(error)
        }
    }

    func call(call: FlutterMethodCall, result: @escaping FlutterResult){
        let userIdKey = "userId"
        guard let userId = MethodUtils.getMethodParams(call: call, key: userIdKey, resultType: String.self) else {
            FlutterResultUtils.handleMethod(code: .paramNotFound, methodName: "call", paramKey: userIdKey, result: result)
            return
        }
        let callMediaTypeKey = "callMediaType"
        guard let callMediaTypeInt = MethodUtils.getMethodParams(call: call, key: callMediaTypeKey, resultType: Int.self) else {
            FlutterResultUtils.handleMethod(code: .paramNotFound, methodName: "call", paramKey: callMediaTypeKey, result: result)
            return
        }
        guard let callMediaType = TUICallMediaType(rawValue: callMediaTypeInt) else { return }
        
        let params = TUICallParams()
        let offlinePushInfo = TUIOfflinePushInfo()
        let paramsKey = "params"
        if let paramsDic = MethodUtils.getMethodParams(call: call, key: paramsKey, resultType: Dictionary<String, Any>.self) {
            if let offlinePushInfoDic = paramsDic["offlinePushInfo"] as?  Dictionary<String, Any> {
                if let title = offlinePushInfoDic["title"] as? String {
                    offlinePushInfo.title = title
                }
                if let desc = offlinePushInfoDic["desc"] as? String {
                    offlinePushInfo.desc = desc
                }
                if let ignoreIOSBadge = offlinePushInfoDic["ignoreIOSBadge"] as? Bool {
                    offlinePushInfo.ignoreIOSBadge = ignoreIOSBadge
                }
                if let iOSSound = offlinePushInfoDic["iOSSound"] as? String {
                    offlinePushInfo.iOSSound = iOSSound
                }
                if let androidSound = offlinePushInfoDic["androidSound"] as? String {
                    offlinePushInfo.androidSound = androidSound
                }
                if let androidOPPOChannelID = offlinePushInfoDic["androidOPPOChannelID"] as? String {
                    offlinePushInfo.androidOPPOChannelID = androidOPPOChannelID
                }
                if let androidVIVOClassification = offlinePushInfoDic["androidVIVOClassification"] as? Int {
                    offlinePushInfo.androidVIVOClassification = androidVIVOClassification
                }
                if let androidXiaoMiChannelID = offlinePushInfoDic["androidXiaoMiChannelID"] as? String {
                    offlinePushInfo.androidXiaoMiChannelID = androidXiaoMiChannelID
                }
                if let androidFCMChannelID = offlinePushInfoDic["androidFCMChannelID"] as? String {
                    offlinePushInfo.androidFCMChannelID = androidFCMChannelID
                }
                if let androidHuaWeiCategory = offlinePushInfoDic["androidHuaWeiCategory"] as? String {
                    offlinePushInfo.androidHuaWeiCategory = androidHuaWeiCategory
                }
                if let isDisablePush = offlinePushInfoDic["isDisablePush"] as? Bool {
                    offlinePushInfo.isDisablePush = isDisablePush
                }
                if let iOSPushType = offlinePushInfoDic["iOSPushType"] as? Int {
                    offlinePushInfo.iOSPushType = TUICallIOSOfflinePushType.apns
                    if iOSPushType == 1 {
                        offlinePushInfo.iOSPushType = TUICallIOSOfflinePushType.voIP
                    }
                }
                params.offlinePushInfo = offlinePushInfo
            }
            
            if let timeout =  paramsDic["timeout"] as? Int32 {
                params.timeout = timeout
            }
            
            if let userData = paramsDic["userData"] as? String {
                params.userData = userData
            }
        }
        
        callkit.call(userId: userId, callMediaType: callMediaType, params: params) {
            result(NSNumber(value: 0))
        }
    }

    func groupCall(call: FlutterMethodCall, result: @escaping FlutterResult){
        let groupIdKey = "groupId"
        guard let groupId = MethodUtils.getMethodParams(call: call, key: groupIdKey, resultType: String.self) else {
            FlutterResultUtils.handleMethod(code: .paramNotFound, methodName: "groupCall", paramKey: groupIdKey, result: result)
            return 
        }
        let userIdListKey = "userIdList"
        guard let userIdList = MethodUtils.getMethodParams(call: call, key: userIdListKey, resultType: Array<String>.self) else {
            FlutterResultUtils.handleMethod(code: .paramNotFound, methodName: "groupCall", paramKey: userIdListKey, result: result)
            return 
        }
        let callMediaTypeKey = "callMediaType"
        guard let callMediaTypeInt = MethodUtils.getMethodParams(call: call, key: callMediaTypeKey, resultType: Int.self) else {
            FlutterResultUtils.handleMethod(code: .paramNotFound, methodName: "groupCall", paramKey: callMediaTypeKey, result: result)
            return 
        }
                
        guard let callMediaType = TUICallMediaType(rawValue: callMediaTypeInt) else { return }
        
        let params = TUICallParams()
        let offlinePushInfo = TUIOfflinePushInfo()
        let paramsKey = "params"
        if let paramsDic = MethodUtils.getMethodParams(call: call, key: paramsKey, resultType: Dictionary<String, Any>.self) {
            if let offlinePushInfoDic = paramsDic["offlinePushInfo"] as? Dictionary<String, Any> {
                if let title = offlinePushInfoDic["title"] as? String {
                    offlinePushInfo.title = title
                }
                if let desc = offlinePushInfoDic["desc"] as? String {
                    offlinePushInfo.desc = desc
                }
                if let ignoreIOSBadge = offlinePushInfoDic["ignoreIOSBadge"] as? Bool {
                    offlinePushInfo.ignoreIOSBadge = ignoreIOSBadge
                }
                if let iOSSound = offlinePushInfoDic["iOSSound"] as? String {
                    offlinePushInfo.iOSSound = iOSSound
                }
                if let androidSound = offlinePushInfoDic["AndroidSound"] as? String {
                    offlinePushInfo.androidSound = androidSound
                }
                if let androidOPPOChannelID = offlinePushInfoDic["AndroidOPPOChannelID"] as? String {
                    offlinePushInfo.androidOPPOChannelID = androidOPPOChannelID
                }
                if let androidVIVOClassification = offlinePushInfoDic["AndroidVIVOClassification"] as? Int {
                    offlinePushInfo.androidVIVOClassification = androidVIVOClassification
                }
                if let iOSPushType = offlinePushInfoDic["iOSPushType"] as? Int {
                    offlinePushInfo.iOSPushType = TUICallIOSOfflinePushType.apns
                    if iOSPushType == 1 {
                        offlinePushInfo.iOSPushType = TUICallIOSOfflinePushType.voIP
                    }
                }
                params.offlinePushInfo = offlinePushInfo
            }
            
            if let timeout =  paramsDic["timeout"] as? Int32 {
                params.timeout = timeout
            }
            
            if let userData = paramsDic["userData"] as? String {
                params.userData = userData
            }
        }

        callkit.groupCall(groupId: groupId, userIdList: userIdList, callMediaType: callMediaType, params: params) {
            result(NSNumber(value: 0))
        }
    }

    func joinInGroupCall(call: FlutterMethodCall, result: @escaping FlutterResult){
        let roomIdKey = "roomId"
        guard let roomIdDictionary = MethodUtils.getMethodParams(call: call, key: roomIdKey, resultType: Dictionary<String, Any>.self) else {
            FlutterResultUtils.handleMethod(code: .paramNotFound, methodName: "joinInGroupCall", paramKey: roomIdKey, result: result)
            return 
        }
        let groupIdKey = "groupId"
        guard let groupId = MethodUtils.getMethodParams(call: call, key: groupIdKey, resultType: String.self) else {
            FlutterResultUtils.handleMethod(code: .paramNotFound, methodName: "joinInGroupCall", paramKey: groupIdKey, result: result)
            return 
        }
        let callMediaTypeKey = "callMediaType"
        guard let callMediaTypeInt = MethodUtils.getMethodParams(call: call, key: callMediaTypeKey, resultType: Int.self) else {
            FlutterResultUtils.handleMethod(code: .paramNotFound, methodName: "joinInGroupCall", paramKey: callMediaTypeKey, result: result)
            return 
        }
        guard let callMediaType = TUICallMediaType(rawValue: callMediaTypeInt) else { return }
        guard let intRoomId = roomIdDictionary["intRoomId"] as? UInt32 else { return }
        let roomId = TUIRoomId.init()
        roomId.intRoomId = intRoomId
        callkit.joinInGroupCall(roomId: roomId, groupId: groupId, callMediaType: callMediaType)
    }

    func setCallingBell(call: FlutterMethodCall, result: @escaping FlutterResult){
        let filePathKey = "filePath"
        guard let filePath = MethodUtils.getMethodParams(call: call, key: filePathKey, resultType: String.self) else {
            FlutterResultUtils.handleMethod(code: .paramNotFound, methodName: "setCallingBell", paramKey: filePathKey, result: result)
            return 
        }
        callkit.setCallingBell(filePath: filePath)
    }

    func enableMuteMode(call: FlutterMethodCall, result: @escaping FlutterResult){
        let enableKey = "enable"
        guard let enable = MethodUtils.getMethodParams(call: call, key: enableKey, resultType: Bool.self) else {
            FlutterResultUtils.handleMethod(code: .paramNotFound, methodName: "enableMuteMode", paramKey: enableKey, result: result)
            return
        }
        callkit.enableMuteMode(enable: enable)

    }

    func enableFloatWindow(call: FlutterMethodCall, result: @escaping FlutterResult){
        let enableKey = "enable"
        guard let enable = MethodUtils.getMethodParams(call: call, key: enableKey, resultType: Bool.self) else {
            FlutterResultUtils.handleMethod(code: .paramNotFound, methodName: "enableFloatWindow", paramKey: enableKey, result: result)
            return
        }
        callkit.enableFloatWindow(enable: enable)
    }
    
    func login(call: FlutterMethodCall, result: @escaping FlutterResult){
        
        guard let sdkAppId = MethodUtils.getMethodParams(call: call, key: "sdkAppId", resultType: Int32.self) else {
            FlutterResultUtils.handleMethod(code: .paramNotFound, methodName: "login", paramKey: "sdkAppId", result: result)
            return
        }
       
        guard let userId = MethodUtils.getMethodParams(call: call, key: "userId", resultType: String.self) else {
            FlutterResultUtils.handleMethod(code: .paramNotFound, methodName: "login", paramKey: "userId", result: result)
            return
        }
        
        guard let userSig = MethodUtils.getMethodParams(call: call, key: "userSig", resultType: String.self) else {
            FlutterResultUtils.handleMethod(code: .paramNotFound, methodName: "login", paramKey:  "userSig", result: result)
            return
        }

        TUILogin.login(sdkAppId, userID: userId, userSig: userSig) {
            self.setFramewofk()
            result(NSNumber(value: 0))
        } fail: { code, message in
            let error = FlutterError(code: "\(code)", message: message, details: nil)
            result(error)
        }
    }
    
    func logout(call: FlutterMethodCall, result: @escaping FlutterResult) {
        TUILogin.logout {
            result(NSNumber(value: 0))
        } fail: { code, message in
            let error = FlutterError(code: "\(code)", message: message, details: nil)
            result(error)
        }
    }
}

// MARK: 数据上报
extension TUICallKitManager {
    private func setFramewofk() {
        
        let jsonParams: [String: Any] = ["api": "setFramework",
                                         "params": ["framework": 7,
                                                    "component": 14]]
        guard let data = try? JSONSerialization.data(withJSONObject: jsonParams,
                                                     options: JSONSerialization.WritingOptions.init(rawValue: 0)) else { return }
        guard let paramsString = NSString(data: data, encoding: String.Encoding.utf8.rawValue) as? String else { return }
        TUICallEngine.createInstance().callExperimentalAPI(jsonObject: paramsString)
    }
}
