//
//  SettingDetailViewController.swift
//  TUICallKitApp
//
//  Created by vincepzhang on 2023/6/6.
//
import Foundation
import UIKit
import TUICore
import TUICallEngine

#if USE_TUICALLKIT_SWIFT
import TUICallKit_Swift
#else
import TUICallKit
#endif

public class SettingDetailViewController: UIViewController, UITextViewDelegate {

    enum detailType{
        case userAv
        case ringInfo
        case entendInfo
        case offlinePushInfo
    }
    var detailtype: detailType
    
    init(detailtype: detailType) {
        self.detailtype = detailtype
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var textView: UITextView = {
        let view = UITextView(frame: .zero)
        view.backgroundColor = UIColor.clear
        view.font = UIFont(name: "PingFangSC-Regular", size: 16)
        view.textColor = UIColor(hex: "333333")
        view.textAlignment = .left
        view.isScrollEnabled = true
        view.delegate = self
        return view
    }()
    weak var currentTextField: UITextField?
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
        
        let backButton = UIButton(type: .system)
        backButton.setImage(UIImage(named: "calling_back"), for: .normal)
        backButton.addTarget(self, action: #selector(backButtonClick), for: .touchUpInside)
        let item = UIBarButtonItem(customView: backButton)
        item.tintColor = UIColor.black
        navigationItem.leftBarButtonItem = item
        
        let confirmButton = UIButton(type: .system)
        confirmButton.setTitle(TUICallKitAppLocalize("TUICallKitApp.Home.determine"), for: .normal)
        confirmButton.addTarget(self, action: #selector(confirmButtonClick), for: .touchUpInside)
        let rightitem = UIBarButtonItem(customView: confirmButton)
        rightitem.tintColor = UIColor.black
        navigationItem.rightBarButtonItem = rightitem

        navigationController?.navigationBar.isHidden = false
        
        constructViewHierarchy()
        activateConstraints()
        
        setTextView()
    }
        
    func constructViewHierarchy() {
        view.addSubview(textView)
    }
    
    func activateConstraints() {
        textView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(100)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    func setTextView() {
        switch detailtype {
        case .userAv:
            textView.text = TUICallKitAppLocalize("TUICallKitApp.Setting.SetAvatarTip")
        case .ringInfo:
            textView.text = TUICallKitAppLocalize("TUICallKitApp.Setting.SetRingTip")
        case .entendInfo:
            textView.text = TUICallKitAppLocalize("TUICallKitApp.Setting.SetExtendTip")
        case .offlinePushInfo:
            textView.text = TUICallKitAppLocalize("TUICallKitApp.Setting.SetOffInleInfoTip")
        }
    }
    
    @objc func backButtonClick() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func confirmButtonClick() {
        guard let textString = textView.text else { return }
        switch detailtype {
        case .userAv:
            userAvSetting(text: textString)
        case .ringInfo:
            ringSetting(text: textString)
        case .entendInfo:
            entendInfoSetting(text: textString)
        case .offlinePushInfo:
            offlinePushInfoSetting(text: textString)
        }
    }
    
    func userAvSetting(text: String) {
        if text.isEmpty {
            return
        }
        
        TUICallKit.createInstance().setSelfInfo(nickname: SettingsConfig.share.name, avatar: text) {
            SettingsConfig.share.avatar = text
            TUITool.makeToast("Set Successful: \(SettingsConfig.share.avatar)")
        } fail: { code, message in
            TUITool.makeToast("Error \(code):\(message ?? "")")
        }
    }
    
    func ringSetting(text: String) {
        if text.isEmpty {
            return
        }
        TUICallKit.createInstance().setCallingBell(filePath: text)
        SettingsConfig.share.ringUrl = text
        TUITool.makeToast("Set Successful: \(SettingsConfig.share.ringUrl)")
    }
    
    func entendInfoSetting(text: String) {
        if text.isEmpty {
            return
        }
        SettingsConfig.share.userData = text
        TUITool.makeToast("Set Successful: \(text)")
    }
    
    func offlinePushInfoSetting(text: String) {
        if text.isEmpty {
            return
        }
        setOfflineData(jsonStr: text)
        TUITool.makeToast("Set Successful: \(SettingsConfig.share.pushInfo)")
    }
    
    func setOfflineData(jsonStr: String) {
        guard let jsonData = jsonStr.data(using: String.Encoding.utf8) else { return }
        let json = try? JSONSerialization.jsonObject(with: jsonData)
        if let jsonDic = json as? [String : Any] {
            
            if let value = jsonDic["title"] as? String {
                SettingsConfig.share.pushInfo.title = value
            }
            
            if let value = jsonDic["desc"] as? String {
                SettingsConfig.share.pushInfo.desc = value
            }
            
            if let value = jsonDic["iOSPushType"] as? Int {
                SettingsConfig.share.pushInfo.iOSPushType = value == 0 ? .apns : .voIP
            }
            
            if let value = jsonDic["ignoreIOSBadge"] as? Bool {
                SettingsConfig.share.pushInfo.ignoreIOSBadge = value
            }
            
            if let value = jsonDic["iOSSound"] as? String {
                SettingsConfig.share.pushInfo.iOSSound = value
            }
            
            if let value = jsonDic["androidSound"] as? String {
                SettingsConfig.share.pushInfo.androidSound = value
            }
            
            if let value = jsonDic["androidOPPOChannelID"] as? String {
                SettingsConfig.share.pushInfo.androidOPPOChannelID = value
            }
            
            if let value = jsonDic["androidFCMChannelID"] as? String {
                SettingsConfig.share.pushInfo.androidFCMChannelID = value
            }
            
            if let value = jsonDic["title"] as? String {
                SettingsConfig.share.pushInfo.title = value
            }
            
            if let value = jsonDic["androidVIVOClassification"] as? Int {
                SettingsConfig.share.pushInfo.androidVIVOClassification = value
            }
            
            if let value = jsonDic["androidHuaWeiCategory"] as? String {
                SettingsConfig.share.pushInfo.androidHuaWeiCategory = value
            }
        }
    }

}
