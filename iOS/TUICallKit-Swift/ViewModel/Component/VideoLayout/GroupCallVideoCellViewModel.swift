//
//  GroupCallVideoCellViewModel.swift
//  TUICallKit
//
//  Created by vincepzhang on 2023/3/6.
//

import Foundation
import TUICallEngine

class GroupCallVideoCellViewModel {
    
    let selfCallStatusObserver = Observer()
    let selfVideoAvailableObserver = Observer()
    let remoteUserStatusObserver = Observer()
    let remoteUserVideoAvailableObserver = Observer()
    let isCameraOpenObserver = Observer()
    let isMicMuteObserver = Observer()
    let remotePlayoutVolumeObserver = Observer()
    let selfPlayoutVolumeObserver = Observer()
    let showLargeViewUserIdObserver = Observer()
    let enableBlurBackgroundObserver = Observer()
    let selfNetworkQualityObserver = Observer()
    let remoteNetworkQualityObserver = Observer()
    
    var isSelf: Bool = false
    
    let selfUser: Observable<User> = Observable(User())
    let selfUserStatus: Observable<TUICallStatus> = Observable(.none)
    let selfUserVideoAvailable: Observable<Bool> = Observable(false)
    let selfPlayoutVolume: Observable<Float> = Observable(0)
    let selfIsShowLowNetworkQuality: Observable<Bool> = Observable(false)
    
    var remoteUser = User()
    let remoteUserStatus: Observable<TUICallStatus> = Observable(.none)
    let remoteUserVideoAvailable: Observable<Bool> = Observable(false)
    let remoteUserVolume: Observable<Float> = Observable(0)
    let remoteIsShowLowNetworkQuality: Observable<Bool> = Observable(false)
    
    let mediaType: Observable<TUICallMediaType> = Observable(.unknown)
    let isCameraOpen: Observable<Bool> = Observable(false)
    let isShowLargeViewUserId: Observable<Bool> = Observable(false)
    let isMicMute: Observable<Bool> = Observable(false)
    let enableBlurBackground: Observable<Bool> = Observable(false)
    
    init(remote: User) {
        remoteUser = remote
        selfUser.value = TUICallState.instance.selfUser.value
        selfUserStatus.value = TUICallState.instance.selfUser.value.callStatus.value
        selfUserVideoAvailable.value = TUICallState.instance.selfUser.value.videoAvailable.value
        selfPlayoutVolume.value = TUICallState.instance.selfUser.value.playoutVolume.value
        mediaType.value = TUICallState.instance.mediaType.value
        isSelf = selfUser.value.id.value == remote.id.value ? true : false
        isCameraOpen.value = TUICallState.instance.isCameraOpen.value
        isMicMute.value = TUICallState.instance.isMicMute.value
        isShowLargeViewUserId.value = (TUICallState.instance.showLargeViewUserId.value == remote.id.value) && (remote.id.value.count > 0)
        enableBlurBackground.value = TUICallState.instance.enableBlurBackground.value
        registerObserve()
    }
    
    deinit {
        TUICallState.instance.selfUser.value.callStatus.removeObserver(selfCallStatusObserver)
        TUICallState.instance.showLargeViewUserId.removeObserver(showLargeViewUserIdObserver)
        TUICallState.instance.selfUser.value.videoAvailable.removeObserver(selfVideoAvailableObserver)
        TUICallState.instance.isCameraOpen.removeObserver(isCameraOpenObserver)
        TUICallState.instance.isMicMute.removeObserver(isMicMuteObserver)
        TUICallState.instance.selfUser.value.playoutVolume.removeObserver(selfPlayoutVolumeObserver)
        TUICallState.instance.enableBlurBackground.removeObserver(enableBlurBackgroundObserver)
        TUICallState.instance.selfUser.value.networkQualityReminder.removeObserver(selfNetworkQualityObserver)
    }
    
