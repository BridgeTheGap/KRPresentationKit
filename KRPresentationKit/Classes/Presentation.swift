//
//  Presentation.swift
//  Pods
//
//  Created by Joshua Park on 23/11/2016.
//
//

import UIKit

public protocol CustomPresenting: class {
    var transitioner: KRTransitioner? { get set }
}

public protocol CustomPresented: class {
    weak var customPresenting: UIViewController? { get set }
}

public protocol ContainerViewDelegate: class {
    func prepare(containerView: UIView, for transitioner: KRTransitioner)
    func animate(containerView: UIView, for transitioner: KRTransitioner)
    func finalize(containerView: UIView, for transitioner: KRTransitioner)
}

public protocol CustomBackgroundProvider: class {
    weak var contentView: UIView! { get }
    var presentationAnimation: (() -> Void)? { get }
    var dismissalAnimation: (() -> Void)? { get }
}

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

