//
//  HealthRateListViewController.swift
//  WarmUpKitMobile
//
//  Created by dennis.k.chiu on 4/11/2022.
//

import UIKit
import HealthKit

class HealthRateListViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var closeButton: UIButton!
    
    @IBOutlet weak var noDataView: UIView!
    @IBOutlet weak var noDataLabel: UILabel!
    
    var healthStore = HKHealthStore()
    
    var heartRateQuery: HKQuery?
    
    var datasource: [HKQuantitySample] = []
    
    let healthKitManager = HealthKitManager.shared
    
    var viewModel: HealthRecordViewModel?
    
    class func create(viewModel: HealthRecordViewModel? = nil) -> HealthRateListViewController? {
        let storyboard = UIStoryboard(name: "HealthRateListViewController", bundle: nil)
        guard let viewController = storyboard.instantiateViewController(withIdentifier: "HealthRateListViewController") as? HealthRateListViewController else { return nil }
        return viewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        healthKitManager.authorizeHealthKitAccess { (success, error) in
            print("HealthKit authorized? \(success)")
            self.retrieveHeartRateData()
        }
        
    }
    
    private func setupUI() {
        closeButton.backgroundColor = ColorCode.mediumJade1000()
        closeButton.setTitle("Close", for: .normal)
        closeButton.layer.borderWidth = 1.5
        closeButton.layer.cornerRadius = 4
        closeButton.layer.borderColor = UIColor.clear.cgColor
        closeButton.tintColor = UIColor.white
        closeButton.addTarget(self, action: #selector(closeButtonAction(_:)), for: .touchUpInside)
        closeButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        
        tableView.backgroundColor = ColorCode.newGreyBackground()
        noDataView.isHidden = !datasource.isEmpty
        noDataLabel.text = "No Heart Rate Data Available"
        noDataLabel.font = UIFont(name: "Helvetica-BoldOblique", size: 16)
        noDataLabel.textColor = ColorCode.darkGrey()

    }
    
    @objc private func closeButtonAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}

extension HealthRateListViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return datasource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "heartRate", for: indexPath) as? HealthRateDetailTableViewCell {
            
            let heartRate = datasource[indexPath.row].quantity
            let time = datasource[indexPath.row].startDate
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd hh:mm:ss"
            let timeString = dateFormatter.string(from: time)
            
            noDataView.isHidden = true

            cell.importData(heartRate: "\(heartRate)", timeInfo: "\(timeString)")
            return cell
        }
        return UITableViewCell()
    }
    
    
}

extension HealthRateListViewController: HeartRateDelegate {
    
    func heartRateUpdated(heartRateSamples: [HKSample]) {
        guard let heartRateSamples = heartRateSamples as? [HKQuantitySample] else {
            return
        }
        
        DispatchQueue.main.async {
            self.datasource.append(contentsOf: heartRateSamples)
            self.tableView.reloadData()
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


// Health Rate Cell
class HealthRateDetailTableViewCell: UITableViewCell {
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var timeDetails: UILabel!
    @IBOutlet weak var heartImageView: UIImageView!

    
    override func awakeFromNib() {
        timeDetails.font = UIFont.systemFont(ofSize: 12)
        title.font = UIFont.systemFont(ofSize: 12)
        heartImageView.image = UIImage(named: "heart")
    }
    
    func importData(heartRate: String, timeInfo: String) {
        title.text = heartRate
        timeDetails.text = timeInfo
    }
}

