//
//  ViewController.swift
//  KRPresentationKit
//
//  Created by Joshua Park on 06/30/2016.
//  Copyright (c) 2016 Joshua Park. All rights reserved.
//

import UIKit
import KRPresentationKit
import KRAnimationKit

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
        if presentedViewController == nil {
            let pvc = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("PresentedVC") as! PresentedViewController
            pvc.sender = sender
            presentViewController(pvc, style: .Popup(.EaseOutBack), completion: nil)
        } else {
            dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    @IBAction func presentBGAction(sender: AnyObject) {
        if presentedViewController == nil {
            let bvc = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("BackgroundVC") as! BackgroundViewController
            let view = bvc.view as! KRView
            view.sender = sender
            view.allowsUserInteraction = true
            
            bvc.backgroundAnim = {
                if $1 {
                    bvc.view.alpha = 0.0
                    return bvc.view.chainAlpha(1.0, duration: $0)
                } else {
                    return bvc.view.chainAlpha(0.0, duration: $0)
                }
            }
            presentViewController(bvc, style: .Popup(.EaseOutBack), completion: nil)
        } else {
            dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    @IBAction func customAction(sender: AnyObject) {
        if presentedViewController == nil {
            let pvc = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("PresentedVC") as! PresentedViewController
            pvc.sender = sender
            pvc.useSnapshot = true
            let style = KRTransitionStyle.getCustomAnimations({ (view, duration) -> [AnimationDescriptor] in
                let frame = pvc.destinationFrame
                view.frame = (sender as! UIButton).frame
                
                return view.chainFrame(frame, duration: duration, function: .EaseOutBack)
            }) { (view, duration) -> [AnimationDescriptor] in
                return view.chainFrame((sender as! UIButton).frame, duration: duration, function: .EaseInCubic)
            }
            presentViewController(pvc, style: style, completion: nil)
        } else {
            dismissViewControllerAnimated(true, completion: nil)
        }
    }
}

