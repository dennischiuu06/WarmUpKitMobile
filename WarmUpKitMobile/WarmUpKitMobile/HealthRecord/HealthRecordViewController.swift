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
//    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var contentView: UIView!

    @IBOutlet weak var chartView: PieChartView!
    @IBOutlet weak var cubicChartView: LineChartView!
    @IBOutlet weak var heartRateView: UIView!

    @IBOutlet weak var highestImageView: UIImageView!
    @IBOutlet weak var highestRateTitle: UILabel!
    @IBOutlet weak var highestRateSubTitle: UILabel!
    
    @IBOutlet weak var lowestRateImageView: UIImageView!
    @IBOutlet weak var lowestRateTitle: UILabel!
    @IBOutlet weak var lowestRateSubTitle: UILabel!

    var healthStore = HKHealthStore()
    
    var heartRateQuery: HKQuery?
    
    var datasource: [HKQuantitySample] = []
    
    let healthKitManager = HealthKitManager.shared
    
    var viewModel: HealthRecordViewModel?
    
    class func create(viewModel: HealthRecordViewModel? = nil) -> HealthRecordViewController? {
        let storyboard = UIStoryboard(name: "HealthRecord", bundle: nil)
        guard let viewController = storyboard.instantiateViewController(withIdentifier: "HealthRecord") as? HealthRecordViewController else { return nil }
        viewController.viewModel = viewModel
        return viewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        healthKitManager.authorizeHealthKitAccess { (success, error) in
            self.retrieveHeartRateData()
        }
        setupUI()
        setUpHeartRateInfoBoard()
    }
    
    func setupUI() {
        self.view.backgroundColor = ColorCode.backgroundGrey()
        chartView.backgroundColor = .white
        heartRateView.backgroundColor = .white
        chartView.setShadow(color: ColorCode.lightState(), opacity: 1, radius: 4, offset: 4)
        heartRateView.setShadow(color: ColorCode.lightState(), opacity: 1, radius: 4, offset: 4)

        scrollView.backgroundColor = ColorCode.backgroundGrey()
        contentView.backgroundColor = ColorCode.backgroundGrey()
        scrollView.frame = view.bounds
        scrollView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        setupNavigationTitle(title: "Health Record Details Page")
        self.setupHalfChartView()
    }
    
    func setUpHeartRateInfoBoard() {
        highestImageView.image = UIImage(named: "highestHeartRate")
        lowestRateImageView.image = UIImage(named: "lowestHeartRate")
        
        highestRateTitle.font = UIFont(name: "Helvetica-BoldOblique", size: 14)
        highestRateTitle.textColor = ColorCode.grey()
        highestRateTitle.text = "HIGHEST RATE"
        
        highestRateSubTitle.font = UIFont(name: "Helvetica-Bold", size: 18)
        highestRateSubTitle.textColor = ColorCode.darkGrey()
        highestRateSubTitle.text = "120 BPM"

        lowestRateTitle.font = UIFont(name: "Helvetica-BoldOblique", size: 14)
        lowestRateTitle.textColor = ColorCode.grey()
        lowestRateTitle.text = "LOWEST RATE"
        
        lowestRateSubTitle.font = UIFont(name: "Helvetica-Bold", size: 18)
        lowestRateSubTitle.textColor = ColorCode.darkGrey()
        lowestRateSubTitle.text = "80 BPM"
    }
    
    func setupHalfChartView() {
        self.baseChartViewSetUp()
        chartView.delegate = self
        chartView.holeColor = .white
        chartView.transparentCircleColor = NSUIColor.white.withAlphaComponent(0.48)
        chartView.holeRadiusPercent = 0.55
        chartView.rotationEnabled = false
        chartView.highlightPerTapEnabled = true
        
        chartView.maxAngle = 180 // Half chart
        chartView.rotationAngle = 180 // Rotate to make the half on the upper side
        chartView.centerTextOffset = CGPoint(x: 0, y: -20)
        
        
        let l = chartView.legend
        l.horizontalAlignment = .center
        l.verticalAlignment = .top
        l.orientation = .horizontal
        l.drawInside = false
        l.xEntrySpace = 8
        l.yEntrySpace = 0
        l.yOffset = 0

        // entry label styling
        chartView.entryLabelColor = .white
        chartView.entryLabelFont = UIFont(name: "Helvetica-Bold", size: 12)
        
        self.setDataCount(3, range: 100)
        
        chartView.animate(xAxisDuration: 1.4, easingOption: .easeOutBack)
        
        setupCubicChartView()
    }
    
    func baseChartViewSetUp() {
        chartView.usePercentValuesEnabled = true
        chartView.drawSlicesUnderHoleEnabled = false
        chartView.transparentCircleRadiusPercent = 0.61
        chartView.chartDescription.enabled = false
        chartView.setExtraOffsets(left: 5, top: 10, right: 5, bottom: 5)
        
        chartView.drawCenterTextEnabled = true
        
        let paragraphStyle = NSParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
        paragraphStyle.lineBreakMode = .byTruncatingTail
        paragraphStyle.alignment = .center
        
        let centerText = NSMutableAttributedString(string: "Health Info Item")
        centerText.setAttributes([.font: UIFont(name: "Helvetica-LightOblique", size: 14)!,
                                  .paragraphStyle : paragraphStyle], range: NSRange(location: 0, length: centerText.length))
        chartView.centerAttributedText = centerText;
        
        chartView.drawHoleEnabled = true
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
        
        chartView.data = data
        
        chartView.setNeedsDisplay()
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
        xAxis.drawAxisLineEnabled = false
        
        let leftAxis = cubicChartView.leftAxis
        leftAxis.setLabelCount(8, force: false)
        leftAxis.labelFont = UIFont(name: "HelveticaNeue-Light", size: 12) ?? .systemFont(ofSize: 12)
        leftAxis.drawGridLinesEnabled = true
        leftAxis.granularityEnabled = true
        leftAxis.labelTextColor = ColorCode.darkGrey()
        leftAxis.axisLineColor = ColorCode.darkGrey()
        
        cubicChartView.rightAxis.enabled = false

        setCubicChartDataCount(31, range: 100)
        
        cubicChartView.animate(xAxisDuration: 2.5)
    }
    
    func setCubicChartDataCount(_ count: Int, range: UInt32) {
        let yVals1 = (0..<count).map { (i) -> ChartDataEntry in
            let mult = range + 1
            let val = Double(arc4random_uniform(mult) + 40)
            return ChartDataEntry(x: Double(i), y: val)
        }

        let set1 = LineChartDataSet(entries: yVals1, label: "DataSet 1")
        set1.setColor(UIColor(red: 51/255, green: 181/255, blue: 229/255, alpha: 1))
        set1.mode = .cubicBezier
        set1.drawCirclesEnabled = true
        set1.lineWidth = 2
        set1.circleRadius = 4
        set1.axisDependency = .left
        set1.setCircleColor(ColorCode.darkGrey())
        set1.highlightColor = UIColor.purple
        set1.fillColor = .white
        set1.fillAlpha = 65/255
        set1.mode = .linear
        set1.fillFormatter = CubicLineSampleFillFormatter()
        set1.drawValuesEnabled = true
        
        let data = LineChartData(dataSet: set1)
        data.setValueFont(UIFont(name: "HelveticaNeue-Light", size: 9)!)
        data.setDrawValues(false)
        
        cubicChartView.data = data

    }
}

