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

/**
 * Tencent Cloud SDKAppId, which needs to be replaced with the SDKAppId under your own account.
 *
 * Enter Tencent Cloud IM to create an application, and you can see the SDKAppId, which is the unique identifier used by Tencent Cloud to distinguish customers.
 */
let SDKAPPID: Int = 0

/**
 *  Signature expiration time, it is recommended not to set it too short
 *
 *  Time unit: seconds
 *  Default time: 7 x 24 x 60 x 60 = 604800 = 7 days
 */
let EXPIRETIME: Int = 604_800

/**
 * Encryption key used for calculating the signature, the steps to obtain it are as follows:
 *
 * step1. Enter Tencent Cloud IM, if you do not have an application yet, create one,
 * step2. Click "Application Configuration" to enter the basic configuration page, and further find the "Account System Integration" section.
 * step3. Click the "View Key" button, you can see the encryption key used to calculate UserSig, please copy and paste it into the following variable
 *
 * Note: This solution is only applicable to debugging demos.
 * Before going online officially, please migrate the UserSig calculation code and keys to your backend server to avoid traffic theft caused by encryption key leakage.
 */
let SECRETKEY = ""

class GenerateTestUserSig {
    
    class func genTestUserSig(identifier: String) -> String {
        let current = CFAbsoluteTimeGetCurrent() + kCFAbsoluteTimeIntervalSince1970
        let TLSTime: CLong = CLong(floor(current))
        var obj: [String: Any] = [
            "TLS.ver": "2.0",
            "TLS.identifier": identifier,
            "TLS.sdkappid": SDKAPPID,
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
        print("string to sign: \(stringToSign)")
        guard var sig = hmac(stringToSign) else {
            print("hmac error: \(stringToSign)")
            return ""
        }
        obj["TLS.sig"] = sig
        print("sig: \(String(describing: sig))")
        guard let jsonData = try? JSONSerialization.data(withJSONObject: obj, options: .sortedKeys) else {
            print("jsonData error: \(obj)")
            return ""
        }
        
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
            print("[Error] Compress Error \(ret), upper bound: \(upperBound)")
            dest.deallocate()
            return ""
        }
        let count = Int(destLen)
        let result = self.base64URL(data: Data(bytesNoCopy: dest, count: count, deallocator: .free))
        return result
    }
    
    class func hmac(_ plainText: String) -> String? {
        guard let cKey = SECRETKEY.cString(using: String.Encoding.ascii) else {
            print("hmac SECRETKEY error: \(SECRETKEY)")
            return nil
        }
        print("hmac SECRETKEY: \(SECRETKEY)")
        print("hmac cKey: \(cKey)")
        guard let cData = plainText.cString(using: String.Encoding.ascii) else{
            print("hmac plainText error: \(plainText)")
            return nil
        }
        print("hmac plainText: \(plainText)")
        print("hmac cData: \(cData)")
        let cKeyLen = SECRETKEY.lengthOfBytes(using: .ascii)
        let cDataLen = plainText.lengthOfBytes(using: .ascii)
        
        var cHMAC = [CUnsignedChar].init(repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        let pointer = cHMAC.withUnsafeMutableBufferPointer { (unsafeBufferPointer) in
            return unsafeBufferPointer
        }
        CCHmac(CCHmacAlgorithm(kCCHmacAlgSHA256), cKey, cKeyLen, cData, cDataLen, pointer.baseAddress)
        guard let adress = pointer.baseAddress else {
            print("adress error: \(String(describing: pointer))")
            return nil
        }
        let data = Data(bytes: adress, count: cHMAC.count)
        print("cHMAC.count: \(String(describing: cHMAC.count))")
        print("data: \(String(describing: data))")
        let result = data.base64EncodedString(options: [])
        return result
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
