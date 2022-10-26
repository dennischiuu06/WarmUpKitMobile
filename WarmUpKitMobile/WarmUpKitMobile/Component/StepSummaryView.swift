//
//  StepSummaryViewViewController.swift
//  WarmUpKitMobile
//
//  Created by dennis.k.chiu on 10/10/2022.
//

import UIKit
import SnapKit

class StepSummaryView: UIView {
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var firstSubTitle: UILabel!
    @IBOutlet weak var firstSubContent: UILabel!
    @IBOutlet weak var secondSubTitle: UILabel!
    @IBOutlet weak var secondSubContent: UILabel!

    override init(frame: CGRect) {
        super.init(frame: frame)
        initialFromXib()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialFromXib()
    }
    
    func initialFromXib() {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "StepSummaryView", bundle: bundle)
        contentView = nib.instantiate(withOwner: self, options: nil)[0] as? UIView
        addSubview(contentView)
        
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    func importData(iconKey: String, title: String, firstTitle: String, firstContent: String, secondTitle: String, secondContent: String) {
        self.iconView.image = UIImage(named: iconKey)
        self.title.text = title
        self.firstSubTitle.text = firstTitle
        self.firstSubContent.text = firstContent
        self.secondSubTitle.text = secondTitle
        self.secondSubContent.text = secondContent
    }
    
    func setupUI() {
        contentView.setShadow(color: ColorCode.darkGrey(), opacity: 1, radius: 4, offset: 4)
        contentView.backgroundColor = .white
    }
}
