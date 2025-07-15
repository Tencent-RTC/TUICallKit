//
//  AudioRouteButton.swift
//  Pods
//
//  Created by vincepzhang on 2025/5/12.
//

import AVKit
import AVRouting

#if canImport(TXLiteAVSDK_TRTC)
import TXLiteAVSDK_TRTC
#elseif canImport(TXLiteAVSDK_Professional)
import TXLiteAVSDK_Professional
#endif

class RoutePickerView: AVRoutePickerView {
    let audioDeviceObserver = Observer()
    
    let changeSpeakerBtn: FeatureButton = {
        var titleKey: String
        if AudioSessionManager.isBluetoothHeadsetActive() {
            titleKey = AudioSessionManager.getCurrentOutputDeviceName() ?? ""
        } else {
            titleKey = CallManager.shared.mediaState.audioPlayoutDevice.value ==
                .speakerphone ? "TUICallKit.AVRoutePickerView.speakerPhone" : "TUICallKit.AVRoutePickerView.earpiece"
        }
        let imageName: String = "icon_audio_route_picker"
        let changeSpeakerBtn = FeatureButton.create(title: TUICallKitLocalize(key: titleKey),
                                                    titleColor: Color_White,
                                                    image: CallKitBundle.getBundleImage(name: imageName),
                                                    imageSize: kBtnSmallSize, buttonAction: { sender in })
        changeSpeakerBtn.isUserInteractionEnabled = false
        return changeSpeakerBtn
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
                
        registerObserver()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        unregisterObserver()
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
        self.subviews.first?.removeFromSuperview()

        addSubview(changeSpeakerBtn)
    }
    
    func activateConstraints() {
        changeSpeakerBtn.translatesAutoresizingMaskIntoConstraints = false
        if let superview = changeSpeakerBtn.superview {
            NSLayoutConstraint.activate([
                changeSpeakerBtn.topAnchor.constraint(equalTo: superview.topAnchor),
                changeSpeakerBtn.leadingAnchor.constraint(equalTo: superview.leadingAnchor),
                changeSpeakerBtn.trailingAnchor.constraint(equalTo: superview.trailingAnchor),
                changeSpeakerBtn.bottomAnchor.constraint(equalTo: superview.bottomAnchor)
            ])
        }
    }
    
    // MARK: Observer
    func registerObserver() {
        CallManager.shared.mediaState.audioPlayoutDevice.addObserver(audioDeviceObserver, closure: { [weak self] newValue, _ in
            guard let self = self else { return }
            self.updateChangeSpeakerButtonTitle()
        })
    }
    
    func unregisterObserver() {
        CallManager.shared.mediaState.audioPlayoutDevice.removeObserver(audioDeviceObserver)
    }

    // MARK: Private
    private func updateChangeSpeakerButtonTitle() {
        var titleKey: String = ""

        if CallManager.shared.mediaState.audioPlayoutDevice.value == .speakerphone {
            titleKey = "TUICallKit.AVRoutePickerView.speakerPhone"
        } else if CallManager.shared.mediaState.audioPlayoutDevice.value == .earpiece {
            titleKey = "TUICallKit.AVRoutePickerView.earpiece"
        } else if CallManager.shared.mediaState.audioPlayoutDevice.value == .bluetooth {
            titleKey = AudioSessionManager.getCurrentOutputDeviceName() ?? ""
        }
        changeSpeakerBtn.updateTitle(title:  TUICallKitLocalize(key: titleKey) ?? titleKey)
    }
}
