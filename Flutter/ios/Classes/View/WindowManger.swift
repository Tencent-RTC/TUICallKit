//
//  FloatWindowManger.swift
//  tencent_calls_uikit
//
//  Created by vincepzhang on 2023/6/27.
//

import Foundation
import RTCRoomEngine

protocol BackToFlutterWidgetDelegate: NSObject {
    func backCallingPageFromFloatWindow()
    func launchCallingPageFromIncomingBanner()
}

class WindowManger: NSObject, FloatWindowViewDelegate, IncomingBannerViewDelegate {
        
    static let instance = WindowManger()
    
    let remoteUserVideoAvailableObserver = Observer()
    let selfUserCallStatusObserver = Observer()
    
    let selfCallStatus: Observable<TUICallStatus> = Observable(TUICallState.instance.selfUser.value.callStatus.value)

    var floatWindowBeganPoint: CGPoint?
    var floatWindowBeganOrigin: CGPoint?
    
    weak var backToFlutterWidgetDelegate: BackToFlutterWidgetDelegate?
    weak var incomingBannerViewDelegate: IncomingBannerViewDelegate?

    var floatWindow = UIWindow()
    
    override init() {
        super.init()
        registerObserveState()
    }
    
    func showFloatWindow() {
        let floatViewController = FloatWindowViewController()
        floatViewController.delegate = self
        initFloatWindowFrame()
        floatWindow.backgroundColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1)
        floatWindow.layer.shadowColor = UIColor.black.cgColor
        floatWindow.layer.shadowOffset = CGSizeMake(10.0, 10.0)
        floatWindow.layer.shadowOpacity = 1.0
        floatWindow.layer.shadowRadius = 1.0
        floatWindow.layer.cornerRadius = 10.0
        floatWindow.layer.masksToBounds = true
        floatWindow.rootViewController = floatViewController
        floatWindow.isHidden = false
        floatWindow.t_makeKeyAndVisible()
    }

    func closeFloatWindow() {
        floatWindow = UIWindow()
    }

    func registerObserveState() {
        TUICallState.instance.selfUser.value.callStatus.addObserver(selfCallStatus, closure: { [weak self] newValue, _ in
            guard let self = self else { return }
            if self.selfCallStatus.value == newValue { return }
            self.selfCallStatus.value = newValue
            self.updateFloatWindowFrame()
            
            if self.selfCallStatus.value == TUICallStatus.none {
                WindowManger.instance.closeFloatWindow()
            }
            
            if self.selfCallStatus.value != TUICallStatus.waiting {
                WindowManger.instance.closeIncomingBannerView()
            }
        })
    }
    
    func initFloatWindowFrame() {
        if TUICallState.instance.scene.value == .single {
            if TUICallState.instance.mediaType.value == .audio {
                floatWindow.frame = CGRect(x: Screen_Width - kSingleCallMicroAudioViewWidth - kMicroLeftRightEdge, y: kMicroTopEdge, 
                                           width: kSingleCallMicroAudioViewWidth, height: kSingleCallMicroAudioViewHeight)
            } else {
                floatWindow.frame = CGRect(x: Screen_Width - kSingleCallMicroVideoViewWidth - kMicroLeftRightEdge, y: kMicroTopEdge, 
                                           width: kSingleCallMicroVideoViewWidth, height: kSingleCallMicroVideoViewHeight)
            }
        } else {
            floatWindow.frame = CGRect(x: Screen_Width - kGroupCallMicroViewWidth - kMicroLeftRightEdge, y: kMicroTopEdge, 
                                       width: kGroupCallMicroViewWidth, height: kGroupCallMicroViewHeight)
        }
    }

    func updateFloatWindowFrame() {
        let originY = floatWindow.frame.origin.y
        if TUICallState.instance.scene.value == .single {
            if TUICallState.instance.mediaType.value == .audio {
                let dstX = floatWindow.frame.origin.x < Screen_Width / 2.0 ? kMicroLeftRightEdge : Screen_Width - kSingleCallMicroAudioViewWidth - kMicroLeftRightEdge
                floatWindow.frame = CGRect(x: dstX, y: originY, width: kSingleCallMicroAudioViewWidth, height: kSingleCallMicroAudioViewHeight)
            } else {
                let dstX = floatWindow.frame.origin.x < Screen_Width / 2.0 ? kMicroLeftRightEdge : Screen_Width - kSingleCallMicroVideoViewWidth - kMicroLeftRightEdge
                floatWindow.frame = CGRect(x: dstX, y: originY, width: kSingleCallMicroVideoViewWidth, height: kSingleCallMicroVideoViewHeight)
            }
        } else {
            let dstX = floatWindow.frame.origin.x < Screen_Width / 2.0 ? kMicroLeftRightEdge : Screen_Width - kGroupCallMicroViewWidth - kMicroLeftRightEdge
            floatWindow.frame = CGRect(x: dstX, y: originY, width: kGroupCallMicroViewWidth, height: kGroupCallMicroViewHeight)
        }
    }

    //MARK: FloatingWindowViewDelegate
    func tapGestureAction(tapGesture: UITapGestureRecognizer) {
        closeFloatWindow()
        if self.backToFlutterWidgetDelegate != nil &&
            ((self.backToFlutterWidgetDelegate?.responds(to: Selector(("backToFlutterWidgetDelegate")))) != nil) &&
            TUICallState.instance.selfUser.value.callStatus.value != .none {
            self.backToFlutterWidgetDelegate?.backCallingPageFromFloatWindow()
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
            if (floatWindow.frame.origin.x + floatWindow.frame.size.width / 2) < Screen_Width / 2 {
                dstX = kMicroLeftRightEdge
            } else if (floatWindow.frame.origin.x + floatWindow.frame.size.width / 2) > Screen_Width / 2 {
                dstX = CGFloat(Screen_Width - floatWindow.frame.size.width - kMicroLeftRightEdge)
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
    
    // MARK: Incoming Banner
    func showIncomingBanner() {
        let incomingFloatView = IncomingBannerView(frame: CGRect.zero)
        incomingFloatView.delegate = self
        let viewController = UIViewController()
        viewController.view.addSubview(incomingFloatView)
        floatWindow.rootViewController = viewController
        floatWindow.isHidden = false
        floatWindow.backgroundColor = UIColor.clear
        floatWindow.frame = CGRect(x: 8.scaleWidth(),
                                  y: StatusBar_Height + 10,
                                  width: Screen_Width - 16.scaleWidth(),
                                  height: 92.scaleWidth())
        floatWindow.t_makeKeyAndVisible()
    }

    func closeIncomingBannerView() {
        closeFloatWindow()
    }
    
    func showCallingView() {
        closeFloatWindow()
        if self.backToFlutterWidgetDelegate != nil &&
            ((self.backToFlutterWidgetDelegate?.responds(to: Selector(("backToFlutterWidgetDelegate")))) != nil) &&
            TUICallState.instance.selfUser.value.callStatus.value != .none {
            self.backToFlutterWidgetDelegate?.launchCallingPageFromIncomingBanner()
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
