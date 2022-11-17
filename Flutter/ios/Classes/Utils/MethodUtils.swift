//
//  MethodUtils.swift
//  Pods
//
//  Created by aby on 2022/11/1.
//

import Foundation

/// Flutter方法取值函数
public class MethodUtils {
    public static func getMethodParams<T: Any>(call: FlutterMethodCall, key: String, resultType: T.Type) -> T? {
        guard let arguments = call.arguments as? [String: Any] else { return nil }
        guard let value = arguments[key] else { return nil }
        return value as? T
    }
}

/// Flutter-Result 回调处理
public class FlutterResultUtils {
    
    /// 处理Method-Result
    /// - Parameters:
    ///   - code: 错误码
    ///   - methodName: 接口名称
    ///   - paramKey: 参数key
    ///   - result: flutter回调
    static func handleMethod(code: TUICallKitFlutterCode = .unknown,
                             methodName: String,
                             paramKey: String,
                             result: FlutterResult? = nil) {
        switch code {
            case .paramNotFound:
                handle(code: code, msg: "\(methodName) Can not find param by key: \(paramKey)", details: nil, result: result)
            case .paramTypeError:
                handle(code: code, msg: "\(methodName) param type error key: \(paramKey)", details: nil, result: result)
            default:
                handle(code: code, result: result)
        }
    }
    
    /// 处理result回调
    static func handle(code: TUICallKitFlutterCode = .unknown,
                       msg: String = "unknown msg",
                       details: Any? = nil,
                       result: FlutterResult? = nil) {
//        Logger.error(content: "flutter error: \(msg)")
        let error = FlutterError(code: "\(code.rawValue)", message: msg, details: details)
        result?(error)
    }
}
