//
//  PresentedViewController.swift
//  TestBed
//
//  Created by Joshua Park on 4/6/16.
//  Copyright © 2016 KnowRe. All rights reserved.
//

import UIKit
import KRPresentationKit

class PresentedViewController: BackgroundSeparableViewController {
    @IBOutlet weak var label: UILabel!
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func switchAction(sender: UIButton) {
        let pvc = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("PresentedVC") as! PresentedViewController
        pvc.view.layoutIfNeeded()
        let finalFrame = pvc.contentView.frame
        
        let anim: (() -> Void) -> Void = { (completion) in
            pvc.contentView.frame = CGRectMake(10.0, 64.0, finalFrame.size.width * 0.1, finalFrame.size.height * 0.1)
            pvc.contentView.animateFrame(finalFrame, duration: 0.3, function: .EaseOutBack, completion: completion)
        }
        
        let styles: [PresentationStyle] = [.SlideUp(nil), .SlideLeft(nil), .SlideRight(nil), .SlideDown(nil), .Popup(nil), .Overlay(nil)]
        
        pvc.presentationStyle = styles[Int(arc4random() % 6)]
        
        switch pvc.presentationStyle {
        case .SlideUp:
            pvc.label.text = "Slide Up"
        case .SlideDown:
            pvc.label.text = "Slide Down"
        case .SlideLeft:
            pvc.label.text = "Slide Left"
        case .SlideRight:
            pvc.label.text = "Slide Right"
        case .Custom:
            pvc.label.text = "Custom"
        case .Popup:
            pvc.label.text = "Pop Up"
        case .Overlay:
            pvc.label.text = "Overlay"
        default:
            break
        }
        pvc.label.sizeToFit()
        let x = (pvc.view.frame.size.width - pvc.label.frame.size.width) / 2.0
        pvc.label.frame.origin.x = x

        self.customPresentingViewController?.fadeToViewController(pvc, duration: 0.3, completion: nil)
    }
    
    @IBAction func dismissAction(sender: UIButton) {
        customPresentingViewController?.dismissViewController(completion: nil)
    }
}
