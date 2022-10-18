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
    @IBOutlet weak var HealthRecordButton: UIButton!
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
        healthKitManager.authorizeHealthKitAccess { (success, error) in
            
        }
        //        self.healthKitManager.readStep()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(false)
        //        testingInfo()
        getHealthKitStepsInfo()
        getHealthEnergyInfo()
    }
    
    func setupUI() {
        contentView.backgroundColor = ColorCode.backgroundGrey()
        scrollView.backgroundColor = ColorCode.backgroundGrey()

        scrollView.frame = view.bounds
        print(view.bounds)
        print(UIScreen.main.bounds.width)
        scrollView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        setupNavigationTitle(title: "Home Page")
        summaryStackView.axis = .vertical
        summaryStackView.distribution = .fill
        summaryStackView.spacing = 16
        summaryStackView.layoutMargins = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        summaryStackView.isLayoutMarginsRelativeArrangement = true
        
        summaryStackView.addArrangedSubview(mainBoard)
        summaryStackView.addArrangedSubview(summaryBoard)
        summaryStackView.addArrangedSubview(secondSummaryBoard)
        
        barChart.frame = CGRect(x: 0, y: 0, width: barChartView.bounds.width - 32 , height: barChartView.bounds.height - 32)
        
        barChartView.addSubview(barChart)
        
        getHealthKitStepsInfo()
        getHealthEnergyInfo()
        testingInfo()
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
    func getHealthKitStepsInfo() {
        let date = Date()
        
        func getStartDay() -> Date {
            let comp: DateComponents = Calendar.current.dateComponents([.year, .month], from: date)
            let startOfMonth = Calendar.current.date(from: comp)!
            return startOfMonth
        }
        
        func getEndDay(startOfMonth: Date) -> Date {
            var comps2 = DateComponents()
            comps2.month = 1
            comps2.day = -1
            let endOfMonth = Calendar.current.date(byAdding: comps2, to: startOfMonth)
            
            return endOfMonth!
        }
        
        func getDayInt(endOfMonth: Date) -> Int {
            let dayFormatter = DateFormatter()
            dayFormatter.dateFormat = "dd"
            let dayString = dayFormatter.string(from: endOfMonth)
            let dayInt = Int(dayString)
            return dayInt!
        }
        
        guard HKHealthStore.isHealthDataAvailable() else {
            return
        }
        
        let startOfMonth = getStartDay()
        let endOfMonth = getEndDay(startOfMonth: startOfMonth)
        let dayInt = getDayInt(endOfMonth: endOfMonth)
        print("startOfMonth", startOfMonth)
        print("endOfMonth", endOfMonth)
        print("dayInt", dayInt)
        
        guard let stepCountType = HKObjectType.quantityType(forIdentifier: .stepCount) else {
            fatalError("*** Unable to get the step count type ***")
        }
        
        var interval = DateComponents()
        interval.day = 1
        
        let calendar = Calendar.current
        //        let anchorDate = calendar.date(bySettingHour: 12, minute: 0, second: 0, of: self.date)
        let anchorDate = calendar.date(bySetting: .day, value: 1, of: date)
        
        let query = HKStatisticsCollectionQuery.init(quantityType: stepCountType,
                                                     quantitySamplePredicate: nil,
                                                     options: .cumulativeSum,
                                                     anchorDate: anchorDate!,
                                                     intervalComponents: interval)
        
        query.initialResultsHandler = {
            query, results, error in
            
            guard let statsCollection = results else {
                // Perform proper error handling here
                return
            }
            var dataEntries = [BarChartDataEntry]()
            
            var thisDay = startOfMonth
            var totalSteps = 0.0
            for i in 1...dayInt {
                let nextDay: Date = calendar.date(byAdding: .day, value: 1, to: thisDay)!
                // Plot the weekly step counts over the past 3 months
                statsCollection.enumerateStatistics(from: thisDay, to: thisDay) { statistics, stop in
                    
                    if let quantity = statistics.sumQuantity() {
                        let _ = statistics.startDate
                        let value = quantity.doubleValue(for: HKUnit.count())
                        
                        let barEntry = BarChartDataEntry(x: (Double(i)), y: value)
                        dataEntries.append(barEntry)
                        totalSteps += value
                        // Call a custom method to plot each data point.String(describing: )
                        
                    }
                }
                thisDay = nextDay
            }
            
            DispatchQueue.main.async {
                self.summaryBoard.importData(iconKey: "walk_icon", title: "Steps", firstTitle: "Steps", firstContent: String(totalSteps), secondTitle: "Average Steps", secondContent: String(totalSteps / Double(dayInt)))
            }
            
            let chartDataSet = BarChartDataSet(entries: dataEntries, label: "Steps")
            chartDataSet.drawValuesEnabled = false
            chartDataSet.notifyDataSetChanged()
            let chartData = BarChartData(dataSets: [chartDataSet])
            chartData.barWidth = 0.5
            chartData.notifyDataChanged()
            self.barChart.data = chartData
            self.barChart.notifyDataSetChanged()
            self.barChart.animate(xAxisDuration: 0.5, yAxisDuration: 0.5)
            //            print("after chartView height : \(self.chartView.bounds.height)")
            //            print("after barchartView height : \(self.barChartPlace.bounds.height)")
            //
            //            print("barchart x:\(self.barChartView.bounds.origin.x) y:\(self.barChartView.bounds.origin.y) width:\(self.barChartView.bounds.width) height:\(self.barChartView.bounds.height)")
        }
        healthKitManager.healthStore.execute(query)
    }
    
    func testingInfo() {
        let date = Date()
        
        func getStartDay() -> Date {
            let comp: DateComponents = Calendar.current.dateComponents([.year, .month], from: date)
            let startOfMonth = Calendar.current.date(from: comp)!
            return startOfMonth
        }
        
        func getEndDay(startOfMonth: Date) -> Date {
            var comps2 = DateComponents()
            comps2.month = 1
            comps2.day = -1
            let endOfMonth = Calendar.current.date(byAdding: comps2, to: startOfMonth)
            
            return endOfMonth!
        }
        
        func getDayInt(endOfMonth: Date) -> Int {
            let dayFormatter = DateFormatter()
            dayFormatter.dateFormat = "dd"
            let dayString = dayFormatter.string(from: endOfMonth)
            let dayInt = Int(dayString)
            return dayInt!
        }
        
        guard let energyType = HKSampleType.quantityType(forIdentifier: .activeEnergyBurned) else {
            print("Sample type not available")
            return
        }
        
        let startOfMonth = getStartDay()
        let endOfMonth = getEndDay(startOfMonth: startOfMonth)
        let dayInt = getDayInt(endOfMonth: endOfMonth)
        
        var interval = DateComponents()
        interval.day = 1
        
        let calendar = Calendar.current
        //        let anchorDate = calendar.date(bySettingHour: 12, minute: 0, second: 0, of: self.date)
        //        let anchorDate = calendar.date(bySettingHour: 12, minute: 0, second: 0, of: Date())
        let startOfDay = Calendar.current.startOfDay(for: Date())
        
        let now = Date()
        
        var anchorComponents = Calendar.current.dateComponents([.day, .month, .year], from: now)
        anchorComponents.hour = 0
        let anchorDate = Calendar.current.date(from: anchorComponents)!
        
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)
        let query = HKStatisticsCollectionQuery.init(quantityType: energyType,
                                                     quantitySamplePredicate: nil,
                                                     options: .cumulativeSum,
                                                     anchorDate: anchorDate,
                                                     intervalComponents: interval)
        
        query.initialResultsHandler = {
            _, results, error in
            
            guard let statsCollection = results else {
                // Perform proper error handling here
                return
            }
            var dataEntries = [BarChartDataEntry]()
            
            var thisDay = startOfMonth
            var totalSteps = 0.0
            for i in 1...dayInt {
                let nextDay: Date = calendar.date(byAdding: .day, value: 1, to: thisDay)!
                // Plot the weekly step counts over the past 3 months
                statsCollection.enumerateStatistics(from: thisDay, to: thisDay) { statistics, stop in
                    
                    if let quantity = statistics.sumQuantity() {
                        let _ = statistics.startDate
                        let value = quantity.doubleValue(for: HKUnit.count())
                        
                        let barEntry = BarChartDataEntry(x: (Double(i)), y: value)
                        dataEntries.append(barEntry)
                        totalSteps += value
                        // Call a custom method to plot each data point.String(describing: )
                        
                    }
                }
                thisDay = nextDay
            }
            
            
            let chartDataSet = BarChartDataSet(entries: dataEntries, label: "Energy")
            chartDataSet.drawValuesEnabled = false
            chartDataSet.notifyDataSetChanged()
            let chartData = BarChartData(dataSets: [chartDataSet])
            chartData.barWidth = 0.5
            chartData.notifyDataChanged()
            self.barChart.data = chartData
            self.barChart.notifyDataSetChanged()
            self.barChart.animate(xAxisDuration: 0.5, yAxisDuration: 0.5)
            //            print("after chartView height : \(self.chartView.bounds.height)")
            //            print("after barchartView height : \(self.barChartPlace.bounds.height)")
        }
    }
    
    func getHealthEnergyInfo() {
        guard let energyType = HKSampleType.quantityType(forIdentifier: .activeEnergyBurned) else {
            print("Sample type not available")
            return
        }
        
        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)
        
        let hkUnit = HKUnit.kilocalorie()
        let energyQuery1 = HKSampleQuery(sampleType: energyType, predicate: predicate, limit: HKObjectQueryNoLimit,sortDescriptors: nil) { (query, sample, error) in
        }
        //        HKSampleQuery(
        let energyQuery = HKSampleQuery(sampleType: energyType,predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) {(query, sample, error) in
            guard error == nil,let quantitySamples = sample as? [HKQuantitySample] else {
                print("Something went wrong: \(String(describing: error))")
                return
            }
            
            let total = quantitySamples.reduce(0.0) { $0 + $1.quantity.doubleValue(for: HKUnit.kilocalorie()) }
            
            DispatchQueue.main.async {
                self.secondSummaryBoard.importData(iconKey: "energy_icon", title: "Active Energy", firstTitle: "Active Energy", firstContent: String(total), secondTitle: "Average Kilocalories", secondContent: String(format: "%.2f", total))
            }
        }
        HKHealthStore().execute(energyQuery)
    }
}
