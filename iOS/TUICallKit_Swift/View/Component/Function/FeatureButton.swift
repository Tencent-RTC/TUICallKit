//
//  FeatureButton.swift
//  Pods
//
//  Created by vincepzhang on 2025/2/8.
//

import Foundation
import UIKit
import SnapKit

typealias FeatureButtonActionCallback = (_ sender: UIButton) -> Void

class FeatureButton: UIView {
    private var buttonActionCallback: FeatureButtonActionCallback?
    private var imageSize: CGSize
    
    let titleLabel: UILabel = {
        let titleLabel = UILabel(frame: CGRect.zero)
        titleLabel.font = UIFont.systemFont(ofSize: 12.0)
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 2
        titleLabel.lineBreakMode = .byTruncatingTail
        return titleLabel
    }()
    
    let button: UIButton = {
        let button = UIButton(type: .system)
        return button
    }()
        
    private init(frame: CGRect, imageSize: CGSize) {
        self.imageSize = imageSize
        super.init(frame: frame)
        backgroundColor = UIColor.clear
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: UI Specification Processing
    private var isViewReady: Bool = false
    override func didMoveToWindow() {
        super.didMoveToWindow()
        if isViewReady { return }
        isViewReady = true
        constructViewHierarchy()
        activateConstraints()
        bindInteraction()
    }
    
    private func constructViewHierarchy() {
        addSubview(button)
        addSubview(titleLabel)
    }
    
    private func activateConstraints() {
        button.snp.makeConstraints { make in
            make.top.equalTo(self)
            make.centerX.equalTo(self)
            make.size.equalTo(imageSize)
        }
        titleLabel.snp.makeConstraints { make in
            make.centerX.equalTo(self)
            make.top.equalTo(button.snp.bottom).offset(10)
            make.width.equalTo(100.scale375Width())
        }
    }
    
    private func bindInteraction() {
        button.addTarget(self, action: #selector(buttonActionEvent(sender: )), for: .touchUpInside)
    }
    
    // MARK: Event Action
    @objc func buttonActionEvent(sender: UIButton) {
        guard let buttonActionCallback = buttonActionCallback else { return }
        buttonActionCallback(sender)
    }
    
    // MARK: Public Interface
    static func create(title: String?, titleColor: UIColor?, image: UIImage?, imageSize: CGSize, buttonAction: @escaping FeatureButtonActionCallback) -> FeatureButton {
        let controlButton = FeatureButton(frame: CGRect.zero, imageSize: imageSize)
        controlButton.titleLabel.text = title
        controlButton.titleLabel.textColor = titleColor
        controlButton.button.setBackgroundImage(image, for: .normal)
        controlButton.buttonActionCallback = buttonAction
        return controlButton
    }

    func updateImage(image: UIImage) {
        button.setBackgroundImage(image, for: .normal)
    }
    
    func updateTitle(title: String) {
        titleLabel.text = title
    }
    
    func updateTitleColor(titleColor: UIColor) {
        titleLabel.textColor = titleColor
    }
}
