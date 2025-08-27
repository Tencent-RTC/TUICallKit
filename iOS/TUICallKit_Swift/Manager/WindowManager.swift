//
//  WindowManager.swift
//  Pods
//
//  Created by vincepzhang on 2025/2/21.
//
import RTCCommon

class WindowManager: NSObject, GestureViewDelegate {
    static let shared = WindowManager()

    private var floatWindowBeganPoint: CGPoint = .zero
    private let window: UIWindow = {
        let callWindow = UIWindow()
        callWindow.windowLevel = .alert + 1
        return callWindow
    }()

    private var currentScreenWidth: CGFloat {
        return UIScreen.main.bounds.width
    }
    private var currentScreenHeight: CGFloat {
        return UIScreen.main.bounds.height
    }
    private var currentScreenFrame: CGRect {
        return UIScreen.main.bounds
    }

    private override init() {
        super.init()
        registerObserver()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func registerObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleOrientationChange),
            name: UIDevice.orientationDidChangeNotification,
            object: nil
        )
    }
    
    @objc private func handleOrientationChange() {
        if !window.isHidden && CallManager.shared.viewState.router.value == .floatView {
            let onRight = window.frame.midX > currentScreenWidth / 2
            let yRatio = window.frame.origin.y / max(1, (currentScreenHeight - window.frame.height))
            DispatchQueue.main.async {
                var frame = self.window.frame
                frame.size = self.getFloatWindowFrame().size
                frame.origin.x = onRight ? (self.currentScreenWidth - frame.width) : 0
                frame.origin.y = yRatio * max(1, (self.currentScreenHeight - frame.height))
                frame.origin.y = max(0, min(frame.origin.y, self.currentScreenHeight - frame.height))
                self.window.frame = frame
            }
        }
        
        if !window.isHidden && CallManager.shared.viewState.router.value == .banner {
                DispatchQueue.main.async {
                    self.window.frame = self.getBannerWindowFrame()
                }
            }
    }
    
    // MARK: show calling Window
    func showCallingWindow() {
        let orientationValue = UIDevice.current.orientation.rawValue
        UIDevice.current.setValue(orientationValue, forKey: "orientation")
        UIViewController.attemptRotationToDeviceOrientation()


        Permission.hasPermission(callMediaType: CallManager.shared.callState.mediaType.value, fail: nil)
        CallManager.shared.viewState.router.value = .fullView
        window.frame = currentScreenFrame
        window.rootViewController = CallKitNavigationController(rootViewController: CallMainViewController())
        window.isHidden = false
        window.backgroundColor = UIColor.black
        window.t_makeKeyAndVisible()
    }
    
    // MARK: show Floating Window
    func showFloatingWindow() {
        closeWindow()
        CallManager.shared.viewState.router.value = .floatView
        let vc = FloatWindowViewController(nibName: nil, bundle: nil)
        vc.delegate = self
        window.rootViewController = vc
        window.frame = getFloatWindowFrame()
        window.isHidden = false
        window.backgroundColor = UIColor.clear
        window.t_makeKeyAndVisible()
    }
        
    // MARK: show Incoming Banner Window
    func showIncomingBannerWindow() {
        CallManager.shared.viewState.router.value = .banner
        window.rootViewController = IncomingBannerViewController(nibName: nil, bundle: nil)
        window.isHidden = false
        window.backgroundColor = UIColor.clear
        window.frame = getBannerWindowFrame()
        window.t_makeKeyAndVisible()
    }
    
    // MARK: close windows
    func closeWindow() {
        CallManager.shared.viewState.router.value = .none
        window.rootViewController = nil
        window.isHidden = true
    }
    
    func hideFloatingWindow() {
        window.isHidden = true
        CallManager.shared.viewState.router.value = .fullView
        
        let orientationValue = WindowUtils.isPortrait ?
            UIInterfaceOrientation.portrait.rawValue :
            UIInterfaceOrientation.landscapeRight.rawValue
        
        UIDevice.current.setValue(orientationValue, forKey: "orientation")
        UIViewController.attemptRotationToDeviceOrientation()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.showCallingWindow()
        }
    }
    
    // MARK: GestureViewDelegate
    func tapGestureAction(tapGesture: UITapGestureRecognizer) {
        guard FrameworkConstants.framework == FrameworkConstants.callFrameworkNative else { return }
        hideFloatingWindow()
    }
    
    func panGestureAction(panGesture: UIPanGestureRecognizer) {
        switch panGesture.state {
        case .began:
            floatWindowBeganPoint = window.frame.origin
            
        case .changed:
            let point = panGesture.translation(in: window)
            var dstX = floatWindowBeganPoint.x + point.x
            var dstY = floatWindowBeganPoint.y + point.y
            window.frame = CGRect(x: max(0, min(dstX, currentScreenWidth - window.frame.width)),
                                 y: max(0, min(dstY, currentScreenHeight - window.frame.height)),
                                 width: window.frame.width,
                                 height: window.frame.height)
            
        case .ended, .cancelled:
            var dstX: CGFloat = window.frame.midX < (screenWidth / 2) ? 0 : (screenWidth - window.frame.width)
            UIView.animate(withDuration: 0.3) {
                self.window.frame.origin.x = dstX
            }
            
        default: break
        }
    }
    
    // MARK: Private
    func getFloatWindowFrame() -> CGRect {
        var xOffset = currentScreenWidth - kMicroAudioViewWidth
        let yOffset = 150.scale375Height()
        let rect: CGRect

        if CallManager.shared.viewState.callingViewType.value == .multi {
            rect = CGRect(x: xOffset, y: yOffset, width: kMicroGroupViewWidth, height: kMicroGroupViewHeight)
        } else if CallManager.shared.callState.mediaType.value == .audio {
            rect = CGRect(x: xOffset, y: yOffset, width: kMicroAudioViewWidth, height: kMicroAudioViewHeight)
        } else {
            xOffset = currentScreenWidth - kMicroVideoViewWidth
            rect = CGRect(x: xOffset, y: yOffset, width: kMicroVideoViewWidth, height: kMicroVideoViewHeight)
        }
        return rect
    }
    
    func getBannerWindowFrame() -> CGRect {
        return CGRect(x: 8.scale375Width(), y: StatusBar_Height + 10,
                      width: currentScreenWidth - 16.scale375Width(), height: 92.scale375Width())
    }
}
