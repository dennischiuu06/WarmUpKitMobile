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
        tabBar.tintColor = .label
        tabBar.barTintColor = .systemGray
        tabBar.backgroundColor = ColorCode.lightSlate()
        self.selectedIndex = 1
        setupMiddleButton()
        setupUI()
    }
    
    func setupUI() {
        if let tabBarItems = tabBar.items {
            for tabBarItem in tabBarItems {
                print(tabBarItem.title)
            }
        }
    }
    func setupMiddleButton() {
        let custoButton = UIButton(frame: CGRect(x: (self.view.bounds.width / 2) - 25, y: -20, width: 60, height: 60 ))
        
        custoButton.setBackgroundImage(UIImage(named: "Icon-40"), for: .normal)
        custoButton.layer.shadowColor = UIColor.black.cgColor
        custoButton.layer.shadowOpacity = 0.1
        custoButton.layer.shadowOffset = CGSize(width: 4, height: 4)
        
        self.tabBar.addSubview(custoButton)
        
        custoButton.addTarget(self, action: #selector(customButtonAction), for: .touchUpInside)
        self.view.layoutIfNeeded()
    }
    
    @objc func customButtonAction(sender: UIButton) {
        print("home")
        self.selectedIndex = 1
    }
    
}
