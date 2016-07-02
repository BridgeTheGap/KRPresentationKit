//
//  KRTransition.swift
//  Pods
//
//  Created by Joshua Park on 7/1/16.
//
//

import UIKit
import KRAnimationKit

private typealias TransitionKey = String
private extension TransitionKey {
    static var FromVC: String { return UITransitionContextFromViewControllerKey }
    static var ToVC: String { return UITransitionContextToViewControllerKey }
    static var FromView: String { return UITransitionContextFromViewKey }
    static var ToView: String { return UITransitionContextToViewKey }
}

public enum KRTransitionStyle {
    case SlideUp(FunctionType?)
    case SlideDown(FunctionType?)
    case SlideLeft(FunctionType?)
    case SlideRight(FunctionType?)
    case Overlay(FunctionType?)
    case Popup(FunctionType?)
    case Custom((() -> Void) -> Void)
    case NoAnimation
}

public class KRPresentationController: UIPresentationController {
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
        presentedViewController.view.frame = frameOfPresentedViewInContainerView()
    }
    
    override public func sizeForChildContentContainer(container: UIContentContainer, withParentContainerSize parentSize: CGSize) -> CGSize {
        return frameOfPresentedViewInContainerView().size
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

public class KRTransitioner: NSObject, UIViewControllerTransitioningDelegate, UIViewControllerAnimatedTransitioning {
    public var transitionStyle: KRTransitionStyle
    public var duration: Double
    public var backgroundColor = UIColor(white: 0.0, alpha: 0.4)
    public var isPresenting: Bool!
    internal private(set) var presenter: KRPresentationController!
    
    public init(_ transitionStyle: KRTransitionStyle, duration: Double) {
        self.transitionStyle = transitionStyle
        self.duration = duration
    }
    
    // MARK: - Transitioning delegate
    
    public func presentationControllerForPresentedViewController(presented: UIViewController, presentingViewController presenting: UIViewController, sourceViewController source: UIViewController) -> UIPresentationController? {
        presenter = KRPresentationController(presentedViewController: presented, presentingViewController: presenting)
        presenter.backgroundView.backgroundColor = backgroundColor
        presenter.duration = duration
        return presenter
    }
    
    public func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        isPresenting = true
        return self
    }
    
    public func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        isPresenting = false
        return self
    }
    
    // MARK: - Animated transitioning
    
    public func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return duration
    }
    
    public func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        func completeTransition() {
            transitionContext.completeTransition(true)
        }
        
        let containerView = transitionContext.containerView()!
        let vcKey = isPresenting! ? TransitionKey.ToVC : TransitionKey.FromVC
        let animatingVC = transitionContext.viewControllerForKey(vcKey) as! KRContentViewController
        let useSnapshot = animatingVC.useSnapshot
        let destinationFrame = transitionContext.finalFrameForViewController(animatingVC)
        let animatingView = { () -> UIView in
            let view = animatingVC.view
            view.frame = destinationFrame
            
            if useSnapshot {
                let (shadowOpacity, autoResizing) = (view.layer.shadowOpacity, view.translatesAutoresizingMaskIntoConstraints)
                (view.layer.shadowOpacity, view.translatesAutoresizingMaskIntoConstraints) = (0, true)
                let snapshot = view.snapshotViewAfterScreenUpdates(true)
                snapshot.frame = destinationFrame
                (view.layer.shadowOpacity, view.translatesAutoresizingMaskIntoConstraints) = (shadowOpacity, autoResizing)
                return snapshot
            } else {
                return view
            }
        }()
        containerView.addSubview(animatingView)
        
        if isPresenting! {
            switch transitionStyle {
            case .SlideUp(let f):
                let function = f ?? .EaseInOutCubic
                animatingView.frame.origin.y += containerView.frame.height
                animatingView.animateY(destinationFrame.origin.y, duration: duration, function: function) {
                    if useSnapshot {
                        animatingView.removeFromSuperview()
                        containerView.addSubview(transitionContext.viewForKey(TransitionKey.ToView)!)
                    }
                    completeTransition()
                }
            default:
                break
            }
        } else {
            if useSnapshot { transitionContext.viewForKey(TransitionKey.FromView)!.removeFromSuperview() }
            
            switch transitionStyle {
            case .SlideUp(let f):
                let function = f ?? .EaseInOutCubic
                let destinationY = animatingView.frame.origin.y + containerView.frame.height
                animatingView.animateY(destinationY, duration: duration, function: function) {
                    animatingView.removeFromSuperview()
                    completeTransition()
                }
            default:
                break
            }
        }
    }
    
    public func animationEnded(transitionCompleted: Bool) {
        if transitionCompleted {
            presenter = nil
        }
    }
}