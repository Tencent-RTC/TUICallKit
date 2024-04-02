//
//  SingleCallFloatWindowView.swift
//  HydraAsync
//
//  Created by vincepzhang on 2023/6/27.
//

import Foundation
import TUICallEngine

class SingleCallFloatWindowView: FloatWindowView {
    
    let viewModel = FloatWindowViewModel()
    let selfCallStatusObserver = Observer()
    let firstRemoteUserVideoAvailableObserver = Observer()
    let timeCountObserver = Observer()
    
    lazy var containerView: UIView = {
        let containerView = UIView()
        containerView.backgroundColor = UIColor.white
        containerView.isUserInteractionEnabled = false
        return containerView
    }()
    
    
    // Video Call
    lazy var localPreView: TUIVideoView = {
        let view = TUIVideoView(frame: CGRect.zero)
        return view
    }()
    
    lazy var remotePreView: TUIVideoView = {
        let view = TUIVideoView(frame: CGRect.zero)
        return view
    }()
    
    lazy var avatarImageView: UIImageView = {
        let avatarImageView = UIImageView()
        avatarImageView.contentMode = .scaleAspectFit
        avatarImageView.clipsToBounds = true
        avatarImageView.isUserInteractionEnabled = false
        return avatarImageView
    }()
    
    lazy var videoDescribeLabel: UILabel = {
        let describeLabel = UILabel()
        describeLabel.font = UIFont.systemFont(ofSize: 12.0)
        describeLabel.textColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
        describeLabel.textAlignment = .center
        describeLabel.isUserInteractionEnabled = false
        return describeLabel
    }()
    
    
    // Audio Call
    lazy var dialingImageView: UIImageView = {
        let imageView = UIImageView()
        if let image = BundleUtils.getBundleImage(name: "icon_float_dialing"){
            imageView.image = image
        }
        
        imageView.isUserInteractionEnabled = false
        return imageView
    }()
    
    lazy var audioDescribeAndTimerLabel: UILabel = {
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
        viewModel.selfCallStatus.removeObserver(selfCallStatusObserver)
        viewModel.firstRemoteUserVideoAvailable.removeObserver(firstRemoteUserVideoAvailableObserver)
        viewModel.timeCount.removeObserver(timeCountObserver)
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
        addSubview(containerView)
        if viewModel.mediaType.value == .audio {
            containerView.addSubview(dialingImageView)
            containerView.addSubview(audioDescribeAndTimerLabel)
            return
        }
        containerView.addSubview(localPreView)
        containerView.addSubview(remotePreView)
        containerView.addSubview(avatarImageView)
        containerView.addSubview(videoDescribeLabel)
    }
    
    func activateConstraints() {
        containerView.snp.makeConstraints { make in
            make.center.equalTo(self)
            make.size.equalToSuperview()
        }
        
        if viewModel.mediaType.value == .audio {
            
            dialingImageView.snp.makeConstraints { make in
                make.top.equalTo(self.containerView).offset(12.scaleWidth())
                make.centerX.equalToSuperview()
                make.width.height.equalTo(36.scaleWidth())
            }
            
            audioDescribeAndTimerLabel.snp.makeConstraints { make in
                make.centerX.width.equalTo(self.containerView)
                make.top.equalToSuperview().offset(48.scaleWidth())
                make.height.equalTo(16.scaleWidth())
            }
            return
        }
        
        localPreView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        remotePreView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        avatarImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(45.scaleWidth())
        }
        
        videoDescribeLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-20.scaleWidth())
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
        
        viewModel.firstRemoteUserVideoAvailable.addObserver(firstRemoteUserVideoAvailableObserver, closure: { [weak self] newValue, _ in
            guard let self = self else { return }
            self.updateUI()
        })
        
        viewModel.timeCount.addObserver(timeCountObserver) {[weak self] newValue, _ in
            guard let self = self else { return }
            self.updateUI()
        }
    }
    
    //MARK: Update UI
    func updateUI() {
        if viewModel.mediaType.value == .audio {
            if viewModel.selfCallStatus.value == .waiting {
                setAudioWaitingUI()
            } else if viewModel.selfCallStatus.value == .accept {
                setAudioAcceptUI()
            }
            return
        }
        
        if viewModel.selfCallStatus.value == .waiting {
            setVideoWaitingUI()
        } else if viewModel.selfCallStatus.value == .accept {
            if viewModel.firstRemoteUserVideoAvailable.value {
                setVideoAcceptUI()
            } else {
                setVideoAcceptWithDisavailableUI()
            }
        }
    }
    
    func setAudioWaitingUI() {
        audioDescribeAndTimerLabel.text = TUICallState.instance.mResourceDic["k_0000088"] as? String
    }
    
    func setAudioAcceptUI() {
        audioDescribeAndTimerLabel.text = viewModel.getCallTimeString()
    }
    
    func setVideoWaitingUI() {
        viewModel.openCamera(videoView: localPreView)
        videoDescribeLabel.text = TUICallState.instance.mResourceDic["k_0000088"] as? String
    }
    
    func setVideoAcceptUI() {
        videoDescribeLabel.isHidden = true
        avatarImageView.isHidden = true
        remotePreView.isHidden = false
        let remoteUserId = viewModel.remoteUserList.value.first?.id.value ?? ""
        viewModel.startRemoteView(userId: remoteUserId, videoView: remotePreView)
    }
    
    func setVideoAcceptWithDisavailableUI() {
        videoDescribeLabel.isHidden = true
        localPreView.isHidden = true
        remotePreView.isHidden = true
        avatarImageView.isHidden = false
        containerView.backgroundColor = UIColor(red: 60 / 255, green: 60 / 255, blue: 60 / 255, alpha: 1)
        let remoteUserAvatar = viewModel.remoteUserList.value.first?.avatar.value ?? ""
        avatarImageView.sd_setImage(with: URL(string: remoteUserAvatar), placeholderImage: BundleUtils.getBundleImage(name: "userIcon"))
    }
}
