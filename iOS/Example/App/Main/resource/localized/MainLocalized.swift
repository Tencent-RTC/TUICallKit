//
//  MainLocalized.strings
//  TUICallKitApp
//
//  Created by noah on 2021/12/27.
//  Copyright © 2021 Tencent. All rights reserved.
//

import Foundation

let MainLocalizeTableName = "MainLocalized"

func MainLocalize(_ key: String) -> String {
    return localizeFromTable(key: key, table: MainLocalizeTableName)
}
