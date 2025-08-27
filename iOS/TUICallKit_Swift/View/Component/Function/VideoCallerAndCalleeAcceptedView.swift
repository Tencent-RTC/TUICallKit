//
//  VideoCallerAndCalleeAcceptedView.swift
//  TUICallKit
//
//  Created by vincepzhang on 2023/2/14.
//
import Foundation
import RTCCommon

let groupFunctionAnimationDuration = 0.3
let groupFunctionBaseControlBtnHeight = 60.scale375Width() + 5.scale375Height() + 20
let groupFunctionBottomHeight = Bottom_SafeHeight > 1 ? Bottom_SafeHeight : 8
let groupFunctionViewHeight = 220.scale375Height()
let groupSmallFunctionViewHeight = 116.scale375Height()

enum VideoCallerFunctionViewMode {
    case expanded
    case collapsed
}

class VideoCallerAndCalleeAcceptedView: UIView {
    
    let isCameraOpenObserver = Observer()
    let showLargeViewUserIdObserver = Observer()
    let isMicMuteObserver = Observer()
    let audioDeviceObserver = Observer()

    private var currentMode: VideoCallerFunctionViewMode = .expanded
    let containerView = UIView()
    private lazy var muteMicBtn = createMuteMicBtn()
    private lazy var closeCameraBtn = createCloseCameraBtn()
    private let audioRoutePickerView = RoutePickerView()
    private lazy var audioRouteButton = createAudioRouteBtn()
    private lazy var hangupBtn = createHangupBtn()
    let switchCameraBtn: UIButton = {
        let btn = UIButton(type: .system)
        if let image = CallKitBundle.getBundleImage(name: "switch_camera") {
            btn.setBackgroundImage(image, for: .normal)
        }
        btn.addTarget(self, action: #selector(switchCameraTouchEvent(sender:)), for: .touchUpInside)
        return btn
    }()
    let virtualBackgroundButton: UIButton = {
        let btn = UIButton(type: .system)
        if let image = CallKitBundle.getBundleImage(name: "virtual_background") {
            btn.setBackgroundImage(image, for: .normal)
        }
        btn.addTarget(self, action: #selector(virtualBackgroundTouchEvent(sender:)), for: .touchUpInside)
        return btn
    }()
    let matchBtn: UIButton = {
        let btn = UIButton(type: .system)
        btn.addTarget(self, action:#selector(matchTouchEvent(sender:)), for: .touchUpInside)
        btn.setBackgroundImage(CallKitBundle.getBundleImage(name: "icon_match"), for: .normal)
        return btn
    }()

    private var activeConstraints: [NSLayoutConstraint] = []
    var timer = ""

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        unregisterObserve()
        GCDTimer.cancel(timerName: timer) {}
    }

    private func setup() {
        containerView.backgroundColor = UIColor(hex: "#4F586B")
        containerView.isUserInteractionEnabled = true
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        containerView.addGestureRecognizer(panGesture)

        timer = GCDTimer.start(interval: 1, repeats: true, async: true, task: { [weak self] in
            guard let self = self else { return }
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.updateAudioRouteButton()
            }
        })
        updateViewHidden()
        registerObserve()
    }

    private var isViewReady = false
    override func didMoveToWindow() {
        super.didMoveToWindow()
        if isViewReady { return }
        isViewReady = true
        constructViewHierarchy()
        activateConstraints()
        setContainerViewCorner()
    }
    
    func constructViewHierarchy() {
        addSubview(containerView)
        addSubview(muteMicBtn)
        addSubview(audioRouteButton)
        addSubview(closeCameraBtn)
        addSubview(hangupBtn)
        addSubview(switchCameraBtn)
        addSubview(virtualBackgroundButton)
        addSubview(audioRoutePickerView)
        addSubview(matchBtn)
    }
    
    private func removeActiveConstraints() {
        NSLayoutConstraint.deactivate(activeConstraints)
        activeConstraints.removeAll()
    }

    func activateConstraints() {
        removeActiveConstraints()
        
        containerView.translatesAutoresizingMaskIntoConstraints = false
        muteMicBtn.translatesAutoresizingMaskIntoConstraints = false
        audioRouteButton.translatesAutoresizingMaskIntoConstraints = false
        closeCameraBtn.translatesAutoresizingMaskIntoConstraints = false
        hangupBtn.translatesAutoresizingMaskIntoConstraints = false
        matchBtn.translatesAutoresizingMaskIntoConstraints = false
        switchCameraBtn.translatesAutoresizingMaskIntoConstraints = false
        virtualBackgroundButton.translatesAutoresizingMaskIntoConstraints = false
        audioRoutePickerView.translatesAutoresizingMaskIntoConstraints = false

        let isRTL = TUICoreDefineConvert.getIsRTL()
        let btnSize = 60.scale375Width()
        let btnSpacing: CGFloat = 110.scale375Width()
        let hangupYMargin: CGFloat = -50.scale375Height()
        let matchBtnLeading: CGFloat = 30.scale375Width()
        let sideBtnSize: CGFloat = 28.scale375Width()
        let callingType = CallManager.shared.viewState.callingViewType.value
        
        if callingType == .one2one {
            let verticalSpacing: CGFloat = 40.scale375Height()
            let horizontalSpacing: CGFloat = 60.scale375Width()
            
            activeConstraints += [
                containerView.widthAnchor.constraint(equalToConstant: 0),
                containerView.heightAnchor.constraint(equalToConstant: 0),
                
                hangupBtn.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -groupFunctionBottomHeight),
                hangupBtn.centerXAnchor.constraint(equalTo: centerXAnchor),
                hangupBtn.widthAnchor.constraint(equalToConstant: btnSize),
                hangupBtn.heightAnchor.constraint(equalToConstant: btnSize),

                virtualBackgroundButton.centerYAnchor.constraint(equalTo: hangupBtn.centerYAnchor),
                virtualBackgroundButton.trailingAnchor.constraint(equalTo: hangupBtn.leadingAnchor, constant: -horizontalSpacing),
                virtualBackgroundButton.widthAnchor.constraint(equalToConstant: sideBtnSize),
                virtualBackgroundButton.heightAnchor.constraint(equalToConstant: sideBtnSize),

                switchCameraBtn.centerYAnchor.constraint(equalTo: hangupBtn.centerYAnchor),
                switchCameraBtn.leadingAnchor.constraint(equalTo: hangupBtn.trailingAnchor, constant: horizontalSpacing),
                switchCameraBtn.widthAnchor.constraint(equalToConstant: sideBtnSize),
                switchCameraBtn.heightAnchor.constraint(equalToConstant: sideBtnSize),

                muteMicBtn.bottomAnchor.constraint(equalTo: hangupBtn.topAnchor, constant: -verticalSpacing),
                muteMicBtn.centerXAnchor.constraint(equalTo: centerXAnchor, constant: -btnSize - 40.scale375Width()),
                muteMicBtn.widthAnchor.constraint(equalToConstant: btnSize),
                muteMicBtn.heightAnchor.constraint(equalToConstant: btnSize),

                audioRouteButton.bottomAnchor.constraint(equalTo: muteMicBtn.bottomAnchor),
                audioRouteButton.centerXAnchor.constraint(equalTo: centerXAnchor),
                audioRouteButton.widthAnchor.constraint(equalToConstant: btnSize),
                audioRouteButton.heightAnchor.constraint(equalToConstant: btnSize),

                closeCameraBtn.bottomAnchor.constraint(equalTo: muteMicBtn.bottomAnchor),
                closeCameraBtn.centerXAnchor.constraint(equalTo: centerXAnchor, constant: btnSize + 40.scale375Width()),
                closeCameraBtn.widthAnchor.constraint(equalToConstant: btnSize),
                closeCameraBtn.heightAnchor.constraint(equalToConstant: btnSize),

                audioRoutePickerView.bottomAnchor.constraint(equalTo: audioRouteButton.bottomAnchor),
                audioRoutePickerView.centerXAnchor.constraint(equalTo: audioRouteButton.centerXAnchor),
                audioRoutePickerView.widthAnchor.constraint(equalToConstant: btnSize),
                audioRoutePickerView.heightAnchor.constraint(equalToConstant: btnSize)
            ]
        } else {
            let containerHeight: CGFloat = (currentMode == .collapsed) ? groupSmallFunctionViewHeight : groupFunctionViewHeight
            let containerLeading: CGFloat = 30.scale375Width()
            let containerTrailing: CGFloat = -30.scale375Width()
            let muteMicX: CGFloat = currentMode == .collapsed ? (isRTL ? btnSpacing : -btnSpacing) : (isRTL ? btnSpacing : -btnSpacing)
            let closeCameraX: CGFloat = currentMode == .collapsed ? (isRTL ? -btnSpacing : btnSpacing) : (isRTL ? -btnSpacing : btnSpacing)
            
            activeConstraints += [
                containerView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant:  !WindowUtils.isPortrait ? containerLeading : 0),
                containerView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: !WindowUtils.isPortrait ? containerTrailing : 0),
                containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
                containerView.heightAnchor.constraint(equalToConstant: containerHeight),
                
                hangupBtn.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -groupFunctionBottomHeight),
                hangupBtn.centerXAnchor.constraint(equalTo: centerXAnchor),
                hangupBtn.widthAnchor.constraint(equalToConstant: btnSize),
                hangupBtn.heightAnchor.constraint(equalToConstant: btnSize),

