//
//  FloatWindowViewController.swift
//  HydraAsync
//
//  Created by vincepzhang on 2023/6/27.
//

import Foundation
import TUICore
import SnapKit

class FloatWindowViewController: UIViewController, FloatingWindowViewDelegate {
    
    weak var delegate: FloatingWindowViewDelegate?

    lazy var floatView = {
        let view =  FloatWindowView(frame: CGRectZero)
        view.delegate = self
        return view
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(floatView)
        floatView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalToSuperview()
        }
    }
    
    deinit {

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
