//
//  IncomingFloatView.swift
//  HydraAsync
//
//  Created by vincepzhang on 2024/4/18.
//

import Foundation
import UIKit
import SnapKit
import RTCRoomEngine

protocol IncomingBannerViewDelegate: NSObject {
    func closeIncomingBannerView()
    func showCallingView()
}

class IncomingBannerView: UIView {
    
    weak var delegate: IncomingBannerViewDelegate?

    let userHeadImageView: UIImageView = {
        let userHeadImageView = UIImageView(frame: CGRect.zero)
        userHeadImageView.layer.masksToBounds = true
        userHeadImageView.layer.cornerRadius = 7.0
        if let image =  BundleUtils.getBundleImage(name: "userIcon") {
            userHeadImageView.image = image
        }
        return userHeadImageView
    }()
    
    let userNameLabel: UILabel = {
        let userNameLabel = UILabel(frame: CGRect.zero)
        userNameLabel.textColor = UIColor(red: 213 / 255, green: 224 / 255, blue: 242 / 255, alpha: 1)
        userNameLabel.font = UIFont.boldSystemFont(ofSize: 18.0)
        userNameLabel.backgroundColor = UIColor.clear
        userNameLabel.textAlignment = .center
        return userNameLabel
    }()
    
    let callStatusTipView: UILabel = {
        let callStatusTipLabel = UILabel(frame: CGRect.zero)
        callStatusTipLabel.textColor = UIColor(red: 197 / 255, green: 204 / 255, blue: 219 / 255, alpha: 1)
        callStatusTipLabel.font = UIFont.boldSystemFont(ofSize: 12.0)
        callStatusTipLabel.textAlignment = .left
        return callStatusTipLabel
    }()
    
    lazy var rejectBtn: UIButton = {
        let btn = UIButton(type: .system)
        if let image =  BundleUtils.getBundleImage(name: "icon_hangup") {
            btn.setBackgroundImage(image, for: .normal)
        }
        btn.addTarget(self, action: #selector(rejectTouchEvent(sender: )), for: .touchUpInside)
        return btn
    }()
    
    lazy var acceptBtn: UIButton = {
        let btn = UIButton(type: .system)
        let imageStr = TUICallState.instance.mediaType.value == .video ? "icon_video_dialing" : "icon_dialing"
        if let image = BundleUtils.getBundleImage(name: imageStr) {
            btn.setBackgroundImage(image, for: .normal)
        }
        btn.addTarget(self, action: #selector(acceptTouchEvent(sender: )), for: .touchUpInside)
        return btn
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        userHeadImageView.layer.masksToBounds = true
        self.layer.cornerRadius = 10.0
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showCallView(sender:))))
        
        backgroundColor = UIColor(red: 34 / 255, green: 38 / 255, blue: 46 / 255, alpha: 1)

        let remoteUser = TUICallState.instance.remoteUserList.value.first ?? User()
        userNameLabel.text = User.getUserDisplayName(user: remoteUser)

        if let url = URL(string: remoteUser.avatar.value) {
            userHeadImageView.sd_setImage(with: url)
        }

        if TUICallState.instance.scene.value == TUICallScene.single {
            if TUICallState.instance.mediaType.value == TUICallMediaType.audio {
                if let str =  TUICallState.instance.mResourceDic["k_0000002"] as? String {
                    callStatusTipView.text = str
                }
            } else {
                if let str =  TUICallState.instance.mResourceDic["k_0000002_1"] as? String {
                    callStatusTipView.text = str
                }
            }
        } else {
            if let str =  TUICallState.instance.mResourceDic["k_0000003"] as? String {
                callStatusTipView.text = str
            }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
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
        addSubview(userHeadImageView)
        addSubview(userNameLabel)
        addSubview(callStatusTipView)
        addSubview(rejectBtn)
        addSubview(acceptBtn)
    }
    
    func activateConstraints() {
        self.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        userHeadImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16.scaleWidth())
            make.centerY.equalTo(self)
            make.width.height.equalTo(60.scaleWidth())
        }
        userNameLabel.snp.makeConstraints { make in
            make.top.equalTo(userHeadImageView).offset(10.scaleWidth())
            make.leading.equalTo(userHeadImageView.snp.trailing).offset(12.scaleWidth())
        }
        callStatusTipView.snp.makeConstraints { make in
            make.leading.equalTo(userHeadImageView.snp.trailing).offset(12.scaleWidth())
            make.bottom.equalTo(userHeadImageView).offset(-10.scaleWidth())
        }
        rejectBtn.snp.makeConstraints { make in
            make.trailing.equalTo(acceptBtn.snp.leading).offset(-22.scaleWidth())
            make.centerY.equalTo(self)
            make.width.height.equalTo(36.scaleWidth())
        }
        acceptBtn.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16.scaleWidth())
            make.centerY.equalTo(self)
            make.width.height.equalTo(36.scaleWidth())
        }
    }
    
    // MARK: Event Action
    @objc func showCallView(sender: UIButton) {
        if delegate != nil && ((delegate?.responds(to: Selector(("showCallingView")))) != nil) {
            delegate?.showCallingView()
        }
    }
    
    @objc func rejectTouchEvent(sender: UIButton) {
        TUICallEngine.createInstance().reject {
        } fail: { code, message in
        }

        if delegate != nil && ((delegate?.responds(to: Selector(("closeIncomingBannerView")))) != nil) {
            delegate?.closeIncomingBannerView()
        }
    }
    
    @objc func acceptTouchEvent(sender: UIButton) {
        TUICallEngine.createInstance().accept {
        } fail: { code, message in
        }
        
        if delegate != nil && ((delegate?.responds(to: Selector(("showCallingView")))) != nil) {
            delegate?.showCallingView()
        }
    }
}
