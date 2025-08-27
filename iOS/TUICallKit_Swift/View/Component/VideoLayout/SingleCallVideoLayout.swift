//
//  SingleCallVideoLayout.swift
//  Pods
//
//  Created by vincepzhang on 2025/2/19.
//

import UIKit
import RTCCommon
import RTCRoomEngine

private let kCallKitSingleSmallVideoViewWidth = 100.0

class SingleCallVideoLayout: UIView, GestureViewDelegate {
    private let callStatusObserver = Observer()
    private let isVirtualBackgroundOpenedObserver = Observer()

    private var isViewReady: Bool = false
    private var selfUserIsLarge = true
    
    private var selfVideoView: VideoView {
        guard let videoView = VideoFactory.shared.createVideoView(user: CallManager.shared.userState.selfUser, isShowFloatWindow: false) else {
            Logger.error("SingleCallVideoLayout->selfVideoView, create video view failed")
            return VideoView(user: CallManager.shared.userState.selfUser, isShowFloatWindow: false)
        }
        return videoView
    }
    
    private var remoteVideoView: VideoView {
        if let remoteUser = CallManager.shared.userState.remoteUserList.value.first {
            if let videoView = VideoFactory.shared.createVideoView(user: remoteUser, isShowFloatWindow: false) {
                return videoView
            }
        }
        Logger.error("SingleCallVideoLayout->remoteVideoView, create video view failed")
        return VideoView(user: User(), isShowFloatWindow: false)
    }
    
    private let userHeadImageView: UIImageView = {
        let userHeadImageView = UIImageView(frame: CGRect.zero)
        userHeadImageView.layer.masksToBounds = true
        userHeadImageView.layer.cornerRadius = 6.0
        if let user = CallManager.shared.userState.remoteUserList.value.first {
            userHeadImageView.sd_setImage(with: URL(string: user.avatar.value), placeholderImage: CallKitBundle.getBundleImage(name: "default_user_icon"))
        }
        return userHeadImageView
    }()
    
    private let userNameLabel: UILabel = {
        let userNameLabel = UILabel(frame: CGRect.zero)
        userNameLabel.textColor = UIColor(hex: "#D5E0F2")
        userNameLabel.font = UIFont.boldSystemFont(ofSize: 18.0)
        userNameLabel.backgroundColor = UIColor.clear
        userNameLabel.textAlignment = .center
        if let user = CallManager.shared.userState.remoteUserList.value.first {
            userNameLabel.text = UserManager.getUserDisplayName(user: user)
        }
        return userNameLabel
    }()
        
