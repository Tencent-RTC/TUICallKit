//
//  FloatDataDefine.swift
//  tencent_calls_uikit
//
//  Created by vincepzhang on 2023/6/27.
//
let kMicroWindowCornerRatio = 15.0
let kMicroContainerViewOffset = 8.0

let kMicroAudioViewWidth = 80.0
let kMicroAudioViewHeight = 80.0
let kMicroVideoViewWidth = 100.0
let kMicroVideoViewHeight = (100.0 * 16) / 9.0


let kCallKitSingleSmallVideoViewWidth = 100.0
let kCallKitSingleSmallVideoViewFrame = CGRect(x: 5, y: 5, width: kCallKitSingleSmallVideoViewWidth - 10,
                                               height: (kCallKitSingleSmallVideoViewWidth / 9.0 * 16.0) - 10 )


let Screen_Width = UIScreen.main.bounds.size.width
let Screen_Height = UIScreen.main.bounds.size.height
let kMicroVideoViewRect = CGRect(x: Screen_Width - kMicroVideoViewWidth, y: 150, width: kMicroVideoViewWidth, height: kMicroVideoViewHeight)
