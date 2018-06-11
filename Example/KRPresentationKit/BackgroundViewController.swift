//
//  BackgroundViewController.swift
//  KRPresentationKit
//
//  Created by Joshua Park on 7/4/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import UIKit
import KRPresentationKit

class BackgroundViewController: UIViewController, CustomPresented, CustomBackgroundProvider {
    
    var customPresenting: UIViewController?
    
    @IBOutlet weak var contentView: UIView!
    
    lazy var presentationAnimation: (() -> Void)? = { [weak view = self.view] in
        view?.backgroundColor = UIColor(white: 1.0, alpha: 0.8)
    }
    
    lazy var dismissalAnimation: (() -> Void)? = { [weak view = self.view] in
        view?.backgroundColor = UIColor.clear
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.clear
        
        contentView.layer.cornerRadius = 6.0
        contentView.layer.shadowColor = UIColor(white: 0.0, alpha: 0.4).cgColor
        contentView.layer.shadowOffset = CGSize.zero
        contentView.layer.shadowRadius = 4.0
        contentView.layer.shadowOpacity = 1.0
    }
        
    @IBAction func action(_ sender: Any) {
        customPresenting?.dismiss(animated: true, completion: nil)
    }
    
    deinit {
        print("Deinit: \(type(of: self))")
    }
}
