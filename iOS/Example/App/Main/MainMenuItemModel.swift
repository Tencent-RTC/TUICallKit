//
//  MainMenuItemModel.swift
//  TUICallKitApp
//
//  Created by adams on 2021/5/11.
//  Copyright © 2021 Tencent. All rights reserved.
//
import UIKit

struct MainMenuItemModel {
    let imageName: String
    let title: String
    let content: String
    let selectHandle: () -> Void
    
    var iconImage: UIImage? {
        UIImage(named: imageName)
    }
    
    init(imageName: String, title: String, content: String, selectHandle: @escaping () -> Void) {
        self.imageName = imageName
        self.title = title
        self.content = content
        self.selectHandle = selectHandle
    }
}
