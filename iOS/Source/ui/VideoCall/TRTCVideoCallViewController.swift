//
//  TRTCCallingVideoViewController.swift
//  trtcScenesDemo
//
//  Created by xcoderliu on 1/17/20.
//  Copyright © 2020 xcoderliu. All rights reserved.
//

import Foundation
import Toast_Swift
import Kingfisher
import TXAppBasic

private let kSmallVideoViewWidth: CGFloat = 100.0

@objc public enum VideoCallingState : Int32, Codable {
    case dailing = 0
    case onInvitee = 1
    case calling = 2
}

public class VideoCallingRenderView: UIView {
    
    private var isViewReady: Bool = false
    
    var userModel = CallUserModel() {
        didSet {
            configModel(model: userModel)
        }
    }
    
    let volumeProgress: UIProgressView = {
        let progress = UIProgressView.init()
        progress.backgroundColor = .clear
        return progress
    }()
    
    public override func didMoveToWindow() {
        super.didMoveToWindow()
        guard !isViewReady else {
            return
        }
        isViewReady = true
        addSubview(volumeProgress)
        volumeProgress.snp.makeConstraints { (make) in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(4)
        }
    }
    
    func configModel(model: CallUserModel) {
        backgroundColor = UIColor(hex: "55534F")
        let noModel = model.userId.count == 0
        if !noModel {
            volumeProgress.progress = model.volume
        }
        volumeProgress.isHidden = noModel
    }
}

public class TRTCCallingVideoViewController: UIViewController {
    lazy var userList: [CallUserModel] = []
    
    /// 需要展示的用户列表
    var avaliableList: [CallUserModel] {
        get {
            return userList.filter {
                $0.isEnter == true
            }
        }
    }
    
    public var dismissBlock: (()->Void)? = nil
    
    // 麦克风和听筒状态记录
    private var isMicMute = false // 默认开启麦克风
    private var isHandsFreeOn = true // 默认开启扬声器
    
    let hangup = TRTCCallingBtn()
    let accept = TRTCCallingBtn()
    let handsfree = TRTCCallingBtn()
    let mute = TRTCCallingBtn()
    public var curSponsor: CallUserModel?
    var callingTime: UInt32 = 0
    var codeTimer = DispatchSource.makeTimerSource(queue: DispatchQueue.global(qos: .userInteractive))
    let callTimeLabel = UILabel()
    let localPreView = VideoCallingRenderView.init()
    static var renderViews: [VideoCallingRenderView] = []
    var remotePreView: VideoCallingRenderView?
    var isLocalPreViewLarge = true
    var isFrontCamera = true
    var switchedAudio = false
    var hasClickedSwitchToAudioBtn = false
    
    var curState: VideoCallingState {
        didSet {
            if oldValue != curState {
                autoSetUIByState()
            }
        }
    }
    
    var collectionCount: Int {
        get {
            var count = ((avaliableList.count <= 4) ? avaliableList.count : 9)
            if curState == .onInvitee || curState == .dailing {
                count = 0
            }
            return count
        }
    }
    
    
    public init(sponsor: CallUserModel? = nil) {
        curSponsor = sponsor
        if let _ = sponsor {
            curState = .onInvitee
        } else {
            curState = .dailing
        }
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        TRTCCalling.shareInstance().closeCamara()
        TRTCCallingVideoViewController.renderViews = []
        UIApplication.shared.isIdleTimerDisabled = false
        debugPrint("deinit \(self)")
    }
    
    lazy var audioCallBtnLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.text = .audioBtnText
        label.font = UIFont(name: "PingFangSC-Regular", size: 12)
        label.textColor = .white
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        label.isUserInteractionEnabled = false
        return label
    }()
    
    lazy var audioCallBtn: UIButton = {
        let btn = TRTCCallingBtn(type: .custom)
        btn.setBackgroundImage(UIImage(named: "switch2audio", in: CallingBundle(), compatibleWith: nil), for: .normal)
        return btn
    }()
    
    lazy var switchCameraBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setImage(UIImage(named: "ic_switch_camera", in: CallingBundle(), compatibleWith: nil), for: .normal)
        return btn
    }()
    
    lazy var closeCameraBtn: TRTCCallingBtn = {
        let btn = TRTCCallingBtn(type: .custom)
        btn.setImage(UIImage(named: "ic_camera_on", in: CallingBundle(), compatibleWith: nil), for: .normal)
        btn.setImage(UIImage(named: "ic_camera_off", in: CallingBundle(), compatibleWith: nil), for: .selected)
        btn.setTitle(.cameraBtnText, for: .normal)
        btn.setTitle(.cameraBtnText, for: .selected)
        return btn
    }()
    
    lazy var userContainerView: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = .clear
        return view
    }()
    
    lazy var userHeadImageView: UIImageView = {
        let imageView = UIImageView(frame: .zero)
        imageView.layer.cornerRadius = 10
        imageView.clipsToBounds = true
        return imageView
    }()
    
    lazy var userNameLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.textColor = .white
        label.font = UIFont(name: "PingFangSC-Medium", size: 24)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        return label
    }()
    
    lazy var waitingInviteLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.textColor = .white
        label.font = UIFont(name: "PingFangSC-Regular", size: 12)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        label.text = .waitingInviteText
        label.isHidden = true
        return label
    }()
    
    lazy var userCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.scrollDirection = .vertical
        let user = UICollectionView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.width),
                                    collectionViewLayout: layout)
        user.register(VideoCallUserCell.classForCoder(), forCellWithReuseIdentifier: "VideoCallUserCell")
        if #available(iOS 10.0, *) {
            user.isPrefetchingEnabled = true
        } else {
            // Fallback on earlier versions
        }
        user.showsVerticalScrollIndicator = false
        user.showsHorizontalScrollIndicator = false
        user.contentMode = .scaleToFill
        user.backgroundColor = .appBackGround
        user.dataSource = self
        user.delegate = self
        return user
    }()
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        UIApplication.shared.isIdleTimerDisabled = true
        setupUI()
        registerButtonTouchEvent()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadData()
    }
    
}

