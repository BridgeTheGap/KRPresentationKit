//
//  PresentedViewController.swift
//  TestBed
//
//  Created by Joshua Park on 4/6/16.
//  Copyright © 2016 KnowRe. All rights reserved.
//
#if false
import UIKit
import KRPresentationKit

class PresentedViewController: KRContentViewController {
    @IBOutlet weak var label: UILabel!
    
    @IBAction func switchAction(_ sender: UIButton) {
        let pvc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PresentedVC") as! PresentedViewController
        let styles: [KRTransitionStyle] = [.slideUp(nil), .slideDown(nil), .slideLeft(nil), .slideRight(nil), .popup(nil), .overlay(nil)]
        sourceVC?.fade(to: pvc, style: styles[Int(UInt32(arc4random()) % 5)], completion: nil)
    }
    
    @IBAction func dismissAction(_ sender: UIButton) {
        presentingViewController?.dismiss(animated: true, completion: nil)
    }
}
#endif
