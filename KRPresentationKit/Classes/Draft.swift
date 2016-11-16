//
//  Draft.swift
//  Pods
//
//  Created by Joshua Park on 10/11/2016.
//
//

import UIKit
import KRTimingFunction

// Preferably use protocols so presented controllers can also present other VCs

public enum Attribute {
    case alpha(CGFloat)
    case frame(CGRect)
    case position(CGPoint)
    case opacity(Float)
    case origin(CGPoint)
    case rotation(CGFloat)
    case scale(CGFloat)
    case size(CGSize)
    case translation(CGSize)
}

public enum FunctionType {
    case linear
    
    case easeInSine
    case easeOutSine
    case easeInOutSine
    
    case easeInQuad
    case easeOutQuad
    case easeInOutQuad
    
    case easeInCubic
    case easeOutCubic
    case easeInOutCubic
    
    case easeInQuart
    case easeOutQuart
    case easeInOutQuart
    
    case easeInQuint
    case easeOutQuint
    case easeInOutQuint
    
    case easeInExpo
    case easeOutExpo
    case easeInOutExpo
    
    case easeInCirc
    case easeOutCirc
    case easeInOutCirc
    
    case easeInBack
    case easeOutBack
    case easeInOutBack
    
    case easeInElastic
    case easeOutElastic
    case easeInOutElastic
    
    case easeInBounce
    case easeOutBounce
    case easeInOutBounce
    
    public func converseFunction() -> FunctionType {
        switch self {
        case .easeInSine: return .easeOutSine
        case .easeOutSine: return .easeInSine
        case .easeInQuad: return .easeOutQuad
        case .easeOutQuad: return .easeInQuad
        case .easeInCubic: return .easeOutCubic
        case .easeOutCubic: return .easeInCubic
        case .easeInQuart: return .easeOutQuart
        case .easeOutQuart: return .easeInQuart
        case .easeInQuint: return .easeOutQuint
        case .easeOutQuint: return .easeInQuint
        case .easeInExpo: return .easeOutExpo
        case .easeOutExpo: return .easeInExpo
        case .easeInCirc: return .easeOutCirc
        case .easeOutCirc: return .easeInCirc
        case .easeInBack: return .easeOutBack
        case .easeOutBack: return .easeInBack
        case .easeInElastic: return .easeOutElastic
        case .easeOutElastic: return .easeInElastic
        case .easeInBounce: return .easeOutBounce
        case .easeOutBounce: return .easeInBounce
        default: return self
        }
    }
}

public protocol TransitionDataType {
    var initial: [Attribute] { get set }
    var duration: Double { get set }
}

public struct TransitionAnimation: TransitionDataType {
    public var initial: [Attribute]
    public var options: UIViewAnimationOptions
    public var duration: Double
    
    public init(initial: [Attribute], options: UIViewAnimationOptions = [], duration: Double) {
        (self.initial, self.options, self.duration) = (initial, options, duration)
    }
}

public struct TransitionAttributes: TransitionDataType {
    public var initial: [Attribute]
    public var timingFunction: FunctionType
    public var duration: Double
    
    public init() {
        self.initial = [Attribute]()
        self.timingFunction = .easeInOutCubic
        self.duration = 0.3
    }

    public init(initial: [Attribute], timingFunction: FunctionType = .easeInOutCubic, duration: Double = 0.3) {
        (self.initial, self.timingFunction, self.duration) = (initial, timingFunction, duration)
    }
}

public protocol CustomPresenting {
    var transitioner: KRTransitioner? { get set }
}

public protocol CustomPresented {
    
}

public protocol CustomBackgroundProvider {
    var contentView: UIView! { get set }
}

//protocol ContentAnimatable {
//    
//}

internal class PresentationController: UIPresentationController {
    override var containerView: UIView? {
        get {
            if let vc = presentedViewController as? CustomBackgroundProvider {
                return (vc as! UIViewController).view
            } else {
                return super.containerView
            }
        }
    }
    
    override var presentedView: UIView? {
        get {
            if let vc = presentedViewController as? CustomBackgroundProvider {
                return vc.contentView
            } else {
                return super.presentedView
            }
        }
    }
    
    // Add background tap to hide
    override func presentationTransitionWillBegin() {
        super.presentationTransitionWillBegin()
    }
    
    override func containerViewWillLayoutSubviews() {
        super.containerViewWillLayoutSubviews()
    }
    
    override func containerViewDidLayoutSubviews() {
        super.containerViewDidLayoutSubviews()
    }
    
    override func presentationTransitionDidEnd(_ completed: Bool) {
        super.presentationTransitionDidEnd(completed)
    }
}

public class KRTransitioner: NSObject, UIViewControllerTransitioningDelegate, UIViewControllerAnimatedTransitioning {
    public var attributes: TransitionDataType
    private(set) var isPresenting = true
    internal private(set) var presenter: PresentationController?
    
    public init(attributes: TransitionDataType) {
        self.attributes = attributes
    }
    
    public override convenience init() {
        self.init(attributes: TransitionAttributes())
    }
    
