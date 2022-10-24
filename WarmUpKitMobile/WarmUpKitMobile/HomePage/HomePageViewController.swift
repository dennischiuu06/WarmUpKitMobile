//
//  HomePageViewController.swift
//  WarmUpKitMobile
//
//  Created by dennis.k.chiu on 8/10/2022.
//

import Foundation
import UIKit
import Charts
import HealthKit

class HomePageViewController: UIViewController {
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var summaryStackView: UIStackView!
    @IBOutlet weak var barChartView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    let healthKitManager = HealthKitManager.shared
    
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
    
    
    let barChart = Charts.BarChartView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        healthKitManager.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(false)
        healthKitManager.authorizeHealthKitAccess { (success, error) in
            self.healthKitManager.getActiveEnergy()
        }
        
        healthKitManager.getActiveEnergy()
        healthKitManager.getHealthKitStepsInfo()
    }
    
    func setupUI() {
        contentView.backgroundColor = ColorCode.backgroundGrey()
        scrollView.backgroundColor = ColorCode.backgroundGrey()

        scrollView.frame = view.bounds
        print(view.bounds)
        print(UIScreen.main.bounds.width)
        scrollView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        setupNavigationTitle(title: "Home Page")
        summaryStackView.addArrangedSubview(mainBoard)
        summaryStackView.addArrangedSubview(summaryBoard)
        summaryStackView.addArrangedSubview(secondSummaryBoard)
        
        // Bar Chart view
        barChart.frame = CGRect(x: 0, y: 0, width: barChartView.bounds.width - 32 , height: barChartView.bounds.height - 32)
        barChart.noDataText = "You need to provide data for the chart."
        barChartView.addSubview(barChart)
        
        barChart.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
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

extension HomePageViewController: WorkoutTrackingDelegate {
    func didReceiveHealthKitStepCounts(stepCounts: Double, avgSteps: Double, stepsData: [Double]) {
        DispatchQueue.main.async {
            self.summaryBoard.importData(iconKey: "walk_icon", title: "Steps", firstTitle: "Steps", firstContent: String(stepCounts), secondTitle: "Average Steps", secondContent: String(format: "%.2f", avgSteps))
            
            var dataEntries = [BarChartDataEntry]()
            
            for (index, data) in stepsData.enumerated() {
                let x = index + 1
                let barEntry = BarChartDataEntry(x: (Double(x)), y: data)
                dataEntries.append(barEntry)
            }
            
            let chartDataSet = BarChartDataSet(entries: dataEntries, label: "Steps")
            chartDataSet.colors = ChartColorTemplates.colorful()
            chartDataSet.notifyDataSetChanged()
            let chartData = BarChartData(dataSet: chartDataSet)
            chartData.barWidth = 0.5
            self.barChart.data = chartData
            self.barChart.notifyDataSetChanged()
//            self.barChart.xAxis.labelPosition = .bottom
            self.barChart.animate(xAxisDuration: 1.0, yAxisDuration: 1.0)
            //            chartDataSet.drawValuesEnabled = false
            //            chartData.notifyDataChanged()

        }
    }
    
    func didReceiveHealthKitEnergy(_ energy: Double) {
        DispatchQueue.main.async {
            self.secondSummaryBoard.importData(iconKey: "energy_icon", title: "Active Energy", firstTitle: "Active Energy", firstContent: String(energy), secondTitle: "Average Kilocalories", secondContent: String(format: "%.2f", energy))
        }
    }
}
