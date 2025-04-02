//
//  CallMainView.swift
//  Pods
//
//  Created by vincepzhang on 2025/2/21.
//

import SnapKit
import RTCCommon

class CallMainView: UIView {
    
    private var isViewReady = false
    private let callStatusObserver = Observer()

    private let videoLayout: UIView = CallVideoLayout(frame: .zero)
    private let functionView = FunctionView(frame: CGRect(x: 0, y: Screen_Height - 220.scale375Height(), width: CGFloat(Int(375.scale375Width())), height: 220.scale375Height()))
    
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
        inviteUserButton.isHidden = !(CallManager.shared.viewState.callingViewType.value == .multi && !CallManager.shared.callState.groupId.isEmpty)
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
        videoLayout.snp.makeConstraints { make in
            make.size.equalToSuperview()
        }
        
        floatWindowButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(StatusBar_Height + 12.scale375Height())
            make.leading.equalToSuperview().offset(12.scale375Width())
            make.height.width.equalTo(24.scale375Width())
        }
        
        inviterUserButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(StatusBar_Height + 12.scale375Height())
            make.trailing.equalToSuperview().offset(-12.scale375Width())
            make.height.width.equalTo(24.scale375Width())
        }
        
        timerView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(StatusBar_Height + 12.scale375Height())
            make.centerX.equalToSuperview()
            make.height.equalTo(24.scale375Width())
        }
        
        hintView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-220.scale375Height() - 10.scale375Height())
            make.height.equalTo(24.scale375Width())
        }
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
}
