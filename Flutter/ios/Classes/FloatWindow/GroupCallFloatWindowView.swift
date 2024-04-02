//
//  GroupCallFloatWindowView.swift
//  HydraAsync
//
//  Created by vincepzhang on 2023/6/27.
//

import Foundation
import TUICallEngine

class GroupCallFloatWindowView: FloatWindowView {
    
    let viewModel = FloatWindowViewModel()
    
    let selfCallStatusObserver = Observer()
    let mediaTypeObserver = Observer()
    let timeCountObserver = Observer()
    let currentSpeakUserObserver = Observer()
    let currentSpeakUserVideoAvailableObserver = Observer()
    
    let isCameraOpenObserver = Observer()
    let isMicMuteObserver = Observer()
    
    // Status UI
    let statusContainerView: UIView = {
        let containerView = UIView()
        containerView.backgroundColor = UIColor(red: 249 / 255, green: 246 / 255, blue: 244 / 255, alpha: 1)
        containerView.isUserInteractionEnabled = false
        return containerView
    }()
    
    let videoImageView: UIImageView = {
        let imageView = UIImageView()
        let imageName = TUICallState.instance.isCameraOpen.value ? "icon_float_group_video_on" : "icon_float_group_video_off"
        if let image = BundleUtils.getBundleImage(name: imageName) {
            imageView.image = image
        }
        return imageView
    }()
    
    let audioImageView: UIImageView = {
        let imageView = UIImageView()
        let imageName = TUICallState.instance.isMicrophoneMute.value ? "icon_float_group_audio_off" : "icon_float_group_audio_on"
        if let image = BundleUtils.getBundleImage(name: imageName) {
            imageView.image = image
        }
        return imageView
    }()
    
    // Calling and Timer UI
    let callingIconContainerView: UIView = {
        let containerView = UIView()
        containerView.backgroundColor = UIColor.white
        containerView.isUserInteractionEnabled = false
        return containerView
    }()
    
    let dialingImageView: UIImageView = {
        let imageView = UIImageView()
        if let image = BundleUtils.getBundleImage(name: "icon_float_dialing"){
            imageView.image = image
        }
        
        imageView.isUserInteractionEnabled = false
        return imageView
    }()
    
    let describeAndTimerLabel: UILabel = {
        let describeLabel = UILabel()
        describeLabel.font = UIFont.systemFont(ofSize: 12.0)
        describeLabel.textColor = UIColor(red: 28 / 255, green: 176 / 255, blue: 86 / 255, alpha: 1)
        describeLabel.textAlignment = .center
        describeLabel.isUserInteractionEnabled = false
        return describeLabel
    }()
    
    // Video Rander 、 Avatar、 userName UI
    let userContainerView: UIView = {
        let containerView = UIView()
        containerView.backgroundColor = UIColor.white
        containerView.isUserInteractionEnabled = false
        return containerView
    }()
    
    lazy var userRenderView: TUIVideoView = {
        let view = TUIVideoView(frame: CGRect.zero)
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 5.scaleWidth()
        return view
    }()

    lazy var userAvatarImageView: UIImageView = {
        let avatarImageView = UIImageView()
        avatarImageView.contentMode = .scaleAspectFill
        avatarImageView.clipsToBounds = true
        avatarImageView.isUserInteractionEnabled = false
        avatarImageView.layer.masksToBounds = true
        avatarImageView.layer.cornerRadius = 5.scaleWidth()
        return avatarImageView
    }()
    
    let userNameLabel: UILabel = {
        let describeLabel = UILabel()
        describeLabel.font = UIFont.systemFont(ofSize: 12.0)
        describeLabel.textColor = UIColor(red: 28 / 255, green: 176 / 255, blue: 86 / 255, alpha: 1)
        describeLabel.textAlignment = .center
        describeLabel.isUserInteractionEnabled = false
        return describeLabel
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        registerObserveState()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        
    }
    
    //MARK: UI Specification Processing
    private var isViewReady: Bool = false
    override func didMoveToWindow() {
        super.didMoveToWindow()
        if isViewReady { return }
        constructViewHierarchy()
        activateConstraints()
        bindInteraction()
        isViewReady = true
        
        updateUI()
    }
    
    func constructViewHierarchy() {
        addSubview(statusContainerView)
        statusContainerView.addSubview(audioImageView)
        statusContainerView.addSubview(videoImageView)
        
        addSubview(callingIconContainerView)
        callingIconContainerView.addSubview(dialingImageView)
        callingIconContainerView.addSubview(describeAndTimerLabel)
        
        addSubview(userContainerView)
        userContainerView.addSubview(userRenderView)
        userContainerView.addSubview(userAvatarImageView)
        userContainerView.addSubview(userNameLabel)
    }
    
    func activateConstraints() {
        statusContainerView.snp.makeConstraints { make in
            make.centerX.width.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(20.scaleWidth())
        }
        
        videoImageView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(14.scaleWidth())
            make.width.height.equalTo(16.scaleWidth())
        }
        
