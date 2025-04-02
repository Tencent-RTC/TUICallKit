//
//  AudioAndVideoCalleeWaitingView.swift
//  TUICallKit
//
//  Created by vincepzhang on 2023/2/14.
//

import Foundation
import RTCRoomEngine
import RTCCommon

class AudioAndVideoCalleeWaitingView: UIView {
    
    private lazy var acceptBtn: UIView = {
        let acceptBtn = FeatureButton.create(title: TUICallKitLocalize(key: "TUICallKit.answer"),
                                             titleColor: Color_White,
                                             image: CallKitBundle.getBundleImage(name: "icon_dialing"),
                                             imageSize: kBtnSmallSize) { [weak self] sender in
            guard let self = self else { return }
            self.acceptTouchEvent(sender: sender)
        }
        return acceptBtn
    }()
    
    private lazy var rejectBtn: UIView = {
        let rejectBtn = FeatureButton.create(title: TUICallKitLocalize(key: "TUICallKit.decline"),
                                             titleColor: Color_White,
                                             image: CallKitBundle.getBundleImage(name: "icon_hangup"),
                                             imageSize: kBtnSmallSize) { [weak self] sender in
            guard let self = self else { return }
            self.rejectTouchEvent(sender: sender)
        }
        return rejectBtn
    }()
    
    // MARK: UI Specification Processing
    private var isViewReady: Bool = false
    override func didMoveToWindow() {
        super.didMoveToWindow()
        if isViewReady { return }
        constructViewHierarchy()
        activateConstraints()
        isViewReady = true
    }
    
    func constructViewHierarchy() {
        addSubview(rejectBtn)
        addSubview(acceptBtn)
    }
    
    func activateConstraints() {
        rejectBtn.snp.makeConstraints { make in
            make.centerX.equalTo(self).offset(TUICoreDefineConvert.getIsRTL() ? 80.scale375Width() : -80.scale375Width())
            make.top.bottom.equalTo(self)
            make.size.equalTo(kControlBtnSize)
        }
        acceptBtn.snp.makeConstraints { make in
            make.centerX.equalTo(self).offset(TUICoreDefineConvert.getIsRTL() ? -80.scale375Width() : 80.scale375Width())
            make.top.bottom.equalTo(self)
            make.size.equalTo(kControlBtnSize)
        }
    }
    
    // MARK: Event Action
    func rejectTouchEvent(sender: UIButton) {
        CallManager.shared.reject()
    }
    
    func acceptTouchEvent(sender: UIButton) {
        CallManager.shared.accept()
    }
}
