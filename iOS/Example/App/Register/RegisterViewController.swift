//
//  RegisterViewController.swift
//  TUICallKitApp
//
//  Created by gg on 2021/4/8.
//  Copyright © 2021 Tencent. All rights reserved.
//

import Foundation
import Toast_Swift
import SnapKit
import UIKit
import TUICore

#if USE_TUICALLKIT_SWIFT
import TUICallKit_Swift
#else
import TUICallKit
#endif

class RegisterViewController: UIViewController {
    
    let loading = UIActivityIndicatorView(style: .large)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        self.title = .titleText
        ToastManager.shared.position = .center
        
        view.addSubview(loading)
        loading.snp.makeConstraints { (make) in
            make.width.height.equalTo(40)
            make.centerX.centerY.equalTo(view)
        }
    }
    
    func register(_ nickName: String) {
        loading.startAnimating()
        
        TUICallKit.createInstance().setSelfInfo(nickname: nickName, avatar: SettingsConfig.share.avatar) { [weak self] in
            guard let self = self else { return }
            self.registerSuccess()
        } fail: { code, message in
            TUITool.makeToast("login failed, code:\(code), error: \(message ?? "nil")")
            self.loading.stopAnimating()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    func registerSuccess() {
        self.loading.stopAnimating()
        self.view.makeToast(.registerSuccessText)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            SceneDelegate.showMainController()
        }
    }
    
    override func loadView() {
        super.loadView()
        let rootView = RegisterRootView()
        rootView.rootVC = self
        view = rootView
    }
}

fileprivate extension String {
    static let titleText = TUICallKitAppLocalize("TUICallKitApp.Login.Register")
    static let registerSuccessText = TUICallKitAppLocalize("TUICallKitApp.Login.RegisterSuccess")
}

