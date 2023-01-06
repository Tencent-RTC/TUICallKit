//
//  RegisterViewController.swift
//  TUICallKitApp
//
//  Created by gg on 2021/4/8.
//  Copyright © 2021 Tencent. All rights reserved.
//

import Foundation
import Toast_Swift
import TXAppBasic
import SnapKit
import UIKit

class RegisterViewController: UIViewController {

    let loading = UIActivityIndicatorView(style: .large)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ToastManager.shared.position = .center
        
        view.addSubview(loading)
        loading.snp.makeConstraints { (make) in
            make.width.height.equalTo(40)
            make.centerX.centerY.equalTo(view)
        }
    }
    
    func register(_ nickName: String) {
        loading.startAnimating()
        ProfileManager.shared.synchronizUserInfo()
        ProfileManager.shared.setNickName(name: nickName) { [weak self] in
            guard let `self` = self else { return }
            self.registerSuccess()
        } failed: { (err) in
            self.loading.stopAnimating()
            self.view.makeToast(err)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    func registerSuccess() {
        self.loading.stopAnimating()
        self.view.makeToast(.registerSuccessText)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            //show main vc
            AppUtils.shared.showMainController()
        }
    }
    
    override func loadView() {
        super.loadView()
        let rootView = RegisterRootView()
        rootView.rootVC = self
        view = rootView
    }
}

/// MARK: - internationalization string
fileprivate extension String {
    static let registerSuccessText = TUICallKitAppLocalize("TUICallKitApp.Login.registersuccess")
}

