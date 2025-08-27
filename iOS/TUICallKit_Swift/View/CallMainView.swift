//
//  CallMainView.swift
//  Pods
//
//  Created by vincepzhang on 2025/2/21.
//

import RTCCommon

class CallMainView: UIView {
    
    private var isViewReady = false
    private let callStatusObserver = Observer()
    private let isScreenCleanedObserver = Observer()
    private let chatGroupIdObserver = Observer()

    private let videoLayout: UIView = CallVideoLayout(frame: .zero)
    private let functionView = FunctionView(frame: .zero)
    
    private let floatWindowButton: UIButton = {
        let floatButton = UIButton(type: .system)
        if let image = CallKitBundle.getBundleImage(name: "icon_min_window") {
            floatButton.setBackgroundImage(image, for: .normal)
        }
        floatButton.addTarget(self, action: #selector(touchFloatWindowEvent(sender:)), for: .touchUpInside)
        floatButton.isHidden = !CallManager.shared.globalState.enableFloatWindow
        return floatButton
    }()

    private let inviterUserButton: UIButton = {
        let inviteUserButton = UIButton(type: .system)
        if let image = CallKitBundle.getBundleImage(name: "icon_add_user") {
            inviteUserButton.setBackgroundImage(image, for: .normal)
        }
        inviteUserButton.addTarget(self, action: #selector(touchInviterUserEvent(sender:)), for: .touchUpInside)
        inviteUserButton.isHidden = !(CallManager.shared.viewState.callingViewType.value == .multi && !CallManager.shared.callState.chatGroupId.value.isEmpty)
        return inviteUserButton
    }()
    
    private let timerView = CallTimerView(frame: .zero)
    private let hintView = CallHintView(frame: .zero)
    
    //MARK: init,deinit
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor(hex: "#242424")
        registerObserver()
    }
    
    deinit {
        unregisterObserver()
    }
    
    @objc private func orientationChanged() {
        DispatchQueue.main.async {
            self.activateConstraints()
        }
    }
    
    // MARK: UI Specification Processing
    override func didMoveToWindow() {
        super.didMoveToWindow()
        if isViewReady { return }
        isViewReady = true
        constructViewHierarchy()
        activateConstraints()
    }
    
    private func constructViewHierarchy() {
        addSubview(videoLayout)
        addSubview(functionView)
        addSubview(floatWindowButton)
        addSubview(inviterUserButton)
        addSubview(timerView)
        addSubview(hintView)
    }
    
    private func activateConstraints() {
        NSLayoutConstraint.deactivate(self.constraints)
        if videoLayout.superview == nil { return }
        
        videoLayout.translatesAutoresizingMaskIntoConstraints = false
        floatWindowButton.translatesAutoresizingMaskIntoConstraints = false
        inviterUserButton.translatesAutoresizingMaskIntoConstraints = false
        timerView.translatesAutoresizingMaskIntoConstraints = false
        hintView.translatesAutoresizingMaskIntoConstraints = false
        functionView.translatesAutoresizingMaskIntoConstraints = false
        
        var constraints = [
            videoLayout.widthAnchor.constraint(equalTo: widthAnchor),
            videoLayout.heightAnchor.constraint(equalTo: heightAnchor),
            
            functionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            functionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            functionView.bottomAnchor.constraint(equalTo: bottomAnchor),
            functionView.heightAnchor.constraint(equalToConstant: 220.scale375Height()),
            
            floatWindowButton.widthAnchor.constraint(equalToConstant: 24.scale375Width()),
            floatWindowButton.heightAnchor.constraint(equalToConstant: 24.scale375Width()),
            
            inviterUserButton.widthAnchor.constraint(equalToConstant: 24.scale375Width()),
            inviterUserButton.heightAnchor.constraint(equalToConstant: 24.scale375Width()),
            
            timerView.heightAnchor.constraint(equalToConstant: 24.scale375Width()),
            hintView.heightAnchor.constraint(equalToConstant: 24.scale375Width())
        ]
        
        if WindowUtils.isPortrait {
            constraints += [
                floatWindowButton.topAnchor.constraint(equalTo: topAnchor, constant: StatusBar_Height + 12.scale375Height()),
                floatWindowButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12.scale375Width()),
                
                inviterUserButton.topAnchor.constraint(equalTo: topAnchor, constant: StatusBar_Height + 12.scale375Height()),
                inviterUserButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12.scale375Width()),
                
                timerView.topAnchor.constraint(equalTo: topAnchor, constant: StatusBar_Height + 12.scale375Height()),
                timerView.centerXAnchor.constraint(equalTo: centerXAnchor),
                
                hintView.centerXAnchor.constraint(equalTo: centerXAnchor),
                hintView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -220.scale375Height() - 10.scale375Height()),
            ]
        } else {
            constraints += [
                floatWindowButton.topAnchor.constraint(equalTo: topAnchor, constant: 30.scale375Height()),
                floatWindowButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20.scale375Width()),
                
                inviterUserButton.topAnchor.constraint(equalTo: topAnchor, constant: 30.scale375Height()),
                inviterUserButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12.scale375Width()),
                
                timerView.topAnchor.constraint(equalTo: topAnchor, constant: 10.scale375Height()),
                timerView.centerXAnchor.constraint(equalTo: centerXAnchor),
                
                hintView.centerXAnchor.constraint(equalTo: centerXAnchor),
                hintView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -150.scale375Height()),
            ]
        }
        
        NSLayoutConstraint.activate(constraints)
    }
    
    // MARK: Action Event
    @objc func touchFloatWindowEvent(sender: UIButton) {
        WindowManager.shared.showFloatingWindow()
    }
    
    @objc func touchInviterUserEvent(sender: UIButton) {
        let selectGroupMemberVC = SelectGroupMemberViewController()
        selectGroupMemberVC.modalPresentationStyle = .fullScreen
        UIWindow.getKeyWindow()?.rootViewController?.present(selectGroupMemberVC, animated: false)
    }
    
    func registerObserver() {
        CallManager.shared.viewState.isScreenCleaned.addObserver(isScreenCleanedObserver) { [weak self] newValue, _ in
            guard let self = self else { return }
            self.updateScreenCleaned()
        }
        
        CallManager.shared.callState.chatGroupId.addObserver(chatGroupIdObserver) { [weak self] newValue, _ in
            guard let self = self else { return }
            self.updateInviterUserButton()
        }
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(orientationChanged),
                                               name: UIDevice.orientationDidChangeNotification,
                                               object: nil)
    }
    
    func unregisterObserver() {
        CallManager.shared.viewState.isScreenCleaned.removeObserver(isScreenCleanedObserver)
        CallManager.shared.callState.chatGroupId.removeObserver(chatGroupIdObserver)
    }
    
    func updateScreenCleaned() {
        guard CallManager.shared.callState.mediaType.value == .video else { return }
        
        if CallManager.shared.viewState.isScreenCleaned.value {
            self.functionView.isHidden = true
            self.floatWindowButton.isHidden = true
            self.timerView.isHidden = true
        } else {
            self.functionView.isHidden = false
            self.floatWindowButton.isHidden = false
            self.timerView.isHidden = false
        }
        
        NotificationCenter.default.removeObserver(self,
                                                  name: UIDevice.orientationDidChangeNotification,
                                                  object: nil)
    }
    
    func updateInviterUserButton() {
        if CallManager.shared.callState.chatGroupId.value.isEmpty {
            inviterUserButton.isHidden = true
            return
        }
        inviterUserButton.isHidden = false
    }
}
