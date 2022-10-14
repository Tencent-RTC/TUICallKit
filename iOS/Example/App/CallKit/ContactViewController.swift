//
//  ContactViewController.swift
//  TUICallKitApp
//
//  Created by abyyxwang on 2020/8/6.
//  Copyright © 2020 Tencent. All rights reserved.
//

import Foundation
import TUICallKit
import UIKit

public class ContactViewController: UIViewController {
    @objc var callType: TUICallMediaType = .audio
    
    lazy var callKitContactView: ContactView = {
        let callingContactView = ContactView(frame: .zero, type: .call) { [weak self] users in
            guard let `self` = self else {return}
            var userIds: [String] = []
            for V2TIMUserFullInfo in users {
                userIds.append(V2TIMUserFullInfo.userID)
            }
            self.showCallVC(users: userIds)
        }
        return callingContactView
    }()
    
    deinit {
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        let backButton = UIButton(type: .custom)
        backButton.setImage(UIImage(named: "calling_back"), for: .normal)
        backButton.addTarget(self, action: #selector(backButtonClick), for: .touchUpInside)
        let item = UIBarButtonItem(customView: backButton)
        item.tintColor = UIColor.black
        navigationItem.leftBarButtonItem = item
        
        setupUI()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    @objc func backButtonClick() {
        navigationController?.popViewController(animated: true)
    }
}

extension ContactViewController {
    func setupUI() {
        view.addSubview(callKitContactView)
        
        callKitContactView.snp.makeConstraints { (make) in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(20)
            make.topMargin.equalTo(view)
            make.leading.trailing.equalTo(view)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
    }
    
    func showCallVC(users: [String]) {
        TUICallKit.createInstance().call(userId: users.first ?? "", callMediaType:callType)
    }
}

