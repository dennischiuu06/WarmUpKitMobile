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
//        getHealthKitStepsInfo()
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
//        getHealthKitStepsInfo()
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

extension HomePageViewController {
//    func getHealthKitStepsInfo() {
//        guard HKHealthStore.isHealthDataAvailable() else {
//            return
//        }
//
//        let startOfMonth = healthKitManager.getStartDay()
//        let endOfMonth = healthKitManager.getEndDay(startOfMonth: startOfMonth)
//        let dayInt = healthKitManager.getDayInt(endOfMonth: endOfMonth)
//        print("startOfMonth", startOfMonth)
//        print("endOfMonth", endOfMonth)
//        print("dayInt", dayInt)
//
//        guard let stepCountType = HKObjectType.quantityType(forIdentifier: .stepCount) else {
//            fatalError("*** Unable to get the step count type ***")
//        }
//
//        var interval = DateComponents()
//        interval.day = 1
//
//        let calendar = Calendar.current
//        //        let anchorDate = calendar.date(bySettingHour: 12, minute: 0, second: 0, of: self.date)
//        let anchorDate = calendar.date(bySetting: .day, value: 1, of: healthKitManager.date)
//
//        let query = HKStatisticsCollectionQuery.init(quantityType: stepCountType,
//                                                     quantitySamplePredicate: nil,
//                                                     options: .cumulativeSum,
//                                                     anchorDate: anchorDate!,
//                                                     intervalComponents: interval)
//
//        query.initialResultsHandler = {
//            query, results, error in
//
//            guard let statsCollection = results else {
//                // Perform proper error handling here
//                return
//            }
//            var dataEntries = [BarChartDataEntry]()
//
//            var thisDay = startOfMonth
//            var totalSteps = 0.0
//            for x in 1...10 {
//                print(x)
//                let barEntry = BarChartDataEntry(x: (Double(x)), y: 5)
//                dataEntries.append(barEntry)
//
//                let nextDay: Date = calendar.date(byAdding: .day, value: 1, to: thisDay)!
//                // Plot the weekly step counts over the past 3 months
//                statsCollection.enumerateStatistics(from: thisDay, to: thisDay) { statistics, stop in
//
//                    if let quantity = statistics.sumQuantity() {
//                        let _ = statistics.startDate
//                        let value = quantity.doubleValue(for: HKUnit.count())
//
////                        let barEntry = BarChartDataEntry(x: (Double(i)), y: value)
////                        dataEntries.append(barEntry)
//                        totalSteps += value
//                        // Call a custom method to plot each data point.String(describing: )
//
//                    }
//                }
//                thisDay = nextDay
//            }
//
//
//            DispatchQueue.main.async {
//                self.summaryBoard.importData(iconKey: "walk_icon", title: "Steps", firstTitle: "Steps", firstContent: String(totalSteps), secondTitle: "Average Steps", secondContent: String(totalSteps / Double(dayInt)))
//            }
//            print(dataEntries.count)
//            let chartDataSet = BarChartDataSet(entries: dataEntries, label: "Steps")
//            chartDataSet.colors = ChartColorTemplates.colorful()
////            chartDataSet.drawValuesEnabled = false
//            chartDataSet.notifyDataSetChanged()
//            let chartData = BarChartData(dataSet: chartDataSet)
//            chartData.barWidth = 0.5
////            chartData.notifyDataChanged()
//            self.barChart.data = chartData
//            self.barChart.notifyDataSetChanged()
////            self.barChart.xAxis.labelPosition = .bottom
//            self.barChart.animate(xAxisDuration: 1.0, yAxisDuration: 1.0)
//        }
//        healthKitManager.healthStore.execute(query)
//    }
    
//    func getHealthEnergyInfo() {
//        guard let energyType = HKSampleType.quantityType(forIdentifier: .activeEnergyBurned) else {
//            print("Energy Burned type not available")
//            return
//        }
//
//        let startOfMonth = healthKitManager.getStartDay()
//        let endOfMonth = healthKitManager.getEndDay(startOfMonth: startOfMonth)
//        let predicate = HKQuery.predicateForSamples(withStart: startOfMonth, end: endOfMonth, options: .strictStartDate)
//
//        let energyQuery = HKSampleQuery(sampleType: energyType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) {(query, sample, error) in
//            guard error == nil,let quantitySamples = sample as? [HKQuantitySample] else {
//                print("Something went wrong: \(String(describing: error))")
//                return
//            }
//
//            let total = quantitySamples.reduce(0.0) { $0 + $1.quantity.doubleValue(for: HKUnit.kilocalorie()) }
//
//            DispatchQueue.main.async {
//                self.secondSummaryBoard.importData(iconKey: "energy_icon", title: "Active Energy", firstTitle: "Active Energy", firstContent: String(total), secondTitle: "Average Kilocalories", secondContent: String(format: "%.2f", total))
//            }
//        }
//        HKHealthStore().execute(energyQuery)
//    }
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
