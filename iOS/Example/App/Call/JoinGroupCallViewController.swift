//
//  JoinGroupCallViewController.swift
//  TUICallKitApp
//
//  Created by vincepzhang on 2023/5/9.
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

public class JoinGroupCallViewController: UIViewController, UITextFieldDelegate {
    var callType: TUICallMediaType = .audio
    var isIntRoom = true
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
    lazy var groupIdTextLable: UILabel = {
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
    
    lazy var roomIdContentView: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = UIColor.white
        return view
    }()
    let roomTypeData = [TUICallKitAppLocalize("TUICallKitApp.Call.RoomIdInt"), TUICallKitAppLocalize("TUICallKitApp.Call.RoomIdString")]
    var roomTypeIndex = 0
    lazy var roomIdBtn: SwiftDropMenuListView = {
        let menu = SwiftDropMenuListView(frame: CGRectZero)
        let titleStr: String = roomTypeData[roomTypeIndex] + " >"
        menu.setTitle(titleStr, for: .normal)
        menu.setTitleColor(.black, for: .normal)
        menu.titleLabel?.font = UIFont(name: "PingFangSC-Medium", size: 15)
        menu.delegate = self
        menu.dataSource = self
        menu.backgroundColor = UIColor.clear
        menu.translatesAutoresizingMaskIntoConstraints = false
        return menu
    }()
    lazy var roomIdTextField: UITextField = {
        let textField = UITextField(frame: .zero)
        textField.backgroundColor = UIColor.clear
        textField.font = UIFont(name: "PingFangSC-Regular", size: 16)
        textField.textColor = UIColor(hex: "333333")
        textField.attributedPlaceholder = NSAttributedString(string: TUICallKitAppLocalize("TUICallKitApp.Call.InputRoomId"))
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
    lazy var typeLable: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = UIColor.black
        label.text = TUICallKitAppLocalize("TUICallKitApp.MediaType")
        return label
    }()
    lazy var videoButton: RadioButton = {
        let button = RadioButton(frame: CGRectZero)
        button.titleText = TUICallKitAppLocalize("TUICallKitApp.Video.call")
        button.titleSize = 16
        return button
    }()
    lazy var vioceButton: RadioButton = {
        let button = RadioButton(frame: CGRectZero)
        button.titleText = TUICallKitAppLocalize("TUICallKitApp.Audio.call")
        button.isSelected = true
        button.titleSize = 16
        return button
    }()
    lazy var buttons: [RadioButton] = {
        let buttons = [videoButton, vioceButton]
        return buttons
    }()
    
    lazy var callBtn: UIButton = {
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
        backButton.setImage(UIImage(named: "calling_back"), for: .normal)
        backButton.addTarget(self, action: #selector(backButtonClick), for: .touchUpInside)
        let item = UIBarButtonItem(customView: backButton)
        item.tintColor = UIColor.black
        navigationItem.leftBarButtonItem = item

        navigationController?.navigationBar.isHidden = false
        
        constructViewHierarchy() // 视图层级布局
        activateConstraints() // 生成约束（此时有可能拿不到父视图正确的frame）
        bindInteraction()
    }
        
    func constructViewHierarchy() {
        view.addSubview(line1View)
        
        view.addSubview(groupIdContentView)
        groupIdContentView.addSubview(groupIdTextLable)
        groupIdContentView.addSubview(groupIdTextField)
        
        view.addSubview(roomIdContentView)
        roomIdContentView.addSubview(roomIdTextField)
        roomIdContentView.addSubview(roomIdBtn)
        
        view.addSubview(line2View)
        
        view.addSubview(mediaTypeContentView)
        mediaTypeContentView.addSubview(typeLable)
        mediaTypeContentView.addSubview(videoButton)
        mediaTypeContentView.addSubview(vioceButton)
                
        view.addSubview(callBtn)
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
        groupIdTextLable.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(40)
        }
        groupIdTextField.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalTo(groupIdTextLable.snp.trailing).offset(20)
            make.trailing.equalToSuperview().offset(-20)
        }

        roomIdContentView.snp.makeConstraints { make in
            make.top.equalTo(groupIdContentView.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(50)
        }
        roomIdBtn.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(40)
        }
        roomIdTextField.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalTo(roomIdBtn.snp.trailing).offset(20)
            make.trailing.equalToSuperview().offset(-20)
        }
        
        line2View.snp.makeConstraints { make in
            make.top.equalTo(roomIdContentView.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(10)
        }
        
        mediaTypeContentView.snp.makeConstraints { make in
            make.top.equalTo(line2View.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview()
            make.width.equalToSuperview()
            make.height.equalTo(30)
        }
        typeLable.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.equalToSuperview().offset(30)
        }
        videoButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalTo(typeLable.snp.trailing).offset(50)
        }
        vioceButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalTo(videoButton.snp.trailing).offset(100)
        }
        
        callBtn.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-60)
            make.height.equalTo(60)
            make.width.equalToSuperview().offset(-40)
        }
    }
    
    func bindInteraction() {
        videoButton.addTarget(self, action: #selector(radioButtonTapped), for: .touchUpInside)
        vioceButton.addTarget(self, action: #selector(radioButtonTapped), for: .touchUpInside)
        callBtn.addTarget(self, action: #selector(callButtonClick), for: .touchUpInside)
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
        guard let roomIdString = roomIdTextField.text else { return }
        guard let groupId = groupIdTextField.text else { return }
        
        if roomIdString.isEmpty || groupId.isEmpty {
            TUITool.makeToast("Please input roomId & groupId ")
            return
        }

        let roomId = TUIRoomId()
        if roomTypeIndex == 0 {
            roomId.intRoomId = UInt32(roomIdString) ?? 0
        } else {
            roomId.strRoomId = roomIdString
        }
                
        TUICallKit.createInstance().joinInGroupCall(roomId: roomId, groupId: groupId, callMediaType: callType)
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
}

extension JoinGroupCallViewController {
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

extension JoinGroupCallViewController: SwiftDropMenuListViewDataSource, SwiftDropMenuListViewDelegate {
    public func numberOfItems(in menu: SwiftDropMenuListView) -> Int {
        return roomTypeData.count
    }
    
    public func dropMenu(_ menu: SwiftDropMenuListView, titleForItemAt index: Int) -> String {
        return roomTypeData[index]
    }
    
    public func heightOfRow(in menu: SwiftDropMenuListView) -> CGFloat {
        return 30
    }
    
    public func numberOfColumns(in menu: SwiftDropMenuListView) -> Int {
        return 1
    }
    
    public func dropMenu(_ menu: SwiftDropMenuListView, didSelectItem: String?, atIndex index: Int) {
        roomTypeIndex = index
        if index == 0 {
            roomIdBtn.setTitle(TUICallKitAppLocalize("TUICallKitApp.Call.RoomIdInt") + " >", for: .normal)
        } else {
            roomIdBtn.setTitle(TUICallKitAppLocalize("TUICallKitApp.Call.RoomIdString") + " >", for: .normal)
        }
        
    }
}
