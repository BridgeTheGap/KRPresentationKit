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

    @IBAction func presentAction(_ sender: AnyObject) {
        if presentedViewController == nil {
            let pvc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PresentedVC") as! PresentedViewController
            pvc.sender = sender
            present(pvc, style: .popup(.easeOutBack), completion: nil)
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func presentBGAction(_ sender: AnyObject) {
        if presentedViewController == nil {
            let bvc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "BackgroundVC") as! BackgroundViewController
            let view = bvc.view as! KRView
            view.sender = sender
            view.allowsUserInteraction = true
            
            bvc.backgroundAnim = {
                if $1 {
                    bvc.view.alpha = 0.0
                    return bvc.view.chain(alpha: 1.0, duration: $0)
                } else {
                    return bvc.view.chain(alpha: 0.0, duration: $0)
                }
            }
            present(bvc, style: .popup(.easeOutBack), completion: nil)
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func customAction(_ sender: AnyObject) {
        if presentedViewController == nil {
            let pvc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PresentedVC") as! PresentedViewController
            pvc.sender = sender
            pvc.useSnapshot = true
            let style = KRTransitionStyle.getCustomAnimations({ (view, duration) -> [AnimationDescriptor] in
                let frame = pvc.destinationFrame
                view.frame = (sender as! UIButton).frame
                
                return view.chain(frame: frame, duration: duration, function: .easeOutBack)
            }) { (view, duration) -> [AnimationDescriptor] in
                return view.chain(frame: (sender as! UIButton).frame, duration: duration, function: .easeInCubic)
            }
            present(pvc, style: style, completion: nil)
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
}

