//
//  MainViewController.swift
//  TUICallKitApp
//
//  Created by vincepzhang on 2023/6/5.
//

import UIKit
import TUICore

class MainViewController: UIViewController {
    
    lazy var userInfoContentView: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = .white
        return view
    }()
    lazy var userAvImage: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "tencent_cloud"))
        let faceURL = SettingsConfig.share.avatar
        if let imageURL = URL(string: faceURL) {
            imageView.kf.setImage(with: .network(imageURL), placeholder: getBundleImage(withName: "userIcon"))
        }
        imageView.layer.cornerRadius = 30
        imageView.layer.masksToBounds = true
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    lazy var userNameLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont.systemFont(ofSize: 20)
        label.textColor = UIColor.black
        label.text = SettingsConfig.share.name
        return label
    }()
    lazy var userIdLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont.systemFont(ofSize: 15)
        label.textColor = UIColor.black
        label.text = "UserID: \(SettingsConfig.share.userId)"
        return label
    }()
    lazy var logoContentView: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = UIColor.white
        return view
    }()
    lazy var logoImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "tencent_cloud"))
        return imageView
    }()
    lazy var titleLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont.systemFont(ofSize: 32)
        label.textColor = UIColor(hex: "333333") ?? .black
        label.text = TUICallKitAppLocalize("TUICallKitApp.Login.Product")
        label.numberOfLines = 0
        return label
    }()
    lazy var singleCallBtn: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitleColor(.white, for: .normal)
        btn.setTitle(TUICallKitAppLocalize("TUICallKitApp.SingleCall"), for: .normal)
        btn.adjustsImageWhenHighlighted = false
        btn.setBackgroundImage(UIColor(hex: "006EFF")?.trans2Image(), for: .normal)
        btn.titleLabel?.font = UIFont(name: "PingFangSC-Medium", size: 20)
        btn.layer.shadowColor = UIColor(hex: "006EFF")?.cgColor ?? UIColor.blue.cgColor
        btn.layer.shadowOffset = CGSize(width: 0, height: 6)
        btn.layer.masksToBounds = true
        btn.layer.cornerRadius = 10
        return btn
    }()
    lazy var groupCallBtn: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitleColor(.white, for: .normal)
        btn.setTitle(TUICallKitAppLocalize("TUICallKitApp.GroupCall"), for: .normal)
        btn.adjustsImageWhenHighlighted = false
        btn.setBackgroundImage(UIColor(hex: "006EFF")?.trans2Image(), for: .normal)
        btn.titleLabel?.font = UIFont(name: "PingFangSC-Medium", size: 20)
        btn.layer.shadowColor = UIColor(hex: "006EFF")?.cgColor ?? UIColor.blue.cgColor
        btn.layer.shadowOffset = CGSize(width: 0, height: 6)
        btn.layer.masksToBounds = true
        btn.layer.cornerRadius = 10
        return btn
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = true
        constructViewHierarchy()
        activateConstraints()
        bindInteraction()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        updateView()
    }
    
    func updateView() {
        let faceURL = SettingsConfig.share.avatar
        if let imageURL = URL(string: faceURL) {
            userAvImage.kf.setImage(with: .network(imageURL), placeholder: getBundleImage(withName: "userIcon"))
        }
        userNameLabel.text = SettingsConfig.share.name
        userIdLabel.text = "UserID: \(SettingsConfig.share.userId)"
    }
    
    func constructViewHierarchy() {
        view.addSubview(userInfoContentView)
        userInfoContentView.addSubview(userAvImage)
        userInfoContentView.addSubview(userNameLabel)
        userInfoContentView.addSubview(userIdLabel)
        
        view.addSubview(logoContentView)
        logoContentView.addSubview(logoImageView)
        logoContentView.addSubview(titleLabel)
        
        view.addSubview(singleCallBtn)
        view.addSubview(groupCallBtn)
    }
    
    func activateConstraints() {
        userInfoContentView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(100)
            make.leading.equalToSuperview().offset(50)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview()
            make.height.equalTo(60)
        }
        userAvImage.snp.makeConstraints { make in
            make.centerY.leading.equalToSuperview()
            make.height.width.equalTo(60)
        }
        userNameLabel.snp.makeConstraints { make in
            make.leading.equalTo(userAvImage.snp.trailing).offset(10)
            make.top.equalToSuperview().offset(5)
        }
        userIdLabel.snp.makeConstraints { make in
            make.leading.equalTo(userAvImage.snp.trailing).offset(10)
            make.bottom.equalToSuperview().offset(-5)
        }
        logoContentView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(200)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.height.equalTo(100)
        }
        logoImageView.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(40)
            make.height.equalTo(80)
            make.width.equalTo(80)
        }
        titleLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(logoImageView.snp.centerY)
            make.leading.equalTo(logoImageView.snp.trailing).offset(10)
            make.trailing.equalToSuperview()
        }
        groupCallBtn.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-60)
            make.leading.equalToSuperview().offset(40)
            make.trailing.equalToSuperview().offset(-40)
            make.height.equalTo(60)
        }
        singleCallBtn.snp.makeConstraints { make in
            make.bottom.equalTo(groupCallBtn.snp.top).offset(-20)
            make.leading.equalToSuperview().offset(40)
            make.trailing.equalToSuperview().offset(-40)
            make.height.equalTo(60)
        }
    }
    
    func bindInteraction() {
        let userAvTapGesture = UITapGestureRecognizer(target: self, action: #selector(userAvImageClick))
        userAvImage.addGestureRecognizer(userAvTapGesture)
        singleCallBtn.addTarget(self, action: #selector(singleCallBtnClick), for: .touchUpInside)
        groupCallBtn.addTarget(self, action: #selector(groupCallBtnClick), for: .touchUpInside)
    }
    
    @objc func userAvImageClick() {
        let alertVC = UIAlertController(title: TUICallKitAppLocalize("TUICallKitApp.Home.AreYouSureLogout"), message: nil, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: TUICallKitAppLocalize("TUICallKitApp.Home.Cancel"), style: .cancel, handler: nil)
        let sureAction = UIAlertAction(title: TUICallKitAppLocalize("TUICallKitApp.Home.Determine"), style: .default) { (action) in
            SettingsConfig.share.avatar = ""
            SettingsConfig.share.name = ""
            SettingsConfig.share.userId = ""
            SceneDelegate.showLoginViewController()
            TUILogin.logout {
            } fail: { _, _ in
            }
        }
        alertVC.addAction(cancelAction)
        alertVC.addAction(sureAction)
        present(alertVC, animated: true, completion: nil)
    }
    
    @objc func singleCallBtnClick() {
        let singleCallVC = SingleCallViewController()
        singleCallVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(singleCallVC, animated: true)
        
    }
    
    @objc func groupCallBtnClick() {
        let groupCallVC = GroupCallViewController()
        groupCallVC.title = TUICallKitAppLocalize("TUICallKitApp.GroupCall")
        groupCallVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(groupCallVC, animated: true)
    }
    
}

extension MainViewController {
    
    func getBundleImage(withName: String) -> UIImage {
        guard let callingKitBundleURL = Bundle.main.url(forResource: "TUICallKitBundle", withExtension: "bundle") else { return UIImage() }
        let bundle = Bundle(url: callingKitBundleURL)
        guard let image = UIImage(named: withName, in: bundle, compatibleWith: nil) else { return UIImage() }
        return image
    }
    
}
