//
//  TRTCCallingAudioContactViewController.swift
//  TXLiteAVDemo_Enterprise
//
//  Created by abyyxwang on 2020/8/5.
//  Copyright © 2020 Tencent. All rights reserved.
//

import UIKit
import Toast_Swift
import TXAppBasic

public protocol CallingViewControllerResponder: UIViewController {
    var dismissBlock: (()->Void)? { get set }
    var curSponsor: CallUserModel? { get }
    func enterUser(user: CallUserModel)
    func leaveUser(user: CallUserModel)
    func updateUser(user: CallUserModel, animated: Bool)
    func updateUserVolume(user: CallUserModel) // 更新用户音量
    func disMiss()
    func getUserById(userId: String) -> CallUserModel?
    func resetWithUserList(users: [CallUserModel], isInit: Bool)
    static func getRenderView(userId: String) -> VideoCallingRenderView?
}

extension CallingViewControllerResponder {
    public static func getRenderView(userId: String) -> VideoCallingRenderView? {
        return nil
    }
    func updateUser(user: CallUserModel, animated: Bool) {
        
    }
    public func updateUserVolume(user: CallUserModel) {
        
    }
}


@objc public enum AudioiCallingState : Int32, Codable {
    case dailing = 0
    case onInvitee = 1
    case calling = 2
}

public class TRTCCallingAuidoViewController: UIViewController {
    lazy var userList: [CallUserModel] = []
    lazy var inviteeList: [CallUserModel] = []
    public var dismissBlock: (()->Void)? = nil
    
    // 麦克风和听筒状态记录
    private var isMicMute = false // 默认开启麦克风
    private var isHandsFreeOn = true // 默认开启扬声器
    
    let hangup = UIButton()
    let accept = UIButton()
    let handsfree = UIButton()
    let mute = UIButton()
    public let curSponsor: CallUserModel?
    var callingTime: UInt32 = 0
    var codeTimer = DispatchSource.makeTimerSource(queue: DispatchQueue.global(qos: .userInteractive))
    let callTimeLabel = UILabel()
    
    var curState: AudioiCallingState {
        didSet {
            if oldValue != curState {
                autoSetUIByState()
            }
        }
    }
    
    var OnInviteePanelList: [CallUserModel] {
        get {
            return inviteeList.filter {
                if let userId = V2TIMManager.sharedInstance()?.getLoginUser() {
                    let isCurrent = $0.userId == userId
                    var isSponor = false
                    if let sponor = curSponsor {
                        isSponor = $0.userId == sponor.userId
                    }
                    return !isCurrent && !isSponor
                } else {
                    print("V2TIMManager not login")
                    return false
                }
            }
        }
    }
    
    var collectionCount: Int {
        get {
            return 1
            var count = ((userList.count <= 4) ? userList.count : 9)
            if curState == .onInvitee {
                count = 1
            }
            return count
        }
    }
    
    lazy var OninviteeStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 2
        return stack
    }()
    
    lazy var OnInviteePanel: UIView = {
        let panel = UIView()
        return panel
    }()
    
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
        UIApplication.shared.isIdleTimerDisabled = false
        debugPrint("deinit \(self)")
    }
    
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
        label.textColor = .black
        label.font = UIFont(name: "PingFangSC-Medium", size: 24)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        return label
    }()
    
    lazy var waitingInviteLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.textColor = UIColor(hex: "999999")
        label.font = UIFont(name: "PingFangSC-Regular", size: 14)
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
        user.register(AudioCallUserCell.classForCoder(), forCellWithReuseIdentifier: "AudioCallUserCell")
        if #available(iOS 10.0, *) {
            user.isPrefetchingEnabled = true
        } else {
            // Fallback on earlier versions
        }
        user.showsVerticalScrollIndicator = false
        user.showsHorizontalScrollIndicator = false
        user.contentMode = .scaleToFill
        user.backgroundColor = .clear
        user.dataSource = self
        user.delegate = self
        return user
    }()
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        UIApplication.shared.isIdleTimerDisabled = true
        setupUI()
        registerButtonTouchEvents()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadData()
    }
    
    
}