    func registerObserve() {
        TUICallState.instance.selfUser.value.callStatus.addObserver(selfCallStatusObserver, closure: { [weak self] newValue, _ in
            guard let self = self else { return }
            self.selfUserStatus.value = newValue
        })
        
        TUICallState.instance.selfUser.value.videoAvailable.addObserver(selfVideoAvailableObserver, closure: { [weak self] newValue, _ in
            guard let self = self else { return }
            self.selfUserVideoAvailable.value = newValue
        })
        
        TUICallState.instance.isCameraOpen.addObserver(isCameraOpenObserver, closure: {  [weak self] newValue, _ in
            guard let self = self else { return }
            self.isCameraOpen.value = newValue
        })
        
        TUICallState.instance.isMicMute.addObserver(isMicMuteObserver, closure: {  [weak self] newValue, _ in
            guard let self = self else { return }
            self.isMicMute.value = newValue
        })
        
        TUICallState.instance.showLargeViewUserId.addObserver(showLargeViewUserIdObserver, closure: {  [weak self] newValue, _ in
            guard let self = self else { return }
            self.isShowLargeViewUserId.value = (newValue == self.remoteUser.id.value)
        })
        
        TUICallState.instance.selfUser.value.playoutVolume.addObserver(selfPlayoutVolumeObserver) { [weak self] newValue, _ in
            guard let self = self else { return }
            self.selfPlayoutVolume.value = newValue
        }
        
        TUICallState.instance.selfUser.value.networkQualityReminder.addObserver(selfNetworkQualityObserver) { [weak self] newValue, _ in
            guard let self = self else { return }
            self.selfIsShowLowNetworkQuality.value = newValue
        }
        
        TUICallState.instance.enableBlurBackground.addObserver(enableBlurBackgroundObserver, closure: {  [weak self] newValue, _ in
            guard let self = self else { return }
            self.enableBlurBackground.value = newValue
        })
        
        for index in 0..<TUICallState.instance.remoteUserList.value.count {
            guard index < TUICallState.instance.remoteUserList.value.count else {
                break
            }
            
            if TUICallState.instance.remoteUserList.value[index].id.value == remoteUser.id.value {
                
                remoteUserStatus.value = TUICallState.instance.remoteUserList.value[index].callStatus.value
                remoteUserVideoAvailable.value = TUICallState.instance.remoteUserList.value[index].videoAvailable.value
                
                TUICallState.instance.remoteUserList.value[index].callStatus.addObserver(remoteUserStatusObserver,
                                                                                         closure: { [weak self] newValue, _ in
                    guard let self = self else { return }
                    self.remoteUserStatus.value = newValue
                })
                
                TUICallState.instance.remoteUserList.value[index].videoAvailable.addObserver(remoteUserVideoAvailableObserver,
                                                                                             closure: { [weak self] newValue, _ in
                    guard let self = self else { return }
                    self.remoteUserVideoAvailable.value = newValue
                })
                
                TUICallState.instance.remoteUserList.value[index].networkQualityReminder.addObserver(remoteNetworkQualityObserver)
                { [weak self] newValue, _ in
                    guard let self = self else { return }
                    self.remoteIsShowLowNetworkQuality.value = newValue
                }
                
                TUICallState.instance.remoteUserList.value[index].playoutVolume.addObserver(remotePlayoutVolumeObserver)
                { [weak self] newValue, _ in
                    guard let self = self else { return }
                    self.remoteUserVolume.value = newValue
                }
            }
        }
    }
    
    // MARK: CallEngine Method
    func openCamera(videoView: TUIVideoView) {
        CallEngineManager.instance.openCamera(videoView: videoView)
    }
    
    func closeCamera() {
        CallEngineManager.instance.closeCamera()
    }
    
    func startRemoteView(user: User, videoView: TUIVideoView) {
        CallEngineManager.instance.startRemoteView(user: user, videoView: videoView)
    }
    
    func switchCamera() {
        CallEngineManager.instance.switchCamera()
    }
    
    func virtualBackground() {
        CallEngineManager.instance.setBlurBackground()
    }
    
}
