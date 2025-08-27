//
//  CallVideoLayout.swift
//  Pods
//
//  Created by vincepzhang on 2025/2/19.
//

import RTCCommon

public class CallVideoLayout: UIView {
    private var isViewReady = false
    private let aiSubtitle = AISubtitle(frame: .zero)
    private var singleCallingView: SingleCallVideoLayout?
    private var multiCallingView: MultiCallVideoLayout?
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        registerObserver()
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    public override func didMoveToWindow() {
        super.didMoveToWindow()
        guard !isViewReady else { return }
        isViewReady = true
        constructViewHierarchy()
        activateConstraints()
    }
    
    private func registerObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleOrientationChange),
            name: UIDevice.orientationDidChangeNotification,
            object: nil
        )
    }

    private func constructViewHierarchy() {
        if CallManager.shared.viewState.callingViewType.value == .one2one {
            singleCallingView = SingleCallVideoLayout(frame: .zero)
            if let singleCallingView = singleCallingView {
                addSubview(singleCallingView)
            }
        } else {
            multiCallingView = MultiCallVideoLayout(frame: .zero)
            if let multiCallingView = multiCallingView {
                addSubview(multiCallingView)
            }
        }

        addSubview(aiSubtitle)
    }
    
    private func activateConstraints() {
        NSLayoutConstraint.deactivate(self.constraints)
        
        aiSubtitle.translatesAutoresizingMaskIntoConstraints = false
        var constraints: [NSLayoutConstraint] = [
            aiSubtitle.centerXAnchor.constraint(equalTo: centerXAnchor),
            aiSubtitle.centerYAnchor.constraint(equalTo: centerYAnchor, constant: 120.scale375Height()),
            aiSubtitle.heightAnchor.constraint(equalToConstant: 24.scale375Width()),
            aiSubtitle.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.8)
        ]
        
        if CallManager.shared.viewState.callingViewType.value == .one2one, let singleCallingView = singleCallingView {
            singleCallingView.translatesAutoresizingMaskIntoConstraints = false
            constraints += [
                singleCallingView.topAnchor.constraint(equalTo: topAnchor),
                singleCallingView.leadingAnchor.constraint(equalTo: leadingAnchor),
                singleCallingView.trailingAnchor.constraint(equalTo: trailingAnchor),
                singleCallingView.bottomAnchor.constraint(equalTo: bottomAnchor)
            ]
        } else if let multiCallingView = multiCallingView {
            multiCallingView.translatesAutoresizingMaskIntoConstraints = false
            constraints += [
                multiCallingView.topAnchor.constraint(equalTo: topAnchor),
                multiCallingView.leadingAnchor.constraint(equalTo: leadingAnchor),
                multiCallingView.trailingAnchor.constraint(equalTo: trailingAnchor),
                multiCallingView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -groupSmallFunctionViewHeight - 10.scale375Height())
            ]
        }
        
        NSLayoutConstraint.activate(constraints)
    }
    
    // MARK: - Orientation Handling
    @objc private func handleOrientationChange() {
        guard UIDevice.current.orientation.isValidInterfaceOrientation else { return }
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            if CallManager.shared.viewState.callingViewType.value == .multi {
                UIView.animate(withDuration: 0.3) {
                    self.activateConstraints()
                    self.layoutIfNeeded()
                }
            }
        }
    }
}
