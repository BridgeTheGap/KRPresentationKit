//
//  KRTransitioningDelegate.swift
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
}

internal protocol KRTransitioningDelegate: UIViewControllerTransitioningDelegate, UIViewControllerAnimatedTransitioning {
    var transitionStyle: KRTransitionStyle { get set }
    var duration: Double { get set }
    var isPresenting: Bool { get set }
}

private extension KRTransitioningDelegate {
    func getAnimationsForView(animatingView: UIView, containerView: UIView, finalFrame: CGRect) -> [AnimationDescriptor] {
        var animations: [AnimationDescriptor]!
        var function: FunctionType!
        
        if isPresenting {
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
                fatalError("KRTransitionStyle.Custom not supported yet.")
            }
        } else {
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
                fatalError("KRTransitionStyle.Custom not supported yet.")
            }
        }
        
        return animations
    }
}

public class KRContentTransitioner: NSObject, KRTransitioningDelegate {
    public var transitionStyle: KRTransitionStyle
    public var duration: Double
    public var backgroundColor = UIColor(white: 0.0, alpha: 0.4)
    public var isPresenting: Bool = true
    public var isFading: Bool = false
    internal private(set) var presenter: KRContentPresentationController!
    private var snapshot: UIView?
    
    public init(_ transitionStyle: KRTransitionStyle, duration: Double) {
        self.transitionStyle = transitionStyle
        self.duration = duration
    }
    
    // MARK: - Transitioning delegate
    
    public func presentationControllerForPresentedViewController(presented: UIViewController, presentingViewController presenting: UIViewController, sourceViewController source: UIViewController) -> UIPresentationController? {
        guard let vc = presented as? KRContentViewController else {
            fatalError("\(presented) passed to \(#function) as `presented`. Use \(self) only for KRContentViewControllers.")
        }
        
        presenter = KRContentPresentationController(presentedViewController: presented, presentingViewController: presenting, backgroundView: isFading ? presenter.backgroundView : KRView(sender: vc.sender) ?? UIView())
        presenter.backgroundView.backgroundColor = backgroundColor
        
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
        
        var animations = getAnimationsForView(animatingView, containerView: containerView, finalFrame: finalFrame)
        var completion: () -> Void
        
        if isPresenting {
            completion = {
                if useSnapshot { containerView.addSubview(animatingVC.view) }
                transitionContext.completeTransition(true)
                self.isFading = false
            }
            
            if !useSnapshot && animatingView.layer.shadowOpacity > 0.0 {
                let shadowOpacity = animatingView.layer.shadowOpacity
                animatingView.layer.shadowOpacity = 0.0
                animations = animations + animatingView.chainShadowOpacity(shadowOpacity, duration: duration)
            }
        } else {
            if useSnapshot { animatingVC.view.removeFromSuperview() }
            
            completion = {
                animatingView.removeFromSuperview()
                transitionContext.completeTransition(true)
                self.snapshot = nil
            }
            
            if !useSnapshot && animatingView.layer.shadowOpacity > 0.0 {
                animations = animations + animatingView.chainShadowOpacity(0.0, duration: duration)
            }
        }
        
        KRAnimation.chain(animations, completion: completion)
    }
    
    public func animationEnded(transitionCompleted: Bool) {
        snapshot?.removeFromSuperview()
    }
}

public class KROverlayTransitioner: NSObject, KRTransitioningDelegate {
    public var transitionStyle: KRTransitionStyle
    public var duration: Double
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
        let containerView = transitionContext.containerView()!
        let vcKey = isPresenting ? TransitionKey.ToVC : TransitionKey.FromVC
        let animatingVC = transitionContext.viewControllerForKey(vcKey) as! KROverlayViewController
        let bgView = animatingVC.view
        let constraints = bgView.constraints
        let finalFrame = animatingVC.destinationFrame
        let useSnapshot = animatingVC.useSnapshot
        let contentViewIndex = bgView.subviews.indexOf(animatingVC.contentView)!
        let contentViewAutoResizing = animatingVC.contentView.translatesAutoresizingMaskIntoConstraints
        let animatingView = { () -> UIView in
            let view = animatingVC.contentView
            view.frame = finalFrame
            
            if useSnapshot && snapshot == nil {
                let (shadowOpacity, autoResizing) = (view.layer.shadowOpacity, view.translatesAutoresizingMaskIntoConstraints)
                (view.layer.shadowOpacity, view.translatesAutoresizingMaskIntoConstraints) = (0, true)
                snapshot = view.snapshotViewAfterScreenUpdates(true)
                snapshot!.frame = finalFrame
                (view.layer.shadowOpacity, view.translatesAutoresizingMaskIntoConstraints) = (shadowOpacity, autoResizing)
                view.hidden = true
                return snapshot!
            } else {
                return snapshot ?? view
            }
        }()
        
        containerView.insertSubview(bgView, atIndex: 0)
        containerView.addSubview(animatingView)
        animatingView.translatesAutoresizingMaskIntoConstraints = true
        
        var animations = animatingVC.backgroundAnim(duration, isPresenting) + getAnimationsForView(animatingView, containerView: containerView, finalFrame: finalFrame)
        var completion: (() -> Void)!
        
        if isPresenting {
            completion = {
                if useSnapshot { animatingVC.contentView.hidden = false }
                bgView.insertSubview(animatingVC.contentView, atIndex: contentViewIndex)
                animatingVC.contentView.translatesAutoresizingMaskIntoConstraints = contentViewAutoResizing
                NSLayoutConstraint.activateConstraints(constraints)
                
                transitionContext.completeTransition(true)
            }
            
            if !useSnapshot && animatingView.layer.shadowOpacity > 0.0 {
                let shadowOpacity = animatingView.layer.shadowOpacity
                animatingView.layer.shadowOpacity = 0.0
                animations = animations + animatingView.chainShadowOpacity(shadowOpacity, duration: duration)
            }
        } else {
            if useSnapshot { transitionContext.viewForKey(TransitionKey.FromView)!.removeFromSuperview() }
            
            completion = {
                animatingView.removeFromSuperview()
                transitionContext.completeTransition(true)
            }
            
            if !useSnapshot && animatingView.layer.shadowOpacity > 0.0 {
                animations = animations + animatingView.chainShadowOpacity(0.0, duration: duration)
            }
        }

        KRAnimation.chain(animations, completion: completion)
    }
    
    public func animationEnded(transitionCompleted: Bool) {
        snapshot?.removeFromSuperview()
    }
}