extension TRTCCallingAuidoViewController {
    func setupUI() {
        
        view.backgroundColor = UIColor(hex: "F4F5F9")
        
        view.addSubview(OnInviteePanel)
        OnInviteePanel.addSubview(OninviteeStackView)
        OninviteeStackView.snp.makeConstraints { (make) in
            make.leading.trailing.bottom.equalTo(OnInviteePanel)
            make.top.equalTo(OnInviteePanel.snp.bottom)
        }
        
        ToastManager.shared.position = .bottom
        
        view.addSubview(userContainerView)
        userContainerView.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.top.equalToSuperview().offset(74 + kDeviceSafeTopHeight)
        }
        
        userContainerView.addSubview(userHeadImageView)
        userHeadImageView.snp.makeConstraints { (make) in
            make.top.centerX.equalToSuperview()
            make.size.equalTo(CGSize(width: 120, height: 120))
        }
        
        userContainerView.addSubview(userNameLabel)
        userNameLabel.snp.makeConstraints { (make) in
            make.top.equalTo(userHeadImageView.snp.bottom).offset(20)
            make.centerX.bottom.equalToSuperview()
            make.leading.greaterThanOrEqualToSuperview()
            make.trailing.lessThanOrEqualToSuperview()
        }
        
        view.addSubview(waitingInviteLabel)
        waitingInviteLabel.snp.makeConstraints { (make) in
            make.top.equalTo(userContainerView.snp.bottom)
            make.centerX.equalToSuperview()
            make.leading.greaterThanOrEqualToSuperview().offset(20)
            make.trailing.lessThanOrEqualToSuperview().offset(-20)
        }
        setupControls()
        autoSetUIByState()
        accept.isHidden = (curSponsor == nil)
    }
    
    var largeSize: CGSize {
        get {
            return CGSize(width: convertPixel(w: 64), height: convertPixel(w: 64))
        }
    }
    
    var smallSize: CGSize {
        get {
            return CGSize(width: convertPixel(w: 52), height: convertPixel(w: 52))
        }
    }
    
    func setupControls() {
        if hangup.superview == nil {
            hangup.setBackgroundImage(UIImage.init(named: "ic_hangup", in: CallingBundle(), compatibleWith: nil), for: .normal)
            view.addSubview(hangup)
            hangup.snp.makeConstraints { (make) in
                make.centerX.equalTo(view)
                make.bottom.equalTo(view).offset(-32 - kDeviceSafeBottomHeight)
                make.size.equalTo(largeSize)
            }
        }
        
        
        if accept.superview == nil {
            accept.setBackgroundImage(UIImage.init(named: "ic_dialing", in: CallingBundle(), compatibleWith: nil), for: .normal)
            view.addSubview(accept)
            accept.snp.remakeConstraints { (make) in
                make.centerX.equalTo(view).offset(80)
                make.bottom.equalTo(view).offset(-32 - kDeviceSafeBottomHeight)
                make.size.equalTo(largeSize)
            }
        }
        
        if mute.superview == nil {
            mute.setBackgroundImage(UIImage.init(named: "ic_mute", in: CallingBundle(), compatibleWith: nil), for: .normal)
            view.addSubview(mute)
            mute.isHidden = true
            mute.snp.makeConstraints { (make) in
                make.centerX.equalTo(view).offset(-120)
                make.bottom.equalTo(hangup)
                make.size.equalTo(smallSize)
            }
        }
        
        if handsfree.superview == nil {
            handsfree.setBackgroundImage(UIImage.init(named: "ic_handsfree_on", in: CallingBundle(), compatibleWith: nil), for: .normal)
            view.addSubview(handsfree)
            handsfree.isHidden = true
            handsfree.snp.makeConstraints { (make) in
                make.centerX.equalTo(view).offset(120)
                make.bottom.equalTo(hangup)
                make.size.equalTo(smallSize)
            }
        }
        
        if callTimeLabel.superview == nil {
            callTimeLabel.textColor = .black
            callTimeLabel.backgroundColor = .clear
            callTimeLabel.text = "00:00"
            callTimeLabel.textAlignment = .center
            view.addSubview(callTimeLabel)
            callTimeLabel.isHidden = true
            callTimeLabel.snp.remakeConstraints { (make) in
                make.leading.trailing.equalTo(view)
                make.bottom.equalTo(hangup.snp.top).offset(-10)
                make.height.equalTo(30)
            }
        }
    }
    
    func autoSetUIByState() {
        switch curState {
        case .dailing:
            waitingInviteLabel.isHidden = false
            accept.isHidden = true
            hangup.transform = .identity
            break
        case .onInvitee:
            waitingInviteLabel.isHidden = true
            accept.isHidden = false
            hangup.transform = CGAffineTransform.identity.translatedBy(x: -80, y: 0)
            break
        case .calling:
            waitingInviteLabel.isHidden = true
            accept.isHidden = true
            hangup.transform = .identity
            startGCDTimer()
            break
        }
        
        if curState == .calling {
            mute.isHidden = false
            handsfree.isHidden = false
            callTimeLabel.isHidden = false
            mute.alpha = 0.0
            handsfree.alpha = 0.0
            callTimeLabel.alpha = 0.0
        }
        
        let shouldHideOnInviteePanel = (OnInviteePanelList.count == 0 || (self.curState != .onInvitee))
        
        OnInviteePanel.snp.remakeConstraints { (make) in
            make.bottom.equalTo(self.hangup.snp.top).offset(-100)
            make.width.equalTo(max(44, 44 * OnInviteePanelList.count + 2 * max(0, OnInviteePanelList.count - 1)))
            make.centerX.equalTo(view)
            make.height.equalTo(80)
        }
        
        OninviteeStackView.safelyRemoveArrangedSubviews()
        if OnInviteePanelList.count > 0,!shouldHideOnInviteePanel {
            for user in OnInviteePanelList {
                let userAvatar = UIImageView()
                guard let avatar = user.avatar else {
                    debugPrint("user avatar is nil")
                    return
                }
                if let imageURL = URL.init(string: avatar) {
                    userAvatar.kf.setImage(with: .network(imageURL))
                }
                userAvatar.widthAnchor.constraint(equalToConstant: 44).isActive = true
                OninviteeStackView.addArrangedSubview(userAvatar)
            }
        }
        
        OnInviteePanel.isHidden = shouldHideOnInviteePanel
        
        UIView.animate(withDuration: 0.3, animations: {
            self.view.layoutIfNeeded()
            if self.curState == .calling {
                self.mute.alpha = 1.0
                self.handsfree.alpha = 1.0
                self.callTimeLabel.alpha = 1.0
            }
        }) { _ in
            
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
}

extension TRTCCallingAuidoViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func resetUserList() {
        if let sponsor = curSponsor {
            userList = [sponsor]
        } else {
            if let name = TUICallingProfileManager.sharedManager().name,
               let avatar = TUICallingProfileManager.sharedManager().avatar,
               let userId = TUICallingProfileManager.sharedManager().userId {
                let curUser = CallUserModel()
                curUser.name = name
                curUser.avatar = avatar
                curUser.userId = userId
                curUser.isEnter = true
                userList = [curUser]
            } else {
                userList = []
            }
        }
    }
    
    //MARK: - UICollectionViewDataSource
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collectionCount
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AudioCallUserCell", for: indexPath) as! AudioCallUserCell
        if (indexPath.row < userList.count) {
            let user = userList[indexPath.row]
            cell.userModel = user
        } else {
            cell.userModel = CallUserModel()
        }
        return cell
    }
    
    //MARK: - UICollectionViewDelegateFlowLayout
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let collectWidth = collectionView.frame.size.width
        if (collectionCount <= 4) {
            let border = collectWidth / 2;
            if (collectionCount % 2 == 1 && indexPath.row == collectionCount - 1) {
                return CGSize(width:  collectWidth, height: border)
            } else {
                return CGSize(width: border, height: border)
            }
        } else {
            let border = collectWidth / 3;
            return CGSize(width: border, height: border)
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
        
        return;
        
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
}

