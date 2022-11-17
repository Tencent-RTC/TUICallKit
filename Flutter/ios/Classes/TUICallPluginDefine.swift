//
//  TUICallPluginDefine.swift
//  tuicall_kit
//
//  Created by aby on 2022/11/1.
//
// Copyright (c) 2021 Tencent. All rights reserved.
// Author: abyyxwang

import Foundation

enum TUICallKitFlutterCode: Int {
    case ok = 0
    /// 暂未归类的错误码
    case unknown = -1
    /// 参数未找到
    case paramNotFound = -1_001
    /// 参数类型错误
    case paramTypeError = -1_002
    /// 获取value为空
    case valueIsNull = -1_004
}
