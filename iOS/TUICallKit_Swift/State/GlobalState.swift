//
//  GlobalState.swift
//  Pods
//
//  Created by vincepzhang on 2025/2/6.
//

class GlobalState: NSObject {
    var enableMuteMode: Bool = UserDefaults.standard.value(forKey: ENABLE_MUTEMODE_USERDEFAULT) as? Bool == true ? true : false
    var enableFloatWindow: Bool = false
    var enableIncomingbanner: Bool = false
    var enableVirtualBackgroud: Bool = false
}
