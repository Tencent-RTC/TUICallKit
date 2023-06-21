//
//  LoginRootView.swift
//  TUICallKitApp
//
//  Created by gg on 2021/4/7.
//  Copyright © 2021 Tencent. All rights reserved.
//

import UIKit
import SnapKit

class LoginRootView: UIView {
    
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
        label.text = .titleText
        label.numberOfLines = 0
        return label
    }()
    
    lazy var userIdContentView: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = UIColor.white
        view.layer.cornerRadius = 10
        view.layer.masksToBounds = true
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.gray.cgColor
        return view
    }()
    lazy var userIdTextLable: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont.systemFont(ofSize: 20)
        label.textColor = UIColor.black
        label.text = "UserId"
        return label
    }()
    lazy var calledUserIdTextField: UITextField = {
        let textField = UITextField(frame: .zero)
        textField.backgroundColor = UIColor.white
        textField.font = UIFont(name: "PingFangSC-Regular", size: 20)
        textField.textColor = UIColor(hex: "333333")
        textField.attributedPlaceholder = NSAttributedString(string: "userId")
        textField.delegate = self
        textField.keyboardType = .phonePad
        return textField
    }()
    weak var currentTextField: UITextField?
    lazy var loginBtn: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitleColor(.white, for: .normal)
        btn.setTitle(.loginText, for: .normal)
        btn.adjustsImageWhenHighlighted = false
        btn.setBackgroundImage(UIColor(hex: "006EFF")?.trans2Image(), for: .normal)
        btn.titleLabel?.font = UIFont(name: "PingFangSC-Medium", size: 20)
        btn.layer.shadowColor = UIColor(hex: "006EFF")?.cgColor ?? UIColor.blue.cgColor
        btn.layer.shadowOffset = CGSize(width: 0, height: 6)
        btn.layer.masksToBounds = true
        btn.layer.cornerRadius = 10
        return btn
    }()
    
    lazy var otherContentView: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = UIColor.white
        return view
    }()
    lazy var lineView: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = UIColor(hex: "EEEEEE")
        return view
    }()
    lazy var quickAccessLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont.systemFont(ofSize: 15)
        label.textColor = UIColor(hex: "333333") ?? .black
        label.text = TUICallKitAppLocalize("TUICallKitApp.QuickAccess")
        label.numberOfLines = 4
        return label
    }()
    lazy var  buyLableTapGesture: UITapGestureRecognizer = {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(buyLableTapGestureClick))
        return tapGesture
    }()
    lazy var buyLable: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont.systemFont(ofSize: 10)
        label.textColor = UIColor.blue
        label.text = .buyText
        label.isUserInteractionEnabled = true
        label.addGestureRecognizer(buyLableTapGesture)
        return label
    }()
    lazy var accessLableTapGesture = {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(accessLableTapGestureClick))
        return tapGesture
    }()
    lazy var accessLable: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont.systemFont(ofSize: 10)
        label.textColor = UIColor.blue
        label.text = .accessText
        label.isUserInteractionEnabled = true
        label.addGestureRecognizer(accessLableTapGesture)
        return label
    }()
    
    lazy var  apiLableTapGesture = {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(apiLableTapGestureClick))
        return tapGesture
    }()
    lazy var apiLable: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont.systemFont(ofSize: 10)
        label.textColor = UIColor.blue
        label.text = .apiText
        label.isUserInteractionEnabled = true
        label.addGestureRecognizer(apiLableTapGesture)
        return label
    }()
    lazy var  problemLableTapGesture = {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(problemLableTapGestureClick))
        return tapGesture
    }()
    lazy var problemLable: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont.systemFont(ofSize: 10)
        label.textColor = UIColor.blue
        label.text = .problemText
        label.isUserInteractionEnabled = true
        label.addGestureRecognizer(problemLableTapGesture)
        return label
    }()
    
    private func createTextField(_ placeholder: String) -> UITextField {
        let textField = UITextField(frame: .zero)
        textField.backgroundColor = .white
        textField.font = UIFont(name: "PingFangSC-Regular", size: 16)
        textField.textColor = UIColor(hex: "333333")
        let attrs = [
            NSAttributedString.Key.font : UIFont(name: "PingFangSC-Regular", size: 16) ?? UIFont.systemFont(ofSize: 16),
            NSAttributedString.Key.foregroundColor : UIColor(hex: "BBBBBB") ?? .gray,
        ]
        textField.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: attrs)
        textField.delegate = self
        return textField
    }
        
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        if let current = currentTextField {
            current.resignFirstResponder()
            currentTextField = nil
        }
        UIView.animate(withDuration: 0.3) {
            self.transform = .identity
        }
    }
    
    weak var rootVC: LoginViewController?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var isViewReady = false
    override func didMoveToWindow() {
        super.didMoveToWindow()
        guard !isViewReady else {
            return
        }
        isViewReady = true
        constructViewHierarchy() // 视图层级布局
        activateConstraints() // 生成约束（此时有可能拿不到父视图正确的frame）
        bindInteraction()
    }
    
    func constructViewHierarchy() {
        addSubview(logoContentView)
        logoContentView.addSubview(tencentCloudImage)
        logoContentView.addSubview(titleLabel)
        
        addSubview(userIdContentView)
        userIdContentView.addSubview(userIdTextLable)
        userIdContentView.addSubview(calledUserIdTextField)
        
        addSubview(loginBtn)
        
        addSubview(otherContentView)
        otherContentView.addSubview(lineView)
        otherContentView.addSubview(quickAccessLabel)
        otherContentView.addSubview(buyLable)
        otherContentView.addSubview(accessLable)
        otherContentView.addSubview(apiLable)
        otherContentView.addSubview(problemLable)
    }
    func activateConstraints() {
        logoContentView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(100)
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
        
        userIdContentView.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.height.equalTo(60)
        }
        userIdTextLable.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(20)
        }
        calledUserIdTextField.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.leading.equalTo(userIdTextLable.snp.trailing).offset(20)
            make.trailing.equalToSuperview().offset(-20)
        }
        
        loginBtn.snp.makeConstraints { (make) in
            make.top.equalTo(userIdContentView.snp.bottom).offset(40)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.height.equalTo(52)
        }
        
        otherContentView.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-50)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.height.equalTo(80)
        }
        quickAccessLabel.snp.makeConstraints { make in
            make.centerX.top.equalToSuperview()
        }
        lineView.snp.makeConstraints { make in
            make.centerY.equalTo(quickAccessLabel.snp.centerY)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.height.equalTo(1)
        }
        accessLable.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.leading.equalToSuperview().offset(20)
        }
        apiLable.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.trailing.equalTo(self.snp.centerX).offset(-20)
        }
        buyLable.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.leading.equalTo(self.snp.centerX).offset(20)
        }
        problemLable.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.trailing.equalToSuperview().offset(-20)
        }
    }
    
    func bindInteraction() {
        loginBtn.addTarget(self, action: #selector(loginBtnClick), for: .touchUpInside)
    }
    
    @objc func loginBtnClick() {
        if let current = currentTextField {
            current.resignFirstResponder()
        }
        guard let phone = calledUserIdTextField.text else {
            return
        }
        rootVC?.login(userId: phone)
    }
    
    @objc func buyLableTapGestureClick() {
        if let url = URL(string: PURCHASE_URL){
            UIApplication.shared.open(url, options: [:], completionHandler: { success in })
        }
    }
    
    @objc func accessLableTapGestureClick() {
        if let url = URL(string: ACCESS_URL){
            UIApplication.shared.open(url, options: [:], completionHandler: { success in })
        }
    }
    
    @objc func apiLableTapGestureClick() {
        if let url = URL(string: API_URL){
            UIApplication.shared.open(url, options: [:], completionHandler: { success in })
        }
    }

    @objc func problemLableTapGestureClick() {
        if let url = URL(string: PROBLEM_URL){
            UIApplication.shared.open(url, options: [:], completionHandler: { success in })
        }
    }
}

