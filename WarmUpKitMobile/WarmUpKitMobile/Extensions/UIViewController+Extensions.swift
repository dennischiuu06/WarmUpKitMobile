//
//  UIViewController+Extensions.swift
//  WarmUpKitMobile
//
//  Created by dennis.k.chiu on 12/10/2022.
//

import UIKit
import SnapKit

extension UIViewController {
    
    func setupNavigationTitle(title: String? = "", textColor: UIColor = ColorCode.darkGrey()) {
        let height = navigationController?.navigationBar.frame.height ?? 0
        let titleView = UIView(frame: CGRect(x: 0, y: 0, width: navigationController?.navigationBar.frame.width ?? 0, height: height))
        navigationItem.titleView = titleView
        
        let label = UILabel(frame: CGRect(x:0, y:0, width: 80, height: height))
        label.numberOfLines = 0
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textAlignment = .center
        label.textColor = textColor
        label.text = title
        titleView.addSubview(label)
        
        label.snp.makeConstraints { make in
            // add the right padding between the title label and the titleView
            // cannot get the width of left and right navigation button, so hardcode it, since it is standard
            if #available(iOS 11.0, *) {
                make.right.equalToSuperview()
            } else {
                if navigationItem.rightBarButtonItem != nil {
                    // add the width of back button (33) at the left corner, and reduce the padding between back button and titleView (6)
                    make.right.equalToSuperview().offset(-33+6)
                } else {
                    // add the width of back button (33) at the left corner, and add the width of menu icon (30)
                    make.right.equalToSuperview().offset(-33-30)
                }
            }
            make.left.equalToSuperview()
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
    
    func setNavigationCloseButton() {
        guard self == navigationController?.viewControllers.first else { return }
        let backButtonImage = UIImage(named: "general_back_button")
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: backButtonImage,
                                                           style: .done,
                                                           target: self,
                                                           action: #selector(closeCurrentPage))
    }
    
    @objc open func closeCurrentPage() {
        dismiss(animated: true)
    }
    
    @objc open func prevPage(){
        navigationController?.popViewController(animated: true)
    }
}

extension UIViewController {
    func setUpBackButton() {
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(customView: {
            let button = UIButton(type: .system)
            button.setTitle("", for: .normal)
            button.widthAnchor.constraint(equalToConstant: 24.0).isActive = true
            button.heightAnchor.constraint(equalToConstant: 24.0).isActive = true
            button.setImage(#imageLiteral(resourceName: "iconArrowLeft"), for: .normal)
            button.addTarget(self, action: #selector(clickOnBackButton), for: .touchUpInside)
            return button
        }())
    }
    
    @objc func clickOnBackButton() {
        navigationController?.dismiss(animated: false, completion: nil)
    }
    
    var className: String {
        String(describing: Self.self)
    }
}
