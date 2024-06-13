//
//  CallStatusView.swift
//  TUICallKit
//
//  Created by vincepzhang on 2023/2/15.
//

import Foundation

class CallStatusTipView: UIView {
    
    let viewModel = UserInfoViewModel()
    let selfCallStatusObserver = Observer()
    let networkQualityObserver = Observer()
    
    let callStatusLabel: UILabel = {
        let callStatusLabel = UILabel(frame: CGRect.zero)
        callStatusLabel.textColor = UIColor.t_colorWithHexString(color: "#FFFFFF")
        callStatusLabel.font = UIFont.systemFont(ofSize: 15.0)
        callStatusLabel.backgroundColor = UIColor.clear
        callStatusLabel.textAlignment = .center
        return callStatusLabel
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        updateStatusText()
        registerObserveState()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        viewModel.selfCallStatus.removeObserver(selfCallStatusObserver)
        viewModel.selfCallStatus.removeObserver(networkQualityObserver)
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
        addSubview(callStatusLabel)
    }
    
    func activateConstraints() {
        self.callStatusLabel.snp.makeConstraints { make in
            make.edges.equalTo(self)
        }
    }
    
    // MARK: Register TUICallState Observer && Update UI
    func registerObserveState() {
        callStatusChange()
        networkQualityChange()
    }
    
    func callStatusChange() {
        viewModel.selfCallStatus.addObserver(selfCallStatusObserver, closure: { [weak self] newValue, _ in
            guard let self = self else { return }
            self.updateStatusText()
        })
    }
    
    func networkQualityChange() {
        TUICallState.instance.networkQualityReminder.addObserver(networkQualityObserver, closure: { [weak self] newValue, _ in
            guard let self = self else { return }
            self.updateNetworkQualityText()
        })
    }
    
    func updateNetworkQualityText() {
        switch TUICallState.instance.networkQualityReminder.value {
        case .Local:
            self.callStatusLabel.text = TUICallKitLocalize(key: "TUICallKit.Self.NetworkLowQuality") ?? ""
            break
        case .Remote:
            self.callStatusLabel.text = TUICallKitLocalize(key: "TUICallKit.OtherParty.NetworkLowQuality") ?? ""
            break
        case .None:
            updateStatusText()
            break
        }
    }
    
    private var isFirstShowAccept: Bool = true
    func updateStatusText() {
        switch viewModel.selfCallStatus.value {
        case .waiting:
            self.callStatusLabel.text = viewModel.getCurrentWaitingText()
            break
        case .accept:
            if isFirstShowAccept {
                self.callStatusLabel.text = TUICallKitLocalize(key: "TUICallKit.accept") ?? ""
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.isFirstShowAccept = false
                }
            } else {
                self.callStatusLabel.text = ""
            }
            break
        case .none:
            break
        default:
            break
        }
    }
}
