//
//  HealthRecordViewController.swift
//  WarmUpKitMobile
//
//  Created by dennis.k.chiu on 7/10/2022.
//

import UIKit
import HealthKit

class HealthRecordViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var closeButton: UIButton!
    
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
            print("HealthKit authorized? \(success)")
            self.retrieveHeartRateData()
            
        }
    }
    @IBAction func closeAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}

extension HealthRecordViewController: UITableViewDataSource,UITableViewDelegate {
    
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
            
            cell.importData(heartRate: "\(heartRate)", timeInfo: "\(timeString)")
            return cell
        }
        return UITableViewCell()
        
        
    }
    
    
}

extension HealthRecordViewController: HeartRateDelegate {
    
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

