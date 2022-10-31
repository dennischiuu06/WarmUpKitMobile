//
//  InfoViewController.swift
//  WarmUpKitMobile
//
//  Created by dennis.k.chiu on 8/10/2022.
//

import UIKit

class BodyScannerViewController: UIViewController {

    class func create() -> BodyScannerViewController? {
        let storyboard = UIStoryboard(name: "BodyScannerViewController", bundle: nil)
        guard let viewController = storyboard.instantiateViewController(withIdentifier: "BodyScannerViewController") as? BodyScannerViewController else { return nil }
        return viewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationTitle(title: "Body Scanner Page")
        setUpBackButton()

        // Do any additional setup after loading the view.
    }

}