                audioRouteButton.bottomAnchor.constraint(equalTo: hangupBtn.topAnchor, constant: hangupYMargin),
                audioRouteButton.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
                audioRouteButton.widthAnchor.constraint(equalToConstant: btnSize),
                audioRouteButton.heightAnchor.constraint(equalToConstant: btnSize),

                audioRoutePickerView.bottomAnchor.constraint(equalTo: hangupBtn.topAnchor, constant: hangupYMargin),
                audioRoutePickerView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
                audioRoutePickerView.widthAnchor.constraint(equalToConstant: btnSize),
                audioRoutePickerView.heightAnchor.constraint(equalToConstant: btnSize),

                muteMicBtn.centerYAnchor.constraint(equalTo: audioRouteButton.centerYAnchor),
                muteMicBtn.centerXAnchor.constraint(equalTo: containerView.centerXAnchor, constant: muteMicX),
                muteMicBtn.widthAnchor.constraint(equalToConstant: btnSize),
                muteMicBtn.heightAnchor.constraint(equalToConstant: btnSize),

                closeCameraBtn.centerYAnchor.constraint(equalTo: audioRouteButton.centerYAnchor),
                closeCameraBtn.centerXAnchor.constraint(equalTo: containerView.centerXAnchor, constant: closeCameraX),
                closeCameraBtn.widthAnchor.constraint(equalToConstant: btnSize),
                closeCameraBtn.heightAnchor.constraint(equalToConstant: btnSize),