extension TRTCCallingAuidoViewController {
    private func registerButtonTouchEvents() {
        hangup.addTarget(self, action: #selector(hangupTouchEvent(sender:)), for: .touchUpInside)
        accept.addTarget(self, action: #selector(acceptTouchEvent(sender:)), for: .touchUpInside)
        handsfree.addTarget(self, action: #selector(handsfreeTouchEvent(sender:)), for: .touchUpInside)
        mute.addTarget(self, action: #selector(muteTouchEvent(sender:)), for: .touchUpInside)
    }
    
    @objc private func hangupTouchEvent(sender: UIButton) {
        TRTCCalling.shareInstance()
        TRTCCalling.shareInstance().hangup()
        disMiss()
    }
    
    @objc private func acceptTouchEvent(sender: UIButton) {
        
        TRTCCalling.shareInstance().accept()
        if let name = TUICallingProfileManager.sharedManager().name,
           let avatar = TUICallingProfileManager.sharedManager().avatar,
           let userId = TUICallingProfileManager.sharedManager().userId {
            let curUser = CallUserModel()
            curUser.name = name
            curUser.avatar = avatar
            curUser.userId = userId
            curUser.isEnter = true
            userList = [curUser]
        } else {
            userList = []
        }
        
        if let name = TUICallingProfileManager.sharedManager().name,
           let avatar = TUICallingProfileManager.sharedManager().avatar,
           let userId = TUICallingProfileManager.sharedManager().userId {
            let curUser = CallUserModel()
            curUser.name = name
            curUser.avatar = avatar
            curUser.userId = userId
            curUser.isEnter = true
            curUser.isEnter = true
            curUser.isVideoAvaliable = true
            enterUser(user: curUser)
            accept.isHidden = true
        }
    }
    
    @objc private func handsfreeTouchEvent(sender: UIButton) {
        self.isHandsFreeOn = !self.isHandsFreeOn
        TRTCCalling.shareInstance().setHandsFree(self.isHandsFreeOn)
        self.handsfree.setImage(UIImage.init(named: self.isHandsFreeOn ? "ic_handsfree_on" : "ic_handsfree", in: CallingBundle(), compatibleWith: nil), for: .normal)
        self.view.makeToast(self.isHandsFreeOn ? .handsfreeonText : .handsfreeoffText)
    }
    
    @objc private func muteTouchEvent(sender: UIButton) {
        self.isMicMute = !self.isMicMute
        TRTCCalling.shareInstance().setMicMute(self.isMicMute)
        self.mute.setImage(UIImage.init(named: self.isMicMute ? "ic_mute_on" : "ic_mute", in: CallingBundle(), compatibleWith: nil), for: .normal)
        self.view.makeToast(self.isMicMute ? .muteonText : .muteoffText)
    }
    
}

extension TRTCCallingAuidoViewController: CallingViewControllerResponder {
    
    public func enterUser(user: CallUserModel) {
        curState = .calling
        updateUser(user: user, animated: true)
    }
    
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
    
    public func leaveUser(user: CallUserModel) {
        if let index = userList.firstIndex(where: { (model) -> Bool in
            model.userId == user.userId
        }) {
            userList.remove(at: index)
        }
        reloadData(animate: true)
    }
    
    public func updateUser(user: CallUserModel, animated: Bool) {
        if let index = userList.firstIndex(where: { (model) -> Bool in
            model.userId == user.userId
        }) {
            userList.remove(at: index)
            userList.insert(user, at: index)
        } else {
            //            userList.append(user)
        }
        reloadData(animate: animated)
    }
    
    public func resetWithUserList(users: [CallUserModel], isInit: Bool = false) {
        resetUserList()
        if isInit && curSponsor != nil {
            inviteeList.append(contentsOf: users)
        } else {
            userList.append(contentsOf: users)
        }
        
        if !isInit {
            reloadData()
        }
    }
    
}

fileprivate extension String {
    static let muteonText = CallingLocalize("Demo.TRTC.calling.muteon")
    static let muteoffText = CallingLocalize("Demo.TRTC.calling.muteoff")
    static let handsfreeonText = CallingLocalize("Demo.TRTC.calling.handsfreeon")
    static let handsfreeoffText = CallingLocalize("Demo.TRTC.calling.handsfreeoff")
    static let waitingInviteText = CallingLocalize("Demo.TRTC.Calling.waitaccept")
}
