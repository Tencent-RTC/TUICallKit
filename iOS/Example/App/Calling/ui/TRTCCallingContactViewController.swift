//
//  TRTCCallingContactViewController.swift
//  TXLiteAVDemo
//
//  Created by abyyxwang on 2020/8/6.
//  Copyright © 2020 Tencent. All rights reserved.
//

import Foundation
import Toast_Swift
import TUICalling
import ImSDK_Plus
import TUICore

enum CallingUserRemoveReason: UInt32 {
    case leave = 0
    case reject
    case noresp
    case busy
}

public class TRTCCallingContactViewController: UIViewController, TUICallingListerner {
    var selectedFinished: (([V2TIMUserFullInfo])->Void)? = nil
    @objc var callType: CallType = .audio
    /// 是否展示搜索结果
    var shouldShowSearchResult: Bool = false {
        didSet {
            if oldValue != shouldShowSearchResult {
                selectTable.reloadData()
            }
        }
    }
    
    /// 搜索结果model
    var searchResult: V2TIMUserFullInfo? = nil
    
    var sheetVC: UIAlertController? = nil
    
    let searchContainerView: UIView = {
        let view = UIView.init(frame: .zero)
        view.backgroundColor = .clear
        return view
    }()
    
    let searchBar: UISearchBar = {
        let searchBar = UISearchBar.init()
        searchBar.backgroundImage = UIImage.init()
        searchBar.placeholder = .searchPhoneNumberText
        searchBar.backgroundColor = UIColor(hex: "F4F5F9")
        searchBar.barTintColor = .clear
        searchBar.returnKeyType = .search
        searchBar.layer.cornerRadius = 20
        return searchBar
    }()
    
    /// 搜索按钮
    lazy var searchBtn: UIButton = {
        let done = UIButton(type: .custom)
        done.setTitle(.searchText, for: .normal)
        done.setTitleColor(.white, for: .normal)
        done.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        done.backgroundColor = UIColor(hex: "006EFF")
        done.clipsToBounds = true
        done.layer.cornerRadius = 20
        return done
    }()
    
    let userInfoLabel: UILabel = {
        let label = UILabel.init(frame: .zero)
        //TODO: 此处需要从IM获取到用户手机号
        label.text = "\(String.yourUserNameText):\("\(V2TIMManager.sharedInstance()?.getLoginUser() ?? "")")"
        label.font = UIFont.systemFont(ofSize: 16.0)
        label.textColor = .black
        label.textAlignment = .left
        return label
    }()
    
    /// 选择列表
    lazy var selectTable: UITableView = {
        let table = UITableView(frame: CGRect.zero, style: .plain)
        table.tableFooterView = UIView(frame: .zero)
        table.backgroundColor = .clear
        table.register(CallingSelectUserTableViewCell.classForCoder(), forCellReuseIdentifier: "CallingSelectUserTableViewCell")
        table.delegate = self
        table.dataSource = self
        return table
    }()
    
    let kUserBorder: CGFloat = 44.0
    let kUserSpacing: CGFloat = 2
    let kUserPanelLeftSpacing: CGFloat = 28
    
    /// 搜索记录为空时，提示
    lazy var noSearchImageView: UIImageView = {
        let imageView = UIImageView.init(image: UIImage.init(named: "noSearchMembers"))
        imageView.isUserInteractionEnabled = false
        return imageView
    }()
    
    lazy var noMembersTip: UILabel = {
        let label = UILabel()
        label.text = .backgroundTipsText
        label.numberOfLines = 2
        label.textAlignment = NSTextAlignment.center
        label.textColor = UIColor(hex: "BBBBBB")
        return label
    }()
    
