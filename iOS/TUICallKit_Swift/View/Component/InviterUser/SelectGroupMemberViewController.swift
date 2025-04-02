//
//  SelectGroupMemberViewController.swift
//  Pods
//
//  Created by vincepzhang on 2025/3/3.
//

import Foundation
import TUICore
import RTCCommon

class SelectGroupMemberViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
        
    var groupMemberList: Observable<[User]> = Observable([])
    var groupMemberState: [String: Bool] = [:]
    var groupMemberStateOrigin: [String: Bool] = [:]

    let navigationView: UIView = {
        let navigationView = UIView()
        navigationView.backgroundColor = TUICoreDefineConvert.getTUICoreDynamicColor(colorKey: "head_bg_gradient_start_color",
                                                                                     defaultHex: "#EBF0F6")
        return navigationView
    }()
    
    let leftBtn: UIButton = {
        let leftBtn = UIButton(type: .custom)
        leftBtn.addTarget(self, action: #selector(goBack), for: .touchUpInside)
        let defaultImage = CallKitBundle.getBundleImage(name: "icon_nav_back") ?? UIImage()
        let leftBtnImage = TUICoreDefineConvert.getTUIDynamicImage(imageKey: "icon_nav_back_image",
                                                                   module: TUIThemeModule.calling,
                                                                   defaultImage: defaultImage)
        leftBtn.setImage(leftBtnImage, for: .normal)
        return leftBtn
    }()
    
    let centerLabel: UILabel = {
        let centerLabel = UILabel(frame: CGRect.zero)
        centerLabel.font = UIFont.boldSystemFont(ofSize: 16.0)
        centerLabel.textAlignment = .center
        centerLabel.text = TUICallKitLocalize(key: "TUICallKit.Recents.addUser")
        centerLabel.textColor = TUICoreDefineConvert.getTUICallKitDynamicColor(colorKey: "callkit_nav_title_text_color",
                                                                               defaultHex: "#000000")
        return centerLabel
    }()
    
    let rightBtn: UIButton = {
        let rightBtn = UIButton(type: .system)
        rightBtn.addTarget(self, action: #selector(addUser), for: .touchUpInside)
        rightBtn.titleLabel?.font = UIFont.systemFont(ofSize: 17.0)
        rightBtn.setTitle(TUICallKitLocalize(key: "TUICallKit.determine"), for: .normal)
        rightBtn.setTitleColor(TUICoreDefineConvert.getTUICallKitDynamicColor(colorKey: "callkit_nav_item_title_text_color",
                                                                              defaultHex: "#000000"), for: .normal)
        return rightBtn
    }()
    
    let selectTableView: UITableView = {
        let selectTableView = UITableView(frame: CGRect.zero)
        selectTableView.backgroundColor = TUICoreDefineConvert.getTUICallKitDynamicColor(colorKey: "callkit_select_group_member_bg_color",
                                                                                         defaultHex: "#F2F2F2")
        return selectTableView
    }()
    
    //MARK: init
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        getGroupMember()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: UI Specification Processing
    override func viewDidLoad() {
        constructViewHierarchy()
        activateConstraints()
        bindInteraction()
    }
    
    func constructViewHierarchy() {
        view.addSubview(navigationView)
        view.addSubview(leftBtn)
        view.addSubview(leftBtn)
        view.addSubview(centerLabel)
        view.addSubview(rightBtn)
        view.addSubview(selectTableView)
    }
    
    func activateConstraints() {
        navigationView.snp.makeConstraints({ make in
            make.leading.trailing.top.equalToSuperview()
            make.height.equalTo(StatusBar_Height + 44)
        })
        leftBtn.snp.makeConstraints({ make in
            make.leading.equalToSuperview().offset(12)
            make.centerY.equalTo(centerLabel)
            make.width.height.equalTo(30)
        })
        centerLabel.snp.makeConstraints({ make in
            make.top.equalToSuperview().offset(StatusBar_Height)
            make.centerX.equalToSuperview()
            make.width.equalTo(Screen_Width * 2 / 3)
            make.height.equalTo(44)
        })
        rightBtn.snp.makeConstraints({ make in
            make.trailing.equalToSuperview().offset(-12)
            make.centerY.equalTo(centerLabel)
        })
        selectTableView.snp.makeConstraints({ make in
            make.top.equalTo(centerLabel.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        })
    }
    
    func bindInteraction() {
        selectTableView.dataSource = self
        selectTableView.delegate = self
        selectTableView.register(SelectGroupMemberCell.self, forCellReuseIdentifier: NSStringFromClass(SelectGroupMemberCell.self))
    }
    
    //MARK: other private
    private func getGroupMember() {
        V2TIMManager.sharedInstance().getGroupMemberList(CallManager.shared.callState.groupId,
                                                         filter: .max,
                                                         nextSeq: 0) { [weak self] nextSeq, imUserInfoList in
            guard let self = self else { return }
            guard let imUserInfoList = imUserInfoList else { return }
            
            for imUserInfo in imUserInfoList {
                if imUserInfo.userID == CallManager.shared.userState.selfUser.id.value {
                    continue
                }
                let user = UserManager.convertUserFromImFullInfo(user: imUserInfo)
                self.groupMemberList.value.append(user)
                self.groupMemberState[user.id.value] = false
                self.groupMemberStateOrigin[user.id.value] = false
            }
            
            for user in CallManager.shared.userState.remoteUserList.value {
                self.groupMemberState[user.id.value] = true
                self.groupMemberStateOrigin[user.id.value] = true
            }
            
            self.selectTableView.reloadData()
        } fail: { code, message in
            
        }
    }
    
    // MARK: Action
    @objc func addUser() {
        var userIds: [String] = []
        for state in groupMemberStateOrigin {
            if state.value {
                continue
            }
            if let isSelect = groupMemberState[state.key] {
                if isSelect {
                    userIds.append(state.key)
                }
            }
        }
        
        if userIds.count + CallManager.shared.userState.remoteUserList.value.count >=  MAX_USER {
            Toast.showToast(TUICallKitLocalize(key: "TUICallKit.User.Exceed.Limit"))
            return
        }
        
        CallManager.shared.inviteUser(userIds: userIds)
        dismiss(animated: true)
    }
    
    @objc func goBack() {
        dismiss(animated: true)
    }
    
}

extension SelectGroupMemberViewController {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groupMemberList.value.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(SelectGroupMemberCell.self),
                                                       for: indexPath) as? SelectGroupMemberCell else {
            return UITableViewCell()
        }
        
        if indexPath.row == 0 {
            cell.configCell(user: CallManager.shared.userState.selfUser, isSelect: true)
        } else {
            let user = groupMemberList.value[indexPath.row - 1]
            let isSelect = groupMemberState[user.id.value]
            cell.configCell(user: user, isSelect: isSelect ?? false)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            return
        }
        
        let user = groupMemberList.value[indexPath.row - 1]
        if groupMemberStateOrigin[user.id.value] ?? false {
            return
        }
        
        if groupMemberState[user.id.value] ?? false {
            groupMemberState[user.id.value] = false
        } else {
            groupMemberState[user.id.value] = true
        }
        selectTableView.reloadData()
    }
}
