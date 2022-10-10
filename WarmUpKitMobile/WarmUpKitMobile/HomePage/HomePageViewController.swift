//
//  HomePageViewController.swift
//  WarmUpKitMobile
//
//  Created by dennis.k.chiu on 8/10/2022.
//

import Foundation
import UIKit

class HomePageViewController: UIViewController {
    
    @IBOutlet weak var HealthRecordButton: UIButton!
    @IBOutlet weak var heartRateLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        self.title = "Home Page"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(false)
    }
    
    @IBAction func buttonAction(_ sender: Any) {
        guard let viewController = HealthRecordViewController.create() else { return }
        viewController.modalPresentationStyle = .fullScreen
        if let nc = self.navigationController {
            nc.pushViewController(viewController, animated: true)
        } else {
            self.present(viewController, animated: true) {}
        }
    }
}
