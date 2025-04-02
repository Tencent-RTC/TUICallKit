//
//  VideoView.swift
//  Pods
//
//  Created by vincepzhang on 2025/2/19.
//

import SnapKit
import UIKit
import RTCCommon
import RTCRoomEngine

@objc protocol GestureViewDelegate: NSObjectProtocol {
    @objc optional func tapGestureAction(tapGesture: UITapGestureRecognizer)
    @objc optional func panGestureAction(panGesture: UIPanGestureRecognizer)
}

class VideoView: UIView, GestureViewDelegate {
    private let videoAvailableObserver = Observer()
    private let avatarObserver = Observer()
    private let nicknameObserver = Observer()
    private let callStatusObserver = Observer()
    private let playoutVolumeObserver = Observer()
    private let networkQualityReminderObserver = Observer()
    private let showLargeViewUserIdObserver = Observer()
    private let callingViewTypeObserver = Observer()
    private let isVirtualBackgroundOpenedObserver = Observer()
    
    weak var delegate: GestureViewDelegate?

    private var isViewReady: Bool = false
    private var user: User
    private var isShowFloatWindow: Bool
    
    private let gestureView = UIView()
    private let videoView = UIView()
    private lazy var backgroundAvatarView: UIImageView = {
        let backgroundAvatarView = UIImageView(frame: CGRect.zero)
        backgroundAvatarView.contentMode = .scaleAspectFill
        backgroundAvatarView.clipsToBounds = true
        backgroundAvatarView.sd_setImage(with:  URL(string: user.avatar.value), placeholderImage: CallKitBundle.getBundleImage(name: "default_user_icon"))
        return backgroundAvatarView
    }()
    private let backgroundFilterView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.alpha = 0.85
        return blurEffectView
    }()
    private let imageAudioInputView = {
        let imageView = UIImageView(frame: CGRect.zero)
        imageView.contentMode = .scaleAspectFill
        if let image = CallKitBundle.getBundleImage(name: "icon_volume") {
            imageView.image = image
        }
        return imageView
    }()
    private lazy var avatarView: UIImageView = {
        let avatarView = UIImageView(frame: CGRect.zero)
        avatarView.layer.masksToBounds = true
        avatarView.layer.cornerRadius = 6.0
        avatarView.sd_setImage(with:  URL(string: user.avatar.value), placeholderImage: CallKitBundle.getBundleImage(name: "default_user_icon"))
        return avatarView
    }()
    private let networkBadView = {
        let imageView = UIImageView(frame: CGRect.zero)
        imageView.contentMode = .scaleAspectFill
        if let image = CallKitBundle.getBundleImage(name: "group_network_low_quality") {
            imageView.image = image
        }
        return imageView
    }()
    private let switchCameraBtn: UIButton = {
        let btn = UIButton(type: .system)
        btn.contentMode = .scaleAspectFit
        if let image = CallKitBundle.getBundleImage(name: "group_switch_camera") {
            btn.setBackgroundImage(image, for: .normal)
        }
        btn.addTarget(self, action: #selector(switchCameraTouchEvent(sender:)), for: .touchUpInside)
        return btn
    }()
    private let virtualBackgroundBtn: UIButton = {
        let btn = UIButton(type: .system)
        btn.contentMode = .scaleAspectFit
        let imageName = CallManager.shared.viewState.isVirtualBackgroundOpened.value ? "group_virtual_background_on" : "group_virtual_background_off"
        if let image = CallKitBundle.getBundleImage(name: imageName) {
            btn.setBackgroundImage(image, for: .normal)
        }
        btn.addTarget(self, action: #selector(virtualBackgroundTouchEvent(sender:)), for: .touchUpInside)
        return btn
    }()
    private let loadingView = {
        let view = MultiCallLoadingView()
        view.backgroundColor = .clear
        return view
    }()
    private lazy var nicknameView = {
        let titleLabel = UILabel(frame: CGRect.zero)
        titleLabel.textColor = Color_White
        titleLabel.font = UIFont.systemFont(ofSize: 12)
        titleLabel.text = UserManager.getUserDisplayName(user: user)
        titleLabel.textAlignment = TUICoreDefineConvert.getIsRTL() ? .right : .left
        return titleLabel
    }()

    //MARK: init,deinit
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(user: User, isShowFloatWindow: Bool) {
        self.user = user
        self.isShowFloatWindow = isShowFloatWindow
        super.init(frame: CGRect.zero)
        
        updateView()
        registerObserver()
    }
    
    deinit {
        unregisterobserver()
    }
    
    // MARK: Public Method
    func getVideoView() -> UIView {
        return videoView
    }
    
    func setIsShowFloatWindow(isShowFloatWindow: Bool) {
        self.isShowFloatWindow = isShowFloatWindow
        updateView()
    }
        
    // MARK: UI Specification Processing
    override func didMoveToWindow() {
        super.didMoveToWindow()
        if isViewReady { return }
        isViewReady = true
        constructViewHierarchy()
        activateConstraints()
        bindInteraction()
    }
    
    private func constructViewHierarchy() {
        addSubview(backgroundAvatarView)
        addSubview(backgroundFilterView)
        addSubview(videoView)
        addSubview(nicknameView)
        addSubview(avatarView)
        addSubview(loadingView)
        addSubview(imageAudioInputView)
        addSubview(networkBadView)
        addSubview(switchCameraBtn)
        addSubview(virtualBackgroundBtn)
        addSubview(gestureView)
    }
    
    private func activateConstraints() {
        gestureView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        backgroundAvatarView.snp.makeConstraints { make in
            make.size.equalToSuperview()
        }
        
        backgroundFilterView.snp.makeConstraints { make in
            make.size.equalToSuperview()
        }
        
        videoView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
                
        if CallManager.shared.viewState.callingViewType.value == .one2one {
            avatarView.snp.makeConstraints { make in
                make.center.equalToSuperview()
                make.width.height.equalTo(self.snp.width).multipliedBy(0.3)
            }
        } else {
            avatarView.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
        }

        loadingView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.height.width.equalToSuperview().multipliedBy(0.5)
        }

        imageAudioInputView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16.scale375Width())
            make.bottom.equalToSuperview().offset(-16.scale375Width())
            make.width.height.equalTo(24.scale375Width())
        }
        
        nicknameView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16.scale375Width())
            make.bottom.equalToSuperview().offset(-16.scale375Width())
            make.height.equalTo(24.scale375Width())
        }
        
        virtualBackgroundBtn.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16.scale375Width())
            make.bottom.equalToSuperview().offset(-16.scale375Width())
            make.width.height.equalTo(24.scale375Width())
        }
        
        switchCameraBtn.snp.makeConstraints { make in
            make.trailing.equalTo(virtualBackgroundBtn.snp.leading).offset(-16.scale375Width())
            make.bottom.equalToSuperview().offset(-16.scale375Width())
            make.width.height.equalTo(24.scale375Width())
        }

        networkBadView.snp.makeConstraints { make in
            make.trailing.equalTo(switchCameraBtn.snp.leading).offset(-16.scale375Width())
            make.bottom.equalToSuperview().offset(-16.scale375Width())
            make.width.height.equalTo(24.scale375Width())
        }
    }
    
    private func bindInteraction() {
        gestureView.backgroundColor = UIColor.clear
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapGesture(tapGesture: )))
        let pan = UIPanGestureRecognizer(target: self, action: #selector(panGesture(panGesture: )))
        gestureView.addGestureRecognizer(tap)
        pan.require(toFail: tap)
        gestureView.addGestureRecognizer(pan)
    }

    // MARK: Action Event
    @objc func switchCameraTouchEvent(sender: UIButton) {
        CallManager.shared.switchCamera()
    }
    
    @objc func virtualBackgroundTouchEvent(sender: UIButton ) {
        CallManager.shared.setBlurBackground()
    }

    // MARK: Observer
    private func registerObserver() {
        user.videoAvailable.addObserver(videoAvailableObserver) { [weak self] newValue, _ in
            guard let self = self else { return }
            self.updateVideoView()
            self.updateAvatarView()
        }
                
        user.callStatus.addObserver(callStatusObserver) { [weak self] newValue, _ in
            guard let self = self else { return }
            self.updateLoadingView()
        }
        
        user.playoutVolume.addObserver(playoutVolumeObserver) { [weak self] newValue, _ in
            guard let self = self else { return }
            self.updateAudioInputView()
            self.updateNicknameView()
        }
        
        user.networkQualityReminder.addObserver(networkQualityReminderObserver) { [weak self] newValue, _ in
            guard let self = self else { return }
            self.updateNetworkQualityView()
        }
        
        CallManager.shared.viewState.showLargeViewUserId.addObserver(showLargeViewUserIdObserver) { [weak self] newValue, _ in
            guard let self = self else { return }
            self.updateSwtchCameraBtn()
            self.updateVirtualBackgroundBtn()
        }
        
        CallManager.shared.viewState.callingViewType.addObserver(callingViewTypeObserver) { [weak self] newValue, _ in
            guard let self = self else { return }
            self.updateGestureView()
        }
        
        CallManager.shared.viewState.isVirtualBackgroundOpened.addObserver(isVirtualBackgroundOpenedObserver){ [weak self] newValue, _ in
            guard let self = self else { return }
            self.updateVirtualBackgroundBtn()
        }
    }
    
    private func unregisterobserver() {
        user.videoAvailable.removeObserver(videoAvailableObserver)
        user.avatar.removeObserver(avatarObserver)
        user.nickname.removeObserver(nicknameObserver)
        user.callStatus.removeObserver(callStatusObserver)
        user.playoutVolume.removeObserver(playoutVolumeObserver)
        user.networkQualityReminder.removeObserver(networkQualityReminderObserver)
        CallManager.shared.viewState.showLargeViewUserId.removeObserver(showLargeViewUserIdObserver)
        CallManager.shared.viewState.callingViewType.removeObserver(callingViewTypeObserver)
    }
    
    // MARK: Config View
    private func updateView() {
        cleanView()
        
        updateVideoView()
        updateAvatarView()
        updateLoadingView()
        updateAudioInputView()
        updateNicknameView()
        updateNetworkQualityView()
        updateSwtchCameraBtn()
        updateVirtualBackgroundBtn()
        updateGestureView()
    }
        
    private func updateVideoView() {
        videoView.isHidden = true

        if CallManager.shared.viewState.callingViewType.value == .multi {
            videoView.isHidden = false
            return
        }
        
        if (user.id.value == CallManager.shared.userState.selfUser.id.value && user.videoAvailable.value) ||
            (user.id.value != CallManager.shared.userState.selfUser.id.value && user.videoAvailable.value && user.callStatus.value == .accept) {
            videoView.isHidden = false
        }
    }
    
    private func updateAvatarView() {
        avatarView.isHidden = true

        if CallManager.shared.viewState.callingViewType.value == .multi {
            if user.videoAvailable.value == false {
                avatarView.isHidden = false
            }
            return
        }
        
        if CallManager.shared.viewState.callingViewType.value == .one2one {
            if CallManager.shared.callState.mediaType.value == .video && user.videoAvailable.value == false && user.callStatus.value == .accept {
                avatarView.isHidden = false
            }
            return
        }
    }
    
    private func updateLoadingView() {        
        loadingView.isHidden = true
        loadingView.stopAnimating()
        if isShowFloatWindow { return }
        if CallManager.shared.viewState.callingViewType.value == .one2one { return }
        
        if user.id.value != CallManager.shared.userState.selfUser.id.value &&
            user.callStatus.value == .waiting {
            loadingView.isHidden = false
            loadingView.startAnimating()
        }
    }
    
    private func updateAudioInputView() {
        imageAudioInputView.isHidden = true
        if isShowFloatWindow { return }

        if user.playoutVolume.value > 5 && CallManager.shared.viewState.callingViewType.value == .multi {
            imageAudioInputView.isHidden = false
        }
    }

    private func updateNicknameView() {
        nicknameView.isHidden = true
        if isShowFloatWindow { return }

        if user.playoutVolume.value <= 5 &&
            CallManager.shared.viewState.callingViewType.value == .multi &&
            CallManager.shared.viewState.showLargeViewUserId.value == user.id.value {
            nicknameView.isHidden = false
        }
    }
    
    private func updateNetworkQualityView() {
        networkBadView.isHidden = true
        if isShowFloatWindow { return }

        if user.networkQualityReminder.value == true && CallManager.shared.viewState.callingViewType.value == .multi {
            networkBadView.isHidden = false
        }
    }
    
    private func updateSwtchCameraBtn() {
        if isShowFloatWindow {
            switchCameraBtn.isHidden = true
            return
        }

        let selfUser = CallManager.shared.userState.selfUser
        let largeViewUserId = CallManager.shared.viewState.showLargeViewUserId.value
        if user.videoAvailable.value && user.id.value == selfUser.id.value && user.id.value == largeViewUserId && !isShowFloatWindow &&
            CallManager.shared.viewState.callingViewType.value == .multi {
            switchCameraBtn.isHidden = false
        } else {
            switchCameraBtn.isHidden = true
        }
    }
    
    private func updateVirtualBackgroundBtn() {
        if isShowFloatWindow {
            virtualBackgroundBtn.isHidden = true
            return
        }
    
        let selfUser = CallManager.shared.userState.selfUser
        let largeViewUserId = CallManager.shared.viewState.showLargeViewUserId.value
        if user.videoAvailable.value && user.id.value == selfUser.id.value &&
            user.id.value == largeViewUserId && !isShowFloatWindow &&
            CallManager.shared.globalState.enableVirtualBackgroud &&
            CallManager.shared.viewState.callingViewType.value == .multi{
            virtualBackgroundBtn.isHidden = false
            let imageName = CallManager.shared.viewState.isVirtualBackgroundOpened.value ? "group_virtual_background_on" : "group_virtual_background_off"
            if let image = CallKitBundle.getBundleImage(name: imageName) {
                virtualBackgroundBtn.setBackgroundImage(image, for: .normal)
            }
        } else {
            virtualBackgroundBtn.isHidden = true
        }
    }
        
    private func updateGestureView() {
        gestureView.isHidden = true
        if CallManager.shared.viewState.callingViewType.value == .one2one && isShowFloatWindow == false {
            gestureView.isHidden = false
        }
    }
    
    private func cleanView() {
        avatarView.isHighlighted = true
        loadingView.isHidden = true
        videoView.isHidden = true
        imageAudioInputView.isHidden = true
        networkBadView.isHidden = true
        switchCameraBtn.isHidden = true
        virtualBackgroundBtn.isHidden = true
        nicknameView.isHidden = true
    }
    
    // MARK: Gesture Action
    @objc func tapGesture(tapGesture: UITapGestureRecognizer) {
        if self.delegate != nil && ((self.delegate?.responds(to: Selector(("tapGestureAction")))) != nil) {
            self.delegate?.tapGestureAction?(tapGesture: tapGesture)
        }
    }
    
    @objc func panGesture(panGesture: UIPanGestureRecognizer) {
        if self.delegate != nil && ((self.delegate?.responds(to: Selector(("panGestureAction")))) != nil) {
            self.delegate?.panGestureAction?(panGesture: panGesture)
        }
    }
}