    var callingVC = UIViewController()
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        navigationController?.navigationBar.barTintColor = .white
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor : UIColor.black];
        title = TRTCCallingLocalize("Demo.TRTC.calling.calltitle")
        let backBtn = UIButton(type: .custom)
        backBtn.setImage(UIImage(named: "calling_back"), for: .normal)
        backBtn.addTarget(self, action: #selector(backBtnClick), for: .touchUpInside)
        let item = UIBarButtonItem(customView: backBtn)
        item.tintColor = .black
        navigationItem.leftBarButtonItem = item
        setupUI()
        registerButtonTouchEvents()
    }
    
    @objc func backBtnClick() {
        let alertVC = UIAlertController.init(title: TRTCCallingLocalize("App.PortalViewController.areyousureloginout"), message: nil, preferredStyle: .alert)
        let cancelAction = UIAlertAction.init(title: TRTCCallingLocalize("App.PortalViewController.cancel"), style: .cancel, handler: nil)
        let sureAction = UIAlertAction.init(title: TRTCCallingLocalize("App.PortalViewController.determine"), style: .default) { (action) in
            ProfileManager.shared.removeLoginCache()
            AppUtils.shared.appDelegate.showLoginViewController()
            TUILogin.logout {
            } fail: { _, _ in
            }
            
            V2TIMManager.sharedInstance()?.logout({
                
            }, fail: { (errCode, errMsg) in
                
            })
        }
        alertVC.addAction(cancelAction)
        alertVC.addAction(sureAction)
        present(alertVC, animated: true, completion: nil)
    }
    
    deinit {
        debugPrint("deinit \(self)")
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
        searchBar.text = ""
        shouldShowSearchResult = false
        // 每次进入页面的时候，刷新手机号
        // TODO: 此处需要从IM获取到用户手机号
        userInfoLabel.text = "\(String.yourUserNameText)\("\(V2TIMManager.sharedInstance()?.getLoginUser() ?? "")")"
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    //MARK: - TUICallingListerner
    
    public func shouldShowOnCallView() -> Bool {
        return true;
    }
    
    public func callStart(userIDs: [String], type: TUICallingType, role: TUICallingRole, viewController: UIViewController?) {
        
        if let vc = viewController {
            callingVC = vc;
            vc.modalPresentationStyle = .fullScreen
            
            if var topController = UIApplication.shared.keyWindow?.rootViewController {
                while let presentedViewController = topController.presentedViewController {
                    topController = presentedViewController
                }
                if let navigationVC = topController as? UINavigationController {
                    if navigationVC.viewControllers.contains(self) {
                        present(vc, animated: false, completion: nil)
                    } else {
                        navigationVC.popToRootViewController(animated: false)
                        navigationVC.pushViewController(self, animated: false)
                        navigationVC.present(vc, animated: false, completion: nil)
                    }
                } else {
                    topController.present(vc, animated: false, completion: nil)
                }
            }
        }
    }
    
    public func callEnd(userIDs: [String], type: TUICallingType, role: TUICallingRole, totalTime: Float) {
        callingVC.dismiss(animated: true) {
        }
    }
    
    public func onCallEvent(event: TUICallingEvent, type: TUICallingType, role: TUICallingRole, message: String) {
        
    }
}

extension TRTCCallingContactViewController {
    
