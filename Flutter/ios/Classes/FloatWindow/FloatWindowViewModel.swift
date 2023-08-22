//
//  FloatWindowViewModel.swift
//  tencent_calls_uikit
//
//  Created by vincepzhang on 2023/6/27.
//

import Foundation
import TUICallEngine

class FloatingWindowViewModel {
    
    let selfCallStatusObserver = Observer()
    let mediaTypeObserver = Observer()
    let remoteUserVideoAvailableObserver = Observer()
    let scenceObserver = Observer()

    let mediaType: Observable<TUICallMediaType> = Observable(.unknown)
    let remoteUserVideoAvailable: Observable<Bool> = Observable(false)
    let selfCallStatus: Observable<TUICallStatus> = Observable(TUICallStatus.none)
    let scence: Observable<TUICallScene> = Observable(TUICallScene.single)
    
    let timeCount: Observable<Int> = Observable(0)
    var timerName: String?
        
    init() {
        mediaType.value = TUICallState.instance.mediaType.value
        remoteUserVideoAvailable.value = TUICallState.instance.remoteUser.value.videoAvailable.value
        selfCallStatus.value = TUICallState.instance.selfUser.value.callStatus.value
        scence.value = TUICallState.instance.scene.value
        
        registerObserve()
        
        if selfCallStatus.value == TUICallStatus.accept {
            startTimer()
        }
    }
    
    deinit {
        TUICallState.instance.selfUser.value.callStatus.removeObserver(selfCallStatusObserver)
        TUICallState.instance.mediaType.removeObserver(mediaTypeObserver)
        TUICallState.instance.remoteUser.removeObserver(remoteUserVideoAvailableObserver)
        TUICallState.instance.scene.removeObserver(scenceObserver)
    }
    
    func registerObserve() {
        
        TUICallState.instance.selfUser.value.callStatus.addObserver(selfCallStatusObserver, closure: { [weak self] newValue, _ in
            guard let self = self else { return }
            if self.selfCallStatus.value == newValue  { return }
            self.selfCallStatus.value = newValue
            
            if self.selfCallStatus.value == TUICallStatus.none {
                self.closeCamera()
                self.stopRemoteView()
            }

            
            if self.selfCallStatus.value == TUICallStatus.accept {
                self.startTimer()
            } else {
                guard let timerName = self.timerName else { return }
                GCDTimer.cancel(timerName: timerName) {
                }
            }
        })
        
        TUICallState.instance.mediaType.addObserver(mediaTypeObserver, closure: { [weak self] newValue, _ in
            guard let self = self else { return }
            if self.mediaType.value == newValue  { return }
            self.mediaType.value = newValue
        })
        
        TUICallState.instance.remoteUser.value.videoAvailable.addObserver(remoteUserVideoAvailableObserver, closure: { [weak self] newValue, _ in
            guard let self = self else { return }
            if self.remoteUserVideoAvailable.value == newValue  { return }
            self.remoteUserVideoAvailable.value = newValue
        })
        
        TUICallState.instance.scene.addObserver(scenceObserver) { [weak self] newValue, _ in
            guard let self = self else { return }
            if self.scence.value == newValue  { return }
            self.scence.value = newValue
        }
    }
    
    func getRemoteAvatar() -> UIImage {
        var output = UIImage()
        if TUICallState.instance.remoteUser.value.avatar.value == "" {
            if let image = BundleUtils.getBundleImage(name: "userIcon") {
                output = image
            }
        } else {
            if let image = BundleUtils.getUrlImage(url: TUICallState.instance.remoteUser.value.avatar.value) {
                output = image
            }
        }
        return output
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
    
    func startRemoteView(videoView: TUIVideoView){
        TUICallEngine.createInstance().startRemoteView(userId: TUICallState.instance.remoteUser.value.id.value, videoView: videoView) { videoId in
            
        } onLoading: { videoId in
            
        } onError: { videoId, code, message in
            
        }
    }
    
    func stopRemoteView(){
        TUICallEngine.createInstance().stopRemoteView(userId: TUICallState.instance.remoteUser.value.id.value)
    }

    func openCamera(videoView: TUIVideoView) {
        TUICallEngine.createInstance().openCamera(TUICallState.instance.camera.value, videoView: videoView) {
            
        } fail: { code, message in
            
        }
    }
    
    func closeCamera() {
        TUICallEngine.createInstance().closeCamera()
    }
}
