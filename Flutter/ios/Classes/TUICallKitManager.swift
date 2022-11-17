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
            FlutterResultUtils.handleMethod(code: .paramNotFound, methodName: "callMediaType", paramKey: callMediaTypeKey, result: result)
            return 
        }
        guard let callMediaType = TUICallMediaType(rawValue: callMediaTypeInt) else { return }
        callkit.call(userId: userId, callMediaType: callMediaType)
    }

    func groupCall(call: FlutterMethodCall, result: @escaping FlutterResult){
        let groupIdKey = "groupId"
        guard let groupId = MethodUtils.getMethodParams(call: call, key: groupIdKey, resultType: String.self) else {
            FlutterResultUtils.handleMethod(code: .paramNotFound, methodName: "groupCall", paramKey: groupIdKey, result: result)
            return 
        }
        let userIdListKey = "userIdList"
        guard let userIdListString = MethodUtils.getMethodParams(call: call, key: userIdListKey, resultType: String.self) else {
            FlutterResultUtils.handleMethod(code: .paramNotFound, methodName: "groupCall", paramKey: userIdListKey, result: result)
            return 
        }
        let callMediaTypeKey = "callMediaType"
        guard let callMediaTypeInt = MethodUtils.getMethodParams(call: call, key: callMediaTypeKey, resultType: Int.self) else {
            FlutterResultUtils.handleMethod(code: .paramNotFound, methodName: "groupCall", paramKey: callMediaTypeKey, result: result)
            return 
        }
        
        var userIdList: [String]
        do{
            let userIdListData = userIdListString.data(using: String.Encoding.utf8)!
            let json : Any! = try JSONSerialization.jsonObject(with: userIdListData, options:JSONSerialization.ReadingOptions.mutableContainers)
            userIdList = json as! [String]
        } catch {
            return
        }
        
        guard let callMediaType = TUICallMediaType(rawValue: callMediaTypeInt) else { return }
        callkit.groupCall(groupId: groupId, userIdList: userIdList ,callMediaType: callMediaType)
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
