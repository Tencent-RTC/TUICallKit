//
//  FloatWindowGroupView.swift
//  Pods
//
//  Created by vincepzhang on 2025/2/25.
//

import RTCCommon

class FloatWindowGroupView: UIView {
        
    private let selfCallStatusObserver = Observer()
    private let callTimeObserver = Observer()
    private var remoteUserVideoView: VideoView? = nil

    let shadowView: UIView = {
        let shadowView = UIView()
        shadowView.backgroundColor = TUICoreDefineConvert.getTUICallKitDynamicColor(colorKey: "callkit_float_window_bg_color",
                                                                                    defaultHex:  "#FFFFFF")
        shadowView.layer.shadowColor = UIColor(hex: "353941")?.cgColor
        shadowView.layer.shadowOpacity = 0.4
        shadowView.layer.shadowRadius = 4.scale375Width()
        shadowView.layer.shadowOffset = CGSize(width: 0, height: 0)
        shadowView.layer.cornerRadius = 12.scale375Width()
        return shadowView
    }()

    let containerView: UIView = {
        let containerView = UIView()
        containerView.backgroundColor = TUICoreDefineConvert.getTUICallKitDynamicColor(colorKey: "callkit_float_window_bg_color",
                                                                                       defaultHex:  "#FFFFFF")
        containerView.layer.cornerRadius = 12.scale375Width()
        containerView.layer.masksToBounds = true
        containerView.isUserInteractionEnabled = false
        return containerView
    }()
    
    let callStateView: UIView = {
        let containerView = UIView()
        containerView.backgroundColor = TUICoreDefineConvert.getTUICallKitDynamicColor(colorKey: "callkit_float_window_bg_color",
                                                                                       defaultHex:  "#FFFFFF")
        return containerView
    }()
    let imageView: UIImageView = {
        let imageView = UIImageView()
        if let image = CallKitBundle.getBundleImage(name: "icon_float_dialing") {
            imageView.image = image
        }
        imageView.isUserInteractionEnabled = false
        return imageView
    }()
    let describeLabel: UILabel = {
        let describeLabel = UILabel()
        describeLabel.font = UIFont.systemFont(ofSize: 12.0)
        describeLabel.textColor = UIColor(hex: "#12B969")
        describeLabel.textAlignment = .center
        describeLabel.isUserInteractionEnabled = false
        describeLabel.text = TUICallKitLocalize(key: "TUICallKit.FloatingWindow.waitAccept") ?? ""
        return describeLabel
    }()
    
    let mediaStatusView: UIView = UIView()
    let videoImageView: UIImageView = {
        let imageView = UIImageView()
        let imageName = CallManager.shared.mediaState.isCameraOpened.value ? "icon_float_group_video_on" : "icon_float_group_video_off"
        if let image = CallKitBundle.getBundleImage(name: imageName) {
            imageView.image = image
        }
        return imageView
    }()
    
    let audioImageView: UIImageView = {
        let imageView = UIImageView()
        let imageName = CallManager.shared.mediaState.isMicrophoneMuted.value ? "icon_float_group_audio_off" : "icon_float_group_audio_on"
        if let image = CallKitBundle.getBundleImage(name: imageName) {
            imageView.image = image
        }
        return imageView
    }()

    // MARK: init、 deinit
    override init(frame: CGRect) {
        super.init(frame: frame)
        registerObserver()
        
        constructViewHierarchy()
        activateConstraints()
        
        setCallStateView()
        setCurrentSpeakerView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        unregisterObserver()
    }
    
    func constructViewHierarchy() {
        addSubview(shadowView)
        addSubview(containerView)
        
        containerView.addSubview(callStateView)
        callStateView.addSubview(imageView)
        callStateView.addSubview(describeLabel)
        
        containerView.addSubview(mediaStatusView)
        mediaStatusView.addSubview(videoImageView)
        mediaStatusView.addSubview(audioImageView)
    }
    
    func activateConstraints() {
        containerView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.top.equalTo(8.scale375Width())
        }
        shadowView.snp.makeConstraints { make in
            make.edges.equalTo(containerView)
        }

        callStateView.snp.makeConstraints { make in
            make.top.centerX.equalTo(containerView)
            make.width.height.equalTo(72.scale375Width())
        }
        imageView.snp.makeConstraints { make in
            make.top.equalTo(callStateView).offset(8.scale375Width())
            make.centerX.equalTo(callStateView)
            make.width.height.equalTo(36.scale375Width())
        }
        describeLabel.snp.makeConstraints { make in
            make.centerX.width.equalTo(callStateView)
            make.top.equalTo(imageView.snp.bottom).offset(4.scale375Width())
            make.height.equalTo(20.scale375Width())
        }
        
        mediaStatusView.snp.makeConstraints { make in
            make.centerX.width.equalTo(containerView)
            make.bottom.equalTo(containerView)
            make.height.equalTo(20.scale375Width())
        }
        videoImageView.snp.makeConstraints { make in
            make.centerY.equalTo(mediaStatusView)
            make.leading.equalTo(mediaStatusView).offset(14.scale375Width())
            make.width.height.equalTo(16.scale375Width())
        }
        audioImageView.snp.makeConstraints { make in
            make.centerY.equalTo(mediaStatusView)
            make.trailing.equalTo(mediaStatusView).offset(-14.scale375Width())
            make.width.height.equalTo(16.scale375Width())
        }
    }
        
    // MARK: Register TUICallState Observer && Update UI
    func registerObserver() {
        CallManager.shared.userState.selfUser.callStatus.addObserver(selfCallStatusObserver, closure: { [weak self] newValue, _ in
            guard let self = self else { return }
            self.setCallStateView()
            self.setCurrentSpeakerView()
        })

        CallManager.shared.callState.callDurationCount.addObserver(callTimeObserver, closure: { [weak self] newValue, _ in
            guard let self = self else { return }
            self.setCallStateView()
            self.setCurrentSpeakerView()
        })
    }
    
    func unregisterObserver() {
        CallManager.shared.userState.selfUser.callStatus.removeObserver(selfCallStatusObserver)
        CallManager.shared.callState.callDurationCount.removeObserver(callTimeObserver)
    }
    
    // MARK: Update UI
    func setCallStateView() {
        if CallManager.shared.userState.selfUser.callStatus.value == .waiting {
            describeLabel.text = TUICallKitLocalize(key: "TUICallKit.FloatingWindow.waitAccept")
        } else if CallManager.shared.userState.selfUser.callStatus.value == .accept {
            describeLabel.text = GCDTimer.secondToHMSString(second: CallManager.shared.callState.callDurationCount.value)
        }
    }
    
    func setCurrentSpeakerView() {
        remoteUserVideoView?.removeFromSuperview()

        guard let user = getCurrentSpeakerUser() else { return }
        guard let videoView = VideoFactory.shared.createVideoView(user: user, isShowFloatWindow: true) else { return }
        remoteUserVideoView = videoView
        addSubview(videoView)
        videoView.snp.makeConstraints { make in
            make.top.centerX.equalTo(containerView)
            make.width.height.equalTo(72.scale375Width())
        }
        
        if user.id.value != CallManager.shared.userState.selfUser.id.value {
            CallManager.shared.startRemoteView(user: user, videoView: videoView.getVideoView())
        }
    }
    
    func getCurrentSpeakerUser() -> User? {
        for user in CallManager.shared.userState.remoteUserList.value {
            if user.playoutVolume.value >= 10 {
                return user
            }
        }
        if CallManager.shared.userState.selfUser.playoutVolume.value >= 10 {
            return CallManager.shared.userState.selfUser
        }
        return nil
    }
}
