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
import TUICore
import TXLiteAVSDK_Professional

class TUICallKitManager {
    static let shared = TUICallKitManager.init()
    private init() {}
    
    func startRing(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let filePath = MethodUtils.getMethodParams(call: call, key: "filePath", resultType: String.self) else {
            FlutterResultUtils.handleMethod(code: .paramNotFound, methodName: "startRing", paramKey: "filePath", result: result)
            result(NSNumber(value: -1))
            return
        }
        CallingBellPlayer.instance.startRing(filePath: filePath)
        result(NSNumber(value: 0))
    }
    
    func stopRing(call: FlutterMethodCall, result: @escaping FlutterResult) {
        CallingBellPlayer.instance.stopRing()
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
        
        if let remoteUserDicList = MethodUtils.getMethodParams(call: call, key: "remoteUserList", resultType: Array<Dictionary<String, Any>>.self) {
            for remoteUserDic in remoteUserDicList {
                setUserInfo(dic: remoteUserDic, isSelfUser: false)
            }
        }
        
        if let startTime = MethodUtils.getMethodParams(call: call, key: "startTime", resultType: Int.self) {
            TUICallState.instance.startTime = startTime
        }
        
        if let isCameraOpen = MethodUtils.getMethodParams(call: call, key: "isCameraOpen", resultType: Bool.self) {
            TUICallState.instance.isCameraOpen.value = isCameraOpen
        }
        
        if let isMicrophoneMute = MethodUtils.getMethodParams(call: call, key: "isMicrophoneMute", resultType: Bool.self) {
            TUICallState.instance.isMicrophoneMute.value = isMicrophoneMute
        }
        
        result(NSNumber(value: 0))
    }
    
    private func setUserInfo(dic: Dictionary<String, Any>, isSelfUser: Bool) {
        guard let id = dic["id"] as? String else { return }
        
        var remoteIndex: Int = -1
        for index in 0..<TUICallState.instance.remoteUserList.value.count {
            if TUICallState.instance.remoteUserList.value[index].id.value == id {
                remoteIndex = index
                break;
            }
        }
        
        let remoteUser = User()
        
        if isSelfUser {
            TUICallState.instance.selfUser.value.id.value = id
        } else {
            if remoteIndex == -1 {
                remoteUser.id.value = id
            } else {
                TUICallState.instance.remoteUserList.value[remoteIndex].id.value = id
            }
        }
        
        if let avatar = dic["avatar"] as? String {
            if isSelfUser {
                TUICallState.instance.selfUser.value.avatar.value = avatar
            } else {
                if remoteIndex == -1 {
                    remoteUser.avatar.value = avatar
                } else {
                    TUICallState.instance.remoteUserList.value[remoteIndex].avatar.value = avatar
                }
            }
        }
        
        if let nickname = dic["nickname"] as? String {
            if isSelfUser {
                TUICallState.instance.selfUser.value.nickname.value = nickname
            } else {
                if remoteIndex == -1 {
                    remoteUser.nickname.value = nickname
                } else {
                    TUICallState.instance.remoteUserList.value[remoteIndex].nickname.value = nickname
                }
            }
        }
        
        if let callRole = dic["callRole"] as? UInt {
            if isSelfUser {
                TUICallState.instance.selfUser.value.callRole.value = TUICallRole(rawValue: callRole) ?? .none
            } else {
                if remoteIndex == -1 {
                    remoteUser.callRole.value = TUICallRole(rawValue: callRole) ?? .none
                } else {
                    TUICallState.instance.remoteUserList.value[remoteIndex].callRole.value = TUICallRole(rawValue: callRole) ?? .none
                }
            }
        }
        
        if let callStatus = dic["callStatus"] as? UInt {
            if isSelfUser {
                TUICallState.instance.selfUser.value.callStatus.value = TUICallStatus(rawValue: callStatus) ?? .none
            } else {
                if remoteIndex == -1 {
                    remoteUser.callStatus.value = TUICallStatus(rawValue: callStatus) ?? .none
                } else {
                    TUICallState.instance.remoteUserList.value[remoteIndex].callStatus.value = TUICallStatus(rawValue: callStatus) ?? .none
                }
            }
        }
        
        if let audioAvailable = dic["audioAvailable"] as? Bool {
            if isSelfUser {
                TUICallState.instance.selfUser.value.audioAvailable.value = audioAvailable
            } else {
                if remoteIndex == -1 {
                    remoteUser.audioAvailable.value = audioAvailable
                } else {
                    TUICallState.instance.remoteUserList.value[remoteIndex].audioAvailable.value = audioAvailable
                }
            }
        }
        
        if let videoAvailable = dic["videoAvailable"] as? Bool {
            if isSelfUser {
                TUICallState.instance.selfUser.value.videoAvailable.value = videoAvailable
            } else {
                if remoteIndex == -1 {
                    remoteUser.videoAvailable.value = videoAvailable
                } else {
                    TUICallState.instance.remoteUserList.value[remoteIndex].videoAvailable.value = videoAvailable
                }
            }
        }
        
        if let playoutVolume = dic["playOutVolume"] as? Float {
            if isSelfUser {
                TUICallState.instance.selfUser.value.playoutVolume.value = playoutVolume
            } else {
                if remoteIndex == -1 {
                    remoteUser.playoutVolume.value = playoutVolume
                } else {
                    TUICallState.instance.remoteUserList.value[remoteIndex].playoutVolume.value = playoutVolume
                }
            }
        }
        
        if !isSelfUser && remoteIndex == -1 {
            TUICallState.instance.remoteUserList.value.append(remoteUser)
        }
    }
    