    func setupUI() {
        constructViewHierarchy()
        activateConstraints()
        bindInteraction()
        setupUIStyle()
        NotificationCenter.default.addObserver(self, selector: #selector(hiddenNoMembersImg), name: NSNotification.Name("HiddenNoSearchVideoNotificationKey"), object: nil)
        selectTable.reloadData()
    }
    
    func constructViewHierarchy() {
        // 添加SearchBar
        view.addSubview(searchContainerView)
        searchContainerView.addSubview(searchBar)
        searchContainerView.addSubview(searchBtn)
        view.addSubview(userInfoLabel)
        view.addSubview(selectTable)
        selectTable.isHidden = true
        view.addSubview(noSearchImageView)
        view.addSubview(noMembersTip)
    }
    
    func activateConstraints() {
        searchContainerView.snp.makeConstraints { (make) in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(20)
            make.leading.equalTo(20)
            make.trailing.equalTo(-20)
            make.height.equalTo(40)
        }
        searchBar.snp.makeConstraints { (make) in
            make.top.leading.bottom.equalToSuperview()
            make.trailing.equalTo(searchBtn.snp.leading).offset(-10)
        }
        searchBtn.snp.makeConstraints { (make) in
            make.top.trailing.bottom.equalToSuperview()
            make.width.equalTo(60)
        }
        userInfoLabel.snp.makeConstraints { (make) in
            make.top.equalTo(searchContainerView.snp.bottom).offset(20)
            make.leading.equalTo(20)
            make.trailing.equalTo(-20)
            make.height.equalTo(20)
        }
        selectTable.snp.makeConstraints { (make) in
            make.top.equalTo(userInfoLabel.snp.bottom).offset(10)
            make.leading.trailing.equalTo(view)
            make.bottomMargin.equalTo(view)
        }
        noSearchImageView.snp.makeConstraints { (make) in
            make.top.equalTo(view.bounds.size.height/3.0)
            make.leading.equalTo(view.bounds.size.width*154.0/375)
            make.trailing.equalTo(-view.bounds.size.width*154.0/375)
            make.height.equalTo(view.bounds.size.width*67.0/375)
        }
        noMembersTip.snp.makeConstraints { (make) in
            make.top.equalTo(noSearchImageView.snp.bottom)
            make.width.equalTo(view.bounds.size.width)
            make.height.equalTo(60)
        }
    }
    
    func setupUIStyle() {
        if let textfield = searchBar.value(forKey: "searchField") as? UITextField {
            textfield.layer.cornerRadius = 10.0
            textfield.layer.masksToBounds = true
            textfield.textColor = .black
            textfield.backgroundColor = .clear
            textfield.leftViewMode = .always
            if let leftView = textfield.leftView as? UIImageView {
                leftView.image =  UIImage.init(named: "cm_search_white")
            }
        }
        ToastManager.shared.position = .bottom
    }
    
    func bindInteraction() {
        searchBar.delegate = self
        // 设置选择通话用户结束后的交互逻辑
        selectedFinished = { [weak self] users in
            guard let `self` = self else {return}
            self.showChooseCallTypeSheet(users: users)
        }
    }
    
    func showChooseCallTypeSheet(users: [V2TIMUserFullInfo]) {
        sheetVC = UIAlertController.init(title: TRTCCallingLocalize("Demo.TRTC.calling.callType") , message: "", preferredStyle: .actionSheet)
        let audioAction = UIAlertAction.init(title: TRTCCallingLocalize("Audio Call"), style: .default) { [weak self] _ in
            guard let `self` = self else { return }
            self.callType = .audio
            var userIds: [String] = []
            
            for userModel in users {
                userIds.append(userModel.userID)
            }
            
            TUICalling.shareInstance().call(userIDs: userIds, type: .audio)
        }
        
        let videoAction = UIAlertAction.init(title: TRTCCallingLocalize("Video Call"), style: .default) { [weak self] _ in
            guard let `self` = self else { return }
            self.callType = .video
            var userIds: [String] = []
            for userModel in users {
                userIds.append(userModel.userID)
            }
            
            TUICalling.shareInstance().call(userIDs: userIds, type: .video)
        }
        sheetVC!.addAction(audioAction)
        sheetVC!.addAction(videoAction)
        present(sheetVC!, animated: true) {
            self.sheetVC!.view.superview?.subviews.first?.isUserInteractionEnabled = true
            self.sheetVC!.view.superview?.subviews.first?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.actionSheetBackgroundTapped)))
        }
    }
    
    @objc func actionSheetBackgroundTapped() {
        sheetVC!.dismiss(animated: true, completion: nil)
    }
    
    @objc func hiddenNoMembersImg() {
        noSearchImageView.removeFromSuperview()
        noMembersTip.removeFromSuperview()
        selectTable.isHidden = false
    }
}

