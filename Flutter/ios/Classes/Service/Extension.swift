//
//  Created by vincepzhang
//  Copyright © 2022 Tencent. All rights reserved.
//

import Foundation
import TUICore

extension NSObject {
    @objc class func swiftLoad() {
        TUICore.registerService(TUICore_TUICallingService, object: TUICallKitService.instance)
    }
}
