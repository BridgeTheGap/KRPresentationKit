#if false
//
//  KRTransitioningDelegate.swift
//  Pods
//
//  Created by Joshua Park on 7/1/16.
//
//

import UIKit
import KRAnimationKit

internal typealias TransitionKey = String
internal extension TransitionKey {
    static var fromVC: String { return UITransitionContextViewControllerKey.from.rawValue }
    static var toVC: String { return UITransitionContextViewControllerKey.to.rawValue }
    static var fromView: String { return UITransitionContextViewKey.from.rawValue }
    static var toView: String { return UITransitionContextViewKey.to.rawValue }
}

public enum KRTransitionStyle {
    case slideUp(FunctionType?)
    case slideDown(FunctionType?)
    case slideLeft(FunctionType?)
    case slideRight(FunctionType?)
    case overlay(FunctionType?)
    case popup(FunctionType?)
    case custom((_ view: UIView, _ duration: Double) -> [AnimationDescriptor], (_ view: UIView, _ duration: Double) -> [AnimationDescriptor])
    
    public static func getCustomAnimations(_ presentAnim: @escaping (_ view: UIView, _ duration: Double) -> [AnimationDescriptor], dismissAnim: @escaping (_ view: UIView, _ duration: Double) -> [AnimationDescriptor]) -> KRTransitionStyle {
        return self.custom(presentAnim, dismissAnim)
    }
}

internal protocol KRTransitioningDelegate: UIViewControllerTransitioningDelegate, UIViewControllerAnimatedTransitioning {
    var transitionStyle: KRTransitionStyle { get set }
    var duration: Double { get set }
    var isPresenting: Bool { get set }
}

fileprivate extension KRTransitioningDelegate {
    func getAnimations(for animatingView: UIView, containerView: UIView, finalFrame: CGRect) -> [AnimationDescriptor] {
        var animations: [AnimationDescriptor]!
        var function: FunctionType!
        
        if isPresenting {
            switch transitionStyle {
            case .slideUp(let f):
                function = f ?? .easeOutQuint
                animatingView.frame.origin.y += containerView.frame.height
                animations = animatingView.chain(y: finalFrame.origin.y, duration: duration, function: function)
            case .slideDown(let f):
                function = f ?? .easeOutQuint
                animatingView.frame.origin.y -= containerView.frame.height
                animations = animatingView.chain(y: finalFrame.origin.y, duration: duration, function: function)
            case .slideLeft(let f):
                function = f ?? .easeOutQuint
                animatingView.frame.origin.x += containerView.frame.width
                animations = animatingView.chain(x: finalFrame.origin.x, duration: duration, function: function)
            case .slideRight(let f):
                function = f ?? .easeOutQuint
                animatingView.frame.origin.x -= containerView.frame.width
                animations = animatingView.chain(x: finalFrame.origin.x, duration: duration, function: function)
            case .overlay(let f):
                function = f ?? .easeOutQuint
                animatingView.alpha = 0.0
                animatingView.layer.transform = CATransform3DMakeScale(2.0, 2.0, 1.0)
                animations = animatingView.chain(scale2D: 1.0, duration: duration, function: function) +
                    animatingView.chain(alpha: 1.0, duration: duration, function: function)
            case .popup(let f):
                function = f ?? .easeOutQuint
                animatingView.alpha = 0.0
                animatingView.layer.transform = CATransform3DMakeScale(0.0, 0.0, 1.0)
                
                animations = animatingView.chain(scale2D: 1.0, duration: duration, function: function) +
                    animatingView.chain(alpha: 1.0, duration: duration, function: function)
            case .custom(let presentingAnim, _):
                animations = presentingAnim(animatingView, duration)
            }
        } else {
            switch transitionStyle {
            case .slideUp(let f):
                function = f?.converseFunction() ?? .easeOutQuint
                let finalY = animatingView.frame.origin.y + containerView.frame.height
                animations = animatingView.chain(y: finalY, duration: duration, function: function)
            case .slideDown(let f):
                function = f?.converseFunction() ?? .easeOutQuint
                let finalY = animatingView.frame.origin.y - containerView.frame.height
                animations = animatingView.chain(y: finalY, duration: duration, function: function)
            case .slideLeft(let f):
                function = f?.converseFunction() ?? .easeOutQuint
                let finalX = animatingView.frame.origin.x + containerView.frame.width
                animations = animatingView.chain(x: finalX, duration: duration, function: function)
            case .slideRight(let f):
                function = f?.converseFunction() ?? .easeOutQuint
                let finalX = animatingView.frame.origin.x - containerView.frame.width
                animations = animatingView.chain(x: finalX, duration: duration, function: function)
            case .overlay(let f):
                function = f ?? .easeOutQuint
                animations = animatingView.chain(scale2D: 2.0, duration: duration, function: function) +
                    animatingView.chain(alpha: 0.0, duration: duration, function: function)
            case .popup(let f):
                function = f ?? .easeOutQuint
                animations = animatingView.chain(scale2D: 0.1, duration: duration, function: function) +
                    animatingView.chain(alpha: 0.0, duration: duration, function: function)
            case .custom(_, let dismissingAnim):
                animations = dismissingAnim(animatingView, duration)
            }
        }
        
        return animations
    }
}

