//
//  AudioCallerWaitingAndAcceptedView.swift
//  TUICallKit
//
//  Created by vincepzhang on 2023/2/14.
//

import Foundation
import UIKit
import RTCRoomEngine
import RTCCommon

class AudioCallerWaitingAndAcceptedView : UIView {
    
    let isMicMuteObserver = Observer()
    let audioDeviceObserver = Observer()
    
    private lazy var muteMicBtn: UIView = {
        let titleKey = CallManager.shared.mediaState.isMicrophoneMuted.value ? "TUICallKit.muted" : "TUICallKit.unmuted"
        let imageName =  CallManager.shared.mediaState.isMicrophoneMuted.value ? "icon_mute_on" : "icon_mute"

        let muteAudioBtn = FeatureButton.create(title: TUICallKitLocalize(key: titleKey),
                                                titleColor: Color_White,
                                                image: CallKitBundle.getBundleImage(name: imageName),
                            imageSize: kBtnSmallSize, buttonAction: { [weak self] sender in
            guard let self = self else { return }
            self.muteMicEvent(sender: sender)
        })
        return muteAudioBtn
    }()
    
    private lazy var hangupBtn: UIView = {
        let hangupBtn = FeatureButton.create(title: TUICallKitLocalize(key: "TUICallKit.hangup"),
                                             titleColor: Color_White,
                                             image: CallKitBundle.getBundleImage(name: "icon_hangup"),
                                             imageSize: kBtnSmallSize, buttonAction: { [weak self] sender in
            guard let self = self else { return }
            self.hangupEvent(sender: sender)
        })
        return hangupBtn
    }()
    
    private lazy var changeSpeakerBtn: UIView = {
        let titleKey = CallManager.shared.mediaState.audioPlayoutDevice.value == .speakerphone ? "TUICallKit.speakerPhone" : "TUICallKit.earpiece"
        let imageName = CallManager.shared.mediaState.audioPlayoutDevice.value == .speakerphone ? "icon_handsfree_on" : "icon_handsfree"

        let changeSpeakerBtn = FeatureButton.create(title: TUICallKitLocalize(key: titleKey),
                                                    titleColor: Color_White,
                                                    image: CallKitBundle.getBundleImage(name: imageName),
                                                    imageSize: kBtnSmallSize, buttonAction: { [weak self] sender in
            guard let self = self else { return }
            self.changeSpeakerEvent(sender: sender)
        })

        return changeSpeakerBtn
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        registerObserveState()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        CallManager.shared.mediaState.isMicrophoneMuted.removeObserver(isMicMuteObserver)
        CallManager.shared.mediaState.audioPlayoutDevice.removeObserver(audioDeviceObserver)
    }
    
    // MARK: UI Specification Processing
    private var isViewReady: Bool = false
    override func didMoveToWindow() {
        super.didMoveToWindow()
        if isViewReady { return }
        constructViewHierarchy()
        activateConstraints()
        isViewReady = true
    }
    
    func constructViewHierarchy() {
        addSubview(muteMicBtn)
        addSubview(hangupBtn)
        addSubview(changeSpeakerBtn)
    }
    
    func activateConstraints() {
        muteMicBtn.snp.makeConstraints { make in
            make.centerX.equalTo(self).offset(TUICoreDefineConvert.getIsRTL() ? 110.scale375Width() : -110.scale375Width())
            make.centerY.equalTo(hangupBtn)
            make.size.equalTo(kControlBtnSize)
        }
        hangupBtn.snp.makeConstraints { make in
            make.centerX.equalTo(self)
            make.bottom.equalTo(self.snp.bottom)
            make.size.equalTo(kControlBtnSize)
        }
        changeSpeakerBtn.snp.makeConstraints { make in
            make.centerX.equalTo(self).offset(TUICoreDefineConvert.getIsRTL() ? -110.scale375Width() : 110.scale375Width())
            make.centerY.equalTo(self.hangupBtn)
            make.size.equalTo(kControlBtnSize)
        }
    }
    
    // MARK: Action Event
    func muteMicEvent(sender: UIButton) {
        CallManager.shared.muteMic()
    }
    
    func changeSpeakerEvent(sender: UIButton) {
        CallManager.shared.changeSpeaker()
    }
    
    func hangupEvent(sender: UIButton) {
        CallManager.shared.hangup()
    }
    
    // MARK: Register TUICallState Observer && Update UI
    func registerObserveState() {
        CallManager.shared.mediaState.isMicrophoneMuted.addObserver(isMicMuteObserver, closure: { [weak self] newValue, _ in
            guard let self = self else { return }
            self.updateMuteAudioBtn(mute: newValue)
        })
        
        CallManager.shared.mediaState.audioPlayoutDevice.addObserver(audioDeviceObserver, closure: { [weak self] newValue, _ in
            guard let self = self else { return }
            self.updateChangeSpeakerBtn(isSpeaker: newValue == .speakerphone)
        })
    }
    
    func updateMuteAudioBtn(mute: Bool) {
        (muteMicBtn as? FeatureButton)?.updateTitle(title: TUICallKitLocalize(key: mute ? "TUICallKit.muted" : "TUICallKit.unmuted") ?? "")
        
        if let image = CallKitBundle.getBundleImage(name: mute ? "icon_mute_on" : "icon_mute") {
            (muteMicBtn as? FeatureButton)?.updateImage(image: image)
        }
    }
    
    func updateChangeSpeakerBtn(isSpeaker: Bool) {
        (changeSpeakerBtn as? FeatureButton)?.updateTitle(title: TUICallKitLocalize(key: isSpeaker ? "TUICallKit.speakerPhone" : "TUICallKit.earpiece") ?? "")
        
        if let image = CallKitBundle.getBundleImage(name: isSpeaker ? "icon_handsfree_on" : "icon_handsfree") {
            (changeSpeakerBtn as? FeatureButton)?.updateImage(image: image)
        }
    }
}
