//
//  KRPresentation.swift
//  Pods
//
//  Created by Joshua Park on 7/3/16.
//
//

import UIKit

public class KRPresentationController: UIPresentationController {
    override public func containerViewWillLayoutSubviews() {
        super.containerViewWillLayoutSubviews()
        presentedViewController.view.frame = frameOfPresentedViewInContainerView()
    }
    
    override public func sizeForChildContentContainer(container: UIContentContainer, withParentContainerSize parentSize: CGSize) -> CGSize {
        return frameOfPresentedViewInContainerView().size
    }
    
    override public func frameOfPresentedViewInContainerView() -> CGRect {
        return containerView!.bounds
    }
}

public class KRContentPresentationController: KRPresentationController {
    var backgroundView = UIView()
    var duration: Double!
    
    override public init(presentedViewController: UIViewController, presentingViewController: UIViewController) {
        super.init(presentedViewController: presentedViewController, presentingViewController: presentingViewController)
        
        backgroundView.alpha = 0.0
        backgroundView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(bgTapAction(_:))))
    }
    
    override public func containerViewWillLayoutSubviews() {
        super.containerViewWillLayoutSubviews()
        backgroundView.frame = containerView!.frame
    }
    
    override public func frameOfPresentedViewInContainerView() -> CGRect {
        return (presentedViewController as! KRContentViewController).destinationFrame
    }
    
    override public func presentationTransitionWillBegin() {
        containerView!.insertSubview(backgroundView, atIndex: 0)
        
        presentedViewController.transitionCoordinator()!.animateAlongsideTransition({ (context) in
            self.backgroundView.animateAlpha(1.0, duration: self.duration)
            }, completion: nil)
    }
    
    override public func dismissalTransitionWillBegin() {
        presentedViewController.transitionCoordinator()!.animateAlongsideTransition({ (context) in
            self.backgroundView.animateAlpha(0.0, duration: self.duration)
            }, completion: nil)
    }
    
    // MARK: - Private
    
    @objc private func bgTapAction(gr: UITapGestureRecognizer) {
        presentingViewController.dismissViewControllerAnimated(true, completion: nil)
    }
}