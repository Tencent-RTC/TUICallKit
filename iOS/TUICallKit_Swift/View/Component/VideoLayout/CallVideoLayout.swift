//
//  CallVideoLayout.swift
//  Pods
//
//  Created by vincepzhang on 2025/2/19.
//

import SnapKit

class CallVideoLayout: UIView {
    private var isViewReady = false
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        if isViewReady { return }
        isViewReady = true

        if CallManager.shared.viewState.callingViewType.value == .one2one {
            addSingleCallingView()
        } else if CallManager.shared.viewState.callingViewType.value == .multi {
            addMultiCallingView()
        }
    }
    
    private func addSingleCallingView() {
        cleanView()
        let singleCallingView = SingleCallVideoLayout(frame: .zero)
        addSubview(singleCallingView)
        singleCallingView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func addMultiCallingView() {
        cleanView()
        let singleCallingView = MultiCallVideoLayout(frame: .zero)
        addSubview(singleCallingView)
        singleCallingView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func cleanView() {
        for view in subviews {
            view.removeFromSuperview()
        }
    }
}
