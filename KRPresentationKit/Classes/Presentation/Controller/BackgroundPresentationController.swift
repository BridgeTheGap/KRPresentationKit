//
//  BackgroundPresentationController.swift
//  KRPresentationKit
//
//  Created by Joshua Park on 11/06/2018.
//

import UIKit

/**
 A presentation controller that is provided when
 the presented view controller itself provides a decorative background
 and a content view that covers only a portion of the screen.
 */
internal class BackgroundPresentationController: UIPresentationController {
    
    private typealias TransitionClosure = (UIViewControllerTransitionCoordinatorContext) -> Void

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
        
        let transition: TransitionClosure = { [weak self] (context) in
            guard let weakSelf = self else { return }
            guard let anim = weakSelf.backgroundProvider.presentationAnimation else { return }
            
            UIView.animate(withDuration: context.transitionDuration,
                           animations: anim)
        }
        
        presentedViewController
            .transitionCoordinator?
            .animate(alongsideTransition: transition)
    }
    
    override func dismissalTransitionWillBegin() {
        let transition: TransitionClosure = { [weak self] (context) in
            guard let weakSelf = self else { return }
            guard let anim = weakSelf.backgroundProvider.dismissalAnimation else { return }
            
            UIView.animate(withDuration: context.transitionDuration,
                           animations: anim)
        }
        
        presentedViewController
            .transitionCoordinator?
            .animate(alongsideTransition: transition,
                     completion: nil)
    }
}

