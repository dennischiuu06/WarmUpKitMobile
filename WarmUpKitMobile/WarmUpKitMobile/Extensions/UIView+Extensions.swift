//
//  UIView.swift
//  WarmUpKitMobile
//
//  Created by dennis.k.chiu on 10/10/2022.
//

import Foundation
import UIKit

public extension UIView {
    func setShadow(color: UIColor = UIColor.black, opacity: Float = 0.3, radius: CGFloat = 7, offset: CGFloat = 0) {
        // can change it more flexiable later. e.g customize the color or width, etc.
        layer.shadowOffset = CGSize(width: offset, height: offset)
        layer.shadowRadius = radius
        layer.shadowOpacity = opacity
        layer.shadowColor = color.cgColor
        layer.masksToBounds = false
        
    }
    
    func addGradient(layerFrame: CGRect, colors: [UIColor], locations: [NSNumber], startPoint: CGPoint = .zero, endPoint: CGPoint = .zero) {
        let gradientLayer = CAGradientLayer()
        var cgColors: [CGColor] = []
        for item in colors {
            cgColors.append(item.cgColor)
        }
        gradientLayer.colors = cgColors
        gradientLayer.locations = locations
        gradientLayer.startPoint = startPoint
        gradientLayer.endPoint = endPoint
        gradientLayer.frame = layerFrame
        layer.insertSublayer(gradientLayer, at: 0)
    }
}
