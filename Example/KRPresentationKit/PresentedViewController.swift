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
        let styles: [KRTransitionStyle] = [.SlideUp(nil), .SlideDown(nil), .SlideLeft(nil), .SlideRight(nil), .Popup(nil), .Overlay(nil)]
        sourceVC?.fadeToViewController(pvc, style: styles[Int(UInt32(arc4random()) % 5)], completion: nil)
    }
    
    @IBAction func dismissAction(sender: UIButton) {
        presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
}
