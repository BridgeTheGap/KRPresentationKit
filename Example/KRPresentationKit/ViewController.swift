//
//  ViewController.swift
//  KRPresentationKit
//
//  Created by Joshua Park on 06/30/2016.
//  Copyright (c) 2016 Joshua Park. All rights reserved.
//

import UIKit
import KRPresentationKit

class ViewController: KRViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func presentAction(sender: AnyObject) {
        let pvc = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("PresentedVC") as! PresentedViewController
        presentViewController(pvc, style: .Popup(.EaseOutBack), completion: nil)
    }
    
    @IBAction func presentBGAction(sender: AnyObject) {
        let bvc = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("BackgroundVC") as! BackgroundViewController
        bvc.backgroundAnim = {
            if $1 {
                bvc.view.alpha = 0.0
                return bvc.view.chainAlpha(1.0, duration: $0)
            } else {
                return bvc.view.chainAlpha(0.0, duration: $0)
            }
        }
        bvc.loadView()
        presentViewController(bvc, style: .SlideUp(.EaseOutQuart), completion: nil)
    }
    
    @IBAction func dismissSegue(segue: UIStoryboardSegue) {
        
    }
}