        audioImageView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().offset(-14.scaleWidth())
            make.width.height.equalTo(16.scaleWidth())
        }
        
        
        callingIconContainerView.snp.makeConstraints { make in
            make.centerX.width.top.equalToSuperview()
            make.bottom.equalTo(statusContainerView.snp.top)
        }
        
        dialingImageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(8.scaleWidth())
            make.width.height.equalTo(36.scaleWidth())
        }
        
        describeAndTimerLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(48.scaleWidth())
            make.height.equalTo(16.scaleWidth())
        }
        
        userContainerView.snp.makeConstraints { make in
            make.centerX.width.top.equalToSuperview()
            make.bottom.equalTo(statusContainerView.snp.top)
        }
        
        userRenderView.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
            make.width.height.equalTo(60.scaleWidth())
        }
        
        userAvatarImageView.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
            make.width.height.equalTo(60.scaleWidth())
        }
        
        userNameLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(48.scaleWidth())
            make.height.equalTo(16.scaleWidth())
        }
    }
    
    func bindInteraction() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapGestureAction(tapGesture: )))
        let pan = UIPanGestureRecognizer(target: self, action: #selector(panGestureAction(panGesture: )))
        addGestureRecognizer(tap)
        pan.require(toFail: tap)
        addGestureRecognizer(pan)
    }
    
    //MARK: Action Event
    @objc func tapGestureAction(tapGesture: UITapGestureRecognizer) {
        if delegate != nil && ((delegate?.responds(to: Selector(("tapGestureAction")))) != nil) {
            delegate?.tapGestureAction(tapGesture: tapGesture)
        }
    }
    
    @objc func panGestureAction(panGesture: UIPanGestureRecognizer) {
        if delegate != nil && ((delegate?.responds(to: Selector(("panGestureAction")))) != nil) {
            delegate?.panGestureAction(panGesture: panGesture)
        }
    }
    
    // MARK: Register TUICallState Observer && Update UI
    func registerObserveState() {
        viewModel.selfCallStatus.addObserver(selfCallStatusObserver, closure: { [weak self] newValue, _ in
            guard let self = self else { return }
            self.updateUI()
        })
        
                
        viewModel.timeCount.addObserver(timeCountObserver) {[weak self] newValue, _ in
            guard let self = self else { return }
            self.updateUI()
        }
        
        viewModel.isMicMute.addObserver(isMicMuteObserver) {[weak self] newValue, _ in
            guard let self = self else { return }
            self.setMicAndCameraStatus()
        }

        viewModel.isCameraOpen.addObserver(isCameraOpenObserver) {[weak self] newValue, _ in
            guard let self = self else { return }
            self.setMicAndCameraStatus()
        }
        
        viewModel.currentSpeakUser.addObserver(currentSpeakUserObserver, closure: { [weak self] newValue, _ in
            guard let self = self else { return }
                self.updateUI()
        })
        
        viewModel.currentSpeakUser.value.videoAvailable.addObserver(currentSpeakUserVideoAvailableObserver, closure: { [weak self] newValue, _ in
            guard let self = self else { return }
            self.updateUI()
        })
    }

    //MARK: Update UI
    func updateUI() {
        if viewModel.selfCallStatus.value == .waiting {
            setWaitingUI()
            return
        }
        
        if viewModel.selfCallStatus.value == .accept {
            setAcceptUI()
            return
        }
    }
    
    func setWaitingUI() {
        userContainerView.isHidden = true
        callingIconContainerView.isHidden = false
        describeAndTimerLabel.text = TUICallState.instance.mResourceDic["k_0000088"] as? String
    }
    
    func setAcceptUI() {
        if viewModel.currentSpeakUser.value.id.value == "" {
            userContainerView.isHidden = true
            callingIconContainerView.isHidden = false
            describeAndTimerLabel.text = viewModel.getCallTimeString()
            return
        }
        
        if viewModel.currentSpeakUser.value.videoAvailable.value == false {
            userContainerView.isHidden = false
            callingIconContainerView.isHidden = true
            userRenderView.isHidden = true
            userAvatarImageView.isHidden = false
            userAvatarImageView.sd_setImage(with: URL(string: viewModel.currentSpeakUser.value.avatar.value), placeholderImage: BundleUtils.getBundleImage(name: "userIcon"))
            describeAndTimerLabel.text = viewModel.getCallTimeString()
            return
        }
        
        userContainerView.isHidden = false
        callingIconContainerView.isHidden = true
        userRenderView.isHidden = false
        userAvatarImageView.isHidden = true
        describeAndTimerLabel.text = viewModel.getCallTimeString()
        if viewModel.currentSpeakUser.value.id.value == TUICallState.instance.selfUser.value.id.value {
            viewModel.openCamera(videoView: userRenderView)
        } else {
            viewModel.startRemoteView(userId: viewModel.currentSpeakUser.value.id.value, videoView: userRenderView)
        }
    }
    
    func setMicAndCameraStatus() {
        let audioImageName = TUICallState.instance.isMicrophoneMute.value ? "icon_float_group_audio_off" : "icon_float_group_audio_on"
        if let image = BundleUtils.getBundleImage(name: audioImageName) {
            audioImageView.image = image
        }

        let videoImageName = TUICallState.instance.isCameraOpen.value ? "icon_float_group_video_on" : "icon_float_group_video_off"
        if let image = BundleUtils.getBundleImage(name: videoImageName) {
            videoImageView.image = image
        }
    }
}
