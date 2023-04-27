//
//  TUIExtension.swift
//  TUIVideoSeat
//
//  Created by WesleyLei on 2022/9/23.
//  Copyright © 2022 Tencent. All rights reserved.
//

import Foundation
import TUICore

extension NSObject {
    @objc class func swiftLoad() {
        TUICore.registerService(TUICore_TUICallingService, object: TUICallKitService.instance)
    }
}
