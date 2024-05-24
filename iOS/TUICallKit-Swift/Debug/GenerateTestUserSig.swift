//
//  GenerateTestUserSig.swift
//  TUICallKitApp
//
//  Created by abyyxwang on 2021/5/7.
//  Copyright © 2021 Tencent. All rights reserved.
//

import Foundation
import CommonCrypto
import zlib
import TUICore

@objc
public class GenerateTestUserSig: NSObject {
   
    @objc
    public class func genTestUserSig(userID: String, sdkAppID: Int, secretKey: String) -> String {
        // Signature expiration time, it is recommended not to set it too short.
        // Default time: 7 x 24 x 60 x 60 = 604800 = 7 days
        let EXPIRETIME = 604_800
        let current = CFAbsoluteTimeGetCurrent() + kCFAbsoluteTimeIntervalSince1970
        let TLSTime: CLong = CLong(floor(current))
        var obj: [String: Any] = [
            "TLS.ver": "2.0",
            "TLS.identifier": userID,
            "TLS.sdkappid": sdkAppID,
            "TLS.expire": EXPIRETIME,
            "TLS.time": TLSTime,
        ]
        let keyOrder = [
            "TLS.identifier",
            "TLS.sdkappid",
            "TLS.time",
            "TLS.expire",
        ]
        var stringToSign = ""
        keyOrder.forEach { (key) in
            if let value = obj[key] {
                stringToSign += "\(key):\(value)\n"
            }
        }
        guard let sig = hmac(plainText: stringToSign, secretKey: secretKey) else {return ""}
        obj["TLS.sig"] = sig
        guard let jsonData = try? JSONSerialization.data(withJSONObject: obj, options: .sortedKeys) else { return "" }
        let bytes = jsonData.withUnsafeBytes { (result) -> UnsafePointer<Bytef>? in
            return result.bindMemory(to: Bytef.self).baseAddress
        }
        let srcLen: uLongf = uLongf(jsonData.count)
        let upperBound: uLong = compressBound(srcLen)
        let capacity: Int = Int(upperBound)
        let dest: UnsafeMutablePointer<Bytef> = UnsafeMutablePointer<Bytef>.allocate(capacity: capacity)
        var destLen = upperBound
        let ret = compress2(dest, &destLen, bytes, srcLen, Z_BEST_SPEED)
        if ret != Z_OK {
            dest.deallocate()
            return ""
        }
        let count = Int(destLen)
        let result = self.base64URL(data: Data(bytesNoCopy: dest, count: count, deallocator: .free))
        return result
    }
    
    class func hmac(plainText: String, secretKey: String) -> String? {
        let cKey = secretKey.cString(using: String.Encoding.ascii)
        let cData = plainText.cString(using: String.Encoding.ascii)
        
        let cKeyLen = secretKey.lengthOfBytes(using: .ascii)
        let cDataLen = plainText.lengthOfBytes(using: .ascii)
        
        var cHMAC = [CUnsignedChar](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        let pointer = cHMAC.withUnsafeMutableBufferPointer { (unsafeBufferPointer) in
            return unsafeBufferPointer
        }
        
        guard let baseAddress = pointer.baseAddress else {
            return nil
        }
        
        CCHmac(CCHmacAlgorithm(kCCHmacAlgSHA256), cKey, cKeyLen, cData, cDataLen, baseAddress)
        let data = Data(bytes: baseAddress, count: cHMAC.count)
        return data.base64EncodedString(options: [])
    }
    
    class func base64URL(data: Data) -> String {
        let result = data.base64EncodedString(options: Data.Base64EncodingOptions(rawValue: 0))
        var final = ""
        result.forEach { (char) in
            switch char {
            case "+":
                final += "*"
            case "/":
                final += "-"
            case "=":
                final += "_"
            default:
                final += "\(char)"
            }
        }
        return final
    }
}
