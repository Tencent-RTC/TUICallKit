//
//  CallUserCell.swift
//  TXLiteAVDemo
//
//  Created by abyyxwang on 2020/8/5.
//  Copyright © 2020 Tencent. All rights reserved.
//

import Foundation
import SnapKit
import TXAppBasic
import Kingfisher

class AudioCallUserCell: UICollectionViewCell {
    
    private var isViewReady: Bool = false
    
    lazy var loading: UIActivityIndicatorView = {
        if #available(iOS 13.0, *) {
            let load = UIActivityIndicatorView.init(style: .large)
            return load
        } else {
            let load = UIActivityIndicatorView.init(style: .whiteLarge)
            return load
        }
    }()

    lazy var cellImgView: UIImageView = {
        let img = UIImageView()
        return img
    }()
    
    lazy var cellVoiceImageView: UIImageView = {
        let img = UIImageView()
        img.image = UIImage.init(named: "calling_mic", in: CallingBundle(), compatibleWith: nil)
        img.contentMode = .scaleAspectFit
        img.isHidden = true
        return img
    }()
    
    lazy var cellUserLabel: UILabel = {
       let user = UILabel()
        user.textColor = .white
        user.backgroundColor = .clear
        user.textAlignment = .left
        return user
    }()
    
    lazy var dimBk: UIView = {
        let dim = UIView()
        dim.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        dim.isHidden = true
        return dim
    }()
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        guard !isViewReady else { return }
        isViewReady = true
        addSubview(cellImgView)
        cellImgView.snp.remakeConstraints { (make) in
            make.width.height.equalTo(self.snp.height)
            make.centerX.centerY.equalTo(self)
        }
        
        addSubview(cellUserLabel)
        cellUserLabel.snp.remakeConstraints { (make) in
            make.bottom.left.equalTo(cellImgView)
            make.height.equalTo(24)
            make.right.equalTo(cellImgView).offset(-24)
        }
        
        addSubview(cellVoiceImageView)
        cellVoiceImageView.snp.remakeConstraints { (make) in
            make.bottom.right.equalTo(cellImgView)
            make.height.width.equalTo(24)
        }
        
        addSubview(dimBk)
        dimBk.snp.remakeConstraints { (make) in
            make.edges.equalTo(cellImgView)
        }
        
        addSubview(loading)
        loading.snp.remakeConstraints { (make) in
            make.center.equalTo(cellImgView)
            make.width.equalTo(44)
            make.height.equalTo(30)
        }
    }
    
    var userModel = CallUserModel(){
        didSet {
            configModel(model: userModel)
        }
    }
    
    public func configModel(model: CallUserModel) {
        guard let avatar = model.avatar else {
            debugPrint("user avatar is nil")
            return
        }
        if let imageURL = URL.init(string: avatar) {
            cellImgView.kf.setImage(with: .network(imageURL))
        }
        cellUserLabel.text = userModel.name
        let noModel = model.userId.count == 0
        dimBk.isHidden = userModel.isEnter || noModel
        loading.isHidden = userModel.isEnter || noModel
        if userModel.isEnter || noModel {
            loading.stopAnimating()
        } else {
            loading.startAnimating()
        }
        cellUserLabel.isHidden = noModel
        cellVoiceImageView.isHidden = model.volume < 0.05
    }
}

class VideoCallUserCell: UICollectionViewCell {
   
    var userModel = CallUserModel() {
        didSet {
            configModel(model: userModel)
        }
    }
    
    public func configModel(model: CallUserModel) {
        let noModel = model.userId.count == 0
        if !noModel {
            if userModel.userId != V2TIMManager.sharedInstance()?.getLoginUser() ?? "" {
                if let render = TRTCCallingVideoViewController.getRenderView(userId: userModel.userId) {
                    if render.superview != self {
                        render.removeFromSuperview()
                        DispatchQueue.main.async {
                            render.frame = self.bounds
                        }
                        addSubview(render)
                        render.userModel = userModel
                    }
                } else {
                    print("error")
                }
            }
        }
    }
}
