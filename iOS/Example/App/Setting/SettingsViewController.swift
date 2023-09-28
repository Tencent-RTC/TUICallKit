//
//  SettingsViewController.swift
//  TUICallKitApp
//
//  Created by vincepzhang on 2023/5/9.
//

import Foundation
import TUICore
import UIKit
import TUICallEngine

#if USE_TUICALLKIT_SWIFT
import TUICallKit_Swift
#else
import TUICallKit
#endif

class SettingsViewController: UIViewController, UITextFieldDelegate {
    var intRoomId: UInt32 = 0
    var strRoomId: String = ""
    var timeout: Int = 30
    var userData: String = ""
    var offlineData: String = ""
    
    var beaurtLevel: Int = 6
    
    weak var currentTextField: UITextField?
    
    lazy var scroView: UIScrollView = {
        return UIScrollView()
    }()
    
    lazy var scroContentView: UIView = {
        return UIView(frame: CGRect.zero)
    }()

    lazy var basicSettingContentView: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = UIColor(hex: "EEEEEE")
        return view
    }()
    lazy var basicSettingLabel: UILabel = {
        return createLabel(textSize: 16, text: TUICallKitAppLocalize("TUICallKitApp.Setting.BasicSetting"))
    }()
    
    lazy var userAvContentView: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = .white
        return view
    }()
    lazy var userAvLabel: UILabel = {
        return createLabel(textSize: 16, text: TUICallKitAppLocalize("TUICallKitApp.UserInfo.Avatar"))
    }()
    lazy var userAvInfoLabel: UILabel = {
        let place: String = SettingsConfig.share.avatar.isEmpty ? TUICallKitAppLocalize("TUICallKitApp.Setting.NotSet") : SettingsConfig.share.avatar
        let view = createLabel(textSize: 16, text: place)
        view.textColor = UIColor(hex: "EEEEEE")
        view.textAlignment = .right
        return view
    }()
    lazy var userAvBtn: UILabel = {
        let view = createLabel(textSize: 16, text: " > ")
        view.isUserInteractionEnabled = true
        return view
    }()
    
    lazy var userNameContentView: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = .white
        return view
    }()
    lazy var userNameLabel: UILabel = {
        return createLabel(textSize: 16, text: TUICallKitAppLocalize("TUICallKitApp.UserInfo.NickName"))
    }()
    lazy var userNameTextField: UITextField = {
        let place: String = SettingsConfig.share.name.isEmpty ? TUICallKitAppLocalize("TUICallKitApp.Setting.NotSet") : SettingsConfig.share.name
        return createTextField(text: place)
    }()

    lazy var ringContentView: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = .white
        return view
    }()
    lazy var ringLabel: UILabel = {
        return createLabel(textSize: 16, text: TUICallKitAppLocalize("TUICallKitApp.Setting.RingSetting"))
    }()
    lazy var ringInfoLabel: UILabel = {
        let place: String = SettingsConfig.share.ringUrl.isEmpty ?
            TUICallKitAppLocalize("TUICallKitApp.Setting.NotSet") : SettingsConfig.share.ringUrl
        let view = createLabel(textSize: 16, text: place)
        view.textColor = UIColor(hex: "EEEEEE")
        view.textAlignment = .right
        return view
    }()
    lazy var ringAvBtn: UILabel = {
        let view = createLabel(textSize: 16, text: " > ")
        view.isUserInteractionEnabled = true
        return view
    }()
    
    lazy var muteContentView: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = .white
        return view
    }()
    lazy var muteLabel: UILabel = {
        return createLabel(textSize: 16, text: TUICallKitAppLocalize("TUICallKitApp.Setting.MuteMode"))
    }()
    lazy var muteSwitch: UISwitch = {
        return createSwich(isOn: SettingsConfig.share.mute)
    }()
    
    lazy var floatingContentView: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = .white
        return view
    }()
    lazy var floatingLabel: UILabel = {
        return createLabel(textSize: 16, text: TUICallKitAppLocalize("TUICallKitApp.Setting.EnableFloating"))
    }()
    lazy var floatingSwitch: UISwitch = {
        return createSwich(isOn: SettingsConfig.share.floatWindow)
    }()
    
    lazy var callSettingContentView: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = UIColor(hex: "EEEEEE")
        return view
    }()
    lazy var callSettingLabel: UILabel = {
        return createLabel(textSize: 16, text: TUICallKitAppLocalize("TUICallKitApp.Setting.CallParamsSetting"))
    }()
    
    lazy var timeoutContentView: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = .white
        return view
    }()
    lazy var timeoutLabel: UILabel = {
        return createLabel(textSize: 16, text: TUICallKitAppLocalize("TUICallKitApp.Setting.Timeout"))
    }()
    lazy var timeoutTextField: UITextField = {
        return createTextField(text: "30")
    }()
        
    lazy var extendedInfoContentView: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = .white
        return view
    }()
    lazy var extendedInfoLabel: UILabel = {
        return createLabel(textSize: 16, text: TUICallKitAppLocalize("TUICallKitApp.Setting.ExpendedInfo"))
    }()
    lazy var extendedInfo: UILabel = {
        let place = SettingsConfig.share.userData.isEmpty ? TUICallKitAppLocalize("TUICallKitApp.Setting.NotSet") : SettingsConfig.share.userData
        let view = createLabel(textSize: 16, text: place)
        view.textColor = UIColor(hex: "EEEEEE")
        view.textAlignment = .right
        return view
    }()
    lazy var extendedBtn: UILabel = {
        let view = createLabel(textSize: 16, text: " > ")
        view.isUserInteractionEnabled = true
        return view
    }()
    
    lazy var offlinePushContentView: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = .white
        return view
    }()
    lazy var offlinePushLabel: UILabel = {
        return createLabel(textSize: 16, text: TUICallKitAppLocalize("TUICallKitApp.Setting.OfflinePushInfo"))
    }()
    lazy var offlinePushInfo: UILabel = {
        let view = createLabel(textSize: 16, text: TUICallKitAppLocalize("TUICallKitApp.Setting.GoToSettings"))
        view.textColor = UIColor(hex: "EEEEEE")
        view.textAlignment = .right
        return view
    }()
    lazy var offlinePushBtn: UILabel = {
        let view = createLabel(textSize: 16, text: " > ")
        view.isUserInteractionEnabled = true
        return view
    }()

    lazy var videoSettingContentView: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = UIColor(hex: "EEEEEE")
        return view
    }()
    lazy var videoSettingLabel: UILabel = {
        return createLabel(textSize: 16, text: TUICallKitAppLocalize("TUICallKitApp.Setting.VideoSetting"))
    }()
    
    lazy var resolutionContentView: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = .white
        return view
    }()
    lazy var resolutionLabel: UILabel = {
        return createLabel(textSize: 16, text: TUICallKitAppLocalize("TUICallKitApp.Setting.Resolution"))
    }()
    let resolutionData = ["640*480","960*720","640*360","960*540","1280*720","1920*1080"]
    lazy var resolutionDropMenu: SwiftDropMenuListView = {
        let menu = SwiftDropMenuListView(frame: CGRect.zero)
        let titleStr: String = resolutionData[convertResolutionToIndex(resolution: SettingsConfig.share.resolution)] + " >"
        menu.setTitle(titleStr, for: .normal)
        menu.setTitleColor(.black, for: .normal)
        menu.titleLabel?.font = UIFont(name: "PingFangSC-Medium", size: 16)
        menu.delegate = self
        menu.dataSource = self
        menu.backgroundColor = UIColor.clear
        menu.translatesAutoresizingMaskIntoConstraints = true
        return menu
    }()
    
    lazy var resolutionModeContentView: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = .white
        return view
    }()
    lazy var resolutionModeLabel: UILabel = {
        return createLabel(textSize: 16, text: TUICallKitAppLocalize("TUICallKitApp.Setting.ResolutionMode"))
    }()
    lazy var resolutionModeSegmoent: UISegmentedControl = {
        let index = SettingsConfig.share.resolutionMode == .landscape ? 0 : 1
        return createSegment(item: [TUICallKitAppLocalize("TUICallKitApp.Setting.ResolutionMode.Horizontal"),
                                    TUICallKitAppLocalize("TUICallKitApp.Setting.ResolutionMode.Vertical"),], select: index)
    }()
    
    lazy var fillModeContentView: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = .white
        return view
    }()
    lazy var fillModeLabel: UILabel = {
        return createLabel(textSize: 16, text: TUICallKitAppLocalize("TUICallKitApp.Setting.FillMode"))
    }()
    lazy var fillModeSegmoent: UISegmentedControl = {
        let index = SettingsConfig.share.fillMode == .fit ? 0 : 1
        return createSegment(item: [TUICallKitAppLocalize("TUICallKitApp.Setting.FillMode.Fit"),
                                    TUICallKitAppLocalize("TUICallKitApp.Setting.FillMode.Fill"),], select: index)
    }()
    
    lazy var rotationContentView: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = .white
        return view
    }()
    lazy var rotationLabel: UILabel = {
        return createLabel(textSize: 16, text: TUICallKitAppLocalize("TUICallKitApp.Setting.Rotation"))
    }()
    lazy var rotationSegmoent: UISegmentedControl = {
        return createSegment(item: ["0", "90", "180", "270"], select: convertRotationToIndex(rotation: SettingsConfig.share.rotation))
    }()
    
    lazy var beautyLevelContentView: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = .white
        return view
    }()
    lazy var beautyLevelLabel: UILabel = {
        return createLabel(textSize: 16, text: TUICallKitAppLocalize("TUICallKitApp.Setting.BeautyLevel"))
    }()
    lazy var beautyLevelTextField: UITextField = {
        let textField = createTextField(text: "\(SettingsConfig.share.beaurtLevel)")
        return textField
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        
        let backButton = UIButton(type: .system)
        backButton.setImage(UIImage(named: "calling_back"), for: .normal)
        backButton.addTarget(self, action: #selector(backButtonClick), for: .touchUpInside)
        let item = UIBarButtonItem(customView: backButton)
        item.tintColor = UIColor.black
        navigationItem.leftBarButtonItem = item

        constructViewHierarchy() // 视图层级布局
        activateConstraints() // 生成约束（此时有可能拿不到父视图正确的frame）
        bindInteraction()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        if let current = currentTextField {
            current.resignFirstResponder()
            currentTextField = nil
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        updateView()
    }
    
    func updateView() {
        ringInfoLabel.text = SettingsConfig.share.ringUrl.isEmpty ?
            TUICallKitAppLocalize("TUICallKitApp.Setting.NotSet") : SettingsConfig.share.ringUrl
        userAvInfoLabel.text = SettingsConfig.share.avatar.isEmpty ?
            TUICallKitAppLocalize("TUICallKitApp.Setting.NotSet") : SettingsConfig.share.avatar
        extendedInfo.text = SettingsConfig.share.userData.isEmpty ?
            TUICallKitAppLocalize("TUICallKitApp.Setting.NotSet") : SettingsConfig.share.userData
    }

    func constructViewHierarchy() {
        view.addSubview(scroView)
        scroView.addSubview(scroContentView)
        
        scroContentView.addSubview(basicSettingContentView)
        basicSettingContentView.addSubview(basicSettingLabel)
        
        scroContentView.addSubview(userAvContentView)
        userAvContentView.addSubview(userAvLabel)
        userAvContentView.addSubview(userAvInfoLabel)
        userAvContentView.addSubview(userAvBtn)
        
        scroContentView.addSubview(userNameContentView)
        userNameContentView.addSubview(userNameLabel)
        userNameContentView.addSubview(userNameTextField)
                
        scroContentView.addSubview(ringContentView)
        ringContentView.addSubview(ringLabel)
        ringContentView.addSubview(ringInfoLabel)
        ringContentView.addSubview(ringAvBtn)
        
        scroContentView.addSubview(muteContentView)
        muteContentView.addSubview(muteLabel)
        muteContentView.addSubview(muteSwitch)
        
        scroContentView.addSubview(floatingContentView)
        floatingContentView.addSubview(floatingLabel)
        floatingContentView.addSubview(floatingSwitch)
        
        scroContentView.addSubview(callSettingContentView)
        callSettingContentView.addSubview(callSettingLabel)
        
        scroContentView.addSubview(timeoutContentView)
        timeoutContentView.addSubview(timeoutLabel)
        timeoutContentView.addSubview(timeoutTextField)
                
        scroContentView.addSubview(extendedInfoContentView)
        extendedInfoContentView.addSubview(extendedInfoLabel)
        extendedInfoContentView.addSubview(extendedInfo)
        extendedInfoContentView.addSubview(extendedBtn)
        
        scroContentView.addSubview(offlinePushContentView)
        offlinePushContentView.addSubview(offlinePushLabel)
        offlinePushContentView.addSubview(offlinePushInfo)
        offlinePushContentView.addSubview(offlinePushBtn)
        
        scroContentView.addSubview(videoSettingContentView)
        videoSettingContentView.addSubview(videoSettingLabel)
        
        scroContentView.addSubview(resolutionContentView)
        resolutionContentView.addSubview(resolutionLabel)
        resolutionContentView.addSubview(resolutionDropMenu)
        
        scroContentView.addSubview(resolutionModeContentView)
        resolutionModeContentView.addSubview(resolutionModeLabel)
        resolutionModeContentView.addSubview(resolutionModeSegmoent)
        
        scroContentView.addSubview(fillModeContentView)
        fillModeContentView.addSubview(fillModeLabel)
        fillModeContentView.addSubview(fillModeSegmoent)
        
        scroContentView.addSubview(rotationContentView)
        rotationContentView.addSubview(rotationLabel)
        rotationContentView.addSubview(rotationSegmoent)
        
        scroContentView.addSubview(beautyLevelContentView)
        beautyLevelContentView.addSubview(beautyLevelLabel)
        beautyLevelContentView.addSubview(beautyLevelTextField)
    }
    
    func activateConstraints() {
        scroView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.top.equalToSuperview().offset(100)
        }
        
        scroContentView.snp.makeConstraints { make in
            make.top.bottom.equalTo(scroView)
            make.left.right.equalTo(view)
        }
        
        basicSettingContentView.snp.makeConstraints { make in
            make.leading.trailing.top.equalToSuperview()
            make.height.equalTo(30)
        }
        basicSettingLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(20)
        }
        
        userAvContentView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(basicSettingLabel.snp.bottom).offset(20)
            make.height.equalTo(20)
        }
        userAvLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(20)
            make.width.equalTo(100)
        }
        userAvBtn.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().offset(-20)
            make.width.equalTo(30)
        }
        userAvInfoLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalTo(userAvBtn.snp.leading)
            make.leading.equalTo(userAvLabel.snp.trailing).offset(20)
        }
        
        userNameContentView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.top.equalTo(userAvContentView.snp.bottom).offset(20)
            make.height.equalTo(20)
        }
        userNameLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(20)
        }
        userNameTextField.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().offset(-50)
            make.leading.equalTo(userNameLabel.snp.trailing).offset(20)
        }

        ringContentView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.top.equalTo(userNameContentView.snp.bottom).offset(20)
            make.height.equalTo(20)
        }
        ringLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(20)
        }
        ringAvBtn.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().offset(-20)
            make.width.equalTo(30)
        }
        ringInfoLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalTo(ringAvBtn.snp.leading)
            make.leading.equalTo(ringLabel.snp.trailing).offset(20)
        }
        
        muteContentView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.top.equalTo(ringContentView.snp.bottom).offset(20)
            make.height.equalTo(20)
        }
        muteLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(20)
        }
        muteSwitch.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().offset(-20)
        }
        
        floatingContentView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.top.equalTo(muteContentView.snp.bottom).offset(20)
            make.height.equalTo(20)
        }
        floatingLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(20)
        }
        floatingSwitch.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().offset(-20)
        }
        
        callSettingContentView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(floatingContentView.snp.bottom).offset(20)
            make.height.equalTo(30)
        }
        callSettingLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(20)
        }
                
        timeoutContentView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(callSettingContentView.snp.bottom).offset(20)
            make.height.equalTo(20)
        }
        timeoutLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(20)
        }
        timeoutTextField.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().offset(-50)
            make.leading.equalTo(timeoutLabel.snp.trailing).offset(20)
        }
        
        extendedInfoContentView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(timeoutContentView.snp.bottom).offset(20)
            make.height.equalTo(20)
        }
        extendedInfoLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(20)
        }
        extendedBtn.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().offset(-20)
            make.width.equalTo(30)
        }
        extendedInfo.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalTo(extendedInfoLabel.snp.trailing).offset(20)
            make.trailing.equalTo(extendedBtn.snp.leading)
        }
        
        offlinePushContentView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(extendedInfoContentView.snp.bottom).offset(20)
            make.height.equalTo(20)
        }
        offlinePushLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(20)
        }
        offlinePushBtn.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().offset(-20)
            make.width.equalTo(30)
        }
        offlinePushInfo.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalTo(offlinePushLabel.snp.trailing).offset(20)
            make.trailing.equalTo(offlinePushBtn.snp.leading)
        }
        
        videoSettingContentView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(offlinePushContentView.snp.bottom).offset(20)
            make.height.equalTo(30)
        }
        videoSettingLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(20)
        }
        
        resolutionContentView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(videoSettingLabel.snp.bottom).offset(20)
            make.height.equalTo(20)
        }
        resolutionLabel.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview().offset(20)
            make.width.equalTo(120)
        }
        resolutionDropMenu.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().offset(-30)
        }
        
        resolutionModeContentView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(resolutionContentView.snp.bottom).offset(20)
            make.height.equalTo(20)
        }
        resolutionModeLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(20)
            make.width.equalTo(120)
        }
        resolutionModeSegmoent.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview()
            make.leading.equalTo(resolutionModeLabel.snp.trailing).offset(20)
        }
        
        fillModeContentView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(resolutionModeContentView.snp.bottom).offset(20)
            make.height.equalTo(20)
        }
        fillModeLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(20)
            make.width.equalTo(120)
        }
        fillModeSegmoent.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview()
            make.leading.equalTo(fillModeLabel.snp.trailing).offset(20)
        }
        
        rotationContentView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(fillModeContentView.snp.bottom).offset(20)
            make.height.equalTo(20)
        }
        rotationLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(20)
            make.width.equalTo(120)
        }
        rotationSegmoent.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview()
            make.leading.equalTo(rotationLabel.snp.trailing).offset(20)
        }
        
        beautyLevelContentView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.top.equalTo(rotationContentView.snp.bottom).offset(20)
            make.bottom.equalToSuperview().offset(-20)
            make.height.equalTo(20)
        }
        beautyLevelLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(20)
            make.width.equalTo(120)
        }
        beautyLevelTextField.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalTo(beautyLevelLabel.snp.leading).offset(30)
            make.trailing.equalToSuperview().offset(-50)
        }
    }
    
    func bindInteraction() {
        let userAvBtnTapGesture = UITapGestureRecognizer(target: self, action: #selector(userAvBtnClick))
        userAvBtn.addGestureRecognizer(userAvBtnTapGesture)
       
        let ringAvBtnTapGesture = UITapGestureRecognizer(target: self, action: #selector(ringAvBtnClick))
        ringAvBtn.addGestureRecognizer(ringAvBtnTapGesture)

        let offlinePushBtnTapGesture = UITapGestureRecognizer(target: self, action: #selector(offlinepushClick))
        offlinePushBtn.addGestureRecognizer(offlinePushBtnTapGesture)

        let extendedBtnTapGesture = UITapGestureRecognizer(target: self, action: #selector(extendClick))
        extendedBtn.addGestureRecognizer(extendedBtnTapGesture)
        
        muteSwitch.addTarget(self, action:  #selector(muteSwitchClick), for: .valueChanged)
        floatingSwitch.addTarget(self, action: #selector(floatingSwitchClick), for: .valueChanged)
        resolutionModeSegmoent.addTarget(self, action: #selector(resolutionModeSegmoentClick), for: .valueChanged)
        fillModeSegmoent.addTarget(self, action: #selector(fillModeSegmoentClick), for: .valueChanged)
        rotationSegmoent.addTarget(self, action: #selector(rotationSegmoentClick), for: .valueChanged)
    }
    
    @objc func userAvBtnClick() {
        let offlinepushVC = SettingDetailViewController(detailtype: .userAv)
        offlinepushVC.title = TUICallKitAppLocalize("TUICallKitApp.Setting.SetAvatar")
        offlinepushVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(offlinepushVC, animated: true)
    }

    @objc func ringAvBtnClick() {
        let offlinepushVC = SettingDetailViewController(detailtype: .ringInfo)
        offlinepushVC.title = TUICallKitAppLocalize("TUICallKitApp.Setting.SetRing")
        offlinepushVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(offlinepushVC, animated: true)
    }

    @objc func offlinepushClick() {
        let offlinepushVC = SettingDetailViewController(detailtype: .offlinePushInfo)
        offlinepushVC.title = TUICallKitAppLocalize("TUICallKitApp.Setting.SetOffInleInfo")
        offlinepushVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(offlinepushVC, animated: true)
    }
    
    @objc func extendClick() {
        let extendVC = SettingDetailViewController(detailtype: .entendInfo)
        extendVC.title = TUICallKitAppLocalize("TUICallKitApp.Setting.SetExtend")
        extendVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(extendVC, animated: true)
    }
        
    @objc func muteSwitchClick(_ sender: UISwitch) {
        SettingsConfig.share.mute = sender.isOn
        TUICallKit.createInstance().enableMuteMode(enable: sender.isOn)
    }
    
    @objc func floatingSwitchClick(_ sender: UISwitch) {
        SettingsConfig.share.floatWindow = sender.isOn
        TUICallKit.createInstance().enableFloatWindow(enable: sender.isOn)
    }
            
    @objc func resolutionModeSegmoentClick(_ sender: UISegmentedControl) {
        SettingsConfig.share.resolutionMode = sender.selectedSegmentIndex == 0 ? .landscape : .portrait
        let params = TUIVideoEncoderParams()
        params.resolution = SettingsConfig.share.resolution
        params.resolutionMode = sender.selectedSegmentIndex == 0 ? .landscape : .portrait
        TUICallEngine.createInstance().setVideoEncoderParams(params) {
        } fail: { code, message in
        }
    }
    
    @objc func fillModeSegmoentClick(_ sender: UISegmentedControl) {
        SettingsConfig.share.fillMode = sender.selectedSegmentIndex == 0 ? .fit : .fill
        
        let param = TUIVideoRenderParams()
        param.fillMode = SettingsConfig.share.fillMode
        param.rotation = SettingsConfig.share.rotation
        TUICallEngine.createInstance().setVideoRenderParams(userId: SettingsConfig.share.userId, params: param) {
        } fail: { code, message in
        }
    }
    
    @objc func rotationSegmoentClick(_ sender: UISegmentedControl) {
        SettingsConfig.share.rotation = convertIndexToRotation(index: sender.selectedSegmentIndex)
        let param = TUIVideoRenderParams()
        param.fillMode = SettingsConfig.share.fillMode
        param.rotation = SettingsConfig.share.rotation
        TUICallEngine.createInstance().setVideoRenderParams(userId: SettingsConfig.share.userId, params: param) {
        } fail: { code, message in
        }
    }
        
    @objc func backButtonClick() {
        navigationController?.popViewController(animated: true)
    }
    
    func userNameSetting(text: String) {
        if text.isEmpty {
            return
        }

        TUICallKit.createInstance().setSelfInfo(nickname: text, avatar: SettingsConfig.share.avatar) { [weak self] in
            guard let self = self else { return }
            SettingsConfig.share.name = text
            
            let place: String = SettingsConfig.share.name.isEmpty ? TUICallKitAppLocalize("TUICallKitApp.Setting.NotSet") : SettingsConfig.share.name
            self.userNameTextField.attributedPlaceholder = NSAttributedString(string: place)
        } fail: { code, message in
            TUITool.makeToast("Error \(code):\(message ?? "")")
        }
    }
        
    func timeoutButtonClick(text: String) {
        if text.isEmpty {
            return
        }
        SettingsConfig.share.timeout = Int(text) ?? 30
        
        self.timeoutTextField.attributedPlaceholder = NSAttributedString(string: String(SettingsConfig.share.timeout))
    }
    
    func beautyLevelSetBtnClick(text: String) {
        if text.isEmpty {
            return
        }
        
        TUICallEngine.createInstance().setBeautyLevel(CGFloat(Int(text) ?? 0)) { [weak self] in
            guard let self = self else { return }
            SettingsConfig.share.beaurtLevel = Int(text) ?? SettingsConfig.share.beaurtLevel
            
            self.beautyLevelTextField.attributedPlaceholder = NSAttributedString(string: String(SettingsConfig.share.beaurtLevel))
        } fail: { code, message in
            TUITool.makeToast("Error \(code):\(message ?? "")")
        }
    }
}

extension SettingsViewController {
    func createTextField(text: String) -> UITextField {
        let textField = UITextField(frame: .zero)
        textField.backgroundColor = UIColor.clear
        textField.font = UIFont(name: "PingFangSC-Regular", size: 16)
        textField.textColor = UIColor(hex: "333333")
        textField.attributedPlaceholder = NSAttributedString(string: text)
        textField.textAlignment = .right
        textField.delegate = self
        return textField
    }
    
    func createSettingButton() -> UIButton {
        let btn = UIButton(type: .system)
        btn.setTitleColor(.white, for: .normal)
        btn.setTitle(TUICallKitAppLocalize("TUICallKitApp.Setting"), for: .normal)
        btn.adjustsImageWhenHighlighted = false
        btn.setBackgroundImage(UIColor(hex: "006EFF")?.trans2Image(), for: .normal)
        btn.titleLabel?.font = UIFont(name: "PingFangSC-Medium", size: 15)
        btn.layer.shadowColor = UIColor(hex: "006EFF")?.cgColor ?? UIColor.blue.cgColor
        btn.layer.shadowOffset = CGSize(width: 0, height: 6)
        btn.layer.shadowRadius = 16
        btn.layer.shadowOpacity = 0.4
        btn.layer.masksToBounds = true
        btn.layer.cornerRadius = 5
        return btn
    }
    
    func createLabel(textSize: CGFloat, text: String) -> UILabel {
        let label = UILabel(frame: .zero)
        label.font = UIFont.systemFont(ofSize: textSize)
        label.textColor = .black
        label.text = text
        return label
    }
    
    func createSwich(isOn: Bool) -> UISwitch {
        let switchBtn = UISwitch(frame: CGRect.zero)
        switchBtn.isOn = isOn
        return switchBtn
    }
    
    func createSegment(item: [Any], select: Int) -> UISegmentedControl {
        let segment = UISegmentedControl(items: item)
        segment.selectedSegmentIndex = select
        segment.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.gray], for: UIControl.State.normal)
        segment.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.black], for: UIControl.State.selected)
        return segment
    }
    
    func convertResolutionToIndex(resolution: TUIVideoEncoderParamsResolution) -> Int {
        switch resolution {
        case ._640_480:
            return 0
        case ._960_720:
            return 1
        case ._640_360:
            return 2
        case ._960_540:
            return 3
        case ._1280_720:
            return 4
        case ._1920_1080:
            return 5
        default:
            return 2
        }
    }
    
    func convertIndexToResolution(index: Int) -> TUIVideoEncoderParamsResolution {
        switch index {
        case 0:
            return ._640_480
        case 1:
            return ._960_720
        case 2:
            return ._640_360
        case 3:
            return ._960_540
        case 4:
            return ._1280_720
        case 5:
            return ._1920_1080
        default:
            return ._640_360
        }
    }
    
    func convertRotationToIndex(rotation: TUIVideoRenderParamsRotation) -> Int {
        switch rotation {
        case ._0:
            return 0
        case ._90:
            return 1
        case ._180:
            return 2
        case ._270:
            return 3
        default:
            return 0
        }
    }
    
    func convertIndexToRotation(index: Int) -> TUIVideoRenderParamsRotation {
        switch index {
        case 0:
            return ._0
        case 1:
            return ._90
        case 2:
            return ._180
        case 3:
            return ._270
        default:
            return ._0
        }
    }
}

extension SettingsViewController {
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
        
        guard let text = textField.text else { return }
        if textField == userNameTextField {
            userNameSetting(text: text)
        } else if textField == timeoutTextField {
            timeoutButtonClick(text: text)
        }  else if  textField == beautyLevelTextField {
            beautyLevelSetBtnClick(text: text)
        }
    }
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension SettingsViewController: SwiftDropMenuListViewDataSource, SwiftDropMenuListViewDelegate {
    func numberOfItems(in menu: SwiftDropMenuListView) -> Int {
        return resolutionData.count
    }
    
    func dropMenu(_ menu: SwiftDropMenuListView, titleForItemAt index: Int) -> String {
        return resolutionData[index]
    }
    
    func heightOfRow(in menu: SwiftDropMenuListView) -> CGFloat {
        return 16
    }
    
    func numberOfColumns(in menu: SwiftDropMenuListView) -> Int {
        return 2
    }
    
    func dropMenu(_ menu: SwiftDropMenuListView, didSelectItem: String?, atIndex index: Int) {
        
        let params = TUIVideoEncoderParams()
        params.resolution = convertIndexToResolution(index: index)
        params.resolutionMode = SettingsConfig.share.resolutionMode
        TUICallEngine.createInstance().setVideoEncoderParams(params) {
            SettingsConfig.share.resolution = self.convertIndexToResolution(index: index)
            if let titleStr: String = didSelectItem {
                self.resolutionDropMenu.setTitle(titleStr + " >", for: .normal)
            }
        } fail: { code, message in
            
        }
    }
}
