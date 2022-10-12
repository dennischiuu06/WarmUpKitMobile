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
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var summaryStackView: UIStackView!
    
    
    lazy var mainBoard: MainCardView = {
        let view = MainCardView()
        return view
    }()
    
    lazy var summaryBoard: StepSummaryView = {
        let view = StepSummaryView()
        return view
    }()
    
    lazy var secondSummaryBoard: StepSummaryView = {
        let view = StepSummaryView()
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        contentView.backgroundColor = ColorCode.backgroundGrey()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(false)
    }
    
    func setupUI() {
        setupNavigationTitle(title: "Home Page")
        summaryStackView.axis = .vertical
        summaryStackView.distribution = .fill
        summaryStackView.spacing = 16
        summaryStackView.layoutMargins = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        summaryStackView.isLayoutMarginsRelativeArrangement = true
        summaryBoard.importData(iconKey: "walk_icon", title: "Steps", firstTitle: "Steps", firstContent: "ff", secondTitle: "Average Steps", secondContent: "frfr")

        secondSummaryBoard.importData(iconKey: "energy_icon", title: "Active Energy", firstTitle: "Active Energy", firstContent: "Active Energy", secondTitle: "Average Kilocalories", secondContent: "frfr")

        summaryStackView.addArrangedSubview(mainBoard)
        summaryStackView.addArrangedSubview(summaryBoard)
        summaryStackView.addArrangedSubview(secondSummaryBoard)
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