extension TRTCCallingContactViewController: UITextFieldDelegate, UISearchBarDelegate {
    
    public func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        if let input = searchBar.text, input.count > 0 {
            searchUser(input: input)
        }
    }
    
    public func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text == nil || searchBar.text?.count ?? 0 == 0 {
            //show recent table
            shouldShowSearchResult = false
        }
        
        if (searchBar.text?.count ?? 0) > 11 {
            searchBar.text = (searchBar.text as NSString?)?.substring(to: 11)
        }
    }
    
    public func searchUser(input: String)  {
        //TODO: 获取用户信息，调用IM
        V2TIMManager.sharedInstance()?.getUsersInfo([input], succ: { [weak self] (userInfos) in
            guard let `self` = self, let userInfo = userInfos?.first else { return }
            self.searchResult = userInfo
            self.shouldShowSearchResult = true
            self.selectTable.reloadData()
            NotificationCenter.default.post(name: NSNotification.Name("HiddenNoSearchVideoNotificationKey"), object: nil)
        }, fail: { [weak self] (_, _) in
            guard let self = self else {return}
            self.searchResult = nil
            self.view.makeToast(.failedSearchText)
        })
    }
}

extension TRTCCallingContactViewController: UITableViewDelegate, UITableViewDataSource {
    
    //MARK: - UITableViewDataSource
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if shouldShowSearchResult {
            return 1
        }
        return 0
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CallingSelectUserTableViewCell") as! CallingSelectUserTableViewCell
        cell.selectionStyle = .none
        if shouldShowSearchResult {
            if let user = searchResult {
                cell.config(model: user, selected: false) { [weak self] in
                    guard let self = self else { return }
                    if user.userID == V2TIMManager.sharedInstance()?.getLoginUser() {
                        self.view.makeToast(.cantInvateSelfText)
                        return
                    }
                    if let finish = self.selectedFinished {
                        finish([user])
                    }
                }
            } else {
                debugPrint("not search result")
            }
        }
        return cell
    }
    
    public func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = .clear
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.textColor = UIColor.white
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    public func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
}

extension TRTCCallingContactViewController {
    private func registerButtonTouchEvents() {
        searchBtn.addTarget(self, action: #selector(searchBtnTouchEvent(sender:)), for: .touchUpInside)
    }
    
    @objc private func searchBtnTouchEvent(sender: UIButton) {
        self.searchBar.resignFirstResponder()
        if let input = self.searchBar.text, input.count > 0 {
            self.searchUser(input: input)
        }
    }
}

private extension String {
    static let yourUserNameText = TRTCCallingLocalize("Demo.TRTC.calling.youruserId")
    static let searchPhoneNumberText = TRTCCallingLocalize("Demo.TRTC.calling.searchUserId")
    static let searchText = TRTCCallingLocalize("Demo.TRTC.calling.searching")
    static let backgroundTipsText = TRTCCallingLocalize("Demo.TRTC.calling.searchandcall")
    static let enterConvText = TRTCCallingLocalize("Demo.TRTC.calling.callingbegan")
    static let cancelConvText = TRTCCallingLocalize("Demo.TRTC.calling.callingcancel")
    static let callTimeOutText = TRTCCallingLocalize("Demo.TRTC.calling.callingtimeout")
    static let rejectToastText = TRTCCallingLocalize("Demo.TRTC.calling.callingrefuse")
    static let leaveToastText = TRTCCallingLocalize("Demo.TRTC.calling.callingleave")
    static let norespToastText = TRTCCallingLocalize("Demo.TRTC.calling.callingnoresponse")
    static let busyToastText = TRTCCallingLocalize("Demo.TRTC.calling.callingbusy")
    static let failedSearchText = TRTCCallingLocalize("Demo.TRTC.calling.searchingfailed")
    static let cantInvateSelfText = TRTCCallingLocalize("Demo.TRTC.calling.cantinviteself")
}
