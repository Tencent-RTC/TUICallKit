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
import RTCRoomEngine
import TUICore
import TXLiteAVSDK_Professional

class TUICallKitHandler {
    static let channelName = "tuicall_kit"
    private let channel: FlutterMethodChannel
    
    enum Mehtod: String {
        case startRing
        case stopRing
        case updateCallStateToNative
        case stopFloatWindow
        case startFloatWindow
        case initResources
        case openMicrophone
        case closeMicrophone
        case isAppInForeground
        case apiLog
        case showIncomingBanner
        case enableWakeLock
        case loginSuccessEvent
        case logoutSuccessEvent
    }
    
    init(registrar: FlutterPluginRegistrar) {
        self.channel = FlutterMethodChannel(name: TUICallKitHandler.channelName, binaryMessenger: registrar.messenger())
        
        channel.setMethodCallHandler({[weak self] call, result in
            guard let self = self else {
                result(FlutterError(code: "Error", message: "self is nil", details: nil))
                return
            }
            
            let method = Mehtod.init(rawValue: call.method)
            switch method {
            case .startRing:
                startRing(call: call, result: result)
                break
            case .stopRing:
                stopRing(call: call, result: result)
                break
            case .updateCallStateToNative:
                updateCallStateToNative(call: call, result: result)
            case .startFloatWindow:
                startFloatWindow(call: call, result: result)
                break
            case .stopFloatWindow:
                stopFloatWindow(call: call, result: result)
                break
            case .initResources:
                initResources(call: call, result: result)
                break
            case .isAppInForeground:
                result(TUICallKitPlugin.isAppInForeground)
                break
            case .openMicrophone:
                openMicrophone(call: call, result: result)
                break
            case .closeMicrophone:
                closeMicrophone(call: call, result: result)
            case .apiLog:
                apiLog(call: call, result: result)
            case .showIncomingBanner:
                showIncomingBanner(call: call, result: result)
            case .enableWakeLock:
                enableWakeLock(call: call, result: result)
            case .loginSuccessEvent:
                loginSuccessEvent(call: call, result: result)
            case .logoutSuccessEvent:
                logoutSuccessEvent(call: call, result: result)
            default:
                break
            }
        })
    }
}

extension TUICallKitHandler {
    public func appEnterBackground() {
        channel.invokeMethod("appEnterBackground", arguments: nil)
    }
    
    public func appEnterForeground() {
        channel.invokeMethod("appEnterForeground", arguments: nil)
    }
}

extension TUICallKitHandler {
    
    func startRing(call: FlutterMethodCall, result: @escaping FlutterResult) {
        if TUICallState.instance.selfUser.value.callRole.value == TUICallRole.called {
            CallingVibrator.startVibration()
        }
        guard let filePath = MethodUtils.getMethodParams(call: call, key: "filePath", resultType: String.self) else {
            FlutterResultUtils.handleMethod(code: .paramNotFound, methodName: "startRing", paramKey: "filePath", result: result)
            result(NSNumber(value: -1))
            return
        }
        CallingBellPlayer.instance.startRing(filePath: filePath)
        result(NSNumber(value: 0))
    }
    
    func stopRing(call: FlutterMethodCall, result: @escaping FlutterResult) {
        if TUICallState.instance.selfUser.value.callRole.value == TUICallRole.called {
            CallingVibrator.stopVirbration()
        }
        CallingBellPlayer.instance.stopRing()
        result(NSNumber(value: 0))
    }
    
    func updateCallStateToNative(call: FlutterMethodCall, result: @escaping FlutterResult) {
        
        if let sceneIndex = MethodUtils.getMethodParams(call: call, key: "scene", resultType: Int.self)  {
            TUICallState.instance.scene.value = UInt(sceneIndex) == 0 ? .single : .group;
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
            TUICallState.instance.remoteUserList.value.removeAll()
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
        TUICallKitService.instance.voipDataSyncHandler.setVoIPMute(false)
        TUICallKitService.instance.voipDataSyncHandler.setVoIPMuteForTUICallKitVoIPExtension(false)

        result(NSNumber(value: 0))
    }
    
    func closeMicrophone(call: FlutterMethodCall, result: @escaping FlutterResult) {
        TUICallKitService.instance.voipDataSyncHandler.setVoIPMute(true)
        TUICallKitService.instance.voipDataSyncHandler.setVoIPMuteForTUICallKitVoIPExtension(true)

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
        
    func showIncomingBanner(call: FlutterMethodCall, result: @escaping FlutterResult) {
        WindowManger.instance.showIncomingBanner();
        result(NSNumber(value: 0))
    }
    
    func enableWakeLock(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let enable = MethodUtils.getMethodParams(call: call, key: "enable", resultType: Bool.self) else {
            FlutterResultUtils.handleMethod(code: .paramNotFound, methodName: "enableWakeLock", paramKey: "enable", result: result)
            result(NSNumber(value: -1))
            return
        }

        if enable {
            WakeLock.shareInstance().enable()
        } else {
            WakeLock.shareInstance().disable()
        }

        result(NSNumber(value: 0))
    }
    
    func loginSuccessEvent(call: FlutterMethodCall, result: @escaping FlutterResult) {
        NotificationCenter.default.post(name: NSNotification.Name.TUILoginSuccess , object: nil)
        result(NSNumber(value: 0))
    }

    func logoutSuccessEvent(call: FlutterMethodCall, result: @escaping FlutterResult) {
        NotificationCenter.default.post(name: NSNotification.Name.TUILogoutSuccess , object: nil)
        result(NSNumber(value: 0))
    }
}


extension TUICallKitHandler {
    // MARK: BackToFlutterWidgetDelegate
    func backCallingPageFromFloatWindow() {
        channel.invokeMethod("backCallingPageFromFloatWindow", arguments: nil)
    }
    
    func launchCallingPageFromIncomingBanner() {
        channel.invokeMethod("launchCallingPageFromIncomingBanner", arguments: nil)
    }
    
    // MARK: TUICallKitServiceDelegate
    func callMethodVoipChangeMute(mute: Bool) {
        channel.invokeMethod("voipChangeMute", arguments: ["mute": mute])
    }
    
    func callMethodVoipChangeAudioPlaybackDevice(audioPlaybackDevice: TUIAudioPlaybackDevice) {
        channel.invokeMethod("voipChangeAudioPlaybackDevice", arguments: ["audioPlaybackDevice": audioPlaybackDevice.rawValue])
    }
    
    func callMethodVoipHangup() {
        channel.invokeMethod("voipChangeHangup", arguments: [:])
    }
    
    func callMethodVoipAccept() {
        channel.invokeMethod("voipChangeAccept", arguments: [:])
    }
}
