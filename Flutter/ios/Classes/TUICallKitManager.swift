//
//  TUICallKitManager.swift
//  tuicall_kit
//
//  Created by aby on 2022/11/1.
//
// Copyright (c) 2021 Tencent. All rights reserved.
// Author: abyyxwang

import Foundation
import Flutter
import TUICallEngine

class TUICallKitManager {
    static let shared = TUICallKitManager.init()
    private init() {}

    func startRing(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let filePath = MethodUtils.getMethodParams(call: call, key: "filePath", resultType: String.self) else {
            FlutterResultUtils.handleMethod(code: .paramNotFound, methodName: "startRing", paramKey: "filePath", result: result)
            result(NSNumber(value: -1))
            return
        }
        
        let url = URL(fileURLWithPath: filePath)
        let _ = CallingBellPlayer.instance.playAudio(url: url)
        result(NSNumber(value: 0))
    }
    
    func stopRing(call: FlutterMethodCall, result: @escaping FlutterResult) {
        CallingBellPlayer.instance.stopPlay()
        result(NSNumber(value: 0))
    }
    
    func updateCallStateToNative(call: FlutterMethodCall, result: @escaping FlutterResult) {

        if let sceneIndex = MethodUtils.getMethodParams(call: call, key: "scene", resultType: Int.self)  {
            TUICallState.instance.scene.value = TUICallScene(rawValue: UInt(sceneIndex)) ?? .single
        }

        if let mediaTypeIndex = MethodUtils.getMethodParams(call: call, key: "mediaType", resultType: Int.self) {
            TUICallState.instance.mediaType.value = TUICallMediaType(rawValue: mediaTypeIndex) ?? .unknown
        }
        
        if let cameraIndex = MethodUtils.getMethodParams(call: call, key: "camera", resultType: UInt.self) {
            TUICallState.instance.camera.value = TUICamera(rawValue: cameraIndex) ?? TUICamera.front
        }

        if let selfUserDic = MethodUtils.getMethodParams(call: call, key: "selfUser", resultType: Dictionary<String, Any>.self) {
            setUserInfo(dic: selfUserDic, isSelfUser: true)
        }

        if let remoteUserDic = MethodUtils.getMethodParams(call: call, key: "remoteUser", resultType: Dictionary<String, Any>.self) {
            setUserInfo(dic: remoteUserDic, isSelfUser: false)
        }
        
        if let startTime = MethodUtils.getMethodParams(call: call, key: "startTime", resultType: Int.self) {
            TUICallState.instance.startTime = startTime
        }

        result(NSNumber(value: 0))
    }
    
    private func setUserInfo(dic: Dictionary<String, Any>, isSelfUser: Bool) {
        
        if let id = dic["id"] as? String {
            if isSelfUser {
                TUICallState.instance.selfUser.value.id.value = id
            } else {
                TUICallState.instance.remoteUser.value.id.value = id
            }
        }
        
        if let avatar = dic["avatar"] as? String {
            if isSelfUser {
                TUICallState.instance.selfUser.value.avatar.value = avatar
            } else {
                TUICallState.instance.remoteUser.value.avatar.value = avatar
            }
        }

        if let nickname = dic["nickname"] as? String {
            if isSelfUser {
                TUICallState.instance.selfUser.value.nickname.value = nickname
            } else {
                TUICallState.instance.remoteUser.value.nickname.value = nickname
            }
        }

        if let callRole = dic["callRole"] as? UInt {
            if isSelfUser {
                TUICallState.instance.selfUser.value.callRole.value = TUICallRole(rawValue: callRole) ?? .none
            } else {
                TUICallState.instance.remoteUser.value.callRole.value = TUICallRole(rawValue: callRole) ?? .none
            }
        }

        if let callStatus = dic["callStatus"] as? UInt {
            if isSelfUser {
                TUICallState.instance.selfUser.value.callStatus.value = TUICallStatus(rawValue: callStatus) ?? .none
            } else {
                TUICallState.instance.remoteUser.value.callStatus.value = TUICallStatus(rawValue: callStatus) ?? .none
            }
        }

        if let audioAvailable = dic["audioAvailable"] as? Bool {
            if isSelfUser {
                TUICallState.instance.selfUser.value.audioAvailable.value = audioAvailable
            } else {
                TUICallState.instance.remoteUser.value.audioAvailable.value = audioAvailable
            }
        }

        if let videoAvailable = dic["videoAvailable"] as? Bool {
            if isSelfUser {
                TUICallState.instance.selfUser.value.videoAvailable.value = videoAvailable
            } else {
                TUICallState.instance.remoteUser.value.videoAvailable.value = videoAvailable
            }
        }

        if let playoutVolume = dic["playoutVolume"] as? Float {
            if isSelfUser {
                TUICallState.instance.selfUser.value.playoutVolume.value = playoutVolume
            } else {
                TUICallState.instance.remoteUser.value.playoutVolume.value = playoutVolume
            }
        }
    }

    func startFloatWindow(call: FlutterMethodCall, result: @escaping FlutterResult) {
        FloatWindowManger.instance.showFloatWindow()
        result(NSNumber(value: 0))
    }
    
    func stopFloatWindow(call: FlutterMethodCall, result: @escaping FlutterResult) {
        FloatWindowManger.instance.closeFloatWindow()
        result(NSNumber(value: 0))
    }
    
    func initResources(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let dic = MethodUtils.getMethodParams(call: call, key: "resources", resultType: Dictionary<String,Any>.self) else {
            FlutterResultUtils.handleMethod(code: .paramNotFound, methodName: "initResources", paramKey: "resources", result: result)
            result(NSNumber(value: -1))
            return
        }
        TUICallState.instance.mResourceDic = dic
        result(NSNumber(value: 0))
    }
}
