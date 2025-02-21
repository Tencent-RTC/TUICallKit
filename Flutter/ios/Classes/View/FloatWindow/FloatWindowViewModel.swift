//
//  FloatWindowViewModel.swift
//  tencent_calls_uikit
//
//  Created by vincepzhang on 2023/6/27.
//

import Foundation
import RTCRoomEngine

class FloatWindowViewModel {
    
    let selfCallStatusObserver = Observer()
    let remoteUserListObserver = Observer()
    let fristRemoteUserVideoAvailableObserver = Observer()
    let isCameraOpenObserver = Observer()
    let isMicMuteObserver = Observer()
    let selfPlayoutVolumeObserver = Observer()
    let remotePlayoutVolumeObserver = Observer()

    let mediaType: Observable<TUICallMediaType> = Observable(.unknown)
    let remoteUserList: Observable<[User]> = Observable(Array())
    let firstRemoteUserVideoAvailable: Observable<Bool> = Observable(false)
    let selfCallStatus: Observable<TUICallStatus> = Observable(TUICallStatus.none)
    let isCameraOpen: Observable<Bool> = Observable(false)
    let isMicMute: Observable<Bool> = Observable(false)
    let currentSpeakUser: Observable<User> = Observable(User())
    
    let timeCount: Observable<Int> = Observable(0)
    var timerName: String?
        
    init() {
        mediaType.value = TUICallState.instance.mediaType.value
        remoteUserList.value = TUICallState.instance.remoteUserList.value
        selfCallStatus.value = TUICallState.instance.selfUser.value.callStatus.value
        isCameraOpen.value = TUICallState.instance.isCameraOpen.value
        isMicMute.value = TUICallState.instance.isMicrophoneMute.value
        
        if TUICallState.instance.remoteUserList.value.first != nil {
            firstRemoteUserVideoAvailable.value = TUICallState.instance.remoteUserList.value.first?.videoAvailable.value ?? false
        }
    
        registerObserve()
        if selfCallStatus.value == TUICallStatus.accept {
            startTimer()
        }
    }
    
    deinit {
        TUICallState.instance.selfUser.value.callStatus.removeObserver(selfCallStatusObserver)
        TUICallState.instance.remoteUserList.removeObserver(remoteUserListObserver)
        TUICallState.instance.isCameraOpen.removeObserver(isCameraOpenObserver)
        TUICallState.instance.isMicrophoneMute.removeObserver(isMicMuteObserver)
        TUICallState.instance.selfUser.value.playoutVolume.removeObserver(selfPlayoutVolumeObserver)
        
        if TUICallState.instance.remoteUserList.value.first != nil {
            TUICallState.instance.remoteUserList.value.first?.videoAvailable.removeObserver(fristRemoteUserVideoAvailableObserver)
        }
        
        for index in 0..<TUICallState.instance.remoteUserList.value.count {
            guard index < TUICallState.instance.remoteUserList.value.count else {
                break
            }
            TUICallState.instance.remoteUserList.value[index].playoutVolume.removeObserver(remotePlayoutVolumeObserver)
        }
    }
    
    func registerObserve() {
        
        TUICallState.instance.selfUser.value.callStatus.addObserver(selfCallStatusObserver, closure: { [weak self] newValue, _ in
            guard let self = self else { return }
            self.selfCallStatus.value = newValue
            
            if self.selfCallStatus.value == TUICallStatus.none {
                self.closeCamera()
                if self.remoteUserList.value.first != nil, let remoteUserId = self.remoteUserList.value.first?.id.value {
                    self.stopRemoteView(userId: remoteUserId)
                }
            }

            if self.selfCallStatus.value == TUICallStatus.accept {
                self.startTimer()
            } else {
                guard let timerName = self.timerName else { return }
                GCDTimer.cancel(timerName: timerName) {
                }
            }
        })
                
        TUICallState.instance.isCameraOpen.addObserver(isCameraOpenObserver) { [weak self] newValue, _ in
            guard let self = self else { return }
            self.isCameraOpen.value = newValue
        }
        
        TUICallState.instance.isMicrophoneMute.addObserver(isMicMuteObserver) { [weak self] newValue, _ in
            guard let self = self else { return }
            self.isMicMute.value = newValue
        }
        
        if TUICallState.instance.remoteUserList.value.first != nil {
            TUICallState.instance.remoteUserList.value.first?.videoAvailable.addObserver(fristRemoteUserVideoAvailableObserver, closure: { [weak self] newValue, _ in
                guard let self = self else { return }
                self.firstRemoteUserVideoAvailable.value = newValue
            })
        }
        
        TUICallState.instance.selfUser.value.playoutVolume.addObserver(selfPlayoutVolumeObserver) { [weak self] newValue, _ in
            guard let self = self else { return }
            if newValue > 10 {
                self.updateCurrentSpeakUser(user: TUICallState.instance.selfUser.value)
            }
        }
        
        for index in 0..<TUICallState.instance.remoteUserList.value.count {
            guard index < TUICallState.instance.remoteUserList.value.count else {
                break
            }
            let user = TUICallState.instance.remoteUserList.value[index]
            TUICallState.instance.remoteUserList.value[index].playoutVolume.addObserver(remotePlayoutVolumeObserver) { [weak self] newValue, _ in
                guard let self = self else { return }
                if newValue > 10 {
                    self.updateCurrentSpeakUser(user: user)
                }
            }
        }
    }
    
    func updateCurrentSpeakUser(user: User) {
        if user.id.value.count > 0 && currentSpeakUser.value.id.value != user.id.value {
            self.currentSpeakUser.value = user
        }
    }
    
    func startTimer() {
        timerName = GCDTimer.start(interval: 1, repeats: true, async: true) { [weak self] in
            guard let self = self else { return }
            self.timeCount.value = Int(Date().timeIntervalSince1970) - TUICallState.instance.startTime
        }
    }
    
    func getCallTimeString() -> String {
        return GCDTimer.secondToHMSString(second: timeCount.value)
    }
    
    func startRemoteView(userId: String, videoView: UIView){
        TUICallEngine.createInstance().startRemoteView(userId: userId, videoView: videoView) { videoId in
            
        } onLoading: { videoId in
            
        } onError: { videoId, code, message in
            
        }
    }
    
    func stopRemoteView(userId: String){
        TUICallEngine.createInstance().stopRemoteView(userId: userId)
    }

    func openCamera(videoView: UIView) {
        TUICallEngine.createInstance().openCamera(TUICallState.instance.camera.value, videoView: videoView) {
            
        } fail: { code, message in
            
        }
    }
    
    func closeCamera() {
        TUICallEngine.createInstance().closeCamera()
    }
}
