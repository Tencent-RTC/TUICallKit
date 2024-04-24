//
//  ExtensionUtils.swift
//  tencent_calls_uikit
//
//  Created by vincepzhang on 2023/11/22.
//

import Foundation

extension CGFloat {
    /// 375 design in the design graph
    ///
    /// - Returns: Final result scaling result
    public func scaleWidth(_ exceptPad: Bool = true) -> CGFloat {
        if UIDevice.current.userInterfaceIdiom == .pad {
            return exceptPad ? self * 1.5 : self * (Screen_Width / 375.00)
        }
        return self * (Screen_Width / 375.00)
    }
    
    public func scaleHeight(_ exceptPad: Bool = true) -> CGFloat {
        if UIDevice.current.userInterfaceIdiom == .pad {
            return exceptPad ? self * 1.5 : self * (Screen_Height / 812.00)
        }
        return self * (Screen_Height / 812.00)
    }
}

extension Int {
    /// 375 design in the design graph
    ///
    /// - Returns: Final result scaling result
    public func scaleWidth(_ exceptPad: Bool = true) -> CGFloat {
        return CGFloat(self).scaleWidth()
    }
    
    public func scaleHeight(_ exceptPad: Bool = true) -> CGFloat {
        return CGFloat(self).scaleHeight()
    }
}
