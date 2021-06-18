//
//  TUICallingProfileManager.swift
//  TUICalling
//
//  Created by adams on 2021/5/27.
//

import Foundation

@objcMembers
public class TUICallingProfileManager: NSObject {
    private static let staticInstance: TUICallingProfileManager = TUICallingProfileManager.init()
    public static func sharedManager() -> TUICallingProfileManager { staticInstance }
    private override init(){}
    
    public var SDKAPPID: Int32 = 0
    public var avatar: String?
    public var userId: String?
    public var name: String?
    
    public func setProfileInfo(SDKAPPID: Int32, avatar: String, userId: String, name: String) {
        self.SDKAPPID = SDKAPPID;
        self.avatar = avatar;
        self.userId = userId;
        self.name = name;
    }
    
}