    func startFloatWindow(call: FlutterMethodCall, result: @escaping FlutterResult) {
        WindowManger.instance.showFloatWindow()
        result(NSNumber(value: 0))
    }
    
    func stopFloatWindow(call: FlutterMethodCall, result: @escaping FlutterResult) {
        WindowManger.instance.closeFloatWindow()
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
    
    func openMicrophone(call: FlutterMethodCall, result: @escaping FlutterResult) {
        TUICore.notifyEvent(TUICore_TUICallKitVoIPExtensionNotify,
                            subKey: TUICore_TUICore_TUICallKitVoIPExtensionNotify_OpenMicrophoneSubKey,
                            object: nil,
                            param: nil)
        result(NSNumber(value: 0))
    }
    
    func closeMicrophone(call: FlutterMethodCall, result: @escaping FlutterResult) {
        TUICore.notifyEvent(TUICore_TUICallKitVoIPExtensionNotify,
                            subKey: TUICore_TUICore_TUICallKitVoIPExtensionNotify_CloseMicrophoneSubKey,
                            object: nil,
                            param: nil)
        
        result(NSNumber(value: 0))
    }
    
    func apiLog(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let logString = MethodUtils.getMethodParams(call: call, key: "logString", resultType: String.self) else {
            FlutterResultUtils.handleMethod(code: .paramNotFound, methodName: "apiLog", paramKey: "logString", result: result)
            result(NSNumber(value: -1))
            return
        }
        guard let level = MethodUtils.getMethodParams(call: call, key: "level", resultType: Int.self) else {
            FlutterResultUtils.handleMethod(code: .paramNotFound, methodName: "apiLog", paramKey: "level", result: result)
            result(NSNumber(value: -1))
            return
        }
        
        let dictionary: [String : Any] = ["api": "TuikitLog",
                                          "params" : ["level": level,
                                                     "message": "TUICallKitPlugin: \(logString)",
                                                      "file": "/some_path/.../foo.c",
                                                      "line": 90]]
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: dictionary, options: .prettyPrinted)
            guard let jsonString = String(data: jsonData, encoding: .utf8) else {
                result(NSNumber(value: -1))
                return
            }
            TRTCCloud.sharedInstance().callExperimentalAPI(jsonString)
            result(NSNumber(value: 0))
            
        } catch {
            print("Error converting dictionary to JSON: \(error.localizedDescription)")
            result(NSNumber(value: -1))
        }
    }
        
    func runAppToNative(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let event = MethodUtils.getMethodParams(call: call, key: "event", resultType: String.self) else {
            FlutterResultUtils.handleMethod(code: .paramNotFound, methodName: "runAppToNative", paramKey: "event", result: result)
            result(NSNumber(value: -1))
            return
        }
        
        if (event == "event_handle_receive_call") {
            WindowManger.instance.showIncomingFloatWindow();
        }
        result(NSNumber(value: 0))
    }
}
