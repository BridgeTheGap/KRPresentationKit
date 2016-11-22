//
//  ViewController.swift
//  KRPresentationKit
//
//  Created by Joshua Park on 06/30/2016.
//  Copyright (c) 2016 Joshua Park. All rights reserved.
//

import UIKit
import KRPresentationKit

class ViewController: UIViewController, CrossfadingTransition, ContainerViewDelegate, UIGestureRecognizerDelegate {
    
    var transitioner: KRTransitioner?
    var containerView: UIView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func presentAction(_ sender: AnyObject) {
        let attrib: [Attribute] = [
            .alpha(0.0),
//            .origin(CGPoint(x: 0.0, y: self.view.frame.maxY)),
//            .frame((sender as! UIButton).frame),
            .position(CGPoint(x: (sender as! UIButton).frame.midX,
                              y: (sender as! UIButton).frame.midY)),
            .scale(0.01),
//            .translation(CGSize(width: 0.0, height: 512.0)),
            .rotation(-360.0),
            ]
        let attribs = TransitionAttributes(initial: attrib, timingFunction: .easeInOutCubic, duration: 0.75)
//        let attribs = TransitionAnimation(initial: attrib, duration: 1.0)
        transitioner = KRTransitioner(attributes: attribs)
        transitioner?.containerViewDelegate = self
        
        let size = CGSize(width: min(UIScreen.main.bounds.width * 0.75, 450.0),
                          height: UIScreen.main.bounds.height * 0.5)
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PresentedVC")
        vc.transitioningDelegate = transitioner
        vc.modalPresentationStyle = .custom
        vc.view.frame = CGRect(origin: CGPoint.zero, size: size)
        vc.view.center = self.view.center
        
        present(vc, animated: true, completion: nil)
    }
    
    @IBAction func presentBGAction(_ sender: AnyObject) {
        let attrib: [Attribute] = [
            .alpha(0.0),
//            .origin(CGPoint(x: 0.0, y: self.view.frame.maxY)),
//            .frame((sender as! UIButton).frame),
            .position(CGPoint(x: (sender as! UIButton).frame.midX,
                              y: (sender as! UIButton).frame.midY)),
            .scale(0.01),
            .rotation(-360.0),
            ]
        
        let attribs = TransitionAttributes(initial: attrib, timingFunction: .easeOutBack, duration: 0.75)
        transitioner = KRTransitioner(attributes: attribs)
        
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "BackgroundVC")
        vc.transitioningDelegate = transitioner
        vc.modalPresentationStyle = .custom
        vc.view.backgroundColor = UIColor.clear
        vc.view.layoutIfNeeded()
        
        present(vc, animated: true, completion: nil)
    }
    
    @IBAction func action(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Container view delegate
    
    func prepare(containerView: UIView, for transitionID: String?) {
        let tapGR = UITapGestureRecognizer(target: self, action: #selector(action(_:)))
        tapGR.delegate = self
        containerView.addGestureRecognizer(tapGR)
        containerView.backgroundColor = UIColor.clear
        
        self.containerView = containerView
    }
    
    func animate(containerView: UIView, for transitionID: String?, isPresenting: Bool) {
        containerView.backgroundColor = isPresenting ? UIColor(white: 0.0, alpha: 0.4) : UIColor.clear
    }
    
    func finalize(containerView: UIView, for transitionID: String?, isPresenting: Bool) { }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return touch.view === containerView ? true : false
    }
}

class PresentedViewController: UIViewController {

    @IBAction func fade(_ sender: Any) {
        let navController = presentingViewController as! UINavigationController
        guard let presenting = navController.viewControllers.first as? CrossfadingTransition else { return }
        
//        let attribs = TransitionAttributes(initial: [.alpha(0.0), .scale(0.01)], duration: 0.5)
//        let transitioner = KRTransitioner(attributes: attribs)
        let transitioner = presenting.transitioner!
        transitioner.containerViewDelegate = presenting as? ContainerViewDelegate
        
        let size = CGSize(width: min(UIScreen.main.bounds.width * 0.75, 450.0),
                          height: UIScreen.main.bounds.height * 0.5)
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PresentedVC")
        vc.view.frame = CGRect(origin: CGPoint.zero, size: size)
        vc.view.center = self.view.center
        
        presenting.fade(to: vc, using: transitioner, completion: nil)
    }
    
    @IBAction func dismiss(_ sender: Any) {
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
}

class BackgroundViewController: UIViewController, CustomBackgroundProvider, UIGestureRecognizerDelegate {
    var contentView: UIView!
    
    lazy var presentationAnimation: (() -> Void)? = {
        self.view.backgroundColor = UIColor(white: 1.0, alpha: 0.8)
    }
    
    lazy var dismissalAnimation: (() -> Void)? = {
        self.view.backgroundColor = UIColor.clear
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        contentView.layer.cornerRadius = 6.0
        contentView.layer.shadowColor = UIColor(white: 0.0, alpha: 0.4).cgColor
        contentView.layer.shadowOffset = CGSize.zero
        contentView.layer.shadowRadius = 4.0
        contentView.layer.shadowOpacity = 1.0
    }
    
    @IBAction func action(_ sender: Any) {
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func bgAction(_ sender: Any) {
        action(sender)
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return touch.view === self.view ? true : false
    }
}
