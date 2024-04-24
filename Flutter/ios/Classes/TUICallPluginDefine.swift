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
    /// The error code that has not yet classified
    case unknown = -1
    /// The parameters were not found
    case paramNotFound = -1_001
    /// Parameter type error
    case paramTypeError = -1_002
    /// Get Value as empty
    case valueIsNull = -1_004
}
