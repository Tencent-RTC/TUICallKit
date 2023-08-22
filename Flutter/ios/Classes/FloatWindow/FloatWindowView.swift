//
//  FloatWindowView.swift
//  HydraAsync
//
//  Created by vincepzhang on 2023/6/27.
//

import Foundation
import TUICallEngine

protocol FloatingWindowViewDelegate: NSObject {
    func tapGestureAction(tapGesture: UITapGestureRecognizer)
    func panGestureAction(panGesture: UIPanGestureRecognizer)
}

class FloatWindowView: UIView {
    
    let viewModel = FloatingWindowViewModel()
    weak var delegate: FloatingWindowViewDelegate?
        
    let selfCallStatusObserver = Observer()
    let mediaTypeObserver = Observer()
    let remoteUserVideoAvailableObserver = Observer()
    let scenceObserver = Observer()
    let timeCountObserver = Observer()

    let localPreView: TUIVideoView = {
        let view = TUIVideoView(frame: CGRectZero)
        return view
    }()
    
    let remotePreView: TUIVideoView = {
        let view = TUIVideoView(frame: CGRectZero)
        return view
    }()

    let avatarImageView: UIImageView = {
        let avatarImageView = UIImageView()
        avatarImageView.contentMode = .scaleAspectFill
        avatarImageView.clipsToBounds = true
        avatarImageView.isUserInteractionEnabled = false
        return avatarImageView
    }()
    
    let containerView: UIView = {
        let containerView = UIView()
        containerView.backgroundColor = UIColor.white
        containerView.layer.cornerRadius = 10.0
        containerView.layer.masksToBounds = true
        containerView.isUserInteractionEnabled = false

        return containerView
    }()
    
    let imageView: UIImageView = {
        let imageView = UIImageView()
        if let image = BundleUtils.getBundleImage(name: "trtccalling_ic_dialing"){
                imageView.image = image
        }
        
        imageView.isUserInteractionEnabled = false
        return imageView
    }()
    
    let describeLabel: UILabel = {
        let describeLabel = UILabel()
        describeLabel.font = UIFont.systemFont(ofSize: 12.0)
        describeLabel.textColor = UIColor.black
        describeLabel.textAlignment = .center
        describeLabel.isUserInteractionEnabled = false
        return describeLabel
    }()
    
    lazy var timerLabel: UILabel = {
        let timerLabel = UILabel()
        timerLabel.font = UIFont.systemFont(ofSize: 12.0)
        timerLabel.textColor = UIColor.black
        timerLabel.textAlignment = .center
        timerLabel.isUserInteractionEnabled = false
        return timerLabel
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
        addSubview(localPreView)
        addSubview(remotePreView)
        addSubview(avatarImageView)
        addSubview(containerView)
        containerView.addSubview(imageView)
        containerView.addSubview(describeLabel)
        containerView.addSubview(timerLabel)
    }
    
    func activateConstraints() {
        
        localPreView.snp.makeConstraints { make in
            make.top.left.equalToSuperview().offset(kMicroContainerViewOffset)
            make.bottom.trailing.equalToSuperview().offset(-kMicroContainerViewOffset)
        }
        
        remotePreView.snp.makeConstraints { make in
            make.top.left.equalToSuperview().offset(kMicroContainerViewOffset)
            make.bottom.trailing.equalToSuperview().offset(-kMicroContainerViewOffset)
        }
            
        avatarImageView.snp.makeConstraints { make in
            make.top.left.equalToSuperview().offset(kMicroContainerViewOffset)
            make.bottom.trailing.equalToSuperview().offset(-kMicroContainerViewOffset)
        }
        
        containerView.snp.makeConstraints { make in
            make.center.equalTo(self)
            make.size.equalTo(CGSize(width: kMicroAudioViewWidth - 5, height: kMicroAudioViewHeight - 5))
        }
        
        imageView.snp.makeConstraints { make in
            make.top.equalTo(self.containerView).offset(5)
            make.centerX.equalTo(self.containerView)
            make.width.height.equalTo(50)
        }
        
        describeLabel.snp.makeConstraints { make in
            make.centerX.width.equalTo(self.containerView)
            make.top.equalTo(self.imageView.snp.bottom)
            make.height.equalTo(20)
        }
        
        timerLabel.snp.makeConstraints { make in
            make.centerX.width.equalTo(self.containerView)
            make.top.equalTo(self.imageView.snp.bottom)
            make.height.equalTo(20)
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
        
        viewModel.remoteUserVideoAvailable.addObserver(remoteUserVideoAvailableObserver, closure: { [weak self] newValue, _ in
            guard let self = self else { return }
            self.updateUI()
        })
        
        viewModel.mediaType.addObserver(mediaTypeObserver, closure: { [weak self] newValue, _ in
            guard let self = self else { return }
            self.updateUI()
        })
        
        viewModel.scence.addObserver(scenceObserver, closure: { [weak self] newValue, _ in
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
        if viewModel.scence.value == .single {
            
            if viewModel.mediaType.value == .audio {
                if viewModel.selfCallStatus.value == .waiting {
                    setAudioWaitingUI()
                } else if viewModel.selfCallStatus.value == .accept {
                    setAudioAcceptUI()
                }
            } else if viewModel.mediaType.value == .video {
                if viewModel.selfCallStatus.value == .waiting {
                    setVideoWaitingUI()
                } else if viewModel.selfCallStatus.value == .accept {
                    if viewModel.remoteUserVideoAvailable.value {
                        setVideoAcceptUI()
                    } else {
                        setVideoAcceptWithDisavailableUI()
                    }
                }
            }
            
        } else {
            
            if viewModel.selfCallStatus.value == .waiting {
                setAudioWaitingUI()
            } else if viewModel.selfCallStatus.value == .accept {
                setAudioAcceptUI()
            }
        }
    }
    
    func setAudioWaitingUI() {
        hiddenSubviews()
        containerView.isHidden = false
        imageView.isHidden = false
        describeLabel.isHidden = false
        describeLabel.text = TUICallState.instance.mResourceDic["k_0000088"] as? String
        timerLabel.text = ""
    }
    
    func setAudioAcceptUI() {
        hiddenSubviews()
        containerView.isHidden = false
        imageView.isHidden = false
        timerLabel.isHidden = false
        describeLabel.text = ""
        timerLabel.text = viewModel.getCallTimeString()
    }
    
    func setVideoWaitingUI() {
        hiddenSubviews()
        localPreView.isHidden = false
        viewModel.openCamera(videoView: localPreView)
    }
    
    func setVideoAcceptUI() {
        hiddenSubviews()
        remotePreView.isHidden = false
        
        viewModel.startRemoteView(videoView: remotePreView)
    }
    
    func setVideoAcceptWithDisavailableUI() {
        hiddenSubviews()
        avatarImageView.isHidden = false

        avatarImageView.image = viewModel.getRemoteAvatar()
    }
    
    func hiddenSubviews() {
        localPreView.isHidden = true
        remotePreView.isHidden = true
        avatarImageView.isHidden = true
        containerView.isHidden = true
        imageView.isHidden = true
        describeLabel.isEnabled = true
        timerLabel.isEnabled = true
    }
}

extension FloatWindowView {
    func DispatchCallKitMainAsyncSafe(closure: @escaping () -> Void) {
        if Thread.current.isMainThread {
            closure()
        } else {
            DispatchQueue.main.async(execute: closure)
        }
    }
}
