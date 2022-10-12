//
//  MainCardView.swift
//  WarmUpKitMobile
//
//  Created by dennis.k.chiu on 12/10/2022.
//

import UIKit

class MainCardView: UIView {

    @IBOutlet weak var dateTimeLabel: UILabel!
    @IBOutlet weak var greetingLabel: UILabel!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var stackView: UIStackView!
    
    let viewModel = MainCardViewModel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialFromXib()
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialFromXib()
    }
    
    func initialFromXib() {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "MainCardView", bundle: bundle)
        contentView = nib.instantiate(withOwner: self, options: nil)[0] as? UIView
        addSubview(contentView)
        
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    func setupUI() {
        stackView.backgroundColor = ColorCode.backgroundGrey()
        stackView.spacing = 8
        dateTimeLabel.textColor = ColorCode.grey()
        dateTimeLabel.font = UIFont.boldSystemFont(ofSize: 14)
        dateTimeLabel.text = viewModel.latestDateTime.uppercased()
        
        greetingLabel.font = UIFont.boldSystemFont(ofSize: 18)
        greetingLabel.text = viewModel.greetingMsg
        
    }
}


struct MainCardViewModel {
    var latestDateTime: String {
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, MMMM d, yyyy"
        dateFormatter.locale = Locale.current
        return dateFormatter.string(from: date)
    }
    
    var greetingMsg: String {
        let currentHour = Calendar.current.component(.hour, from: Date())
        if (currentHour < 12) {
            // Before 12PM
            return "Good Morning, Mr/Miss"
        } else if (currentHour < 18) {
            // After 12pm, before 6PM
            return "Good Afternoon, Mr/Miss"
        } else {
            // After 6PM
            return "Good Evening, Mr/Miss"
        }
    }
}