    // MARK: - Transitioning delegate
    
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        isPresenting = true
        return self
    }
    
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        isPresenting = false
        return self
    }
    
    public func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        if presented is CustomBackgroundProvider {
            presenter = PresentationController(presentedViewController: presented, presenting: presenting)
        } else {
            presenter = PresentationController(presentedViewController: presented, presenting: presenting)
        }
        
        return presenter
    }
    
    // MARK: - Animated transitioning
    
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return attributes.duration
    }
    
    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        if isPresenting {
            let toView = transitionContext.view(forKey: UITransitionContextViewKey.to)!
            let targetAttrib = apply(attributes: attributes.initial, to: toView)
            let completion = { (didComplete: Bool) in
                if !didComplete { toView.removeFromSuperview() }
                transitionContext.completeTransition(didComplete)
            }
            
            transitionContext.containerView.addSubview(toView)
            
            if let animation = attributes as? TransitionAnimation {
                UIView.animate(withDuration: animation.duration,
                               delay: 0.0,
                               options: animation.options,
                               animations: { self.set(view: toView, using: targetAttrib) })
                { (_) in
                    // TODO: Check if animation completion status should be a factor to revert
                    completion(!transitionContext.transitionWasCancelled)
                }
            } else {
                KRAnimation.chain(animation(for: toView, using: targetAttrib)) {
                    completion(!transitionContext.transitionWasCancelled)
                }
                set(view: toView, using: targetAttrib)
            }
        } else {
            let fromView = transitionContext.view(forKey: UITransitionContextViewKey.from)!
            let completion = { (didComplete: Bool) in
                if didComplete { fromView.removeFromSuperview() }
                transitionContext.completeTransition(didComplete)
            }
            
            if let animation = attributes as? TransitionAnimation {
                UIView.animate(withDuration: animation.duration,
                               delay: 0.0,
                               options: animation.options,
                               animations: { self.set(view: fromView, using: animation.initial) })
                { (_) in
                    completion(!transitionContext.transitionWasCancelled)
                }
            } else {
                KRAnimation.chain(animation(for: fromView, using: attributes.initial)) {
                    completion(!transitionContext.transitionWasCancelled)
                }
            }
        }
    }
    
    public func animationEnded(_ transitionCompleted: Bool) {
        print("YOLO")
    }
    
    // MARK: - Private
    
    @discardableResult private func apply(attributes: [Attribute], to view: UIView) -> [Attribute] {
        var targetAttrib = [Attribute]()
        for attrib in attributes {
            switch attrib {
            case .alpha(let alpha):
                targetAttrib.append(.alpha(view.alpha))
                view.alpha = alpha
            case .frame(let frame):
                targetAttrib.append(.frame(view.frame))
                view.frame = frame
            case .opacity(let opacity):
                targetAttrib.append(.opacity(view.layer.opacity))
                view.layer.opacity = opacity
            case .origin(let origin):
                targetAttrib.append(.origin(view.frame.origin))
                view.frame.origin = origin
            case .position(let position):
                targetAttrib.append(.position(view.layer.position))
                view.layer.position = position
            case .rotation(let rotation):
                targetAttrib.append(.rotation(-rotation))
                let angle = radians(from: rotation)
                view.layer.transform = CATransform3DRotate(view.layer.transform, angle, 0.0, 0.0, 1.0)
            case .scale(let scale):
                targetAttrib.append(.scale(1.0/scale))
                view.layer.transform = CATransform3DScale(view.layer.transform, scale, scale, 1.0)
            case .size(let size):
                targetAttrib.append(.size(view.bounds.size))
                view.bounds.size = size
            case .translation(let translation):
                targetAttrib.append(.translation(CGSize(width: -translation.width, height: -translation.height)))
                view.layer.transform = CATransform3DTranslate(view.layer.transform, translation.width, translation.height, 0.0)
            }
        }
        return targetAttrib
    }
    
    private func animation(for toView: UIView, using targetAttributes: [Attribute]) -> [AnimationDescriptor] {
        guard let attributes = attributes as? TransitionAttributes else {
            fatalError("<KRPresentationKit> - Failed to cast `attributes` as TransitionAttributes.")
        }
        
        let d = attributes.duration
        let f = attributes.timingFunction
        
        var anim = [AnimationDescriptor]()
        
        for attrib in targetAttributes {
            switch attrib {
            case .alpha(let alpha):
                anim += toView.chain(alpha: alpha, duration: d, function: f)
            case .frame(let frame):
                anim += toView.chain(frame: frame, duration: d, function: f)
            case .opacity(let opacity):
                anim += toView.chain(opacity: opacity, duration: d, function: f)
            case .origin(let origin):
                anim += toView.chain(origin: origin, duration: d, function: f)
            case .position(let position):
                anim += toView.chain(position: position, duration: d, function: f)
            case .rotation(let rotation):
                anim += toView.chain(rotationDeg: rotation, duration: d, function: f)
            case .scale(let scale):
                anim += toView.chain(scale2D: scale, duration: d, function: f)
            case .size(let size):
                anim += toView.chain(size: size, duration: d, function: f)
            case .translation(let translation):
                anim += toView.chain(translation2D: translation, duration: d, function: f)
            }
        }
        return anim
    }
    
    private func set(view: UIView, using targetAttributes: [Attribute]) {
        for attrib in targetAttributes {
            switch attrib {
            case .alpha(let alpha):
                view.alpha = alpha
            case .frame(let frame):
                view.frame = frame
            case .opacity(let opacity):
                view.layer.opacity = opacity
            case .origin(let origin):
                view.frame.origin = origin
            case .position(let position):
                view.layer.position = position
            case .rotation(let rotation):
                let angle = radians(from: rotation)
                view.layer.transform = CATransform3DRotate(view.layer.transform, angle, 0.0, 0.0, 1.0)
            case .scale(let scale):
                view.layer.transform = CATransform3DScale(view.layer.transform, scale, scale, 1.0)
            case .size(let size):
                view.bounds.size = size
            case .translation(let translation):
                view.layer.transform = CATransform3DTranslate(view.layer.transform, translation.width, translation.height, 0.0)
            }
        }
    }
}
