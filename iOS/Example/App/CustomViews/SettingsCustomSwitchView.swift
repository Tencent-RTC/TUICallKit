//
//  SettingsCustomSwitchView.swift
//  TUICallKitApp
//
//  Created by noah on 2024/8/20.
//

import UIKit

class SettingsCustomSwitchView: UIView  {
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .black
        return label
    }()
    
    private let switchControl: UISwitch = {
        let switchControl = UISwitch()
        return switchControl
    }()
    
    var switchValueChanged: ((Bool) -> Void)?
    
    init(title: String, isOn: Bool) {
        super.init(frame: .zero)
        backgroundColor = .white
        titleLabel.text = title
        switchControl.isOn = isOn
        switchControl.addTarget(self, action: #selector(switchChanged), for: .valueChanged)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var isViewReady: Bool = false
    override func didMoveToWindow() {
        super.didMoveToWindow()
        if isViewReady { return }
        constructViewHierarchy()
        activateConstraints()
        isViewReady = true
    }
    
    func constructViewHierarchy() {
        addSubview(titleLabel)
        addSubview(switchControl)
    }
    
    func activateConstraints() {
        titleLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(20)
        }
        switchControl.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().offset(-20)
        }
    }
    
    @objc private func switchChanged() {
        switchValueChanged?(switchControl.isOn)
    }
}