open class KRContentTransitioner: NSObject, KRTransitioningDelegate {
    open var transitionStyle: KRTransitionStyle
    open var duration: Double
    open var backgroundColor = UIColor(white: 0.0, alpha: 0.4)
    open var isPresenting: Bool = true
    open var isFading: Bool = false
    internal private(set) var presenter: KRContentPresentationController!
    private var snapshot: UIView?
    
    public init(_ transitionStyle: KRTransitionStyle, duration: Double) {
        self.transitionStyle = transitionStyle
        self.duration = duration
    }
    
    // MARK: - Transitioning delegate
    
    open func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        guard let vc = presented as? KRContentViewController else {
            fatalError("\(presented) passed to \(#function) as `presented`. Use \(self) only for KRContentViewControllers.")
        }
        
        presenter = KRContentPresentationController(presentedViewController: presented, presentingViewController: presenting, backgroundView: isFading ? presenter.backgroundView : KRView(sender: vc.sender) ?? UIView())
        presenter.backgroundView.backgroundColor = backgroundColor
        
        return presenter
    }
    
    open func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        isPresenting = true
        return self
    }
    
    open func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        isPresenting = false
        return self
    }
    
    // MARK: - Animated transitioning
    
    open func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    open func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        let vcKey = isPresenting ? TransitionKey.toVC : TransitionKey.fromVC
        let animatingVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey(rawValue: vcKey)) as! KRContentViewController
        let useSnapshot = animatingVC.useSnapshot
        let finalFrame = transitionContext.finalFrame(for: animatingVC)
        let animatingView = { () -> UIView in
            let view = animatingVC.view
            view?.frame = finalFrame
            
            if useSnapshot && snapshot == nil {
                let (shadowOpacity, autoResizing) = (view?.layer.shadowOpacity, view?.translatesAutoresizingMaskIntoConstraints)
                view?.layer.shadowOpacity = 0.0
                view?.translatesAutoresizingMaskIntoConstraints = true
                
                snapshot = view?.snapshotView(afterScreenUpdates: true)
                snapshot!.frame = finalFrame
                view?.layer.shadowOpacity = shadowOpacity!
                view?.translatesAutoresizingMaskIntoConstraints = autoResizing!
                
                return snapshot!
            } else {
                return snapshot ?? view!
            }
        }()
        containerView.addSubview(animatingView)
        
        var animations = getAnimations(for: animatingView, containerView: containerView, finalFrame: finalFrame)
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
                animations = animations + animatingView.chain(shadowOpacity: shadowOpacity, duration: duration)
            }
        } else {
            if useSnapshot { animatingVC.view.removeFromSuperview() }
            
            completion = {
                animatingView.removeFromSuperview()
                transitionContext.completeTransition(true)
                self.snapshot = nil
            }
            
            if !useSnapshot && animatingView.layer.shadowOpacity > 0.0 {
                animations = animations + animatingView.chain(shadowOpacity: 0.0, duration: duration)
            }
        }
        
        KRAnimation.chain(animations, completion: completion)
    }
    
    open func animationEnded(_ transitionCompleted: Bool) {
        snapshot?.removeFromSuperview()
    }
}