    // MARK: Init, deinit
    override init(frame: CGRect) {
        super.init(frame: frame)
        updateView()
        registerObserver()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        unregisterobserver()
    }
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        if isViewReady { return }
        isViewReady = true
        constructViewHierarchy()
        activateConstraints()
        bindInteraction()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateVideoFrames()
    }
    
    @objc private func orientationChanged() {
        DispatchQueue.main.async {
            self.setNeedsLayout()
        }
    }
        
    private func constructViewHierarchy() {
        if CallManager.shared.callState.mediaType.value == .video {
            addSubview(selfVideoView)
        }
        addSubview(remoteVideoView)
        addSubview(userHeadImageView)
        addSubview(userNameLabel)
    }
    
    private func activateConstraints() {
        userHeadImageView.translatesAutoresizingMaskIntoConstraints = false 
        userNameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            userHeadImageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            userHeadImageView.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -100.scale375Width()),
            userHeadImageView.widthAnchor.constraint(equalToConstant: 100.scale375Width()),
            userHeadImageView.heightAnchor.constraint(equalToConstant: 100.scale375Width()),
            
            userNameLabel.topAnchor.constraint(equalTo: userHeadImageView.bottomAnchor, constant: 10.scale375Height()),
            userNameLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            userNameLabel.widthAnchor.constraint(equalTo: widthAnchor),
            userNameLabel.heightAnchor.constraint(equalToConstant: 30)
        ])
        
        if CallManager.shared.callState.mediaType.value == .audio {
            remoteVideoView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                remoteVideoView.topAnchor.constraint(equalTo: topAnchor),
                remoteVideoView.leadingAnchor.constraint(equalTo: leadingAnchor),
                remoteVideoView.trailingAnchor.constraint(equalTo: trailingAnchor),
                remoteVideoView.bottomAnchor.constraint(equalTo: bottomAnchor)
            ])
        } else {
            remoteVideoView.translatesAutoresizingMaskIntoConstraints = true
            selfVideoView.translatesAutoresizingMaskIntoConstraints = true
            updateVideoFrames()
        }
    }
    
    private func updateVideoFrames() {
        guard CallManager.shared.callState.mediaType.value == .video else { return }
        
        let isLandscape = !WindowUtils.isPortrait
        let smallWidth = kCallKitSingleSmallVideoViewWidth
        let smallHeight = smallWidth / 9.0 * 16.0
        
        let smallFrame: CGRect = isLandscape ?
            CGRect(x: bounds.width - smallWidth - 20,
                   y: StatusBar_Height + 20,
                   width: smallWidth,
                   height: smallHeight) :
            CGRect(x: bounds.width - smallWidth - 10,
                   y: StatusBar_Height + 40,
                   width: smallWidth,
                   height: smallHeight)
        
        let largeFrame = bounds
        
        selfVideoView.frame = selfUserIsLarge ? largeFrame : smallFrame
        remoteVideoView.frame = selfUserIsLarge ? smallFrame : largeFrame
        bringSubviewToFront(selfUserIsLarge ? remoteVideoView : selfVideoView)
    }
    
    
    private func bindInteraction() {
        if CallManager.shared.callState.mediaType.value == .video {
            selfVideoView.delegate = self
        }
        remoteVideoView.delegate = self
    }
    
    // MARK: Observer
    private func registerObserver() {
        CallManager.shared.userState.selfUser.callStatus.addObserver(callStatusObserver) { [weak self] newValue, _ in
            guard let self = self else { return }
            if newValue == .none { return }
            self.updateView()
            self.switchPreview()
        }
        
        CallManager.shared.viewState.isVirtualBackgroundOpened.addObserver(isVirtualBackgroundOpenedObserver) { [weak self] newValue, _ in
            guard let self = self else { return }
            if newValue && !self.selfUserIsLarge {
                self.switchPreview()
            }
        }
        
        NotificationCenter.default.addObserver(self,
                                             selector: #selector(orientationChanged),
                                             name: UIDevice.orientationDidChangeNotification,
                                             object: nil)
    }
    
    private func unregisterobserver() {
        CallManager.shared.userState.selfUser.callStatus.removeObserver(callStatusObserver)
        CallManager.shared.viewState.isVirtualBackgroundOpened.removeObserver(isVirtualBackgroundOpenedObserver)
        NotificationCenter.default.removeObserver(self,
                                               name: UIDevice.orientationDidChangeNotification,
                                               object: nil)
    }
    
    private func updateView() {
        updateUserInfo()
        
        if CallManager.shared.callState.mediaType.value == .audio {
            remoteVideoView.isHidden = false
            return
        }
        
        if CallManager.shared.userState.selfUser.videoAvailable.value == false &&
           CallManager.shared.mediaState.isCameraOpened.value == true {
            CallManager.shared.openCamera(videoView: selfVideoView.getVideoView()) { }
            fail: { code, message in }
        }

        if CallManager.shared.userState.selfUser.callStatus.value == .waiting {
            remoteVideoView.isHidden = true
            selfVideoView.isHidden = false
        }
        
        if CallManager.shared.userState.selfUser.callStatus.value == .accept {
            remoteVideoView.isHidden = false
            selfVideoView.isHidden = false

            if let remoteUser = CallManager.shared.userState.remoteUserList.value.first {
                CallManager.shared.startRemoteView(user: remoteUser, videoView: remoteVideoView.getVideoView())
            }
        }
    }
    
    private func switchPreview() {
        guard CallManager.shared.callState.mediaType.value == .video else { return }
        
        selfUserIsLarge = !selfUserIsLarge
        UIView.animate(withDuration: 0.3) {
            self.updateVideoFrames()
        }
    }
    
    private func updateUserInfo() {
        if CallManager.shared.userState.selfUser.callStatus.value == .accept &&
           CallManager.shared.callState.mediaType.value == .video {
            userHeadImageView.isHidden = true
            userNameLabel.isHidden = true
        }
    }
    
    // MARK: Gesture Action
    @objc func tapGestureAction(tapGesture: UITapGestureRecognizer) {
        if  tapGesture.view?.frame.size.width == CGFloat(kCallKitSingleSmallVideoViewWidth) {
            switchPreview()
            return
        }
        
        if CallManager.shared.userState.selfUser.callStatus.value == .accept {
            CallManager.shared.viewState.isScreenCleaned.value = !CallManager.shared.viewState.isScreenCleaned.value
        }
    }
    
    @objc func panGestureAction(panGesture: UIPanGestureRecognizer) {
        guard let smallView = panGesture.view?.superview,
              smallView.frame.size.width == kCallKitSingleSmallVideoViewWidth else { return }
        
        if panGesture.state == .changed {
            let translation = panGesture.translation(in: self)
            let newCenterX = translation.x + smallView.center.x
            let newCenterY = translation.y + smallView.center.y
            
            let minX = smallView.bounds.width / 2
            let maxX = bounds.width - smallView.bounds.width / 2
            let minY = smallView.bounds.height / 2
            let maxY = bounds.height - smallView.bounds.height / 2
            
            let clampedX = min(max(newCenterX, minX), maxX)
            let clampedY = min(max(newCenterY, minY), maxY)
            
            UIView.animate(withDuration: 0.1) {
                smallView.center = CGPoint(x: clampedX, y: clampedY)
            }
            panGesture.setTranslation(.zero, in: self)
        }
    }
}