extension TRTCCallingVideoViewController: UICollectionViewDelegate, UICollectionViewDataSource,
                                   UICollectionViewDelegateFlowLayout {
    
    
    
    func resetUserList() {
        if let sponsor = curSponsor {
            let sp = sponsor
            sp.isVideoAvaliable = false
            userList = [sp]
        } else {
            if let name = TUICallingProfileManager.sharedManager().name,
               let avatar = TUICallingProfileManager.sharedManager().avatar,
               let userId = TUICallingProfileManager.sharedManager().userId {
                let curUser = CallUserModel()
                curUser.name = name
                curUser.avatar = avatar
                curUser.userId = userId
                curUser.isEnter = true
                curUser.isVideoAvaliable = true
                self.userList = [curUser]
            }
        }
    }
    
    //MARK: - UICollectionViewDataSource
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionCount == 2 {
            return 0
        }
        return collectionCount
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "VideoCallUserCell", for: indexPath) as! VideoCallUserCell
        if (indexPath.row < avaliableList.count) {
            let user = avaliableList[indexPath.row]
            cell.userModel = user
            if user.userId == V2TIMManager.sharedInstance()?.getLoginUser() ?? "" {
                localPreView.removeFromSuperview()
                cell.addSubview(localPreView)
                cell.sendSubviewToBack(localPreView)
                localPreView.frame = CGRect(x: 0, y: 0, width: cell.bounds.width, height: cell.bounds.height)
            }
        } else {
            cell.userModel = CallUserModel()
        }
        return cell
    }
    
    //MARK: - UICollectionViewDelegateFlowLayout
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let collectWidth = collectionView.frame.size.width
        let collectHight = collectionView.frame.size.height
        if (collectionCount <= 4) {
            let width = collectWidth / 2
            let height = collectHight / 2
            if (collectionCount % 2 == 1 && indexPath.row == collectionCount - 1) {
                if indexPath.row == 0 && collectionCount == 1 {
                    return CGSize(width: width, height: width)
                } else {
                    return CGSize(width: width, height: height)
                }
            } else {
                return CGSize(width: width, height: height)
            }
        } else {
            let width = collectWidth / 3
            let height = collectHight / 3
            return CGSize(width: width, height: height)
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func reloadData(animate: Bool = false) {
        
        if let user = userList.last {
            userNameLabel.text = user.name
            guard let avatar = user.avatar else {
                debugPrint("user avatar is nil")
                return
            }
            if let url = URL.init(string: avatar) {
                userHeadImageView.kf.setImage(with: .network(url))
            }
        }
        userContainerView.isHidden = collectionCount >= 2 && !switchedAudio
        
        if curState == .calling && collectionCount > 2 {
            userCollectionView.isHidden = false
        } else {
            userCollectionView.isHidden = true
        }
        
        if collectionCount <= 2 {
//            updateLayout()
            return
        }
        
        var topPadding: CGFloat = 0
        
        if #available(iOS 11.0, *) {
            let window = UIApplication.shared.keyWindow
            topPadding = window!.safeAreaInsets.top
        }
        
        if animate {
            userCollectionView.performBatchUpdates({ [weak self] in
                guard let self = self else {return}
                self.userCollectionView.snp.remakeConstraints { (make) in
                    make.leading.trailing.equalTo(self.view)
                    make.bottom.equalTo(self.view).offset(-132)
                    make.top.equalTo(self.collectionCount == 1 ? (topPadding + 62) : topPadding)
                }
                self.userCollectionView.reloadSections(IndexSet(integer: 0))
            }) { _ in
                
            }
        } else {
            UIView.performWithoutAnimation {
                userCollectionView.snp.remakeConstraints { (make) in
                    make.leading.trailing.equalTo(view)
                    make.bottom.equalTo(view).offset(-132)
                    make.top.equalTo(collectionCount == 1 ? (topPadding + 62) : topPadding)
                }
                userCollectionView.reloadSections(IndexSet(integer: 0))
            }
        }
    }
    
    func updateLayout() {
        func setLocalViewInVCView(frame: CGRect, shouldTap: Bool = false) {
            if localPreView.frame == frame {
                return
            }
            localPreView.isUserInteractionEnabled = shouldTap
            localPreView.subviews.first?.isUserInteractionEnabled = !shouldTap
            if localPreView.superview != view {
                let preFrame = view.convert(localPreView.frame, to: localPreView.superview)
                if localPreView.superview == nil {
                    view.insertSubview(localPreView, aboveSubview: userCollectionView)
                }
                localPreView.frame = preFrame
                UIView.animate(withDuration: 0.3) {
                    self.localPreView.frame = frame
                }
            } else {
                UIView.animate(withDuration: 0.3) {
                    self.localPreView.frame = frame
                }
            }
        }
        
        if collectionCount == 2 {
            if localPreView.superview != view { // 从9宫格变回来
                setLocalViewInVCView(frame: CGRect(x: self.view.frame.size.width - kSmallVideoViewWidth - 18,
                                                   y: 20, width: kSmallVideoViewWidth, height: kSmallVideoViewWidth / 9.0 * 16.0), shouldTap: true)
            } else { //进来了一个人
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    if self.collectionCount == 2 {
                        if self.localPreView.bounds.size.width != kSmallVideoViewWidth {

                            self.switchPreView()
//                            setLocalViewInVCView(frame: CGRect(x: self.view.frame.size.width - kSmallVideoViewWidth - 18,
//                            y: 20, width: kSmallVideoViewWidth, height: kSmallVideoViewWidth / 9.0 * 16.0), shouldTap: true)
                        }
                    }
                }
            }
            
            let userFirst = avaliableList.filter {
                $0.userId != V2TIMManager.sharedInstance()?.getLoginUser() ?? ""
            }.first
            
            if let user = userFirst {
                if let firstRender = TRTCCallingVideoViewController.getRenderView(userId: user.userId) {
                    firstRender.userModel = user
                    if firstRender.superview != view {
                        let preFrame = view.convert(localPreView.frame, to: localPreView.superview)
                        view.insertSubview(firstRender, belowSubview: localPreView)
                        firstRender.frame = preFrame
                        UIView.animate(withDuration: 0.1) {
                            firstRender.frame = self.view.bounds
                        }
                    } else {
                        firstRender.frame = self.view.bounds
                    }
                } else {
                    print("error")
                }
            }
            
        } else { //用户退出只剩下自己（userleave引起的）
            if collectionCount == 1 {
                setLocalViewInVCView(frame: UIApplication.shared.keyWindow?.bounds ?? CGRect.zero)
            }
        }
    }
}

