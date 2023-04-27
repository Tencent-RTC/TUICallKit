//
//  SelectUserTableViewCell.swift
//  TUICallKitApp
//
//  Created by adams on 2021/5/20.
//  Copyright © 2021 Tencent. All rights reserved.
//

import UIKit
import TUICallKit
import ImSDK_Plus
public enum SelectUserButtonType {
    case call
    case add
    case delete
}

public class SelectUserTableViewCell: UITableViewCell {
    private var isViewReady = false
    private var buttonAction: (() -> Void)?
    lazy var userImageView: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()
    
    lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.black
        label.backgroundColor = UIColor.clear
        return label
    }()
    
    let rightButton: UIButton = {
        let button = UIButton(type: .custom)
        button.backgroundColor = UIColor("006EFF")
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 15
        return button
    }()
    
    public override func didMoveToWindow() {
        super.didMoveToWindow()
        guard !isViewReady else { return }
        isViewReady = true
        contentView.addSubview(userImageView)
        userImageView.snp.remakeConstraints { (make) in
            make.leading.equalToSuperview().offset(20)
            make.width.height.equalTo(50)
            make.centerY.equalTo(self)
        }
        
        contentView.addSubview(nameLabel)
        nameLabel.snp.remakeConstraints { (make) in
            make.leading.equalTo(userImageView.snp.trailing).offset(12)
            make.trailing.top.bottom.equalTo(self)
        }
        
        contentView.addSubview(rightButton)
        rightButton.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.width.equalTo(60)
            make.height.equalTo(30)
            make.right.equalToSuperview().offset(-20)
        }
        
        rightButton.addTarget(self, action: #selector(callAction(_:)), for: .touchUpInside)
    }
    
    public override func prepareForReuse() {
        super.prepareForReuse()
        self.buttonAction = nil
    }
    
    public func config(model: V2TIMUserFullInfo, type: SelectUserButtonType, selected: Bool = false, action: (() -> Void)? = nil) {
        backgroundColor = UIColor.clear
        var buttonName = ""
        
        let faceURL = model.faceURL ?? TUI_CALL_DEFAULT_AVATAR
        if let imageURL = URL(string: faceURL) {
            userImageView.kf.setImage(with: .network(imageURL), placeholder: getBundleImage(withName: "userIcon"))
        }
        
        userImageView.layer.masksToBounds = true
        userImageView.layer.cornerRadius = 25
        nameLabel.text = model.nickName != "" ? model.nickName : model.userID
        buttonAction = action
        
        switch type {
        case .call:
            buttonName = TUICallKitAppLocalize("TUICallKitApp.streaming.call")
        case .add:
            buttonName = TUICallKitAppLocalize("TUICallKitApp.add")
        case .delete:
            buttonName = TUICallKitAppLocalize("TUICallKitApp.delete")
        }
        
        rightButton.setTitle(buttonName, for: .normal)
    }
    
    @objc
    func callAction(_ sender: UIButton) {
        if let action = self.buttonAction {
            action()
        }
    }
}

extension SelectUserTableViewCell {
    
    func getBundleImage(withName: String) -> UIImage {
        guard let callingKitBundleURL = Bundle.main.url(forResource: "TUICallingKitBundle", withExtension: "bundle") else { return UIImage() }
        let bundle = Bundle(url: callingKitBundleURL)
        guard let image = UIImage(named: withName, in: bundle, compatibleWith: nil) else { return UIImage() }
        return image
    }
}
