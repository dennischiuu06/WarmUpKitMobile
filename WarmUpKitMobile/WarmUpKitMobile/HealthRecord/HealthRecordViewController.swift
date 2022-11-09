//
//  HealthRecordViewController.swift
//  WarmUpKitMobile
//
//  Created by dennis.k.chiu on 7/10/2022.
//

import UIKit
import HealthKit
import Charts

private class CubicLineSampleFillFormatter: FillFormatter {
    func getFillLinePosition(dataSet: LineChartDataSetProtocol, dataProvider: LineChartDataProvider) -> CGFloat {
        return -10
    }
}

class HealthRecordViewController: UIViewController, ChartViewDelegate {
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!

    @IBOutlet weak var halfChartView: PieChartView!
    @IBOutlet weak var cubicChartView: LineChartView!
    @IBOutlet weak var heartRateView: UIView!

    @IBOutlet weak var highestImageView: UIImageView!
    @IBOutlet weak var highestRateTitle: UILabel!
    @IBOutlet weak var highestRateSubTitle: UILabel!
    
    @IBOutlet weak var lowestRateImageView: UIImageView!
    @IBOutlet weak var lowestRateTitle: UILabel!
    @IBOutlet weak var lowestRateSubTitle: UILabel!
    @IBOutlet weak var heartRateListButton: UIButton!
    
    @IBOutlet weak var recentImageView: UIImageView!
    @IBOutlet weak var recentTitle: UILabel!
    @IBOutlet weak var recentHeartRate: UILabel!
    
    var healthStore = HKHealthStore()
    
    var heartRateQuery: HKQuery?
    
    var datasource: [HKQuantitySample] = []
    
    let healthKitManager = HealthKitManager.shared
    
    var viewModel = HealthRecordViewModel()
    