extension TRTCCallingVideoViewController {
    func setupUI() {
        TRTCCallingVideoViewController.renderViews = []
        ToastManager.shared.position = .bottom
        view.backgroundColor = .appBackGround
        var topPadding: CGFloat = 0
        
        if #available(iOS 11.0, *) {
            let window = UIApplication.shared.keyWindow
            topPadding = window!.safeAreaInsets.top
        }
        view.addSubview(userCollectionView)
        userCollectionView.snp.makeConstraints { (make) in
            make.leading.trailing.equalTo(view)
            make.bottom.equalTo(view).offset(-132)
            make.top.equalTo(topPadding + 62)
        }
        view.addSubview(localPreView)
        localPreView.backgroundColor = .appBackGround
        localPreView.frame = UIApplication.shared.keyWindow?.bounds ?? CGRect.zero
        localPreView.isUserInteractionEnabled = false
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture(tap:)))
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(pan:)))
        localPreView.addGestureRecognizer(tap)
        pan.require(toFail: tap)
        localPreView.addGestureRecognizer(pan)
        userCollectionView.isHidden = true
        
        view.addSubview(userContainerView)
        userContainerView.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.top.equalToSuperview().offset(20 + kDeviceSafeTopHeight)
        }
        
        userContainerView.addSubview(userHeadImageView)
        userHeadImageView.snp.makeConstraints { (make) in
            make.top.trailing.bottom.equalToSuperview()
            make.size.equalTo(CGSize(width: 100, height: 100))
        }
        
        userContainerView.addSubview(userNameLabel)
        userNameLabel.snp.makeConstraints { (make) in
            make.trailing.equalTo(userHeadImageView.snp.leading).offset(-20)
            make.top.equalTo(userHeadImageView)
            make.leading.greaterThanOrEqualToSuperview()
        }
        
        userContainerView.addSubview(waitingInviteLabel)
        waitingInviteLabel.snp.makeConstraints { (make) in
            make.top.equalTo(userNameLabel.snp.bottom).offset(3)
            make.trailing.equalTo(userHeadImageView.snp.leading).offset(-10)
            make.leading.greaterThanOrEqualToSuperview()
        }
        
        setupControls()
        autoSetUIByState()
        accept.isHidden = (curSponsor == nil)
        alertUserTips()
        isFrontCamera = true
        TRTCCalling.shareInstance().openCamera(frontCamera: isFrontCamera, view: localPreView)
    }
    
    var largeSize: CGSize {
        get {
            return CGSize(width: convertPixel(w: 64), height: convertPixel(w: 64) + 10 + 18)
        }
    }
    
    var smallSize: CGSize {
        get {
            return CGSize(width: convertPixel(w: 52), height: convertPixel(w: 52) + 16 + 18)
        }
    }
    
    public func switchToAudio() {
        guard !switchedAudio else {
            return
        }
        switchedAudio = true
        
        if curState == .onInvitee && hasClickedSwitchToAudioBtn {
            accept.sendActions(for: .touchUpInside)
        }
        
        DispatchQueue.main.async {
            TRTCCalling.shareInstance().closeCamara()
        }
        
        audioCallBtn.isHidden = true
        if curState == .dailing {
            closeCameraBtn.isHidden = true
            switchCameraBtn.isHidden = true
            userContainerView.isHidden = false
            userHeadImageView.snp.remakeConstraints { (make) in
                make.top.equalToSuperview().offset(40)
                make.centerX.equalToSuperview()
                make.size.equalTo(CGSize(width: 100, height: 100))
            }
            userNameLabel.snp.remakeConstraints { (make) in
                make.top.equalTo(userHeadImageView.snp.bottom).offset(10)
                make.centerX.equalToSuperview()
                make.leading.greaterThanOrEqualToSuperview()
                make.trailing.lessThanOrEqualToSuperview()
            }
            waitingInviteLabel.snp.remakeConstraints { (make) in
                make.top.equalTo(userNameLabel.snp.bottom).offset(3)
                make.trailing.lessThanOrEqualToSuperview()
                make.leading.greaterThanOrEqualToSuperview()
                make.bottom.centerX.equalToSuperview()
            }
            for renderView in TRTCCallingVideoViewController.renderViews {
                renderView.removeFromSuperview()
            }
            TRTCCallingVideoViewController.renderViews.removeAll()
            localPreView.removeFromSuperview()
            view.makeToast(.switchToAudioAlertText)
        }
        else if curState == .onInvitee {
            closeCameraBtn.isHidden = true
            switchCameraBtn.isHidden = true
            userContainerView.isHidden = false
            mute.snp.remakeConstraints { (make) in
                make.centerX.equalTo(view).offset(-120)
                make.bottom.equalTo(hangup)
                make.size.equalTo(smallSize)
            }
            handsfree.snp.remakeConstraints { (make) in
                make.centerX.equalTo(view).offset(120)
                make.bottom.equalTo(hangup)
                make.size.equalTo(smallSize)
            }
            callTimeLabel.snp.remakeConstraints { (make) in
                make.leading.trailing.equalTo(view)
                make.bottom.equalTo(hangup.snp.top).offset(-10)
                make.height.equalTo(30)
            }
            userHeadImageView.snp.remakeConstraints { (make) in
                make.top.equalToSuperview().offset(40)
                make.centerX.equalToSuperview()
                make.size.equalTo(CGSize(width: 100, height: 100))
            }
            userNameLabel.snp.remakeConstraints { (make) in
                make.top.equalTo(userHeadImageView.snp.bottom).offset(10)
                make.centerX.equalToSuperview()
                make.leading.greaterThanOrEqualToSuperview()
                make.trailing.lessThanOrEqualToSuperview()
            }
            waitingInviteLabel.snp.remakeConstraints { (make) in
                make.top.equalTo(userNameLabel.snp.bottom).offset(3)
                make.trailing.lessThanOrEqualToSuperview()
                make.leading.greaterThanOrEqualToSuperview()
                make.bottom.centerX.equalToSuperview()
            }
            for renderView in TRTCCallingVideoViewController.renderViews {
                renderView.removeFromSuperview()
            }
            TRTCCallingVideoViewController.renderViews.removeAll()
            localPreView.removeFromSuperview()
            view.makeToast(.switchToAudioAlertText)
        }
        else {
            closeCameraBtn.isHidden = true
            switchCameraBtn.isHidden = true
            userContainerView.isHidden = false
            mute.snp.remakeConstraints { (make) in
                make.centerX.equalTo(view).offset(-120)
                make.bottom.equalTo(hangup)
                make.size.equalTo(smallSize)
            }
            handsfree.snp.remakeConstraints { (make) in
                make.centerX.equalTo(view).offset(120)
                make.bottom.equalTo(hangup)
                make.size.equalTo(smallSize)
            }
            callTimeLabel.snp.remakeConstraints { (make) in
                make.leading.trailing.equalTo(view)
                make.bottom.equalTo(hangup.snp.top).offset(-10)
                make.height.equalTo(30)
            }
            userHeadImageView.snp.remakeConstraints { (make) in
                make.top.equalToSuperview().offset(40)
                make.centerX.equalToSuperview()
                make.size.equalTo(CGSize(width: 100, height: 100))
            }
            userNameLabel.snp.remakeConstraints { (make) in
                make.top.equalTo(userHeadImageView.snp.bottom).offset(10)
                make.centerX.bottom.equalToSuperview()
                make.leading.greaterThanOrEqualToSuperview()
                make.trailing.lessThanOrEqualToSuperview()
            }
            for renderView in TRTCCallingVideoViewController.renderViews {
                renderView.removeFromSuperview()
            }
            TRTCCallingVideoViewController.renderViews.removeAll()
            localPreView.removeFromSuperview()
            view.makeToast(.switchToAudioAlertText)
        }
    }
    
    func setupControls() {
        if hangup.superview == nil {
            hangup.setImage(UIImage.init(named: "ic_hangup", in: CallingBundle(), compatibleWith: nil), for: .normal)
            view.addSubview(hangup)
            hangup.setTitle(.hangupBtnText, for: .normal)
            hangup.snp.makeConstraints { (make) in
                make.centerX.equalTo(view)
                make.bottom.equalTo(view).offset(-20 - kDeviceSafeBottomHeight)
                make.size.equalTo(largeSize)
            }
        }
        
        if accept.superview == nil {
            accept.setImage(UIImage.init(named: "ic_dialing", in: CallingBundle(), compatibleWith: nil), for: .normal)
            view.addSubview(accept)
            accept.setTitle(.acceptBtnText, for: .normal)
            accept.snp.makeConstraints { (make) in
                make.centerX.equalTo(view).offset(80)
                make.top.equalTo(hangup)
                make.size.equalTo(largeSize)
            }
        }
        
        if mute.superview == nil {
            mute.setImage(UIImage.init(named: "ic_mute", in: CallingBundle(), compatibleWith: nil), for: .normal)
            view.addSubview(mute)
            mute.setTitle(.muteBtnText, for: .normal)
            mute.isHidden = true
            mute.snp.remakeConstraints { (make) in
                make.centerX.equalTo(view).offset(-120)
                make.bottom.equalTo(hangup.snp.top).offset(-20)
                make.size.equalTo(smallSize)
            }
        }
        
        if handsfree.superview == nil {
            handsfree.setImage(UIImage.init(named: "ic_handsfree_on", in: CallingBundle(), compatibleWith: nil), for: .normal)
            view.addSubview(handsfree)
            handsfree.setTitle(.handsfreeBtnText, for: .normal)
            handsfree.isHidden = true
            handsfree.snp.remakeConstraints { (make) in
                make.centerX.equalTo(view)
                make.bottom.equalTo(mute)
                make.size.equalTo(smallSize)
            }
        }
        
        view.addSubview(closeCameraBtn)
        closeCameraBtn.isHidden = true
        closeCameraBtn.snp.makeConstraints { (make) in
            make.centerX.equalTo(view).offset(120)
            make.bottom.equalTo(mute)
            make.size.equalTo(smallSize)
        }
        
        view.addSubview(audioCallBtn)
        audioCallBtn.snp.makeConstraints { (make) in
            make.bottom.equalTo(hangup.snp.top).offset(-50)
            make.centerX.equalToSuperview()
        }
        
        audioCallBtn.addSubview(audioCallBtnLabel)
        audioCallBtnLabel.transform = CGAffineTransform(translationX: 0, y: 30)
        audioCallBtnLabel.snp.makeConstraints { (make) in
            make.centerX.bottom.equalToSuperview()
            make.leading.greaterThanOrEqualTo(view).offset(20)
            make.trailing.lessThanOrEqualTo(view).offset(-20)
        }
        
        if callTimeLabel.superview == nil {
            callTimeLabel.textColor = .white
            callTimeLabel.backgroundColor = .clear
            callTimeLabel.text = "00:00"
            callTimeLabel.textAlignment = .center
            view.addSubview(callTimeLabel)
            callTimeLabel.isHidden = true
            callTimeLabel.snp.remakeConstraints { (make) in
                make.leading.trailing.equalTo(view)
                make.bottom.equalTo(audioCallBtn.snp.top).offset(-10)
                make.height.equalTo(30)
            }
        }
        
        view.addSubview(switchCameraBtn)
        switchCameraBtn.snp.makeConstraints { (make) in
            make.centerY.equalTo(view.snp.top).offset(36 + kDeviceSafeTopHeight)
            make.centerX.equalTo(view.snp.leading).offset(36)
        }
    }
    
    func autoSetUIByState() {
        userCollectionView.isHidden = ((curState != .calling) || (collectionCount <= 2))
        
        switch curState {
        case .dailing:
            hangup.setTitle(.hangupBtnText, for: .normal)
            waitingInviteLabel.isHidden = false
            accept.isHidden = true
            hangup.transform = .identity
            break
        case .onInvitee:
            hangup.setTitle(.refuseBtnText, for: .normal)
            waitingInviteLabel.text = .inviteVideoCallText
            waitingInviteLabel.isHidden = false
            accept.isHidden = false
            hangup.transform = CGAffineTransform.identity.translatedBy(x: -80, y: 0)
            break
        case .calling:
            if switchedAudio {
                hangup.setTitle(.hangupBtnText, for: .normal)
                waitingInviteLabel.isHidden = true
                accept.isHidden = true
                hangup.transform = .identity
                startGCDTimer()
                
                mute.isHidden = false
                handsfree.isHidden = false
                callTimeLabel.isHidden = false
                closeCameraBtn.isHidden = true
                switchCameraBtn.isHidden = true
                mute.snp.remakeConstraints { (make) in
                    make.centerX.equalTo(view).offset(-120)
                    make.bottom.equalTo(hangup)
                    make.size.equalTo(smallSize)
                }
                handsfree.snp.remakeConstraints { (make) in
                    make.centerX.equalTo(view).offset(120)
                    make.bottom.equalTo(hangup)
                    make.size.equalTo(smallSize)
                }
                callTimeLabel.snp.remakeConstraints { (make) in
                    make.leading.trailing.equalTo(view)
                    make.bottom.equalTo(hangup.snp.top).offset(-10)
                    make.height.equalTo(30)
                }
            }
            else {
                mute.isHidden = false
                closeCameraBtn.isHidden = false
                handsfree.isHidden = false
                callTimeLabel.isHidden = false
                hangup.setTitle(.hangupBtnText, for: .normal)
                waitingInviteLabel.isHidden = true
                accept.isHidden = true
                hangup.transform = .identity
                startGCDTimer()
                audioCallBtn.snp.remakeConstraints { (make) in
                    make.bottom.equalTo(handsfree.snp.top).offset(-50)
                    make.centerX.equalToSuperview()
                }
            }
            break
        }
    }
    
    // Dispatch Timer
     func startGCDTimer() {
        // 设定这个时间源是每秒循环一次，立即开始
        codeTimer.schedule(deadline: .now(), repeating: .seconds(1))
        // 设定时间源的触发事件
        codeTimer.setEventHandler(handler: { [weak self] in
            guard let self = self else {return}
            self.callingTime += 1
            // UI 更新
            DispatchQueue.main.async {
                var mins: UInt32 = 0
                var seconds: UInt32 = 0
                mins = self.callingTime / 60
                seconds = self.callingTime % 60
                self.callTimeLabel.text = String(format: "%02d:", mins) + String(format: "%02d", seconds)
            }
        })
        
        // 判断是否取消，如果已经取消了，调用resume()方法时就会崩溃！！！
        if codeTimer.isCancelled {
            return
        }
        // 启动时间源
        codeTimer.resume()
    }
    
    @objc func switchTo2UserPreView() {
        guard let remoteView = remotePreView else {
            return
        }
        localPreView.isUserInteractionEnabled = true
        localPreView.subviews.first?.isUserInteractionEnabled = false
        UIView.animate(withDuration: 0.3) {
            remoteView.frame = CGRect(x: self.view.frame.size.width - kSmallVideoViewWidth - 18,
                                      y: 20, width: kSmallVideoViewWidth, height: kSmallVideoViewWidth / 9.0 * 16.0)
        } completion: { (result) in
            remoteView.removeFromSuperview()
            self.view.insertSubview(remoteView, aboveSubview: self.localPreView)
        }
    }
    
    @objc func switchPreView() {
        guard let remoteView = remotePreView else {
            return
        }
        if isLocalPreViewLarge {
            remoteView.isHidden = false
            UIView.animate(withDuration: 0.3, animations: { [weak remoteView ,weak self] in
                guard let `self` = self else {return}
                guard let `remoteView` = remoteView else { return }
                remoteView.frame = self.view.frame
                self.localPreView.frame = CGRect(x: self.view.frame.size.width - kSmallVideoViewWidth - 18,
                                                 y: 20, width: kSmallVideoViewWidth, height: kSmallVideoViewWidth / 9.0 * 16.0)
                
            }) { [weak self, weak remoteView] (result) in
                guard let `self` = self else { return }
                guard let `remoteView` = remoteView else { return }
                remoteView.removeFromSuperview()
                self.view.insertSubview(remoteView, belowSubview: self.localPreView)
                if self.localPreView.isHidden || remoteView.isHidden {
                    self.localPreView.isUserInteractionEnabled = false
                    remoteView.isUserInteractionEnabled = false
                }
                else {
                    if self.localPreView.isHidden || remoteView.isHidden {
                        self.localPreView.isUserInteractionEnabled = true
                        remoteView.isUserInteractionEnabled = true
                    }
                }
            }
        }
        else {
            localPreView.isHidden = false
            UIView.animate(withDuration: 0.3, animations: { [weak remoteView ,weak self] in
                guard let `self` = self else {return}
                guard let `remoteView` = remoteView else { return }
                self.localPreView.frame = self.view.frame
                remoteView.frame = CGRect(x: self.view.frame.size.width - kSmallVideoViewWidth - 18,
                                                 y: 20, width: kSmallVideoViewWidth, height: kSmallVideoViewWidth / 9.0 * 16.0)
                
            }) { [weak self, weak remoteView] (result) in
                guard let `self` = self else { return }
                guard let `remoteView` = remoteView else { return }
                self.localPreView.removeFromSuperview()
                self.view.insertSubview(self.localPreView, belowSubview: remoteView)
                self.remotePreView = remoteView
                if self.localPreView.isHidden || remoteView.isHidden {
                    self.localPreView.isUserInteractionEnabled = false
                    remoteView.isUserInteractionEnabled = false
                }
                else {
                    if self.localPreView.isHidden || remoteView.isHidden {
                        self.localPreView.isUserInteractionEnabled = true
                        remoteView.isUserInteractionEnabled = true
                    }
                }
            }
        }
        isLocalPreViewLarge = !isLocalPreViewLarge
    }
    
    @objc func handleTapGesture(tap: UIPanGestureRecognizer) {
        if collectionCount != 2 {
            return
        }
        if tap.view?.frame.width == kSmallVideoViewWidth {
            switchPreView()
        }
    }
    
    @objc func handlePanGesture(pan: UIPanGestureRecognizer) {
        if let smallView = pan.view {
            if smallView.frame.size.width == kSmallVideoViewWidth {
                if (pan.state == .changed) {
                    let translation = pan.translation(in: view)
                    let newCenterX = translation.x + (smallView.center.x)
                    let newCenterY = translation.y + (smallView.center.y)
                    if ( newCenterX < (smallView.bounds.width) / 2) ||
                        ( newCenterX > view.bounds.size.width - (smallView.bounds.width) / 2)  {
                        return
                    }
                    if ( newCenterY < (smallView.bounds.height) / 2) ||
                        (newCenterY > view.bounds.size.height - (smallView.bounds.height) / 2)  {
                        return
                    }
                    
                    UIView.animate(withDuration: 0.1) {
                        smallView.center = CGPoint(x: newCenterX, y: newCenterY)
                    }
                    pan.setTranslation(.zero, in: view)
                }
            }
        }
    }
}

