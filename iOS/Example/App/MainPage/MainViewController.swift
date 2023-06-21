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
            imageView.kf.setImage(with: .network(imageURL), placeholder: AppUtils.getBundleImage(withName: "userIcon"))
        }
        imageView.layer.cornerRadius = 30
        imageView.layer.masksToBounds = true
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    lazy var userNameLable: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont.systemFont(ofSize: 20)
        label.textColor = UIColor.black
        label.text = SettingsConfig.share.name
        return label
    }()
    lazy var userIdLable: UILabel = {
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
    lazy var tencentCloudImage: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "tencent_cloud"))
        return imageView
    }()
    lazy var titleLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont.systemFont(ofSize: 32)
        label.textColor = UIColor(hex: "333333") ?? .black
        label.text = TUICallKitAppLocalize("TUICallKitApp.Login.tencentcloud")
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
        constructViewHierarchy() // 视图层级布局
        activateConstraints() // 生成约束（此时有可能拿不到父视图正确的frame）
        bindInteraction()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        updateView()
    }
    
    func updateView() {
        let faceURL = SettingsConfig.share.avatar
        if let imageURL = URL(string: faceURL) {
            userAvImage.kf.setImage(with: .network(imageURL), placeholder: AppUtils.getBundleImage(withName: "userIcon"))
        }
        userNameLable.text = SettingsConfig.share.name
        userIdLable.text = "UserID: \(SettingsConfig.share.userId)"
    }

    func constructViewHierarchy() {
        view.addSubview(userInfoContentView)
        userInfoContentView.addSubview(userAvImage)
        userInfoContentView.addSubview(userNameLable)
        userInfoContentView.addSubview(userIdLable)

        view.addSubview(logoContentView)
        logoContentView.addSubview(tencentCloudImage)
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
        userNameLable.snp.makeConstraints { make in
            make.leading.equalTo(userAvImage.snp.trailing).offset(10)
            make.top.equalToSuperview().offset(5)
        }
        userIdLable.snp.makeConstraints { make in
            make.leading.equalTo(userAvImage.snp.trailing).offset(10)
            make.bottom.equalToSuperview().offset(-5)
        }
        
        logoContentView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(200)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.height.equalTo(100)
        }
        tencentCloudImage.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(40)
            make.height.equalTo(80)
            make.width.equalTo(80)
        }
        titleLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(tencentCloudImage.snp.centerY)
            make.leading.equalTo(tencentCloudImage.snp.trailing).offset(10)
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
        let alertVC = UIAlertController(title: TUICallKitAppLocalize("TUICallKitApp.Home.areyousureloginout"), message: nil, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: TUICallKitAppLocalize("TUICallKitApp.Home.cancel"), style: .cancel, handler: nil)
        let sureAction = UIAlertAction(title: TUICallKitAppLocalize("TUICallKitApp.Home.determine"), style: .default) { (action) in
            SettingsConfig.share.avatar = ""
            SettingsConfig.share.name = ""
            SettingsConfig.share.userId = ""
            AppUtils.shared.appDelegate.showLoginViewController()
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
    
    func getUrlImage(url: String) -> UIImage? {
        guard let url = URL(string: url) else { return nil }
        var data = Data()
        do {
            data = try Data(contentsOf: url)
        } catch _ as NSError {}
        return  UIImage(data: data)
    }
    
}
