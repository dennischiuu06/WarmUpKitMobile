//
//  NavigationController.swift
//  WarmUpKitMobile
//
//  Created by dennis.k.chiu on 12/10/2022.
//

import Foundation
import UIKit

class NavigationController: UINavigationController {
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        print("NavigationController")
        // FIXME: Create a flag here, now dev doesn't contian ui alignment codes
        
        UINavigationBar.appearance().tintColor = ColorCode.backgroundGrey()
        
        updateBackButtonImageWithOffsetMargin()
        
        let offset = UIOffset(horizontal: -10, vertical: -5)
        let barTintColor = ColorCode.newGreyBackground()
        let titleTextAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16),
                                   NSAttributedString.Key.foregroundColor: ColorCode.backgroundGrey()]
         
        UIBarButtonItem.appearance().setBackButtonTitlePositionAdjustment(offset, for:.default)
        UINavigationBar.appearance().isTranslucent = false
        UINavigationBar.appearance().barTintColor = barTintColor
        UINavigationBar.appearance().titleTextAttributes = titleTextAttributes
        
        if #available(iOS 15.0, *) {
            setNavigationBarStylingForIOS15(barTintColor,titleTextAttributes)
        }

    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if let viewController = topViewController as? ViewControllerWithCustomStatusBarStyle {
            return viewController.preferredStatusBarStyle
        }
        return .default
    }
    
    // MARK: - NavigationBar Styles
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        super.pushViewController(viewController, animated: animated)
        
        if let navigationBarStyleChangeable = topViewController as? NavigationBarStyleChangeable {
            navigationBar.titleTextAttributes = navigationBarStyleChangeable.preferredTextAttributes
            navigationBar.tintColor = navigationBarStyleChangeable.preferredTintColor
            navigationBar.barTintColor = navigationBarStyleChangeable.preferredBarTintColor
        } else {
            navigationBar.titleTextAttributes = preferredTextAttributes
            navigationBar.tintColor = preferredTintColor
            navigationBar.barTintColor = preferredBarTintColor
        }
    }
    
    override func popViewController(animated: Bool) -> UIViewController? {
        let popViewController = super.popViewController(animated: animated)
        updateNavigationBarStyles()
        
        return popViewController
    }
    
    override func popToViewController(_ viewController: UIViewController, animated: Bool) -> [UIViewController]? {
        let viewControllers = super.popToViewController(viewController, animated: animated)
        
        if animated {
            transitionCoordinator?.animate(alongsideTransition: nil) { [weak self] _ in
                self?.updateNavigationBarStyles()
            }
        } else {
            updateNavigationBarStyles()
        }
        
        return viewControllers
    }
    
    override func popToRootViewController(animated: Bool) -> [UIViewController]? {
        let viewControllers = super.popToRootViewController(animated: animated)
        
        if animated {
            transitionCoordinator?.animate(alongsideTransition: nil) { [weak self] _ in
                self?.updateNavigationBarStyles()
            }
        } else {
            updateNavigationBarStyles()
        }
        
        return viewControllers
    }
    
    fileprivate func updateNavigationBarStyles() {
        if let navigationBarStyleChangeable = topViewController as? NavigationBarStyleChangeable {
            navigationBar.titleTextAttributes = navigationBarStyleChangeable.preferredTextAttributes
            navigationBar.tintColor = navigationBarStyleChangeable.preferredTintColor
            navigationBar.barTintColor = navigationBarStyleChangeable.preferredBarTintColor
            if #available(iOS 15.0, *) {
                setNavigationBarStylingForIOS15(preferredBarTintColor, preferredTextAttributes)
            }
        } else {
            navigationBar.titleTextAttributes = preferredTextAttributes
            navigationBar.tintColor = preferredTintColor
            navigationBar.barTintColor = preferredBarTintColor
            if #available(iOS 15.0, *) {
                setNavigationBarStylingForIOS15(preferredBarTintColor,preferredTextAttributes)
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateBackButtonImageWithOffsetMargin()
        fixBarButtonItemMargin(viewController: viewControllers.last)
    }
    
    private func fixBarButtonItemMargin(viewController: UIViewController?) {
        // automatically adjust custom back button inset
        // (currently applies to unadjusted, new guidelines aligned items with 24pt width)
        let margins = view.directionalLayoutMargins
        if let leftCustomViewButton = viewController?.navigationItem.leftBarButtonItem?.customView as? UIButton,
            leftCustomViewButton.bounds.width == 24.0,
            margins.leading > 16.0 {
            var insets = leftCustomViewButton.contentEdgeInsets
            if insets.left == 0, insets.right == 0 {
                insets.left = 16.0 - margins.leading
                insets.right = -insets.left
                leftCustomViewButton.contentEdgeInsets = insets
            }
        }
    }
    
    private func updateBackButtonImageWithOffsetMargin() {
        let leadingMargin = view.directionalLayoutMargins.leading
        var backButtonImage: UIImage?
        if #available(iOS 13.0, *) {
            let offsetX: CGFloat = leadingMargin > 0 ? 24 - leadingMargin : 0
            let offsetY: CGFloat = 3
            backButtonImage = UIImage(named: "iconArrowLeft")?.withAlignmentRectInsets(UIEdgeInsets(top: offsetY, left: -offsetX, bottom: -offsetY, right: offsetX))
        } else {
            let offsetX: CGFloat = leadingMargin > 0 ? 24 - leadingMargin : 8
            backButtonImage = UIImage(named: "iconArrowLeft")?.withInsets(UIEdgeInsets(top: 2, left: offsetX, bottom: 3, right: offsetX))
        }
        UINavigationBar.appearance().backIndicatorImage = backButtonImage
        UINavigationBar.appearance().backIndicatorTransitionMaskImage = backButtonImage
        navigationBar.backIndicatorImage = backButtonImage
        navigationBar.backIndicatorTransitionMaskImage = backButtonImage
        
    }
    
    //Fix nav bar styling not working in iOS 15
    private func setNavigationBarStylingForIOS15(_ barTintColor: UIColor ,_ titleTextAttributes: [NSAttributedString.Key : Any]){
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = barTintColor
        appearance.titleTextAttributes = titleTextAttributes
        navigationBar.standardAppearance = appearance
        navigationBar.scrollEdgeAppearance = navigationBar.standardAppearance
        
    }
}

protocol ViewControllerWithCustomStatusBarStyle {
    var preferredStatusBarStyle: UIStatusBarStyle { get }
}
extension NavigationController: NavigationBarStyleChangeable {}


public extension UIImage {
    func withInsets(_ insets: UIEdgeInsets) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(
            CGSize(width: self.size.width + insets.left + insets.right,
                   height: self.size.height + insets.top + insets.bottom), false, self.scale
        )
        _ = UIGraphicsGetCurrentContext()
        let origin = CGPoint(x: insets.left, y: insets.top)
        self.draw(at: origin)
        let imageWithInsets = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return imageWithInsets
    }
}
