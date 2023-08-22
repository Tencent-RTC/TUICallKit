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
let kCallKitSingleSmallVideoViewFrame = CGRectMake(5, 5, kCallKitSingleSmallVideoViewWidth - 10,
                                                           (kCallKitSingleSmallVideoViewWidth / 9.0 * 16.0) - 10 )


let Screen_Width = UIScreen.main.bounds.size.width
let Screen_Height = UIScreen.main.bounds.size.height
let kMicroVideoViewRect = CGRectMake(Screen_Width - kMicroVideoViewWidth, 150, kMicroVideoViewWidth, kMicroVideoViewHeight)
