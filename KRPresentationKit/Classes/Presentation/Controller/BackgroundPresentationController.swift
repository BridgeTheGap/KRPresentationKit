//
//  BackgroundPresentationController.swift
//  KRPresentationKit
//
//  Created by Joshua Park on 11/06/2018.
//

import UIKit

internal class BackgroundPresentationController: UIPresentationController {
    weak var transitioner: KRTransitioner?
    
    override var presentedView: UIView? {
        return backgroundProvider.contentView
    }
    
    override var frameOfPresentedViewInContainerView: CGRect {
        return backgroundProvider.contentView.frame
    }
    
    private var backgroundProvider: CustomBackgroundProvider {
        return presentedViewController as! CustomBackgroundProvider
    }
    
    override func presentationTransitionWillBegin() {
        containerView?.insertSubview(presentedViewController.view, at: 0)
        
        presentedViewController.transitionCoordinator?.animate(alongsideTransition: { (context) in
            UIView.animate(withDuration: context.transitionDuration, animations: {
                self.backgroundProvider.presentationAnimation?()
            })
        }, completion: nil)
    }
    
    override func dismissalTransitionWillBegin() {
        presentedViewController.transitionCoordinator?.animate(alongsideTransition: { (context) in
            if let anim = self.backgroundProvider.dismissalAnimation {
                UIView.animate(withDuration: context.transitionDuration, animations: anim)
            }
        }, completion: nil)
    }
}

