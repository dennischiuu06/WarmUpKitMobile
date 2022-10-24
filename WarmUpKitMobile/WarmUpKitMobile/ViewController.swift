//
//  ViewController.swift
//  WarmUpKitMobile
//
//  Created by dennis.k.chiu on 3/10/2022.
//

import UIKit
import HealthKit

class TabBarPageViewController: UITabBarController {
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMiddleButton()
    }

    func setupMiddleButton() {
        let tabBarAppearance = UITabBarAppearance()
        let tabBarItemAppearance = UITabBarItemAppearance()

        tabBarItemAppearance.normal.titleTextAttributes = [NSAttributedString.Key.foregroundColor: ColorCode.grey()]

        tabBarAppearance.stackedLayoutAppearance = tabBarItemAppearance

        tabBar.tintColor = .label
        tabBar.barTintColor = .systemGray
        tabBar.backgroundColor = ColorCode.lightSlate()
        self.selectedIndex = 0

        tabBar.standardAppearance = tabBarAppearance
        tabBar.scrollEdgeAppearance = tabBarAppearance
        
        var filled = UIButton.Configuration.filled()
        filled.buttonSize = .large
        filled.image = UIImage(named: "bodyScan")
        filled.imagePlacement = .trailing
        filled.imagePadding = 2
        filled.baseBackgroundColor = ColorCode.separatorLightBlue()

        let customButton = UIButton(configuration: filled, primaryAction: nil)
        customButton.setBackgroundImage(UIImage(named: "bodyScan"), for: .normal)
        customButton.imageView?.contentMode = .scaleAspectFit
        customButton.frame = CGRect(x: (self.view.bounds.width / 2) - 25, y: -20, width: 50, height: 50)
        customButton.layer.cornerRadius = 0.5 * customButton.bounds.size.width
        customButton.clipsToBounds = true
        customButton.tintColor = .red
        customButton.layer.shadowColor = ColorCode.darkGrey().cgColor
        customButton.layer.shadowOffset = CGSize(width: 4, height: 4)

        self.tabBar.addSubview(customButton)
        
        customButton.addTarget(self, action: #selector(customButtonAction), for: .touchUpInside)
        self.view.layoutIfNeeded()
    }
    
    @objc func customButtonAction(sender: UIButton) {
        self.selectedIndex = 0
    }
    
}
