//
//  UIView+roundrect.swift
//  TRTCScene
//
//  Created by adams on 2021/4/8.
//

import Foundation

public extension UIView {
    /// 切部分圆角
    ///
    /// - Parameters:
    ///   - rect: 传入View的Rect
    ///   - byRoundingCorners: 裁剪位置
    ///   - cornerRadii: 裁剪半径
    func roundedRect(rect:CGRect, byRoundingCorners: UIRectCorner, cornerRadii: CGSize) {
        let maskPath = UIBezierPath.init(roundedRect: rect, byRoundingCorners: byRoundingCorners, cornerRadii: cornerRadii)
        let maskLayer = CAShapeLayer.init()
        maskLayer.frame = bounds
        maskLayer.path = maskPath.cgPath
        self.layer.mask = maskLayer
    }
    
    /// 切圆角
    ///
    /// - Parameter rect: 传入view的Rect
    func roundedCircle(rect: CGRect) {
        roundedRect(rect: rect, byRoundingCorners: .allCorners, cornerRadii: CGSize(width: bounds.size.width / 2, height: bounds.size.height / 2))
    }
}
