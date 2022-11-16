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
            if success {
                self.healthKitManager.getActiveEnergy()
            } else if let error = error {
                print(error)
            }
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
        barChart.frame = CGRect(x: 0, y: 0, width: barChartView.bounds.width , height: barChartView.bounds.height)
        barChart.noDataText = "You need to provide data for the chart."
        barChartView.addSubview(barChart)
        
        barChart.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        barChart.rightAxis.enabled = false

        let xAxis = barChart.xAxis
        xAxis.labelPosition = .bottom
        xAxis.labelTextColor = ColorCode.darkGrey()
        xAxis.labelFont = UIFont(name: "Helvetica-Light", size: 8) ?? .systemFont(ofSize: 8)
        xAxis.granularity = 1
        xAxis.labelCount = 8
        xAxis.drawAxisLineEnabled = true
        xAxis.valueFormatter = DayAxisValueFormatter(chart: barChart)
        
        let leftAxis = barChart.leftAxis
        leftAxis.labelFont = .systemFont(ofSize: 8)
        leftAxis.labelCount = 8
        leftAxis.labelPosition = .outsideChart
        leftAxis.spaceTop = 0.4
        leftAxis.axisMinimum = 0
        
        let l = barChart.legend
        l.horizontalAlignment = .left
        l.verticalAlignment = .bottom
        l.orientation = .horizontal
        l.drawInside = false
        l.form = .circle
        l.formSize = 9
        l.font = UIFont(name: "HelveticaNeue-Light", size: 8)!
        l.xEntrySpace = 4
        
        let marker = XYMarkerView(color: UIColor(white: 180/250, alpha: 1),
                                  font: .systemFont(ofSize: 12),
                                  textColor: .white,
                                  insets: UIEdgeInsets(top: 8, left: 8, bottom: 20, right: 8),
                                  xAxisValueFormatter: barChart.xAxis.valueFormatter!)
        marker.chartView = barChart
        marker.minimumSize = CGSize(width: 80, height: 40)
        barChart.marker = marker
    }
    
}

extension HomePageViewController: WorkoutTrackingDelegate {
    func didReceiveHealthKitStepCounts(stepCounts: Double, avgSteps: Double, stepsData: [Double]) {
        DispatchQueue.main.async {
            self.summaryBoard.importData(iconKey: "iconstep", title: "Steps", firstTitle: "Steps", firstContent: String(stepCounts), secondTitle: "Average Steps", secondContent: String(format: "%.2f", avgSteps))
            
            var dataEntries = [BarChartDataEntry]()
            
            for (index, data) in stepsData.enumerated() {
                let x = index + 1
                let doubleStr = String(format: "%.2f", data)
                if let value = Double(doubleStr) {
                    let barEntry = BarChartDataEntry(x: (Double(x)), y: value)
                    dataEntries.append(barEntry)
                }
            }

            let chartDataSet = BarChartDataSet(entries: dataEntries, label: "Steps")
            chartDataSet.colors = ChartColorTemplates.colorful()
            chartDataSet.notifyDataSetChanged()
            let chartData = BarChartData(dataSet: chartDataSet)
            chartData.barWidth = 0.6

            if let _ = stepsData.first(where: { $0 != 0 }) {
                self.barChart.data = chartData
            } else {
                self.barChart.data = nil
            }
            self.barChart.notifyDataSetChanged()
            self.barChart.highlightPerTapEnabled = true
            self.barChart.doubleTapToZoomEnabled = false
            self.barChart.animate(xAxisDuration: 1.0, yAxisDuration: 1.0)

        }
    }
    
    func didReceiveHealthKitEnergy(_ energy: Double, _ avgEnergy: Double) {
        DispatchQueue.main.async {
            self.secondSummaryBoard.importData(iconKey: "iconactive_oval", title: "Active Energy", firstTitle: "Active Energy", firstContent: String(energy), secondTitle: "Average Kilocalories", secondContent: String(format: "%.2f", avgEnergy))
        }
    }
}

public class XYMarkerView: BalloonMarker {
    public var xAxisValueFormatter: AxisValueFormatter
    fileprivate var yFormatter = NumberFormatter()
    
    public init(color: UIColor, font: UIFont, textColor: UIColor, insets: UIEdgeInsets,
                xAxisValueFormatter: AxisValueFormatter) {
        self.xAxisValueFormatter = xAxisValueFormatter
        yFormatter.minimumFractionDigits = 1
        yFormatter.maximumFractionDigits = 1
        super.init(color: color, font: font, textColor: textColor, insets: insets)
    }
    
    public override func refreshContent(entry: ChartDataEntry, highlight: Highlight) {
        let string = "Date: "
            + xAxisValueFormatter.stringForValue(entry.x, axis: XAxis())
            + ", Value: "
            + yFormatter.string(from: NSNumber(floatLiteral: entry.y))!
        setLabel(string)
    }
    
}