                matchBtn.centerYAnchor.constraint(equalTo: hangupBtn.centerYAnchor),
                matchBtn.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: matchBtnLeading),
                matchBtn.widthAnchor.constraint(equalToConstant: sideBtnSize),
                matchBtn.heightAnchor.constraint(equalToConstant: sideBtnSize),
            ]
        }

        NSLayoutConstraint.activate(activeConstraints)
    }
    
    // MARK: Register TUICallState Observer
    func registerObserve() {
        CallManager.shared.mediaState.isCameraOpened.addObserver(isCameraOpenObserver, closure: { [weak self] newValue, _ in
            guard let self = self else { return }
            self.updateCloseCameraBtn(open: newValue)
        })

        CallManager.shared.viewState.showLargeViewUserId.addObserver(showLargeViewUserIdObserver) { [weak self] newValue, _  in
            guard let self = self else { return }
            if !newValue.isEmpty && CallManager.shared.viewState.callingViewType.value == .multi {
                self.setNonExpansion()
            }
        }

        CallManager.shared.mediaState.isMicrophoneMuted.addObserver(isMicMuteObserver, closure: { [weak self] newValue, _ in
            guard let self = self else { return }
            self.updateMuteAudioBtn(mute: newValue)
        })

        CallManager.shared.mediaState.audioPlayoutDevice.addObserver(audioDeviceObserver, closure: { [weak self] newValue, _ in
            guard let self = self else { return }
            self.updateChangeSpeakerBtn(isSpeaker: newValue == .speakerphone)
        })

        NotificationCenter.default.addObserver(self,selector: #selector(handleOrientationChange),
                                               name: UIDevice.orientationDidChangeNotification,
                                               object: nil)
        
        CallManager.shared.viewState.callingViewType.addObserver(Observer()) { [weak self] _, _ in
            guard let self = self, self.isViewReady else { return }
            self.activateConstraints()
            self.updateViewHidden()
            self.setContainerViewCorner()
        }
    }
    func unregisterObserve() {
        CallManager.shared.mediaState.isCameraOpened.removeObserver(isCameraOpenObserver)
        CallManager.shared.viewState.showLargeViewUserId.removeObserver(showLargeViewUserIdObserver)
        CallManager.shared.mediaState.isMicrophoneMuted.removeObserver(isMicMuteObserver)
        CallManager.shared.mediaState.audioPlayoutDevice.removeObserver(audioDeviceObserver)
        NotificationCenter.default.removeObserver(self, name: UIDevice.orientationDidChangeNotification, object: nil)
    }

    func setNonExpansion() {
        guard currentMode != .collapsed, CallManager.shared.viewState.callingViewType.value == .multi else { return }
        currentMode = .collapsed
        activateConstraints()
        let alpha: CGFloat = 0.0
        let scale: CGFloat = 2.0 / 3.0

        let isRTL = TUICoreDefineConvert.getIsRTL()
        let muteMicX = isRTL ? -24.scale375Width() : 24.scale375Width()
        let changeSpeakerX = isRTL ? 10.scale375Width() : -10.scale375Width()
        let closeCameraX = isRTL ? 44.scale375Width() : -44.scale375Width()
        let hangupX = isRTL ? -140.scale375Width() : 140.scale375Width()
        let hangupTranslationY = -(groupFunctionBaseControlBtnHeight + 28.scale375Height())
        let titleLabelTranslationY = -12.scale375Width()

        UIView.animate(withDuration: groupFunctionAnimationDuration, animations: {
            self.muteMicBtn.titleLabel.alpha = alpha
            self.audioRouteButton.titleLabel.alpha = alpha
            self.audioRoutePickerView.changeSpeakerBtn.titleLabel.alpha = alpha
            self.closeCameraBtn.titleLabel.alpha = alpha

            self.muteMicBtn.titleLabel.transform = CGAffineTransform(translationX: 0, y: titleLabelTranslationY)
            self.audioRouteButton.titleLabel.transform = CGAffineTransform(translationX: 0, y: titleLabelTranslationY)
            self.closeCameraBtn.titleLabel.transform = CGAffineTransform(translationX: 0, y: titleLabelTranslationY)

            self.muteMicBtn.button.transform = CGAffineTransform(scaleX: scale, y: scale)
            self.audioRouteButton.button.transform = CGAffineTransform(scaleX: scale, y: scale)
            self.audioRoutePickerView.changeSpeakerBtn.button.transform = CGAffineTransform(scaleX: scale, y: scale)
            self.closeCameraBtn.button.transform = CGAffineTransform(scaleX: scale, y: scale)
            self.hangupBtn.button.transform = CGAffineTransform(scaleX: scale, y: scale)

            self.muteMicBtn.transform = CGAffineTransform(translationX: muteMicX, y: -hangupTranslationY)
            self.audioRouteButton.transform = CGAffineTransform(translationX: changeSpeakerX, y: -hangupTranslationY)
            self.audioRoutePickerView.transform = CGAffineTransform(translationX: changeSpeakerX, y: -hangupTranslationY)
            self.closeCameraBtn.transform = CGAffineTransform(translationX: closeCameraX, y: -hangupTranslationY)
            self.hangupBtn.transform = CGAffineTransform(translationX: hangupX, y: -2.scale375Height())
            self.matchBtn.transform = CGAffineTransform.identity

            self.layoutIfNeeded()
        }, completion: { _ in
            self.setContainerViewCorner()
        })

        let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotationAnimation.toValue = NSNumber(value: Double.pi)
        rotationAnimation.duration = groupFunctionAnimationDuration
        rotationAnimation.fillMode = .forwards
        rotationAnimation.isRemovedOnCompletion = false
        matchBtn.layer.add(rotationAnimation, forKey: "rotationAnimation")
    }

    func setExpansion() {
        guard currentMode != .expanded, CallManager.shared.viewState.callingViewType.value == .multi else { return }
        currentMode = .expanded
        activateConstraints()

        UIView.animate(withDuration: groupFunctionAnimationDuration, animations: {
            self.muteMicBtn.titleLabel.alpha = 1
            self.audioRouteButton.titleLabel.alpha = 1
            self.audioRoutePickerView.changeSpeakerBtn.titleLabel.alpha = 1
            self.closeCameraBtn.titleLabel.alpha = 1

            self.muteMicBtn.titleLabel.transform = CGAffineTransform.identity
            self.audioRouteButton.titleLabel.transform = CGAffineTransform.identity
            self.closeCameraBtn.titleLabel.transform = CGAffineTransform.identity

            self.muteMicBtn.button.transform = CGAffineTransform.identity
            self.audioRouteButton.button.transform = CGAffineTransform.identity
            self.audioRoutePickerView.changeSpeakerBtn.button.transform = CGAffineTransform.identity
            self.closeCameraBtn.button.transform = CGAffineTransform.identity
            self.hangupBtn.button.transform = CGAffineTransform.identity

            self.muteMicBtn.transform = CGAffineTransform.identity
            self.audioRouteButton.transform = CGAffineTransform.identity
            self.audioRoutePickerView.transform = CGAffineTransform.identity
            self.closeCameraBtn.transform = CGAffineTransform.identity
            self.hangupBtn.transform = CGAffineTransform.identity
            self.matchBtn.transform = CGAffineTransform.identity

            self.layoutIfNeeded()
        }, completion: { _ in
            self.setContainerViewCorner()
        })

        let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotationAnimation.toValue = NSNumber(value: 0.0)
        rotationAnimation.duration = groupFunctionAnimationDuration
        rotationAnimation.fillMode = .forwards
        rotationAnimation.isRemovedOnCompletion = true
        matchBtn.layer.add(rotationAnimation, forKey: "rotationAnimation")
    }

    
    // MARK: Action Event
    func muteMicEvent(sender: UIButton) {
        CallManager.shared.muteMic()
        updateMuteAudioBtn(mute: CallManager.shared.mediaState.isMicrophoneMuted.value == true)
    }

    func closeCameraTouchEvent(sender: UIButton) {
        updateCloseCameraBtn(open: CallManager.shared.mediaState.isCameraOpened.value != true)
        if CallManager.shared.mediaState.isCameraOpened.value == true {
            CallManager.shared.closeCamera()
        } else {
            guard let videoViewEntity = VideoFactory.shared.createVideoView(user: CallManager.shared.userState.selfUser, isShowFloatWindow: false) else { return }
            CallManager.shared.openCamera(videoView: videoViewEntity.getVideoView()) { } fail: { code, message in }
        }
    }

    func changeSpeakerEvent(sender: UIButton) {
        if CallManager.shared.mediaState.audioPlayoutDevice.value == .speakerphone {
            CallManager.shared.selectAudioPlaybackDevice(device: .earpiece)
        } else {
            CallManager.shared.selectAudioPlaybackDevice(device: .speakerphone)
        }
        updateChangeSpeakerBtn(isSpeaker: CallManager.shared.mediaState.audioPlayoutDevice.value == .speakerphone)
    }

    @objc func hangupTouchEvent(sender: UIButton) {
        CallManager.shared.hangup() { } fail: { code, message in }
    }
    @objc func switchCameraTouchEvent(sender: UIButton) {
        CallManager.shared.switchCamera()
    }
    @objc func virtualBackgroundTouchEvent(sender: UIButton) {
        CallManager.shared.setBlurBackground(enable: !CallManager.shared.viewState.isVirtualBackgroundOpened.value)
    }
    @objc func matchTouchEvent(sender: UIButton) {
        guard CallManager.shared.viewState.callingViewType.value == .multi else { return }
        if currentMode == .collapsed {
            setExpansion()
        } else {
            setNonExpansion()
        }
    }
    
    @objc func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        guard CallManager.shared.viewState.callingViewType.value == .multi else { return }
        let scale = gesture.translation(in: containerView).y / 105
        if gesture.state == .ended {
            if scale > 0 {
                // Swipe down
                if (scale > 0.5) {
                    setNonExpansion()
                } else {
                    setExpansion()
                }
            } else {
                // Swipe up
                if (scale < -0.5) {
                    setExpansion()
                } else {
                    setNonExpansion()
                }
            }
        }
    }

    @objc private func handleOrientationChange() {
        DispatchQueue.main.async {
            let currentOrientation = UIDevice.current.orientation
            guard currentOrientation.isValidInterfaceOrientation else { return }
            UIView.animate(withDuration: 0.3) {
                self.activateConstraints()
                self.setContainerViewCorner()
                self.layoutIfNeeded()
            }
        }
    }

    func updateViewHidden() {
        let callingType = CallManager.shared.viewState.callingViewType.value
        let enableVirtualBackground = CallManager.shared.globalState.enableVirtualBackground
        
        switchCameraBtn.isHidden = (callingType != .one2one)
        virtualBackgroundButton.isHidden = (callingType != .one2one) || !enableVirtualBackground
        matchBtn.isHidden = (callingType == .one2one)
        containerView.isHidden = (callingType == .one2one)
    }
    
    func updateMuteAudioBtn(mute: Bool) {
        muteMicBtn.updateTitle(title: TUICallKitLocalize(key: mute ? "TUICallKit.muted" : "TUICallKit.unmuted") ?? "")
        
        if let image = CallKitBundle.getBundleImage(name: mute ? "icon_mute_on" : "icon_mute") {
            muteMicBtn.updateImage(image: image)
        }
    }
    
    func updateChangeSpeakerBtn(isSpeaker: Bool) {
        audioRouteButton.updateTitle(title: TUICallKitLocalize(key: isSpeaker ? "TUICallKit.speakerPhone" : "TUICallKit.earpiece") ?? "")
        if let image = CallKitBundle.getBundleImage(name: isSpeaker ? "icon_handsfree_on" : "icon_handsfree") {
            audioRouteButton.updateImage(image: image)
        }
    }
    
    func updateCloseCameraBtn(open: Bool) {
        closeCameraBtn.updateTitle(title: TUICallKitLocalize(key: open ? "TUICallKit.cameraOn" : "TUICallKit.cameraOff") ?? "")
        
        if let image = CallKitBundle.getBundleImage(name: open ? "icon_camera_on" : "icon_camera_off") {
            closeCameraBtn.updateImage(image: image)
        }
    }
    
    func setContainerViewCorner() {
        DispatchQueue.main.async {
            let callingType = CallManager.shared.viewState.callingViewType.value
            guard callingType == .multi else {
                self.containerView.layer.mask = nil
                return
            }
            
            let heightConstraint = self.currentMode == .collapsed ? groupSmallFunctionViewHeight : groupFunctionViewHeight
            let maskLayer = CAShapeLayer()
            maskLayer.path = UIBezierPath(
                roundedRect: CGRect(x: 0, y: 0,
                                  width: self.containerView.bounds.width,
                                  height: heightConstraint),
                byRoundingCorners: [.topLeft, .topRight],
                cornerRadii: CGSize(width: 20, height: 20)
            ).cgPath
            self.containerView.layer.mask = maskLayer
        }
    }
    func updateAudioRouteButton() {
        if AudioSessionManager.isBluetoothHeadsetConnected() {
            audioRoutePickerView.isHidden = false
            audioRouteButton.isHidden = true
            AudioSessionManager.enableiOSAvroutePickerViewMode(true)
        } else {
            audioRoutePickerView.isHidden = true
            audioRouteButton.isHidden = false
            AudioSessionManager.enableiOSAvroutePickerViewMode(false)
        }
    }

    private func createMuteMicBtn() -> FeatureButton {
        let titleKey = CallManager.shared.mediaState.isMicrophoneMuted.value ? "TUICallKit.muted" : "TUICallKit.unmuted"
        let imageName = CallManager.shared.mediaState.isMicrophoneMuted.value ? "icon_mute_on" : "icon_mute"
        let muteAudioBtn = FeatureButton.create(title: TUICallKitLocalize(key: titleKey),
                                                titleColor: Color_White,
                                                image: CallKitBundle.getBundleImage(name: imageName),
                                                imageSize: kBtnSmallSize, buttonAction: { [weak self] sender in
            guard let self = self else { return }
            self.muteMicEvent(sender: sender)
        })
        return muteAudioBtn
    }
    private func createCloseCameraBtn() -> FeatureButton {
        let titleKey = CallManager.shared.mediaState.isCameraOpened.value ? "TUICallKit.cameraOn" : "TUICallKit.cameraOff"
        let imageName = CallManager.shared.mediaState.isCameraOpened.value ? "icon_camera_on" : "icon_camera_off"
        let btn = FeatureButton.create(title: TUICallKitLocalize(key: titleKey),
                                       titleColor: Color_White,
                                       image: CallKitBundle.getBundleImage(name: imageName),
                                       imageSize: kBtnSmallSize) { [weak self] sender in
            guard let self = self else { return }
            self.closeCameraTouchEvent(sender: sender)
        }
        return btn
    }
    private func createAudioRouteBtn() -> FeatureButton {
        let titleKey = CallManager.shared.mediaState.audioPlayoutDevice.value == .speakerphone ? "TUICallKit.speakerPhone" : "TUICallKit.earpiece"
        let imageName = CallManager.shared.mediaState.audioPlayoutDevice.value == .speakerphone ? "icon_handsfree_on" : "icon_handsfree"
        let changeSpeakerBtn = FeatureButton.create(title: TUICallKitLocalize(key: titleKey),
                                                    titleColor: Color_White,
                                                    image: CallKitBundle.getBundleImage(name: imageName),
                                                    imageSize: kBtnSmallSize, buttonAction: { [weak self] sender in
            guard let self = self else { return }
            self.changeSpeakerEvent(sender: sender)
        })
        if DeviceManager.isPad() {
            changeSpeakerBtn.isUserInteractionEnabled = false
            changeSpeakerBtn.alpha = 0.5
        }
        return changeSpeakerBtn
    }
    private func createHangupBtn() -> FeatureButton {
        let btn = FeatureButton.create(title: nil,
                                       titleColor: Color_White,
                                       image: CallKitBundle.getBundleImage(name: "icon_hangup"),
                                       imageSize: kBtnLargeSize) { [weak self] sender in
            guard let self = self else { return }
            self.hangupTouchEvent(sender: sender)
        }
        return btn
    }
}
