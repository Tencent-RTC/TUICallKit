//
//  MainViewController.swift
//  TUICallKitApp
//
//  Created by noah on 2021/12/27.
//  Copyright © 2021 Tencent. All rights reserved.
//

import UIKit
import Toast_Swift
import TUICallKit
import TUICore

class MainViewController: UIViewController {
    
    lazy var collectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.sectionInset = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        flowLayout.itemSize = CGSize(width: view.bounds.width - 40, height: 144)
        flowLayout.minimumLineSpacing = 16
        flowLayout.minimumInteritemSpacing = 16
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.register(MainCollectionViewCell.self, forCellWithReuseIdentifier: MainCollectionViewCell.reuseIdentifier)
        collectionView.backgroundColor = UIColor.clear
        collectionView.delegate = self
        collectionView.dataSource = self
        return collectionView
    }()
    
    lazy var backBtn: UIButton = {
        let backBtn = UIButton(type: .custom)
        backBtn.setTitle(TUICallKitAppLocalize("TUICallKitApp.Home.logout"), for: .normal)
        backBtn.setTitleColor(UIColor.black, for: .normal)
        backBtn.titleLabel?.font = UIFont(name: "PingFangSC-Regular", size: 16)
        backBtn.sizeToFit()
        return backBtn
    }()
    
    var logFilesArray: [String] = []
    lazy var mainMenuItems: [MainMenuItemModel] = {
        return [
            MainMenuItemModel(imageName: "main_home_audiocall",
                              title: TUICallKitAppLocalize("TUICallKitApp.Home.audio"),
                              content: TUICallKitAppLocalize("TUICallKitApp.Home.audiocalldesc"),
                              selectHandle: { [weak self] in
                                  guard let `self` = self else { return }
                                  self.gotoAudioCallView()
                              }),
            MainMenuItemModel(imageName: "main_home_videocall",
                              title: TUICallKitAppLocalize("TUICallKitApp.Home.video"),
                              content: TUICallKitAppLocalize("TUICallKitApp.Home.videocalldesc"),
                              selectHandle: { [weak self] in
                                  guard let `self` = self else { return }
                                  self.gotoVideoCallView()
                              }),
        ]
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNaviBar()
        backBtn.addTarget(self, action: #selector(logout(sender:)), for: .touchUpInside)
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupToast()
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13.0, *) {
            return .darkContent
        }
        return .default
    }
}

extension MainViewController {
    
    private func setupNaviBar() {
        view.backgroundColor = UIColor("F4F5F9")
        navigationController?.navigationBar.topItem?.title = "TRTC"
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor:UIColor.black,
                                                                   NSAttributedString.Key.font:UIFont(name: "PingFangSC-Semibold", size: 18)!]
        navigationController?.navigationBar.barTintColor = UIColor.white
        navigationController?.navigationBar.isTranslucent = false
        let item = UIBarButtonItem(customView: backBtn)
        navigationItem.rightBarButtonItems = [item]
    }
}

extension MainViewController {
    func gotoAudioCallView() {
        let audioCallVC = ContactViewController()
        audioCallVC.callType = .audio
        audioCallVC.title = TUICallKitAppLocalize("TUICallKitApp.Home.audio")
        audioCallVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(audioCallVC, animated: true)
    }
    
    func gotoVideoCallView() {
        let videoCallVC = ContactViewController()
        videoCallVC.callType = .video
        videoCallVC.title = TUICallKitAppLocalize("TUICallKitApp.Home.video")
        videoCallVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(videoCallVC, animated: true)
    }
}

extension MainViewController {
    @objc private func logout(sender: UIButton) {
        let alertVC = UIAlertController(title: TUICallKitAppLocalize("TUICallKitApp.Home.areyousureloginout"), message: nil, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: TUICallKitAppLocalize("TUICallKitApp.Home.cancel"), style: .cancel, handler: nil)
        let sureAction = UIAlertAction(title: TUICallKitAppLocalize("TUICallKitApp.Home.determine"), style: .default) { (action) in
            ProfileManager.shared.removeLoginCache()
            AppUtils.shared.appDelegate.showLoginViewController()
            TUILogin.logout {
            } fail: { _, _ in
            }
            
            V2TIMManager.sharedInstance()?.logout({
                
            }, fail: { (errCode, errMsg) in
                
            })
        }
        alertVC.addAction(cancelAction)
        alertVC.addAction(sureAction)
        present(alertVC, animated: true, completion: nil)
    }
}

extension MainViewController {
    @objc func setupToast() {
        ToastManager.shared.position = .bottom
    }
}

extension MainViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        mainMenuItems[indexPath.row].selectHandle()
    }
}

extension MainViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return mainMenuItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let model = mainMenuItems[indexPath.item]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MainCollectionViewCell.reuseIdentifier,
                                                      for: indexPath) as! MainCollectionViewCell
        cell.config(model)
        return cell
    }
}
