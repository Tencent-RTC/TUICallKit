//
//  GroupContactViewController.swift
//  TUICallKitApp
//
//  Created by noah on 2021/12/21.
//  Copyright © 2021 Tencent. All rights reserved.
//

import UIKit
import Foundation
import Toast_Swift
import TUICallKit

public class GroupContactViewController: UIViewController {
    var selectedFinished: (([V2TIMUserFullInfo])->Void)? = nil
    var addedV2TIMUserFullInfo: [V2TIMUserFullInfo] = []
    @objc var callType: TUICallMediaType = .audio
    
    let addedTableTitle: UILabel = {
        let label = UILabel(frame: .zero)
        label.text = TUICallKitAppLocalize("TUICallKitApp.addedUser")
        label.font = UIFont.systemFont(ofSize: 16.0)
        label.textColor = UIColor.black
        label.textAlignment = .left
        return label
    }()
    
    /// 已添加用户列表
    lazy var addedTable: UITableView = {
        let table = UITableView(frame: CGRect.zero, style: .plain)
        table.tableFooterView = UIView(frame: .zero)
        table.backgroundColor = UIColor.clear
        table.register(SelectUserTableViewCell.classForCoder(), forCellReuseIdentifier: "CallingSelectUserTableViewCell")
        table.delegate = self
        table.dataSource = self
        return table
    }()
    
    /// 已添加成员为空时，提示
    lazy var noMembersTip: UILabel = {
        let label = UILabel()
        label.text = TUICallKitAppLocalize("TUICallKitApp.tips")
        label.numberOfLines = 2
        label.textAlignment = NSTextAlignment.center
        label.textColor = UIColor(hex: "BBBBBB")
        return label
    }()
    
    lazy var callingContactView: ContactView = {
        let callingContactView = ContactView(frame: .zero, type: .add) { [weak self] users in
            guard let `self` = self else {return}
            self.addUser(users: users)
        }
        
        return callingContactView
    }()
    
    deinit {
        debugPrint("deinit \(self)")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        // 左侧按钮
        let backButton = UIButton(type: .custom)
        backButton.setImage(UIImage(named: "calling_back"), for: .normal)
        backButton.addTarget(self, action: #selector(backButtonClick), for: .touchUpInside)
        let item = UIBarButtonItem(customView: backButton)
        item.tintColor = UIColor.black
        navigationItem.leftBarButtonItem = item
        // 右侧按钮
        let callButton = UIButton(frame: CGRect(x: 0, y:0, width: 50, height: 30))
        callButton.setTitle(TUICallKitAppLocalize("TUICallKitApp.done"), for: .normal)
        callButton.setTitleColor(UIColor.black, for: .normal)
        callButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        callButton.addTarget(self, action: #selector(showCallVC), for: .touchUpInside)
        let rightItem = UIBarButtonItem(customView: callButton)
        rightItem.tintColor = UIColor.black
        navigationItem.rightBarButtonItem = rightItem
        
        setupUI()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
        hiddenNoMembersImage(isHidden: false)
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    @objc func backButtonClick() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func showCallVC() {
        var userIds:[String] = []
        for item in addedV2TIMUserFullInfo {
            userIds.append(item.userID)
        }
        
        guard userIds.count > 0 else {
            self.view.makeToast(TUICallKitAppLocalize("TUICallKitApp.tips"))
            return
        }
        
        TUICallKit.createInstance().groupCall(groupId: "", userIdList: userIds, callMediaType: callType)
    }
}

extension GroupContactViewController {
    func setupUI() {
        constructViewHierarchy()
        activateConstraints()
        bindInteraction()
        ToastManager.shared.position = .bottom
        hiddenNoMembersImage(isHidden: false)
        addedTable.reloadData()
    }
    
    func constructViewHierarchy() {
        view.addSubview(addedTableTitle)
        view.addSubview(addedTable)
        view.addSubview(noMembersTip)
        view.addSubview(callingContactView)
    }
    
    func activateConstraints() {
        addedTableTitle.snp.makeConstraints { (make) in
            make.topMargin.equalTo(view).offset(20)
            make.leading.equalTo(view).offset(20)
            make.trailing.equalTo(-20)
            make.height.equalTo(20)
        }
        addedTable.snp.makeConstraints { (make) in
            make.top.equalTo(addedTableTitle.snp.bottom).offset(10)
            make.leading.trailing.equalTo(view)
            make.height.equalTo(200)
        }
        noMembersTip.snp.makeConstraints { (make) in
            make.top.equalTo(addedTable.bounds.size.height/3.0)
            make.leading.equalTo(addedTable.bounds.size.width*154.0/375)
            make.trailing.equalTo(-addedTable.bounds.size.width*154.0/375)
            make.height.equalTo(addedTable.bounds.size.width*67.0/375)
        }
        callingContactView.snp.makeConstraints { (make) in
            make.top.equalTo(addedTable.snp.bottom)
            make.left.right.equalTo(view)
            make.bottomMargin.equalTo(view)
        }
    }
    
    func bindInteraction() {
        // 设置选择通话用户结束后的交互逻辑
        selectedFinished = { [weak self] users in
            guard let `self` = self else {return}
            self.deleteAddedUser(users: users)
        }
    }
    
    func deleteAddedUser(users: [V2TIMUserFullInfo]) {
        guard users.count > 0 else { return }
        guard let waitingAddUser: V2TIMUserFullInfo = users.first else { return }
        
        var waitingDeleteUser : Int = -1
        for (index, item) in addedV2TIMUserFullInfo.enumerated() where waitingAddUser.userID == item.userID {
            waitingDeleteUser = index
        }
        
        guard waitingDeleteUser != -1 else { return }
        addedV2TIMUserFullInfo.remove(at: waitingDeleteUser)
        addedTable.reloadData()
    }
    
    func addUser(users: [V2TIMUserFullInfo]) {
        guard users.count > 0 else { return }
        guard let waitingAddUser: V2TIMUserFullInfo = users.first else { return }
        var addedFlag = false
        for _ in addedV2TIMUserFullInfo.filter({$0.userID == waitingAddUser.userID}) {
            addedFlag = true
        }
        guard addedFlag == false else { return }
        addedV2TIMUserFullInfo.append(waitingAddUser)
        addedTable.reloadData()
    }
    
    @objc func hiddenNoMembersImage(isHidden: Bool) {
        noMembersTip.isHidden = isHidden
    }
}

extension GroupContactViewController: UITableViewDelegate, UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return addedV2TIMUserFullInfo.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CallingSelectUserTableViewCell") as! SelectUserTableViewCell
        cell.selectionStyle = .none
        let V2TIMUserFullInfo = addedV2TIMUserFullInfo[indexPath.row]
        
        cell.config(model: V2TIMUserFullInfo, type: .delete, selected: false) { [weak self] in
            guard let `self` = self else { return }
            
            if let finish = self.selectedFinished {
                finish([V2TIMUserFullInfo])
            }
        }
        
        return cell
    }
    
    public func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = UIColor.clear
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
