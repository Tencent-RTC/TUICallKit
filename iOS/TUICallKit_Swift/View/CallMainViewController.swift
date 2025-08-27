//
//  CallKitViewController.swift
//  TUICallKit
//
//  Created by vincepzhang on 2022/12/30.
//

import Foundation
import UIKit
import TUICore

class CallMainViewController: UIViewController {
        
    let mainView = CallMainView(frame: .zero)
    private let screenObserver = Observer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(mainView)
        mainView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            mainView.topAnchor.constraint(equalTo: view.topAnchor),
            mainView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mainView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mainView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        updateInitialOrientation()
    }
    
    private func updateInitialOrientation() {
        if UIDevice.current.userInterfaceIdiom == .pad {
            switch CallManager.shared.globalState.orientation {
            case .portrait:
                forceOrientation(false)
            case .landscape:
                forceOrientation(true)
            case .auto:
                break
            }
        }
    }
    
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        coordinator.animate(alongsideTransition: { _ in
            self.mainView.updateConstraints()
        }, completion: nil)
    }

    private func forceOrientation(_ isLandscape: Bool) {
        let orientationMask: UIInterfaceOrientationMask = isLandscape ? .landscapeRight : .portrait
        let orientation: UIDeviceOrientation = isLandscape ? .landscapeRight : .portrait
        if #available(iOS 16.0, *) {
            guard let scene = view.window?.windowScene else { return }
            let preferences = UIWindowScene.GeometryPreferences.iOS(interfaceOrientations: orientationMask)
            scene.requestGeometryUpdate(preferences) { error in
                debugPrint("forceOrientation: \(error.localizedDescription)")
            }
        } else {
            let value = isLandscape ? UIInterfaceOrientation.landscapeRight.rawValue : UIInterfaceOrientation.portrait.rawValue
            UIDevice.current.setValue(value, forKey: "orientation")
            UIViewController.attemptRotationToDeviceOrientation()
        }
    }
}

class CallKitNavigationController: UINavigationController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setNavigationBarHidden(true, animated: false)
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .pad {
            if CallManager.shared.globalState.orientation == .auto {
                return .all
            } else if CallManager.shared.globalState.orientation == .landscape {
                return .landscape
            }
        } else {
            return .portrait
        }
        return .portrait
    }
    
    override var shouldAutorotate: Bool {
        if UIDevice.current.userInterfaceIdiom == .pad && CallManager.shared.globalState.orientation == .auto {
            return true
        } else {
            return false
        }
    }
}
