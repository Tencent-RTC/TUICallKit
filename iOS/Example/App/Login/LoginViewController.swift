//
//  LoginViewController.swift
//  TUICallKitApp
//
//  Created by gg on 2021/4/7.
//  Copyright © 2021 Tencent. All rights reserved.
//

import Foundation
import Toast_Swift
import WebKit
import ImSDK_Plus
import TUICore

#if canImport(TUICallKit_Swift)
import TUICallKit_Swift
#elseif canImport(TUICallKit)
import TUICallKit
#endif

class LoginViewController: UIViewController {
    
    let loading = UIActivityIndicatorView()
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.bringSubviewToFront(loading)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.barTintColor = .white
        ToastManager.shared.position = .center
        
        view.addSubview(loading)
        loading.snp.makeConstraints { (make) in
            make.width.height.equalTo(40)
            make.centerX.centerY.equalTo(view)
        }
    }
    
    func login(userId: String) {
        loading.startAnimating()
        let userSig = GenerateTestUserSig.genTestUserSig(identifier: userId)
        TUILogin.login(Int32(SDKAPPID), userID: userId, userSig: userSig) { [weak self] in
            guard let self = self else { return }
            self.loading.stopAnimating()
            SettingsConfig.share.userId = userId
            
            V2TIMManager.sharedInstance()?.getUsersInfo([userId], succ: { [weak self] (infos) in
                guard let self = self else { return }
                if let info = infos?.first {
                    SettingsConfig.share.avatar = info.faceURL ?? TUI_CALL_DEFAULT_AVATAR
                    SettingsConfig.share.name = info.nickName ?? ""
                }
                self.loginSucc()
            }, fail: { (code, err) in
                
            })
        } fail: { [weak self] code, errorDes in
            guard let self = self else { return }
            self.loading.stopAnimating()
            TUITool.makeToast("login failed, code:\(code), error: \(errorDes ?? "nil")")
        }
    }
    
    func loginSucc() {
        if SettingsConfig.share.name.count == 0 {
            let vc = RegisterViewController()
            navigationController?.pushViewController(vc, animated: true)
        } else {
            self.view.makeToast(TUICallKitAppLocalize("TUICallKitApp.Login.LoginSuccess"))
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                SceneDelegate.showMainController()
            }
        }
    }
    
    override func loadView() {
        super.loadView()
        let rootView = LoginRootView()
        rootView.rootVC = self
        view = rootView
    }
}

extension String {
    static let verifySuccessStr = "verifySuccess"
    static let verifyCancelStr = "verifyCancel"
    static let verifyErrorStr = "verifyError"
}
