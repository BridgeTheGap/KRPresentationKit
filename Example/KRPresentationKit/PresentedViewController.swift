//
//  PresentedViewController.swift
//  TestBed
//
//  Created by Joshua Park on 4/6/16.
//  Copyright © 2016 KnowRe. All rights reserved.
//
import UIKit
import KRPresentationKit

class PresentedViewController: UIViewController, CustomPresented {
    var customPresenting: UIViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.layer.cornerRadius = 6.0
        view.layer.shadowColor = UIColor(white: 0.0, alpha: 0.4).cgColor
        view.layer.shadowOffset = CGSize.zero
        view.layer.shadowRadius = 10.0
        view.layer.shadowOpacity = 1.0
    }
    
    private func fade(withID identifier: String) {
        guard let presenting = customPresenting as? CrossfadingTransition else { return }
        
        let duration = presenting.transitioner!.attributes.duration
        
        let attribs: TransitionAttributes = {
            switch identifier {
            case "fade1": return TransitionAttributes(initial: attrib1, timingFunction: .easeOutCubic, duration: duration)
            case "fade2": return TransitionAttributes(initial: attrib2, timingFunction: .easeOutBounce, duration: duration)
            default: return TransitionAttributes(initial: attrib3, timingFunction: .easeOutBack, duration: duration)
            }
        }()
        let transitioner = KRTransitioner(attributes: attribs)
        
        
        transitioner.transitionID = identifier
        transitioner.containerViewDelegate = presenting as? ContainerViewDelegate
        let size = CGSize(width: min(UIScreen.main.bounds.width * 0.8, 450.0),
                          height: UIScreen.main.bounds.height * 0.5)
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PresentedVC")
        vc.view.frame = CGRect(origin: CGPoint.zero, size: size)
        vc.view.center = self.view.center

        presenting.fade(to: vc, using: transitioner)
    }

    @IBAction func fade1(_ sender: Any) {
        fade(withID: "fade1")
    }
    
    @IBAction func fade2(_ sender: Any) {
        fade(withID: "fade2")
    }
    
    @IBAction func fade3(_ sender: Any) {
        fade(withID: "fade3")
    }
    
    @IBAction func dismiss(_ sender: Any) {
        customPresenting?.dismiss(animated: true, completion: nil)
    }
 
    deinit {
        print("Deinit: \(type(of: self))")
    }
}
