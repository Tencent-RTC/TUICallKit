//
//  BundleUtils.swift
//  tencent_calls_uikit
//
//  Created by vincepzhang on 2023/6/27.
//

import Foundation

class BundleUtils {
    
    static func getBundleImage(name: String) -> UIImage? {
        guard let url: URL = Bundle.main.url(forResource: "TUICallKitBundle", withExtension: "bundle") else { return nil }
        return UIImage(named: name, in: Bundle(url: url), compatibleWith: nil)
    }
    
    static func getUrlImage(url: String) -> UIImage? {
        guard let url = URL(string: url) else { return nil }
        var data = Data()
        do {
            data = try Data(contentsOf: url)
        } catch _ as NSError {}
        return  UIImage(data: data)
    }
}
