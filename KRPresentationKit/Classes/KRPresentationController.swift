//
//  KRPresentation.swift
//  Pods
//
//  Created by Joshua Park on 7/3/16.
//
//

import UIKit

public class KRPresentationController: UIPresentationController, UIGestureRecognizerDelegate {
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
    
    override public func presentationTransitionWillBegin() {
        if (containerView!.gestureRecognizers ?? []).isEmpty {
            let tap = UITapGestureRecognizer(target: self, action: #selector(bgTapAction(_:)))
            tap.delegate = self
            containerView!.addGestureRecognizer(tap)
        }
    }
    
    // MARK: - Gesture recognizer
    public func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        return touch.view! !== (presentedViewController as! KROverlayViewController).contentView
    }
    
    @objc private func bgTapAction(gr: UITapGestureRecognizer) {
        presentingViewController.dismissViewControllerAnimated(true, completion: nil)
    }
}

public class KRContentPresentationController: KRPresentationController {
    var backgroundView = UIView() {
        didSet {
            backgroundView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(bgTapAction(_:))))
        }
    }
    
    public init(presentedViewController: UIViewController, presentingViewController: UIViewController, backgroundView: UIView) {
        super.init(presentedViewController: presentedViewController, presentingViewController: presentingViewController)
        
        backgroundView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(bgTapAction(_:))))
        self.backgroundView = backgroundView
    }
    
    convenience override init(presentedViewController: UIViewController, presentingViewController: UIViewController) {
        self.init(presentedViewController: presentedViewController, presentingViewController: presentingViewController, backgroundView: UIView())
    }
    
    override public func containerViewWillLayoutSubviews() {
        super.containerViewWillLayoutSubviews()
        backgroundView.frame = containerView!.frame
    }
    
    override public func frameOfPresentedViewInContainerView() -> CGRect {
        return (presentedViewController as! KRContentViewController).destinationFrame
    }
    
    override public func presentationTransitionWillBegin() {
        let transitioningDelegate = presentedViewController.transitioningDelegate as! KRContentTransitioner
        
        if transitioningDelegate.isFading {
            containerView!.insertSubview(backgroundView, atIndex: 0)
        } else {
            backgroundView.alpha = 0.0
            containerView!.insertSubview(backgroundView, atIndex: 0)
            presentedViewController.transitionCoordinator()!.animateAlongsideTransition({ (context) in
                self.backgroundView.animateAlpha(1.0, duration: transitioningDelegate.duration)
                }, completion: nil)
        }
    }
    
    override public func dismissalTransitionWillBegin() {
        let transitioningDelegate = presentedViewController.transitioningDelegate as! KRContentTransitioner
        
        if transitioningDelegate.isFading {
            presentingViewController.view.addSubview(backgroundView)
        } else {
            presentedViewController.transitionCoordinator()!.animateAlongsideTransition({ (context) in
                self.backgroundView.animateAlpha(0.0, duration: transitioningDelegate.duration)
                }, completion: nil)
        }
    }
}