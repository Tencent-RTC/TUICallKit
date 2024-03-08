//
//  TUICallKitAppLocalized.swift
//  TUICallKitApp
//
//  Created by adams on 2021/5/20.
//

import Foundation

func localizeFromTable(key: String, table: String) -> String {
    return Bundle.main.localizedString(forKey: key, value: "", table: table)
}

let TUICallKitLocalizeTableName = "TUICallKitAppLocalized"

func TUICallKitAppLocalize(_ key: String) -> String {
    return localizeFromTable(key: key, table: TUICallKitLocalizeTableName)
}