extension TRTCCallingVideoViewController {
    private func registerButtonTouchEvent() {
        hangup.addTarget(self, action: #selector(hangupBtnTouchEvent(sender:)), for: .touchUpInside)
        accept.addTarget(self, action: #selector(acceptBtnTouchEvent(sender:)), for: .touchUpInside)
        mute.addTarget(self, action: #selector(muteBtnTouchEvent(sender:)), for: .touchUpInside)
        handsfree.addTarget(self, action: #selector(handsfreeBtnTouchEvent(sender:)), for: .touchUpInside)
        closeCameraBtn.addTarget(self, action: #selector(closeCameraBtnTouchEvent(sender:)), for: .touchUpInside)
        audioCallBtn.addTarget(self, action: #selector(audioCallBtnTouchEvent(sender:)), for: .touchUpInside)
        switchCameraBtn.addTarget(self, action: #selector(swithCameraBtnTouchEvent(sender:)), for: .touchUpInside)
    }
    
    @objc private func hangupBtnTouchEvent(sender: UIButton) {
        TRTCCalling.shareInstance().hangup()
       self.disMiss()
    }
    
    @objc private func acceptBtnTouchEvent(sender: UIButton) {
        TRTCCalling.shareInstance().accept()
        if let name = TUICallingProfileManager.sharedManager().name,
           let avatar = TUICallingProfileManager.sharedManager().avatar,
           let userId = TUICallingProfileManager.sharedManager().userId {
            let curUser = CallUserModel()
            curUser.name = name
            curUser.avatar = avatar
            curUser.userId = userId
            curUser.isEnter = true
            curUser.isVideoAvaliable = true
            self.enterUser(user: curUser)
            self.curState = .calling
            self.accept.isHidden = true
        }
    }
    
    @objc private func muteBtnTouchEvent(sender: UIButton) {
        self.isMicMute = !self.isMicMute
        TRTCCalling.shareInstance().setMicMute(self.isMicMute)
        self.mute.setImage(UIImage.init(named: self.isMicMute ? "ic_mute_on" : "ic_mute", in: CallingBundle(), compatibleWith: nil), for: .normal)
        self.view.makeToast(self.isMicMute ? .muteonText : .muteoffText)
    }
    
    @objc private func handsfreeBtnTouchEvent(sender: UIButton) {
        self.isHandsFreeOn = !self.isHandsFreeOn
        TRTCCalling.shareInstance().setHandsFree(self.isHandsFreeOn)
        self.handsfree.setImage(UIImage.init(named: self.isHandsFreeOn ? "ic_handsfree_on" : "ic_handsfree", in: CallingBundle(), compatibleWith: nil), for: .normal)
        self.view.makeToast(self.isHandsFreeOn ? .handsfreeonText : .handsfreeoffText)
    }
    
    @objc private func closeCameraBtnTouchEvent(sender: UIButton) {
        self.closeCameraBtn.isUserInteractionEnabled = false
        self.closeCameraBtn.isSelected = !self.closeCameraBtn.isSelected
        if self.closeCameraBtn.isSelected {
            TRTCCalling.shareInstance().closeCamara()
        }
        else {
            TRTCCalling.shareInstance().openCamera(frontCamera: self.isFrontCamera, view: self.localPreView)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.closeCameraBtn.isUserInteractionEnabled = true
        }
        self.localPreView.isHidden = self.closeCameraBtn.isSelected
    }
    
    @objc private func audioCallBtnTouchEvent(sender: UIButton) {
        self.hasClickedSwitchToAudioBtn = true
        TRTCCalling.shareInstance().switchToAudio()
    }
    
    @objc private func swithCameraBtnTouchEvent(sender: UIButton) {
        self.isFrontCamera = !self.isFrontCamera
        TRTCCalling.shareInstance().switchCamera(self.isFrontCamera)
    }
}
public class TRTCCallingBtn: UIButton {
    public override func setTitle(_ title: String?, for state: UIControl.State) {
        super.setTitle(title, for: state)
        setTitleColor(.white, for: state)
        guard let label = titleLabel else {
            return
        }
        if !label.adjustsFontSizeToFitWidth {
            label.adjustsFontSizeToFitWidth = true
            label.minimumScaleFactor = 0.5
            label.textAlignment = .center
        }
    }
    
    public override func titleRect(forContentRect contentRect: CGRect) -> CGRect {
        if contentRect.width == convertPixel(w: 64) {
            return CGRect(x: 0, y: contentRect.width + 10, width: contentRect.width, height: 18)
        }
        else {
            return CGRect(x: 0, y: contentRect.width + 16, width: contentRect.width, height: 18)
        }
    }
    
    public override func imageRect(forContentRect contentRect: CGRect) -> CGRect {
        return CGRect(x: 0, y: 0, width: contentRect.width, height: contentRect.width)
    }
}
extension TRTCCallingVideoViewController {
    func alertUserTips() {
        // 提醒用户不要用Demo App来做违法的事情
        // 每天提醒一次
        let nowDay = Calendar.current.component(.day, from: Date())
        if let day = UserDefaults.standard.object(forKey: "UserTipsKey") as? Int {
            if day == nowDay {
                return
            }
        }
        UserDefaults.standard.set(nowDay, forKey: "UserTipsKey")
        UserDefaults.standard.synchronize()
        let alertVC = UIAlertController(title:CallingLocalize("LoginNetwork.AppUtils.warmprompt"), message: CallingLocalize("LoginNetwork.AppUtils.tomeettheregulatory"), preferredStyle: UIAlertController.Style.alert)
        let okView = UIAlertAction(title: CallingLocalize("LoginNetwork.AppUtils.determine"), style: UIAlertAction.Style.default, handler: nil)
        alertVC.addAction(okView)
        present(alertVC, animated: true, completion: nil)
    }
}

extension TRTCCallingVideoViewController: CallingViewControllerResponder {
    
    public func getUserById(userId: String) -> CallUserModel? {
        for user in userList {
            if user.userId == userId {
                return user
            }
        }
        return nil
    }
    
    public func disMiss() {
        if self.curState != .calling {
            if !codeTimer.isCancelled {
                self.codeTimer.resume()
            }
        }
        self.codeTimer.cancel()
        dismiss(animated: false) {
            if let dis = self.dismissBlock {
                dis()
            }
        }
    }
    
    public static func getRenderView(userId: String) -> VideoCallingRenderView? {
        for renderView in renderViews {
            if  renderView.userModel.userId == userId {
                return renderView
            }
        }
        return nil
    }
    
    public func resetWithUserList(users: [CallUserModel], isInit: Bool = false) {
        resetUserList()
        let usersFilter = users.filter {
            $0.userId != V2TIMManager.sharedInstance()?.getLoginUser() ?? ""
        }
        userList.append(contentsOf: usersFilter)
        if !isInit {
           reloadData()
        }
    }
    
    /// enterUser回调 每个用户进来只能调用一次
    /// - Parameter user: 用户信息
    public func enterUser(user: CallUserModel) {
        if switchedAudio {
            curState = .calling
            return
        }
        if user.userId != V2TIMManager.sharedInstance()?.getLoginUser() ?? "" {
            let renderView = VideoCallingRenderView()
            renderView.userModel = user
            TRTCCalling.shareInstance().startRemoteView(userId: user.userId, view: renderView)
            TRTCCallingVideoViewController.renderViews.append(renderView)
            let tap = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture(tap:)))
            let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(pan:)))
            renderView.addGestureRecognizer(tap)
            pan.require(toFail: tap)
            renderView.addGestureRecognizer(pan)
            remotePreView = renderView
        }
        curState = .calling
        updateUser(user: user, animated: true)
        switchTo2UserPreView()
    }
    
    public func leaveUser(user: CallUserModel) {
        TRTCCalling.shareInstance().stopRemoteView(userId: user.userId)
        TRTCCallingVideoViewController.renderViews = TRTCCallingVideoViewController.renderViews.filter {
            $0.userModel.userId != user.userId
        }
        if let index = userList.firstIndex(where: { (model) -> Bool in
            model.userId == user.userId
        }) {
            let dstUser = userList[index]
            let animate = dstUser.isVideoAvaliable
            userList.remove(at: index)
            reloadData(animate: animate)
        }
    }
    
    public func updateUser(user: CallUserModel, animated: Bool) {
        if let index = userList.firstIndex(where: { (model) -> Bool in
            model.userId == user.userId
        }) {
            userList.remove(at: index)
            userList.insert(user, at: index)
        } else {
            userList.append(user)
        }
        if !switchedAudio, let renderView = TRTCCallingVideoViewController.getRenderView(userId: user.userId) {
            renderView.isHidden = !user.isVideoAvaliable
            if renderView.frame.width == kSmallVideoViewWidth {
                localPreView.isUserInteractionEnabled = user.isVideoAvaliable
                remotePreView?.isUserInteractionEnabled = user.isVideoAvaliable
            }
        }
        reloadData(animate: animated)
    }
    
    public func updateUserVolume(user: CallUserModel) {
        if let firstRender = TRTCCallingVideoViewController.getRenderView(userId: user.userId) {
            firstRender.userModel = user
        } else {
            localPreView.userModel = user
        }
    }
    
}

fileprivate extension String {
    static let inviteVideoCallText = CallingLocalize("Demo.TRTC.calling.invitetovideocall")
    static let muteonText = CallingLocalize("Demo.TRTC.calling.muteon")
    static let muteoffText = CallingLocalize("Demo.TRTC.calling.muteoff")
    static let handsfreeonText = CallingLocalize("Demo.TRTC.calling.handsfreeon")
    static let handsfreeoffText = CallingLocalize("Demo.TRTC.calling.handsfreeoff")
    static let waitingInviteText = CallingLocalize("Demo.TRTC.Calling.waitaccept")
    static let hangupBtnText = CallingLocalize("Demo.TRTC.Calling.hangup")
    static let refuseBtnText = CallingLocalize("Demo.TRTC.Calling.decline")
    static let acceptBtnText = CallingLocalize("Demo.TRTC.Calling.answer")
    static let muteBtnText = CallingLocalize("Demo.TRTC.Calling.mic")
    static let handsfreeBtnText = CallingLocalize("Demo.TRTC.Calling.speaker")
    static let cameraBtnText = CallingLocalize("Demo.TRTC.Calling.camera")
    static let audioBtnText = CallingLocalize("Demo.TRTC.Calling.switchtoaudio")
    static let switchToAudioAlertText = CallingLocalize("Demo.TRTC.Calling.switchtoaudio")
}