    var totalRate: [Int] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("viewDidLoad")
        setupUI()
        setupHalfChartView()
        setUpHeartRateInfoBoard()
        setupCubicChartView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("viewDidAppear")
        healthKitManager.authorizeHealthKitAccess { (success, error) in
            if success {
                self.retrieveHeartRateData()
            } else if let error = error {
                print(error)
            }
        }
    }
    
    func setupUI() {
        setupNavigationTitle(title: "Health Record Details Page")
        self.view.backgroundColor = ColorCode.backgroundGrey()
        halfChartView.backgroundColor = .white
        heartRateView.backgroundColor = .white
        halfChartView.setShadow(color: ColorCode.lightState(), opacity: 1, radius: 4, offset: 4)
        heartRateView.setShadow(color: ColorCode.lightState(), opacity: 1, radius: 4, offset: 4)

        scrollView.backgroundColor = ColorCode.backgroundGrey()
        contentView.backgroundColor = ColorCode.backgroundGrey()
        scrollView.frame = view.bounds
        scrollView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        heartRateListButton.addTarget(self, action: #selector(heartRateListAction(_:)), for: .touchUpInside)
    }
    
    @objc private func heartRateListAction(_ sender: Any?) {
        guard let viewController = HealthRateListViewController.create() else { return }
        viewController.modalPresentationStyle = .fullScreen
        self.present(viewController, animated: true) {}
    }
    
    func setUpHeartRateInfoBoard() {
        highestImageView.image = UIImage(named: "highestHeartRate")
        lowestRateImageView.image = UIImage(named: "lowestHeartRate")
        
        highestRateTitle.font = UIFont(name: "Helvetica-BoldOblique", size: 14)
        highestRateTitle.textColor = ColorCode.grey()
        highestRateTitle.text = "HIGHEST RATE"
        
        highestRateSubTitle.font = UIFont(name: "Helvetica-Bold", size: 18)
        highestRateSubTitle.textColor = ColorCode.darkGrey()
        highestRateSubTitle.text = "-"

        lowestRateTitle.font = UIFont(name: "Helvetica-BoldOblique", size: 14)
        lowestRateTitle.textColor = ColorCode.grey()
        lowestRateTitle.text = "LOWEST RATE"
        
        lowestRateSubTitle.font = UIFont(name: "Helvetica-Bold", size: 18)
        lowestRateSubTitle.textColor = ColorCode.darkGrey()
        lowestRateSubTitle.text = "-"
        
        recentImageView.image = UIImage(named: "icon_health_profile")
        recentTitle.text = "Recent Resting Heart Rate"
        recentHeartRate.text = "- BPM"
    }
    
    func setupHalfChartView() {
        self.baseChartViewSetUp()
        halfChartView.delegate = self
        halfChartView.holeColor = .white
        halfChartView.transparentCircleColor = NSUIColor.white.withAlphaComponent(0.48)
        halfChartView.holeRadiusPercent = 0.55
        halfChartView.rotationEnabled = false
        halfChartView.highlightPerTapEnabled = true
        
        halfChartView.maxAngle = 180 // Half chart
        halfChartView.rotationAngle = 180 // Rotate to make the half on the upper side
        halfChartView.centerTextOffset = CGPoint(x: 0, y: -20)
        
        
        let l = halfChartView.legend
        l.horizontalAlignment = .center
        l.verticalAlignment = .top
        l.orientation = .horizontal
        l.drawInside = false
        l.xEntrySpace = 8
        l.yEntrySpace = 0
        l.yOffset = 0

        // entry label styling
        halfChartView.entryLabelColor = .white
        halfChartView.entryLabelFont = UIFont(name: "Helvetica-Bold", size: 12)
        
        self.setDataCount(3, range: 100)
        
        halfChartView.animate(xAxisDuration: 1.4, easingOption: .easeOutBack)
        
    }
    
    func baseChartViewSetUp() {
        halfChartView.usePercentValuesEnabled = true
        halfChartView.drawSlicesUnderHoleEnabled = false
        halfChartView.transparentCircleRadiusPercent = 0.61
        halfChartView.chartDescription.enabled = false
        halfChartView.setExtraOffsets(left: 5, top: 10, right: 5, bottom: 5)
        
        halfChartView.drawCenterTextEnabled = true
        
        let paragraphStyle = NSParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
        paragraphStyle.lineBreakMode = .byTruncatingTail
        paragraphStyle.alignment = .center
        
        let centerText = NSMutableAttributedString(string: "Health Info Item")
        centerText.setAttributes([.font: UIFont(name: "Helvetica-LightOblique", size: 14)!,
                                  .paragraphStyle : paragraphStyle], range: NSRange(location: 0, length: centerText.length))
        halfChartView.centerAttributedText = centerText;
        
        halfChartView.drawHoleEnabled = true
    }
    
    let parties = ["Party A", "Party B", "Party C", "Party D", "Party E", "Party F",
                   "Party G", "Party H", "Party I", "Party J", "Party K", "Party L",
                   "Party M", "Party N", "Party O", "Party P", "Party Q", "Party R",
                   "Party S", "Party T", "Party U", "Party V", "Party W", "Party X",
                   "Party Y", "Party Z"]
    
    func setDataCount(_ count: Int, range: UInt32) {
        let entries = (0..<count).map { (i) -> PieChartDataEntry in
            // IMPORTANT: In a PieChart, no values (Entry) should have the same xIndex (even if from different DataSets), since no values can be drawn above each other.
            return PieChartDataEntry(value: Double(arc4random_uniform(range) + range / 5),
                                     label: parties[i % parties.count])
        }
        
        let set = PieChartDataSet(entries: entries, label: "-- Health Items")
        set.sliceSpace = 3
        set.selectionShift = 5
        set.colors = ChartColorTemplates.material()
        let data = PieChartData(dataSet: set)
        
        let pFormatter = NumberFormatter()
        pFormatter.numberStyle = .percent
        pFormatter.maximumFractionDigits = 1
        pFormatter.multiplier = 1
        pFormatter.percentSymbol = " %"
        data.setValueFormatter(DefaultValueFormatter(formatter: pFormatter))
        data.setValueFont(UIFont(name: "Helvetica-Bold", size: 11) ?? UIFont.systemFont(ofSize: 12))
        data.setValueTextColor(.white)
        
        halfChartView.data = data
        
        halfChartView.setNeedsDisplay()
    }
    
    func updateHeartRateInfo() {
        for data in datasource as [HKQuantitySample] {
            let value = data.quantity.doubleValue(for: HKUnit(from: "count/min"))

            let intValue = Int(value)
            totalRate.append(intValue)
        }
        
        if let maxRate = totalRate.max(), let minRate = totalRate.min(), let recentRate = totalRate.last {
            highestRateSubTitle.text = "\(maxRate) BPM"
            lowestRateSubTitle.text = "\(minRate) BPM"
            recentHeartRate.text = "\(recentRate) BPM"
        }
       
    }
}

