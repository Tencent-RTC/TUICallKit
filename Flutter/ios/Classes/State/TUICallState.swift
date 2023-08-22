//
//  TUICallState.swift
//  tencent_calls_uikit
//
//  Created by vincepzhang on 2023/6/26.
//

import Foundation
import TUICallEngine

class TUICallState {
    static let instance = TUICallState()
    
    let selfUser: Observable<User> = Observable(User())
    let remoteUser: Observable<User> = Observable(User())
    let scene: Observable<TUICallScene> = Observable(TUICallScene.single)
    let mediaType: Observable<TUICallMediaType> = Observable(TUICallMediaType.unknown)
    let camera: Observable<TUICamera> = Observable(TUICamera.front)
    
    var startTime = 0
    var mResourceDic: [String: Any] = [:]
}
