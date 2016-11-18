//
//  ViewController.swift
//  KRPresentationKit
//
//  Created by Joshua Park on 06/30/2016.
//  Copyright (c) 2016 Joshua Park. All rights reserved.
//

import UIKit
import KRPresentationKit

class ViewController: UIViewController, CustomPresenting {
    
    var transitioner: KRTransitioner?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func presentAction(_ sender: AnyObject) {

    }
    
    @IBAction func presentBGAction(_ sender: AnyObject) {

    }
    
    @IBAction func customAction(_ sender: AnyObject) {
        if transitioner == nil {
            let frame = (sender as! UIButton).frame
            let attrib: [Attribute] = [
                .alpha(0.0),
//                .origin(CGPoint(x: 0.0, y: self.view.frame.maxY)),
//                .frame(frame),
//                .position(CGPoint(x: frame.midX, y: frame.midY)),
                .scale(0.01),
                .translation(CGSize(width: 0.0, height: -512.0)),
                .rotation(-360.0),
                ]
            let attribs = TransitionAttributes(initial: attrib, timingFunction: .easeInOutCubic, duration: 1.0)
//            let attribs = TransitionAnimation(initial: attrib, duration: 1.0)
            transitioner = KRTransitioner(attributes: attribs)
        }

        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TempVC")
        vc.transitioningDelegate = transitioner
        vc.modalPresentationStyle = .custom
        vc.view.frame.size.height = 512.0
        
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