open class KROverlayTransitioner: NSObject, KRTransitioningDelegate {
    open var transitionStyle: KRTransitionStyle
    open var duration: Double
    open var isPresenting: Bool = true
    internal fileprivate(set) var presenter: KRPresentationController!
    private var snapshot: UIView?
    
    public init(_ transitionStyle: KRTransitionStyle, duration: Double) {
        self.transitionStyle = transitionStyle
        self.duration = duration
    }
    
    // MARK: - Transitioning delegate
    
    open func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        presenter = KRPresentationController(presentedViewController: presented, presenting: presenting)
        
        return presenter
    }
    
    open func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        isPresenting = true
        return self
    }
    
    open func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        isPresenting = false
        return self
    }
    
    // MARK: - Animated transitioning
    
    open func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    open func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        let vcKey = isPresenting ? TransitionKey.toVC : TransitionKey.fromVC
        let animatingVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey(rawValue: vcKey)) as! KROverlayViewController
        let bgView = animatingVC.view
        let constraints = bgView?.constraints
        let finalFrame = animatingVC.destinationFrame
        let useSnapshot = animatingVC.useSnapshot
        let contentViewIndex = bgView?.subviews.index(of: animatingVC.contentView)!
        let contentViewAutoResizing = animatingVC.contentView.translatesAutoresizingMaskIntoConstraints
        let animatingView = { () -> UIView in
            let view = animatingVC.contentView
            view?.frame = finalFrame
            
            if useSnapshot && snapshot == nil {
                let (shadowOpacity, autoResizing) = (view?.layer.shadowOpacity, view?.translatesAutoresizingMaskIntoConstraints)
                view?.layer.shadowOpacity = 0.0
                view?.translatesAutoresizingMaskIntoConstraints = true
                
                snapshot = view?.snapshotView(afterScreenUpdates: true)
                snapshot!.frame = finalFrame
                
                view?.layer.shadowOpacity = shadowOpacity!
                view?.translatesAutoresizingMaskIntoConstraints = autoResizing!
                
                view?.isHidden = true
                return snapshot!
            } else {
                return snapshot ?? view!
            }
        }()
        
        containerView.insertSubview(bgView!, at: 0)
        containerView.addSubview(animatingView)
        animatingView.translatesAutoresizingMaskIntoConstraints = true
        
        var animations = animatingVC.backgroundAnim(duration, isPresenting) + getAnimations(for: animatingView, containerView: containerView, finalFrame: finalFrame)
        var completion: (() -> Void)!
        
        if isPresenting {
            completion = {
                if useSnapshot { animatingVC.contentView.isHidden = false }
                bgView?.insertSubview(animatingVC.contentView, at: contentViewIndex!)
                animatingVC.contentView.translatesAutoresizingMaskIntoConstraints = contentViewAutoResizing
                NSLayoutConstraint.activate(constraints!)
                
                transitionContext.completeTransition(true)
            }
            
            if !useSnapshot && animatingView.layer.shadowOpacity > 0.0 {
                let shadowOpacity = animatingView.layer.shadowOpacity
                animatingView.layer.shadowOpacity = 0.0
                animations = animations + animatingView.chain(shadowOpacity: shadowOpacity, duration: duration)
            }
        } else {
            if useSnapshot { transitionContext.view(forKey: UITransitionContextViewKey(rawValue: TransitionKey.fromView))!.removeFromSuperview() }
            
            completion = {
                animatingView.removeFromSuperview()
                transitionContext.completeTransition(true)
            }
            
            if !useSnapshot && animatingView.layer.shadowOpacity > 0.0 {
                animations = animations + animatingView.chain(shadowOpacity: 0.0, duration: duration)
            }
        }

        KRAnimation.chain(animations, completion: completion)
    }
    
    open func animationEnded(_ transitionCompleted: Bool) {
        snapshot?.removeFromSuperview()
    }
}
#endif
