//
//  ViewController.swift
//  KRPresentationKit
//
//  Created by Joshua Park on 06/30/2016.
//  Copyright (c) 2016 Joshua Park. All rights reserved.
//

import UIKit
import KRPresentationKit

class ViewController: KRViewController, CustomPresenting {

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
    
    var transitioner: KRTransitioner?
    
    @IBAction func customAction(_ sender: AnyObject) {
        if transitioner == nil {
            let attribs = TransitionAttributes(initial: [.alpha(0.1), .rotation(-360), .scale(0.1)], timingFunction: .easeInOutCubic, duration: 1.0)
//            let attribs = TransitionAnimation(initial: [.alpha(0.1), .scale(0.1), .rotation(180.0)], duration: 1.0)
            transitioner = KRTransitioner(attributes: attribs)
        }

        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TempVC")
        vc.transitioningDelegate = transitioner
        vc.modalPresentationStyle = .custom

        present(vc, animated: true, completion: nil)
    }
    
    @IBAction func action(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}

class TempViewController: UIViewController {
    @IBAction func action(_ sender: Any) {
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
}