extension LoginRootView: UITextFieldDelegate {
    public func textFieldDidBeginEditing(_ textField: UITextField) {
        if let last = currentTextField {
            last.resignFirstResponder()
        }
        currentTextField = textField
        textField.becomeFirstResponder()
    }
    public func textFieldDidEndEditing(_ textField: UITextField) {
        textField.resignFirstResponder()
        currentTextField = nil
    }
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return true
    }
}

/// MARK: - internationalization string
fileprivate extension String {
    static let titleText = TUICallKitAppLocalize("TUICallKitApp.Login.tencentcloud")
    static let phoneNumPlaceholderText = TUICallKitAppLocalize("TUICallKitApp.Login.enterphonenumber")
    static let verifyCodePlaceholderText = TUICallKitAppLocalize("TUICallKitApp.Login.enterverificationcode")
    static let getVerifyCodeText = TUICallKitAppLocalize("TUICallKitApp.Login.getverificationcode")
    static let loginText = TUICallKitAppLocalize("TUICallKitApp.login")
    static let tuicallkitIntroduceText = TUICallKitAppLocalize("TUICallKitApp.Login.Introduce")
    static let tuicallkitPlatformText = TUICallKitAppLocalize("TUICallKitApp.Login.Platform")
    static let buyText = TUICallKitAppLocalize("TUICallKitApp.Login.Purchase")
    static let accessText = TUICallKitAppLocalize("TUICallKitApp.Login.Access")
    static let apiText = TUICallKitAppLocalize("TUICallKitApp.Login.APIDocumentation")
    static let problemText = TUICallKitAppLocalize("TUICallKitApp.Login.Problem")
}
