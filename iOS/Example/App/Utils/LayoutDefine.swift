//
//  LayoutDefine.swift
//  TUICallKitApp
//
//  Created by gg on 2021/3/15.
//  Copyright © 2021 Tencent. All rights reserved.
//

import UIKit

public let ScreenWidth = UIScreen.main.bounds.width
public let ScreenHeight = UIScreen.main.bounds.height

public let kDeviceIsIPhoneX : Bool = {
    if UIDevice.current.userInterfaceIdiom == .pad {
        return false
    }
    let size = UIScreen.main.bounds.size
    let notchValue = Int(size.width / size.height * 100)
    if notchValue == 216 || notchValue == 46 {
        return true
    }
    return false
}()

public let kDeviceSafeTopHeight : CGFloat = {
    return kDeviceIsIPhoneX ? 44 : 20
}()

public let kDeviceSafeBottomHeight : CGFloat = {
    return kDeviceIsIPhoneX ? 34 : 0
}()

public func convertPixel(w:CGFloat) -> CGFloat {
    return w / 375.0 * ScreenWidth
}

public func convertPixel(h:CGFloat) -> CGFloat {
    return h / 812.0 * ScreenHeight
}

