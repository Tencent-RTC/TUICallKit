//
//  FloatWindowManger.swift
//  tencent_calls_uikit
//
//  Created by vincepzhang on 2023/6/27.
//

import Foundation
import TUICallEngine

protocol BackToFlutterWidgetDelegate: NSObject {
    func backToFlutterWidget()
}

class FloatWindowManger: NSObject, FloatingWindowViewDelegate {
    
    static let instance = FloatWindowManger()
    
    let mediaTypeObserver = Observer()
    let remoteUserVideoAvailableObserver = Observer()
    let selfUserCallStatusObserver = Observer()
    
    let mediaType: Observable<TUICallMediaType> = Observable(TUICallState.instance.mediaType.value)
    let remoteUserVideoAvailable: Observable<Bool> = Observable(TUICallState.instance.remoteUser.value.videoAvailable.value)
    let selfCallStatus: Observable<TUICallStatus> = Observable(TUICallState.instance.selfUser.value.callStatus.value)

    var floatWindowBeganPoint: CGPoint?
    var floatWindowBeganOrigin: CGPoint?
    
    weak var backToFlutterWidgetDelegate: BackToFlutterWidgetDelegate?

    var floatWindow = UIWindow()
    
    override init() {
        super.init()
        registerObserveState()
    }
    
    func showFloatWindow() {
        let floatViewController = FloatWindowViewController()
        floatViewController.delegate = self
        floatWindow.frame = CGRect(x: Screen_Width - kMicroVideoViewWidth, y: 150, width: kMicroVideoViewWidth, height: kMicroVideoViewHeight)
        floatWindow.backgroundColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1)
        floatWindow.layer.cornerRadius = 10.0
        floatWindow.layer.masksToBounds = true
        updateFloatWindowFrame()
        floatWindow.rootViewController = floatViewController
        floatWindow.isHidden = false
        floatWindow.t_makeKeyAndVisible()
    }

    func closeFloatWindow() {
        floatWindow = UIWindow()
    }

    func registerObserveState() {
        TUICallState.instance.mediaType.addObserver(mediaTypeObserver, closure: { [weak self] newValue, _ in
            guard let self = self else { return }
            if self.mediaType.value == newValue { return }
            self.mediaType.value = newValue
            self.updateFloatWindowFrame()
        })

        TUICallState.instance.remoteUser.value.videoAvailable.addObserver(remoteUserVideoAvailableObserver, closure: { [weak self] newValue, _ in
            guard let self = self else { return }
            if self.remoteUserVideoAvailable.value == newValue { return }
            self.remoteUserVideoAvailable.value = newValue
            self.updateFloatWindowFrame()
        })
        
        TUICallState.instance.selfUser.value.callStatus.addObserver(selfCallStatus, closure: { [weak self] newValue, _ in
            guard let self = self else { return }
            if self.selfCallStatus.value == newValue { return }
            self.selfCallStatus.value = newValue
            self.updateFloatWindowFrame()
            
            if self.selfCallStatus.value == TUICallStatus.none {
                FloatWindowManger.instance.closeFloatWindow()
            }
        })
    }
    
    func updateFloatWindowFrame() {
        let originY = floatWindow.frame.origin.y
        if TUICallState.instance.scene.value == .single {
            if TUICallState.instance.mediaType.value == .audio {
                let dstX = floatWindow.frame.origin.x < Screen_Width / 2.0 ? 0 : Screen_Width - kMicroAudioViewWidth
                floatWindow.frame = CGRect(x: dstX, y: originY, width: kMicroAudioViewWidth, height: kMicroAudioViewHeight)
            } else {
                let dstX = floatWindow.frame.origin.x < Screen_Width / 2.0 ? 0 : Screen_Width - kMicroVideoViewWidth
                if TUICallState.instance.selfUser.value.callStatus.value == TUICallStatus.waiting {
                    floatWindow.frame = CGRect(x: dstX, y: originY, width: kMicroVideoViewWidth, height: kMicroVideoViewHeight)
                } else {
                    if TUICallState.instance.remoteUser.value.videoAvailable.value {
                        floatWindow.frame = CGRect(x: dstX, y: originY, width: kMicroVideoViewWidth, height: kMicroVideoViewHeight)
                    } else {
                        floatWindow.frame = CGRect(x: dstX, y: originY, width: kMicroVideoViewWidth, height: kMicroVideoViewHeight - 60)
                    }
                }
            }
        } else {
            let dstX = floatWindow.frame.origin.x < Screen_Width / 2.0 ? 0 : Screen_Width - kMicroAudioViewWidth
            floatWindow.frame = CGRect(x: dstX, y: originY, width: kMicroAudioViewWidth, height: kMicroAudioViewHeight)
        }
    }

    //MARK: FloatingWindowViewDelegate
    func tapGestureAction(tapGesture: UITapGestureRecognizer) {
        closeFloatWindow()
        if self.backToFlutterWidgetDelegate != nil && ((self.backToFlutterWidgetDelegate?.responds(to: Selector(("backToFlutterWidget")))) != nil) {
            self.backToFlutterWidgetDelegate?.backToFlutterWidget()
        }
    }

    func panGestureAction(panGesture: UIPanGestureRecognizer) {
        switch panGesture.state {
        case .began:
            floatWindowBeganPoint = floatWindow.frame.origin
            floatWindowBeganOrigin = floatWindow.frame.origin
            break
        case.changed:
            let point = panGesture.translation(in: floatWindow)
            var dstX = (floatWindowBeganPoint?.x ?? 0) + CGFloat(point.x)
            var dstY = (floatWindowBeganPoint?.y ?? 0) + CGFloat(point.y)

            if dstX < 0 {
                dstX = 0
            } else if dstX > (Screen_Width - floatWindow.frame.size.width) {
                dstX = Screen_Width - floatWindow.frame.size.width
            }

            if dstY < 0 {
                dstY = 0
            } else if dstY > (Screen_Height - floatWindow.frame.size.height) {
                dstY = Screen_Height - floatWindow.frame.size.height

            }

            floatWindow.frame = CGRect(x: dstX,
                                  y: dstY,
                                  width: floatWindow.frame.size.width,
                                  height: floatWindow.frame.size.height)
            break
        case.cancelled:
            break
        case.ended:
            var dstX: CGFloat = 0
            if floatWindow.frame.origin.x < Screen_Width / 2 {
                dstX = CGFloat(0)
            } else if floatWindow.frame.origin.x > Screen_Width / 2 {
                dstX = CGFloat(Screen_Width - floatWindow.frame.size.width)
            }
            floatWindow.frame = CGRect(x: dstX,
                                       y: floatWindow.frame.origin.y,
                                   width: floatWindow.frame.size.width,
                                  height: floatWindow.frame.size.height)
            break
        default:
            break
        }
    }
}

extension UIWindow {
    func t_makeKeyAndVisible() {
        if #available(iOS 13.0, *) {
            for windowScene in UIApplication.shared.connectedScenes {
                if windowScene.activationState == UIScene.ActivationState.foregroundActive ||
                    windowScene.activationState == UIScene.ActivationState.background {
                    self.windowScene = windowScene as? UIWindowScene
                    break
                }
            }
        }
        self.makeKeyAndVisible()
    }
}
