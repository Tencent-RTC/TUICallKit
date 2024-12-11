//
//  Created by vincepzhang on 2023/4/20.
//

import Foundation
import TUICore
import TUICallEngine
import UIKit

class TUICallKitService: NSObject, TUIServiceProtocol {
    static let instance = TUICallKitService()
    lazy var voipDataSyncHandler = {
        return VoIPDataSyncHandler()
    }()
        
    func onCall(_ method: String, param: [AnyHashable : Any]?) -> Any? {
        guard let param = param else { return nil }
        voipDataSyncHandler.onCall(method, param: param)
        return nil
    }
}
