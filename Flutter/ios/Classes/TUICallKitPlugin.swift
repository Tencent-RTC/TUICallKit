// Copyright (c) 2021 Tencent. All rights reserved.
// Author: abyyxwang

import Flutter
import UIKit

public class TUICallKitPlugin: NSObject {
    static let channelName = "tuicall_kit"
    private let channel: FlutterMethodChannel
    let registrar: FlutterPluginRegistrar
    var messager: FlutterBinaryMessenger {
        return registrar.messenger()
    }
    
    init(registrar: FlutterPluginRegistrar) {
        self.channel = FlutterMethodChannel(name: TUICallKitPlugin.channelName, binaryMessenger: registrar.messenger())
        self.registrar = registrar
        
        super.init()
    }
    
    enum Mehtod: String {
        case call
        case setSelfInfo
        case groupCall
        case joinInGroupCall
        case setCallingBell
        case enableMuteMode
        case enableFloatWindow
        case login
        case logout
    }
    
    deinit {
        print("deinit \(TUICallKitPlugin.self)")
    }
}

extension TUICallKitPlugin: FlutterPlugin {
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let instance = TUICallKitPlugin.init(registrar: registrar)
        registrar.addMethodCallDelegate(instance, channel: instance.channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        // TODO:添加Log
        
        let method = Mehtod.init(rawValue: call.method)
        switch method {
            case .setSelfInfo:
                TUICallKitManager.shared.setSelfInfo(call: call, result: result)
                break
            case .call:
                TUICallKitManager.shared.call(call: call, result: result)
                break
            case .groupCall:
                TUICallKitManager.shared.groupCall(call: call, result: result)
                break
            case .joinInGroupCall:
                TUICallKitManager.shared.joinInGroupCall(call: call, result: result)
                break
            case .setCallingBell:
                TUICallKitManager.shared.setCallingBell(call: call, result: result)
                break
            case .enableMuteMode:
                TUICallKitManager.shared.enableMuteMode(call: call, result: result)
                break
            case .enableFloatWindow:
                TUICallKitManager.shared.enableFloatWindow(call: call, result: result)
                break
            case .login:
                TUICallKitManager.shared.login(call: call, result: result)
            case .logout:
                TUICallKitManager.shared.logout(call: call, result: result)
            default:
                // TODO:添加Log打印错误
                break
        }
    }
}
