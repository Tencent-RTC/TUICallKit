//
//  DeviceManager.swift
//  Pods
//
//  Created by yukiwwwang on 2025/8/7.
//

class DeviceManager {
    
    static func isPad() -> Bool {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        return identifier.hasPrefix("iPad")
    }
}
