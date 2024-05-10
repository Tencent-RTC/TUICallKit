//
//  GroupCallViewController.swift
//  TUICallKitApp
//
//  Created by vincepzhang on 2023/5/9.
//

import Foundation
import UIKit
import TUICore
import TUICallEngine

#if canImport(TUICallKit_Swift)
import TUICallKit_Swift
#elseif canImport(TUICallKit)
import TUICallKit
#endif

public class GroupCallViewController: UIViewController, UITextFieldDelegate {
    var callType: TUICallMediaType = .audio
    
    lazy var line1View: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = UIColor(hex: "EEEEEE")
        return view
    }()
    lazy var groupIdContentView: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = UIColor.white
        return view
    }()
    lazy var groupIdTextLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = UIColor.black
        label.text = TUICallKitAppLocalize("TUICallKitApp.Call.GroupId")
        return label
    }()
    lazy var groupIdTextField: UITextField = {
        let textField = UITextField(frame: .zero)
        textField.backgroundColor = UIColor.clear
        textField.font = UIFont(name: "PingFangSC-Regular", size: 16)
        textField.textColor = UIColor(hex: "333333")
        textField.attributedPlaceholder = NSAttributedString(string: TUICallKitAppLocalize("TUICallKitApp.Call.InputGroupId"))
        textField.textAlignment = .right
        textField.delegate = self
        return textField
    }()
    lazy var userIdContentView: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = UIColor.white
        return view
    }()
    lazy var userIdTextLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = UIColor.black
        label.text = TUICallKitAppLocalize("TUICallKitApp.Call.UserId")
        return label
    }()
    lazy var calledUserIdTextField: UITextField = {
        let textField = UITextField(frame: .zero)
        textField.backgroundColor = UIColor.clear
        textField.font = UIFont(name: "PingFangSC-Regular", size: 16)
        textField.textColor = UIColor(hex: "333333")
        textField.attributedPlaceholder = NSAttributedString(string: TUICallKitAppLocalize("TUICallKitApp.Call.InputUserIds"))
        textField.textAlignment = .right
        textField.delegate = self
        return textField
    }()
    
    weak var currentTextField: UITextField?
    
    lazy var line2View: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = UIColor(hex: "EEEEEE")
        return view
    }()
    lazy var mediaTypeContentView: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = UIColor.white
        return view
    }()
    lazy var typeLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = UIColor.black
        label.text = TUICallKitAppLocalize("TUICallKitApp.MediaType")
        return label
    }()
    lazy var videoButton: RadioButton = {
        let button = RadioButton(frame: CGRect.zero)
        button.titleText = TUICallKitAppLocalize("TUICallKitApp.Video.call")
        button.titleSize = 16
        return button
    }()
    lazy var voiceButton: RadioButton = {
        let button = RadioButton(frame: CGRect.zero)
        button.titleText = TUICallKitAppLocalize("TUICallKitApp.Audio.call")
        button.isSelected = true
        button.titleSize = 16
        return button
    }()
    lazy var buttons: [RadioButton] = {
        let buttons = [videoButton, voiceButton]
        return buttons
    }()
    lazy var callSettingsLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = UIColor.blue
        label.text = "\(TUICallKitAppLocalize("TUICallKitApp.Setting.CallSettings"))  >"
        label.isUserInteractionEnabled = true
        return label
    }()
    
    lazy var joinInGroupLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = UIColor.blue
        label.text = TUICallKitAppLocalize("TUICallKitApp.JoinGroupCall")
        label.isUserInteractionEnabled = true
        return label
    }()
    lazy var callButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitleColor(.white, for: .normal)
        btn.setTitle(TUICallKitAppLocalize("TUICallKitApp.Call"), for: .normal)
        btn.adjustsImageWhenHighlighted = false
        btn.setBackgroundImage(UIColor(hex: "006EFF")?.trans2Image(), for: .normal)
        btn.titleLabel?.font = UIFont(name: "PingFangSC-Medium", size: 20)
        btn.layer.shadowColor = UIColor(hex: "006EFF")?.cgColor ?? UIColor.blue.cgColor
        btn.layer.shadowOffset = CGSize(width: 0, height: 6)
        btn.layer.shadowRadius = 16
        btn.layer.shadowOpacity = 0.4
        btn.layer.masksToBounds = true
        btn.layer.cornerRadius = 10
        return btn
    }()
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
        
        let backButton = UIButton(type: .system)
        backButton.setImage(UIImage(named: "callKit_back"), for: .normal)
        backButton.addTarget(self, action: #selector(backButtonClick), for: .touchUpInside)
        let item = UIBarButtonItem(customView: backButton)
        item.tintColor = UIColor.black
        navigationItem.leftBarButtonItem = item
        
        navigationController?.navigationBar.isHidden = false
        
        constructViewHierarchy()
        activateConstraints()
        bindInteraction()
    }
    
    func constructViewHierarchy() {
        view.addSubview(line1View)
        
        view.addSubview(groupIdContentView)
        groupIdContentView.addSubview(groupIdTextLabel)
        groupIdContentView.addSubview(groupIdTextField)
        
        view.addSubview(userIdContentView)
        userIdContentView.addSubview(calledUserIdTextField)
        userIdContentView.addSubview(userIdTextLabel)
        
        view.addSubview(line2View)
        
        view.addSubview(mediaTypeContentView)
        mediaTypeContentView.addSubview(typeLabel)
        mediaTypeContentView.addSubview(videoButton)
        mediaTypeContentView.addSubview(voiceButton)
        
        view.addSubview(callSettingsLabel)
        view.addSubview(joinInGroupLabel)
        view.addSubview(callButton)
    }
    
    func activateConstraints() {
        line1View.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(100)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(10)
        }
        groupIdContentView.snp.makeConstraints { make in
            make.top.equalTo(line1View.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(50)
        }
        groupIdTextLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(20)
        }
        groupIdTextField.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalTo(groupIdTextLabel.snp.trailing).offset(20)
            make.trailing.equalToSuperview().offset(-20)
        }
        userIdContentView.snp.makeConstraints { make in
            make.top.equalTo(groupIdContentView.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(50)
        }
        userIdTextLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(20)
            make.width.equalTo(80)
        }
        calledUserIdTextField.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalTo(userIdTextLabel.snp.trailing).offset(20)
            make.trailing.equalToSuperview().offset(-20)
        }
        line2View.snp.makeConstraints { make in
            make.top.equalTo(userIdContentView.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(10)
        }
        mediaTypeContentView.snp.makeConstraints { make in
            make.top.equalTo(line2View.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview()
            make.width.equalToSuperview()
            make.height.equalTo(30)
        }
        typeLabel.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview().offset(20)
        }
        videoButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalTo(typeLabel.snp.trailing).offset(40)
        }
        voiceButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalTo(videoButton.snp.trailing).offset(80)
        }
        callSettingsLabel.snp.makeConstraints { make in
            make.top.equalTo(mediaTypeContentView.snp.bottom).offset(50)
            make.centerX.equalToSuperview()
        }
        joinInGroupLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(callButton.snp.top).offset(-40)
        }
        callButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-60)
            make.height.equalTo(60)
            make.width.equalToSuperview().offset(-40)
        }
    }
    
    func bindInteraction() {
        videoButton.addTarget(self, action: #selector(radioButtonTapped), for: .touchUpInside)
        voiceButton.addTarget(self, action: #selector(radioButtonTapped), for: .touchUpInside)
        
        let callSettingsLabelTapGesture = UITapGestureRecognizer(target: self, action: #selector(settingButtonClick))
        callSettingsLabel.addGestureRecognizer(callSettingsLabelTapGesture)
        
        let joinInGroupLabelTapGesture = UITapGestureRecognizer(target: self, action: #selector(joinInGroupClick))
        joinInGroupLabel.addGestureRecognizer(joinInGroupLabelTapGesture)
        
        callButton.addTarget(self, action: #selector(callButtonClick), for: .touchUpInside)
    }
    
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        super.touchesBegan(touches, with: event)
        
        if let current = currentTextField {
            current.resignFirstResponder()
            currentTextField = nil
        }
    }
    
    @objc func radioButtonTapped(_ sender: RadioButton) {
        buttons.forEach({ $0.isSelected = false})
        sender.isSelected = true
        if sender == videoButton {
            callType = .video
        } else {
            callType = .audio
        }
    }
    
    @objc func callButtonClick() {
        guard let userIdArray = calledUserIdTextField.text else { return }
        guard let groupId = groupIdTextField.text else { return }
        
        if userIdArray.isEmpty || groupId.isEmpty {
            TUITool.makeToast("Please input userId & groupId ")
            return
        }
        let userIds = userIdArray.components(separatedBy: ",")
        
        let params = TUICallParams()
        params.timeout = Int32(SettingsConfig.share.timeout)
        params.userData = SettingsConfig.share.userData
        params.offlinePushInfo = SettingsConfig.share.pushInfo
        
        let roomId = TUIRoomId()
        roomId.intRoomId = SettingsConfig.share.intRoomId
        roomId.strRoomId = SettingsConfig.share.strRoomId
        params.roomId = roomId
        
        TUICallKit.createInstance().groupCall(groupId: groupId, userIdList: userIds, callMediaType: callType, params: params){
            
        } fail: { code, message in
            TUITool.makeToast("Error \(code):\(message ?? "")")
        }
    }
    
    @objc func backButtonClick() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func settingButtonClick() {
        let settingVC = SettingsViewController()
        settingVC.title = TUICallKitAppLocalize("TUICallKitApp.Setting.CallSettings")
        settingVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(settingVC, animated: true)
    }
    
    @objc func joinInGroupClick() {
        let joinInGroupVC = JoinGroupCallViewController()
        joinInGroupVC.title = TUICallKitAppLocalize("TUICallKitApp.JoinGroupCall")
        joinInGroupVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(joinInGroupVC, animated: true)
    }
}

extension GroupCallViewController {
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
}

