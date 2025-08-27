//
//  ViewState.swift
//  TUICallKit_swift
//
//  Created by vincepzhang on 2025/2/6.
//

import RTCCommon

class ViewState: NSObject {
    
    let showLargeViewUserId: Observable<String> = Observable("")
    let isVirtualBackgroundOpened: Observable<Bool> = Observable(false)
    let router: Observable<ViewRouter> = Observable(.none)
    let callingViewType: Observable<CallingViewType> = Observable(.one2one)
    let isScreenCleaned: Observable<Bool> = Observable(false)
    var multiCallLargeViewIndex = 0
    
    enum ViewRouter {
        case none
        case banner
        case fullView
        case floatView
    }
    
    enum CallingViewType {
        case one2one
        case multi
    }
    
    func reset() {
        showLargeViewUserId.value = ""
        isVirtualBackgroundOpened.value = false
        router.value = .none
        callingViewType.value = .one2one
        isScreenCleaned.value = false
        multiCallLargeViewIndex = 0
    }
}
