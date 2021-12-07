//
//  CallingSelectUserTableViewCell.swift
//  TRTCScene
//
//  Created by adams on 2021/5/20.
//

import UIKit
import TUICalling

public class CallingSelectUserTableViewCell: UITableViewCell {
    private var isViewReady = false
    private var buttonAction: (() -> Void)?
    lazy var userImageView: UIImageView = {
       let img = UIImageView()
        return img
    }()
    
    lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.backgroundColor = .clear
        return label
    }()
    
    let callButton: UIButton = {
        let button = UIButton.init(type: .custom)
        button.backgroundColor = UIColor.init("006EFF")
        button.setTitle(CallingLocalize("Demo.TRTC.Streaming.call"), for: .normal)
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
        
        contentView.addSubview(callButton)
        callButton.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.width.equalTo(60)
            make.height.equalTo(30)
            make.right.equalToSuperview().offset(-20)
        }
        
        callButton.addTarget(self, action: #selector(callAction(_:)), for: .touchUpInside)
    }
    
    public override func prepareForReuse() {
        super.prepareForReuse()
        self.buttonAction = nil
    }
    
    public func config(model: V2TIMUserFullInfo, selected: Bool = false, action: (() -> Void)? = nil) {
        backgroundColor = .clear
        if let faceURL = model.faceURL, let imageURL = URL.init(string: faceURL) {
            userImageView.kf.setImage(with: .network(imageURL))
        } else {
            userImageView.image = UIImage.init(named: "voiceroom_cover1")
        }
        
        userImageView.layer.masksToBounds = true
        userImageView.layer.cornerRadius = 25
        nameLabel.text = model.nickName != "" ? model.nickName : model.userID
        buttonAction = action
    }
    
    @objc
    func callAction(_ sender: UIButton) {
        if let action = self.buttonAction {
            action()
        }
    }
}
