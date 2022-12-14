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
    
    /// #F9F9F9 #colorLiteral(red: 0.9764705882, green: 0.9764705882, blue: 0.9764705882, alpha: 1)
    public static func disabled(alpha: CGFloat = 1) -> UIColor {
        return UIColor(red: value(249), green: value(249), blue: value(249), alpha: alpha)
    }
    
    static func lightGrey(alpha: CGFloat = 1) -> UIColor {
        return UIColor(red: value(235), green: value(237), blue: value(236), alpha: alpha)
    }
    
    static func backgroundGrey(alpha: CGFloat = 1) -> UIColor {
        return UIColor(red: value(248), green: value(248), blue: value(248), alpha: alpha)
    }
    
    public static func blue(alpha: CGFloat = 1) -> UIColor {
        return UIColor(red: value(0), green: value(113), blue: value(140), alpha: alpha)
    }
    /// #E6E7E8
    public static func lightState(alpha: CGFloat = 1) -> UIColor {
        return UIColor(red: value(230), green: value(231), blue: value(232), alpha: alpha)
    }
    
    // #4C4C4C #colorLiteral(red: 0.2980392157, green: 0.2980392157, blue: 0.2980392157, alpha: 1)
    static func darkGrey(alpha: CGFloat = 1) -> UIColor {
        return UIColor(red: value(76), green: value(76), blue: value(76), alpha: alpha)
    }
    
    static func separatorLightBlue(alpha: CGFloat = 1) -> UIColor {
        return UIColor(red: value(197), green: value(197), blue: value(197), alpha: alpha)
    }
    
    /// #808285
    public static func grey(alpha: CGFloat = 1) -> UIColor {
        return UIColor(red: value(128), green: value(130), blue: value(133), alpha: alpha)
    }
    
    static func newGreyBackground(alpha: CGFloat = 1) -> UIColor {
        return UIColor(red: value(248), green: value(248), blue: value(248), alpha: alpha)
    }
    
    static func linkRed(alpha: CGFloat = 1) -> UIColor {
        return UIColor(red: value(244), green: value(117), blue: value(117), alpha: alpha)
    }
    
    static func darkRedBackground(alpha: CGFloat = 1) -> UIColor {
        return UIColor(red: value(206), green: value(81), blue: value(87), alpha: alpha)
    }
    
    public static func lightBlue(alpha: CGFloat = 1) -> UIColor {
        return UIColor(red: value(206), green: value(232), blue: value(240), alpha: alpha)
    }
    /// #387E79 Primary colour: Medium Jade 1000 (Medium Jade)
    public static func mediumJade1000(alpha: CGFloat = 1) -> UIColor {
        return UIColor(red: value(56), green: value(126), blue: value(121), alpha: alpha)
    }
    
    /// #5F9793 Primary colour: Medium Jade 800 (Medium Jade +20)
    public static func mediumJade800(alpha: CGFloat = 1) -> UIColor {
        return UIColor(red: value(95), green: value(151), blue: value(147), alpha: alpha)
    }
}
