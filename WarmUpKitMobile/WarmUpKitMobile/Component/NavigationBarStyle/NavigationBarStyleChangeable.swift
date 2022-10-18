//
//  NavigationBarStyleChangeable.swift
//  WarmUpKitMobile
//
//  Created by dennis.k.chiu on 12/10/2022.
//

import UIKit

protocol NavigationBarStyleChangeable {
    var preferredTextAttributes: [NSAttributedString.Key: AnyObject] { get }
    var preferredBarTintColor: UIColor { get }
    var preferredTintColor: UIColor { get }
}

extension NavigationBarStyleChangeable {
    var preferredTextAttributes: [NSAttributedString.Key: AnyObject] {
        return  [.font: UIFont.systemFont(ofSize: 16),
                 .foregroundColor: ColorCode.backgroundGrey()]
    }

    var preferredBarTintColor: UIColor {
        return ColorCode.backgroundGrey()
    }

    var preferredTintColor: UIColor {
        return ColorCode.backgroundGrey()
    }
}

protocol NavigationBarStyleChangeableLightGrey: NavigationBarStyleChangeable, ViewControllerWithCustomStatusBarStyle {}

extension NavigationBarStyleChangeableLightGrey {
    var preferredTextAttributes: [NSAttributedString.Key: AnyObject] {
        return  [.font: UIFont.systemFont(ofSize: 16),
                 .foregroundColor: ColorCode.backgroundGrey()]
    }

    var preferredBarTintColor: UIColor {
        return ColorCode.backgroundGrey()
    }

    var preferredTintColor: UIColor {
        return ColorCode.backgroundGrey()
    }
    
    var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
}
