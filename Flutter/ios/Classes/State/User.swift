//
//  User.swift
//  tencent_calls_uikit
//
//  Created by vincepzhang on 2023/6/26.
//

import Foundation
import RTCRoomEngine

class User {
    let id: Observable<String> = Observable("")
    let nickname: Observable<String> = Observable("")
    let avatar: Observable<String> = Observable("")
    
    let callRole: Observable<TUICallRole> = Observable(.none)
    let callStatus: Observable<TUICallStatus> = Observable(.none)
    
    let audioAvailable: Observable<Bool> = Observable(false)
    let videoAvailable: Observable<Bool> = Observable(false)
    let playoutVolume: Observable<Float> = Observable(0)
    var viewID: Observable<Int> = Observable(0)
    
    static func getUserDisplayName(user: User) -> String {
        if !user.nickname.value.isEmpty {
            return user.nickname.value
        }
        
        return user.id.value
    }
}
