//
//  colorCode.swift
//  WarmUpKitMobile
//
//  Created by dennis.k.chiu on 8/10/2022.
//

import UIKit
public struct ColorCode {
    static fileprivate func value(_ value: CGFloat) -> CGFloat {
        return value/255
    }
}
// MARK: - Primary Color
extension ColorCode {
    /// #F1F2F2
    public static func lightSlate(alpha: CGFloat = 1) -> UIColor {
        return UIColor(red: value(241), green: value(242), blue: value(242), alpha: alpha)
    }
}