extension HealthRecordViewController {
    func setupCubicChartView() {
        cubicChartView.delegate = self
        
        cubicChartView.setViewPortOffsets(left: 35, top: 35, right: 20, bottom: 0)
        cubicChartView.backgroundColor = .white
        
        cubicChartView.dragEnabled = true
        cubicChartView.highlightPerTapEnabled = true
        cubicChartView.setScaleEnabled(true)
        cubicChartView.maxHighlightDistance = 300
        cubicChartView.pinchZoomEnabled = true
        cubicChartView.doubleTapToZoomEnabled = false
        
        let l = cubicChartView.legend
        l.form = .line
        l.font = UIFont(name: "HelveticaNeue-Light", size: 11)!
        l.textColor = ColorCode.blue()
        l.horizontalAlignment = .left
        l.verticalAlignment = .bottom
        l.orientation = .horizontal
        l.drawInside = false
        
        let xAxis = cubicChartView.xAxis
        xAxis.labelFont = UIFont(name: "Helvetica-LightOblique", size: 12) ?? .systemFont(ofSize: 12)
        xAxis.labelTextColor = ColorCode.darkGrey()
        xAxis.axisMinLabels = 4
        xAxis.axisMinimum = 0
        xAxis.labelCount = 0
        xAxis.drawAxisLineEnabled = false
        
        let leftAxis = cubicChartView.leftAxis
        leftAxis.setLabelCount(8, force: false)
        leftAxis.labelFont = UIFont(name: "HelveticaNeue-Light", size: 12) ?? .systemFont(ofSize: 12)
        leftAxis.drawGridLinesEnabled = true
        leftAxis.granularityEnabled = true
        leftAxis.labelTextColor = ColorCode.darkGrey()
        leftAxis.axisLineColor = ColorCode.darkGrey()
        
        cubicChartView.rightAxis.enabled = false
        
        setCubicChartDataCount()
        
        cubicChartView.animate(xAxisDuration: 2.5)
    }
    
    func setCubicChartDataCount() {
        let yVals1 = datasource.enumerated().map { (index, data) -> ChartDataEntry in
            let value = data.quantity.doubleValue(for: HKUnit(from: "count/min"))
            
            let rate = Double(value)
            return ChartDataEntry(x: Double(index), y: rate)
        }
        
        let set1 = LineChartDataSet(entries: yVals1, label: "Heart Rate")
        set1.setColor(UIColor(red: 51/255, green: 181/255, blue: 229/255, alpha: 1))
        set1.mode = .cubicBezier
        set1.drawCirclesEnabled = true
        set1.lineWidth = 2
        set1.circleRadius = 4
        set1.axisDependency = .left
        set1.setCircleColor(ColorCode.darkGrey())
        set1.highlightColor = ColorCode.darkRedBackground()
        set1.fillColor = .white
        set1.fillAlpha = 65/255
        set1.mode = .linear
        set1.fillFormatter = CubicLineSampleFillFormatter()
        set1.drawValuesEnabled = true
        
        let data = LineChartData(dataSet: set1)
        data.setValueFont(UIFont(name: "HelveticaNeue-Light", size: 9)!)
        data.setDrawValues(false)
        
        if totalRate.isEmpty {
            cubicChartView.backgroundColor = ColorCode.lightBlue()
            cubicChartView.data = nil
        } else {
            cubicChartView.backgroundColor = UIColor.white
            cubicChartView.data = data
        }
    }
}


extension HealthRecordViewController: HeartRateDelegate {

    func heartRateUpdated(heartRateSamples: [HKSample]) {
        guard let heartRateSamples = heartRateSamples as? [HKQuantitySample] else {
            return
        }

        DispatchQueue.main.async {
            self.datasource.append(contentsOf: heartRateSamples)
            self.updateHeartRateInfo()
            self.setCubicChartDataCount()
        }
    }

    func retrieveHeartRateData() {
        if let query = healthKitManager.createHeartRateStreamingQuery(Date()) {
            self.heartRateQuery = query
            self.healthKitManager.heartRateDelegate = self
            self.healthKitManager.healthStore.execute(query)
        }
    }
}
