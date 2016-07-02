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
    public var isPresenting: Bool = true
    internal private(set) var presenter: KRPresentationController!
    private var snapshot: UIView?
    
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
        let vcKey = isPresenting ? TransitionKey.ToVC : TransitionKey.FromVC
        let animatingVC = transitionContext.viewControllerForKey(vcKey) as! KRContentViewController
        let useSnapshot = animatingVC.useSnapshot
        let finalFrame = transitionContext.finalFrameForViewController(animatingVC)
        let animatingView = { () -> UIView in
            let view = animatingVC.view
            view.frame = finalFrame
            
            if useSnapshot && snapshot == nil {
                let (shadowOpacity, autoResizing) = (view.layer.shadowOpacity, view.translatesAutoresizingMaskIntoConstraints)
                (view.layer.shadowOpacity, view.translatesAutoresizingMaskIntoConstraints) = (0, true)
                snapshot = view.snapshotViewAfterScreenUpdates(true)
                snapshot!.frame = finalFrame
                (view.layer.shadowOpacity, view.translatesAutoresizingMaskIntoConstraints) = (shadowOpacity, autoResizing)
                return snapshot!
            } else {
                return snapshot ?? view
            }
        }()
        containerView.addSubview(animatingView)
        
        var animations: [AnimationDescriptor]!
        var function: FunctionType!
        var completion: () -> Void
        
        if isPresenting {
            completion = {
                if useSnapshot {
                    animatingView.removeFromSuperview()
                    containerView.addSubview(transitionContext.viewForKey(TransitionKey.ToView)!)
                }
                completeTransition()
            }
            
            switch transitionStyle {
            case .SlideUp(let f):
                function = f ?? .EaseOutQuint
                animatingView.frame.origin.y += containerView.frame.height
                animations = animatingView.chainY(finalFrame.origin.y, duration: duration, function: function)
            case .SlideDown(let f):
                function = f ?? .EaseOutQuint
                animatingView.frame.origin.y -= containerView.frame.height
                animations = animatingView.chainY(finalFrame.origin.y, duration: duration, function: function)
            case .SlideLeft(let f):
                function = f ?? .EaseOutQuint
                animatingView.frame.origin.x += containerView.frame.width
                animations = animatingView.chainX(finalFrame.origin.x, duration: duration, function: function)
            case .SlideRight(let f):
                function = f ?? .EaseOutQuint
                animatingView.frame.origin.x -= containerView.frame.width
                animations = animatingView.chainX(finalFrame.origin.x, duration: duration, function: function)
            case .Overlay(let f):
                function = f ?? .EaseOutQuint
                animatingView.alpha = 0.0
                animatingView.layer.transform = CATransform3DMakeScale(2.0, 2.0, 1.0)
                animations = animatingView.chainScale2D(1.0, duration: duration, function: function) +
                    animatingView.chainAlpha(1.0, duration: duration, function: function)
            case .Popup(let f):
                function = f ?? .EaseOutQuint
                animatingView.alpha = 0.0
                animatingView.layer.transform = CATransform3DMakeScale(0.0, 0.0, 1.0)
                
                animations = animatingView.chainScale2D(1.0, duration: duration, function: function) +
                    animatingView.chainAlpha(1.0, duration: duration, function: function)
            default:
                break
            }
            
            if !useSnapshot {
                animatingView.layer.shadowOpacity = 0.0
                animations = animations + animatingView.chainShadowOpacity(1.0, duration: duration)
            }
        } else {
            if useSnapshot { transitionContext.viewForKey(TransitionKey.FromView)!.removeFromSuperview() }
            completion = {
                animatingView.removeFromSuperview()
                completeTransition()
            }
            
            switch transitionStyle {
            case .SlideUp(let f):
                function = f?.converseFunction() ?? .EaseOutQuint
                let finalY = animatingView.frame.origin.y + containerView.frame.height
                animations = animatingView.chainY(finalY, duration: duration, function: function)
            case .SlideDown(let f):
                function = f?.converseFunction() ?? .EaseOutQuint
                let finalY = animatingView.frame.origin.y - containerView.frame.height
                animations = animatingView.chainY(finalY, duration: duration, function: function)
            case .SlideLeft(let f):
                function = f?.converseFunction() ?? .EaseOutQuint
                let finalX = animatingView.frame.origin.x + containerView.frame.width
                animations = animatingView.chainX(finalX, duration: duration, function: function)
            case .SlideRight(let f):
                function = f?.converseFunction() ?? .EaseOutQuint
                let finalX = animatingView.frame.origin.x - containerView.frame.width
                animations = animatingView.chainX(finalX, duration: duration, function: function)
            case .Overlay(let f):
                function = f ?? .EaseOutQuint
                animations = animatingView.chainScale2D(2.0, duration: duration, function: function) +
                    animatingView.chainAlpha(0.0, duration: duration, function: function)
            case .Popup(let f):
                function = f ?? .EaseOutQuint
                animations = animatingView.chainScale2D(0.1, duration: duration, function: function) +
                    animatingView.chainAlpha(0.0, duration: duration, function: function)
            default:
                break
            }
            
            if !useSnapshot {
                animations = animations + animatingView.chainShadowOpacity(0.0, duration: duration)
            }
        }
        
        KRAnimation.chain(animations, completion: completion)
    }
    
    public func animationEnded(transitionCompleted: Bool) {
        if !isPresenting && transitionCompleted {
            presenter = nil
            snapshot = nil
        }
    }
}