//extension HealthRecordViewController: UITableViewDataSource,UITableViewDelegate {
//
//    func numberOfSections(in tableView: UITableView) -> Int {
//        return 1
//    }
//
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return 10
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        if let cell = tableView.dequeueReusableCell(withIdentifier: "heartRate", for: indexPath) as? HealthRateDetailTableViewCell {
////
////            let heartRate = datasource[indexPath.row].quantity
////            let time = datasource[indexPath.row].startDate
////            let dateFormatter = DateFormatter()
////            dateFormatter.dateFormat = "yyyy-MM-dd hh:mm:ss"
////            let timeString = dateFormatter.string(from: time)
////
//            cell.importData(heartRate: "\(22)", timeInfo: "\(33)")
//            return cell
//        }
//        return UITableViewCell()
//    }
//}


extension HealthRecordViewController: HeartRateDelegate {

    func heartRateUpdated(heartRateSamples: [HKSample]) {
        guard let heartRateSamples = heartRateSamples as? [HKQuantitySample] else {
            return
        }

        DispatchQueue.main.async {
            self.datasource.append(contentsOf: heartRateSamples)
//            self.tableView.reloadData()
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

//
//// Health Rate Cell
//class HealthRateDetailTableViewCell: UITableViewCell {
//    @IBOutlet weak var title: UILabel!
//    @IBOutlet weak var timeDetails: UILabel!
//    @IBOutlet weak var heartImageView: UIImageView!
//
//
//    override func awakeFromNib() {
//        timeDetails.font = UIFont.systemFont(ofSize: 12)
//        title.font = UIFont.systemFont(ofSize: 12)
//        heartImageView.image = UIImage(named: "heart")
//    }
//
//    func importData(heartRate: String, timeInfo: String) {
//        title.text = heartRate
//        timeDetails.text = timeInfo
//    }
//}

