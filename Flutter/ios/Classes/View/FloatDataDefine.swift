//
//  FloatDataDefine.swift
//  tencent_calls_uikit
//
//  Created by vincepzhang on 2023/6/27.
//
let kMicroTopEdge = 75.scaleWidth()
let kMicroLeftRightEdge = 6.scaleWidth()
let kMicroWindowCornerRatio = 15.scaleWidth()

let kSingleCallMicroAudioViewWidth = 72.scaleWidth()
let kSingleCallMicroAudioViewHeight = 72.scaleWidth()

let kSingleCallMicroVideoViewWidth = 110.scaleWidth()
let kSingleCallMicroVideoViewHeight = 196.scaleWidth()

let kGroupCallMicroViewWidth = 72.scaleWidth()
let kGroupCallMicroViewHeight = 90.scaleWidth()

let ScreenSize = UIScreen.main.bounds.size
let Screen_Width = UIScreen.main.bounds.size.width
let Screen_Height = UIScreen.main.bounds.size.height
let StatusBar_Height: CGFloat = {
    var statusBarHeight: CGFloat = 0
    if #available(iOS 13.0, *) {
        statusBarHeight = UIApplication.shared.windows.first?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
    } else {
        statusBarHeight = UIApplication.shared.statusBarFrame.height
    }
    return statusBarHeight
}()
let Bottom_SafeHeight = {var bottomSafeHeight: CGFloat = 0
    if #available(iOS 11.0, *) {
        let window = UIApplication.shared.windows.first
        bottomSafeHeight = window?.safeAreaInsets.bottom ?? 0
    }
    return bottomSafeHeight
}()

