// Copyright (c) 2021 Tencent. All rights reserved.
// Author: abyyxwang

import Flutter
import UIKit
import TUICallEngine

public class TUICallKitPlugin: NSObject, BackToFlutterWidgetDelegate, TUICallKitServiceDelegate {
        
    static let channelName = "tuicall_kit"
    private let channel: FlutterMethodChannel
    let registrar: FlutterPluginRegistrar
    var messager: FlutterBinaryMessenger {
        return registrar.messenger()
    }
    
    var isAppInForeground: Bool = false
    
    init(registrar: FlutterPluginRegistrar) {
        self.channel = FlutterMethodChannel(name: TUICallKitPlugin.channelName, binaryMessenger: registrar.messenger())
        self.registrar = registrar
        
        super.init()
        
        FloatWindowManger.instance.backToFlutterWidgetDelegate = self
        TUICallKitService.instance.callKitServiceDelegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(applicationWillResignActive),
                                               name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidBecomeActive),
                                               name: UIApplication.didBecomeActiveNotification, object: nil) 
    }
    
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
    }
    
    @objc func applicationWillResignActive() {
        isAppInForeground = false
        channel.invokeMethod("appEnterBackground", arguments: nil)
    }

    @objc func applicationDidBecomeActive() {
        isAppInForeground = true
        channel.invokeMethod("appEnterForeground", arguments: nil)
    }
}

extension TUICallKitPlugin {
    // MARK: BackToFlutterWidgetDelegate
    func backToFlutterWidget() {
        channel.invokeMethod("backCallingPage", arguments: nil)
    }
    
    // MARK: TUICallKitServiceDelegate
    func callMethodHandleLoginSuccess(sdkAppID: Int, userId: String, userSig: String) {
        channel.invokeMethod("handleLoginSuccess", arguments: ["sdkAppId": sdkAppID,
                                                               "userId": userId,
                                                               "userSig": userSig] as [String : Any])
    }

    func callMethodHandleLogoutSuccess() {
        channel.invokeMethod("handleLogoutSuccess", arguments: nil)
    }

    func callMethodCall(userId: String, callMediaType: TUICallMediaType) {
        channel.invokeMethod("call", arguments: ["userId": userId,
                                                 "mediaType": callMediaType.rawValue] as [String : Any])
    }

    func callMethodGroupCall(groupId: String, userIdList: [String], callMediaType: TUICallMediaType) {
        channel.invokeMethod("groupCall", arguments: ["groupId": groupId,
                                                      "userIdList": userIdList,
                                                      "mediaType": callMediaType.rawValue] as [String : Any])
    }

    func callMethodEnabelFloatWindow(enable: Bool) {
        channel.invokeMethod("enabelFloatWindow", arguments: ["enable": enable])
    }
    
    func callMethodVoipChangeMute(mute: Bool) {
        channel.invokeMethod("voipChangeMute", arguments: ["mute": mute])
    }
    
    func callMethodVoipChangeAudioPlaybackDevice(audioPlaybackDevice: TUIAudioPlaybackDevice) {
        channel.invokeMethod("voipChangeAudioPlaybackDevice", arguments: ["audioPlaybackDevice": audioPlaybackDevice.rawValue])
    }
}

extension TUICallKitPlugin: FlutterPlugin {
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let instance = TUICallKitPlugin.init(registrar: registrar)
        registrar.addMethodCallDelegate(instance, channel: instance.channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let method = Mehtod.init(rawValue: call.method)
        switch method {
        case .startRing:
            TUICallKitManager.shared.startRing(call: call, result: result)
            break
        case .stopRing:
            TUICallKitManager.shared.stopRing(call: call, result: result)
            break
        case .updateCallStateToNative:
            TUICallKitManager.shared.updateCallStateToNative(call: call, result: result)
        case .startFloatWindow:
            TUICallKitManager.shared.startFloatWindow(call: call, result: result)
            break
        case .stopFloatWindow:
            TUICallKitManager.shared.stopFloatWindow(call: call, result: result)
            break
        case .initResources:
            TUICallKitManager.shared.initResources(call: call, result: result)
            break
        case .isAppInForeground:
            result(isAppInForeground)
            break
        case .openMicrophone:
            TUICallKitManager.shared.openMicrophone(call: call, result: result)
            break
        case .closeMicrophone:
            TUICallKitManager.shared.closeMicrophone(call: call, result: result)
        case .apiLog:
            TUICallKitManager.shared.apiLog(call: call, result: result)
        default:
            break
        }
    }
}
