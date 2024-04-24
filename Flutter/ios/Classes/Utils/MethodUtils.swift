//
//  MethodUtils.swift
//  Pods
//
//  Created by aby on 2022/11/1.
//

import Foundation

/// Flutter method value function
public class MethodUtils {
    public static func getMethodParams<T: Any>(call: FlutterMethodCall, key: String, resultType: T.Type) -> T? {
        guard let arguments = call.arguments as? [String: Any] else { return nil }
        guard let value = arguments[key] else { return nil }
        return value as? T
    }
}

/// Flutter-Result
public class FlutterResultUtils {
    
    /// Process Method-Result
    /// - Parameters:
    ///   - code: error code
    ///   - methodName: Interface name
    ///   - paramKey: Parameter key
    ///   - result: Flutter callback
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
    
    /// Process Result
    static func handle(code: TUICallKitFlutterCode = .unknown,
                       msg: String = "unknown msg",
                       details: Any? = nil,
                       result: FlutterResult? = nil) {
//        Logger.error(content: "flutter error: \(msg)")
        let error = FlutterError(code: "\(code.rawValue)", message: msg, details: details)
        result?(error)
    }
}
