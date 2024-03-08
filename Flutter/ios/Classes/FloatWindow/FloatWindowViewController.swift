//
//  FloatWindowViewController.swift
//  HydraAsync
//
//  Created by vincepzhang on 2023/6/27.
//

import Foundation
import TUICore
import SnapKit
import TUICallEngine

protocol FloatWindowViewDelegate: NSObject {
    func tapGestureAction(tapGesture: UITapGestureRecognizer)
    func panGestureAction(panGesture: UIPanGestureRecognizer)
}

class FloatWindowView: UIView {
    weak var delegate: FloatWindowViewDelegate?
}

class FloatWindowViewController: UIViewController, FloatWindowViewDelegate {
    
    weak var delegate: FloatWindowViewDelegate?

    lazy var floatView: FloatWindowView = {
        let view = TUICallState.instance.scene.value == TUICallScene.single ?
        SingleCallFloatWindowView(frame: CGRect.zero) : GroupCallFloatWindowView(frame: CGRect.zero)
        view.delegate = self
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(floatView)
        floatView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    //MARK: FloatingWindowViewDelegate
    func tapGestureAction(tapGesture: UITapGestureRecognizer) {
        if self.delegate != nil && ((self.delegate?.responds(to: Selector(("tapGestureAction")))) != nil) {
            self.delegate?.tapGestureAction(tapGesture: tapGesture)
        }
    }
    
    func panGestureAction(panGesture: UIPanGestureRecognizer) {
        if self.delegate != nil && ((self.delegate?.responds(to: Selector(("panGestureAction")))) != nil) {
            self.delegate?.panGestureAction(panGesture: panGesture)
        }
    }
}
