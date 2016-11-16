#if false
//
//  KRPresentation.swift
//  Pods
//
//  Created by Joshua Park on 7/3/16.
//
//

import UIKit

open class KRPresentationController: UIPresentationController, UIGestureRecognizerDelegate {
    override open func containerViewWillLayoutSubviews() {
        super.containerViewWillLayoutSubviews()
        presentedViewController.view.frame = frameOfPresentedViewInContainerView
    }
    
    override open func size(forChildContentContainer container: UIContentContainer, withParentContainerSize parentSize: CGSize) -> CGSize {
        return frameOfPresentedViewInContainerView.size
    }
    
    override open var frameOfPresentedViewInContainerView : CGRect {
        return containerView!.bounds
    }
    
    override open func presentationTransitionWillBegin() {
        if (containerView!.gestureRecognizers ?? []).isEmpty {
            let tap = UITapGestureRecognizer(target: self, action: #selector(bgTapAction(_:)))
            tap.delegate = self
            containerView!.addGestureRecognizer(tap)
        }
    }
    
    // MARK: - Gesture recognizer
    open func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return touch.view! !== (presentedViewController as! KROverlayViewController).contentView
    }
    
    @objc fileprivate func bgTapAction(_ gr: UITapGestureRecognizer) {
        presentingViewController.dismiss(animated: true, completion: nil)
    }
}

open class KRContentPresentationController: KRPresentationController {
    var backgroundView: UIView!
    
    public init(presentedViewController: UIViewController, presentingViewController: UIViewController?, backgroundView: UIView) {
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
        
        backgroundView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(bgTapAction(_:))))
        self.backgroundView = backgroundView
    }
    
    convenience override init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?) {
        self.init(presentedViewController: presentedViewController, presentingViewController: presentingViewController, backgroundView: UIView())
    }
    
    override open func containerViewWillLayoutSubviews() {
        super.containerViewWillLayoutSubviews()
        backgroundView.frame = containerView!.frame
    }
    
    override open var frameOfPresentedViewInContainerView : CGRect {
        return (presentedViewController as! KRContentViewController).destinationFrame
    }
    
    override open func presentationTransitionWillBegin() {
        let transitioningDelegate = presentedViewController.transitioningDelegate as! KRContentTransitioner
        
        if transitioningDelegate.isFading {
            containerView!.insertSubview(backgroundView, at: 0)
        } else {
            backgroundView.alpha = 0.0
            containerView!.insertSubview(backgroundView, at: 0)
            presentedViewController.transitionCoordinator!.animate(alongsideTransition: { (context) in
                self.backgroundView.animate(alpha: 1.0, duration: transitioningDelegate.duration)
                }, completion: nil)
        }
    }
    
    override open func dismissalTransitionWillBegin() {
        let transitioningDelegate = presentedViewController.transitioningDelegate as! KRContentTransitioner
        
        if transitioningDelegate.isFading {
            presentingViewController.view.addSubview(backgroundView)
        } else {
            presentedViewController.transitionCoordinator!.animate(alongsideTransition: { (context) in
                self.backgroundView.animate(alpha: 0.0, duration: transitioningDelegate.duration)
                }, completion: nil)
        }
    }
}
#endif
