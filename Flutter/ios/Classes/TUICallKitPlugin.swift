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
        
        WindowManger.instance.backToFlutterWidgetDelegate = self
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
        case showIncomingBanner
        case enableWakeLock
        case loginSuccessEvent
        case logoutSuccessEvent
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
        case .showIncomingBanner:
            TUICallKitManager.shared.showIncomingBanner(call: call, result: result)
        case .enableWakeLock:
            TUICallKitManager.shared.enableWakeLock(call: call, result: result)
        case .loginSuccessEvent:
            TUICallKitManager.shared.loginSuccessEvent(call: call, result: result)
        case .logoutSuccessEvent:
            TUICallKitManager.shared.logoutSuccessEvent(call: call, result: result)

        default:
            break
        }
    }
}
