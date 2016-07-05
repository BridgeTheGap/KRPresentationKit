//
//  PresentedViewController.swift
//  TestBed
//
//  Created by Joshua Park on 4/6/16.
//  Copyright © 2016 KnowRe. All rights reserved.
//

import UIKit
import KRPresentationKit

class PresentedViewController: KRContentViewController {
    @IBOutlet weak var label: UILabel!
    
    @IBAction func switchAction(sender: UIButton) {
        let pvc = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("PresentedVC") as! PresentedViewController
        sourceVC?.fadeToViewController(pvc, style: .Popup(nil), completion: nil)
    }
    
    @IBAction func dismissAction(sender: UIButton) {
        presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
}
