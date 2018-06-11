//
//  PresentationController.swift
//  KRPresentationKit
//
//  Created by Joshua Park on 11/06/2018.
//

import UIKit

/**
 A default presentation controller provided custom presentation.
 The root view of the view controller to be presented (presented VC)
 should cover the whole screen.
 */
internal class PresentationController: UIPresentationController {
    
    weak var containerViewDelegate: ContainerViewDelegate?
    
    weak var transitioner: KRTransitioner?
    
    override func presentationTransitionWillBegin() { transition() }
    
    override func dismissalTransitionWillBegin() { transition() }
    
    private func transition() {
        containerViewDelegate?.prepare(containerView: containerView!, for: transitioner!)
        
        presentedViewController.transitionCoordinator?.animate(alongsideTransition: { [weak delegate = self.containerViewDelegate] (context) in
            UIView.animate(withDuration: context.transitionDuration, animations: {
                delegate?.animate(containerView: context.containerView, for: self.transitioner!)
            })
            }, completion: { [weak delegate = self.containerViewDelegate] (context) in
                delegate?.finalize(containerView: context.containerView, for: self.transitioner!)
        })
    }
}
