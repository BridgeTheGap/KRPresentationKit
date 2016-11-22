//
//  Draft.swift
//  Pods
//
//  Created by Joshua Park on 10/11/2016.
//
//

import UIKit
import KRTimingFunction

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
    public var duration: Double
    public var timingFunction: FunctionType
    public var shouldInvertForDismissal: Bool = true
    
    public init() {
        self.initial = [Attribute]()
        self.timingFunction = .easeInOutCubic
        self.duration = 0.3
    }

    public init(initial: [Attribute], timingFunction: FunctionType = .easeInOutCubic, duration: Double = 0.3) {
        (self.initial, self.timingFunction, self.duration) = (initial, timingFunction, duration)
    }
}

public protocol CustomPresenting: NSObjectProtocol {
    var transitioner: KRTransitioner? { get set }
}

public protocol ContainerViewDelegate: NSObjectProtocol {
    func prepare(containerView: UIView, for transitionID: String?)
    func animate(containerView: UIView, for transitionID: String?, isPresenting: Bool)
    func finalize(containerView: UIView, for transitionID: String?, isPresenting: Bool)
}

public protocol CustomBackgroundProvider: NSObjectProtocol {
    var contentView: UIView! { get set }
    var presentationAnimation: (() -> Void)? { get }
    var dismissalAnimation: (() -> Void)? { get }
}

public protocol CrossfadingTransition: CustomPresenting {
    func fade(to viewController: UIViewController, using transitioner: KRTransitioner?, completion: (() -> Void)?)
}

public extension CrossfadingTransition {
    func fade(to viewController: UIViewController, using transitioner: KRTransitioner?, completion: (() -> Void)?) {
        let me = self as! UIViewController
        
        me.dismiss(animated: true, completion: {
            let transitioner = { () -> KRTransitioner? in
                if transitioner === self.transitioner {
                    let t = KRTransitioner(attributes: transitioner!.attributes)
                    t.transitionID = transitioner!.transitionID
                    t.containerViewDelegate = transitioner!.containerViewDelegate
                    return t
                } else {
                    return transitioner
                }
            }()
            
            self.transitioner = transitioner
            
            viewController.transitioningDelegate = transitioner
            viewController.modalPresentationStyle = .custom
            me.present(viewController, animated: true, completion: completion)
        })
    }
}

protocol ContentAnimatable: NSObjectProtocol {
    
}

internal class PresentationController: UIPresentationController {
    weak var containerViewDelegate: ContainerViewDelegate?
    fileprivate var transitionID: String?
    
    override func presentationTransitionWillBegin() {
        let id = transitionID
        containerViewDelegate?.prepare(containerView: containerView!, for: id)
        
        presentedViewController.transitionCoordinator?.animate(alongsideTransition: { [weak delegate = self.containerViewDelegate] (context) in
            UIView.animate(withDuration: context.transitionDuration, animations: { 
                delegate?.animate(containerView: context.containerView, for: id, isPresenting: true)
            })
        }, completion: { [weak delegate = self.containerViewDelegate] (context) in
            delegate?.finalize(containerView: context.containerView, for: id, isPresenting: true)
        })
    }
    
    override func dismissalTransitionWillBegin() {
        let id = transitionID
        
        presentedViewController.transitionCoordinator?.animate(alongsideTransition:{ [weak delegate = self.containerViewDelegate] (context) in
            UIView.animate(withDuration: context.transitionDuration, animations: {
                delegate?.animate(containerView: context.containerView, for: id, isPresenting: false)
            })
        }, completion: { [weak delegate = self.containerViewDelegate] (context) in
            delegate?.finalize(containerView: context.containerView, for: id, isPresenting: false)
        })
    }
}

internal class BackgroundPresentationController: UIPresentationController {
    
    override var presentedView: UIView? {
        return backgroundProvider.contentView
    }
    
    override var frameOfPresentedViewInContainerView: CGRect {
        return backgroundProvider.contentView.frame
    }
    
    private var backgroundProvider: CustomBackgroundProvider {
        return presentedViewController as! CustomBackgroundProvider
    }
    
    // MARK: - Presentation

    override func presentationTransitionWillBegin() {
        containerView?.insertSubview(presentedViewController.view, at: 0)
        
        presentedViewController.transitionCoordinator?.animate(alongsideTransition: { (context) in
            if let anim = self.backgroundProvider.presentationAnimation {
                UIView.animate(withDuration: context.transitionDuration, animations: anim)
            }
        }, completion: nil)
    }

    // MARK: - Dismissal
    
    override func dismissalTransitionWillBegin() {
        presentedViewController.transitionCoordinator?.animate(alongsideTransition: { (context) in
            if let anim = self.backgroundProvider.dismissalAnimation {
                UIView.animate(withDuration: context.transitionDuration, animations: anim)
            }
        }, completion: nil)
    }
}

public class KRTransitioner: NSObject, UIViewControllerTransitioningDelegate, UIViewControllerAnimatedTransitioning {
    public var transitionID: String?
    public var attributes: TransitionDataType
    public weak var containerViewDelegate: ContainerViewDelegate?
    internal private(set) var isPresenting = true
    internal private(set) var presenter: UIPresentationController?
    
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
        
        if containerViewDelegate != nil {
            let presenter = PresentationController(presentedViewController: presented, presenting: presenting)
            (presenter.containerViewDelegate, presenter.transitionID) = (containerViewDelegate, transitionID)
            self.presenter = presenter
        } else if presented is CustomBackgroundProvider {
            presenter = BackgroundPresentationController(presentedViewController: presented, presenting: presenting)
        }
        
        return presenter
    }
    
    // MARK: - Animated transitioning
    
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return attributes.duration
    }
    
    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        
        if isPresenting {
            let toVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)
            let toView = transitionContext.view(forKey: UITransitionContextViewKey.to)!

            let targetAttrib = apply(attributes: attributes.initial, to: toView)
            let completion = { (didComplete: Bool) in
                if !didComplete { toView.removeFromSuperview() }
                transitionContext.completeTransition(didComplete)
            }
            
            if !(toVC is CustomBackgroundProvider) { containerView.addSubview(toView) }
            
            if let animation = attributes as? TransitionAnimation {
                UIView.animate(withDuration: animation.duration,
                               delay: 0.0,
                               options: animation.options,
                               animations: { self.apply(attributes: targetAttrib, to: toView) })
                { (_) in
                    // TODO: Check if animation completion status should be a factor to revert
                    completion(!transitionContext.transitionWasCancelled)
                }
            } else {
                CATransaction.begin()
                CATransaction.setCompletionBlock {
                    completion(!transitionContext.transitionWasCancelled)
                }
                
                if attributes.duration > 0.0 {
                    let animGroup = CAAnimationGroup()
                    animGroup.animations = animation(for: toView, using: targetAttrib)
                    animGroup.duration = attributes.duration
                    
                    toView.layer.add(animGroup, forKey: nil)
                }
                
                CATransaction.commit()
                apply(attributes: targetAttrib, to: toView)
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
                               animations: { self.apply(attributes: animation.initial, to: fromView) })
                { (_) in
                    completion(!transitionContext.transitionWasCancelled)
                }
            } else {
                let animKey = "KRPresentationAnimationKey"
                CATransaction.begin()
                CATransaction.setCompletionBlock {
                    completion(!transitionContext.transitionWasCancelled)
                    fromView.layer.removeAnimation(forKey: animKey)
                }
                
                if attributes.duration > 0.0 {
                    let animGroup = CAAnimationGroup()
                    animGroup.animations = animation(for: fromView, using: attributes.initial)
                    animGroup.duration = attributes.duration
                    animGroup.fillMode = kCAFillModeForwards
                    animGroup.isRemovedOnCompletion = false
                    
                    fromView.layer.add(animGroup, forKey: animKey)
                }

                CATransaction.commit()
            }
        }
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
    
    private func animation(for toView: UIView, using targetAttributes: [Attribute]) -> [CAAnimation] {
        guard let attributes = attributes as? TransitionAttributes else {
            fatalError("<KRPresentationKit> - Failed to cast `attributes` as TransitionAttributes.")
        }
        
        var animations = [CAAnimation]()
        let numberOfFrames = attributes.duration * 60.0
        var scales = [Double]()
        
        for i in 0 ... Int(numberOfFrames) {
            let rt = Double(i) / numberOfFrames
            let function = !isPresenting && attributes.shouldInvertForDismissal ?
                attributes.timingFunction.inverse : attributes.timingFunction
            scales.append(TimingFunction.value(using: function, rt: rt, b: 0.0, c: 1.0, d: attributes.duration))
        }
        
        var frameAttrib: CGRect?
        var tAttrib = [(String, Any)]()
        
        for attrib in targetAttributes {
            let anim = CAKeyframeAnimation()
            anim.duration = attributes.duration
            
            switch attrib {
            case .alpha(let opacity):
                let c = Float(opacity) - toView.layer.opacity
                
                anim.keyPath = "opacity"
                anim.values = scales.map { toView.layer.opacity + c * Float($0) }
            case .frame(let frame):
                frameAttrib = frame
                continue
            case .opacity(let opacity):
                let c = opacity - toView.layer.opacity
                
                anim.keyPath = "opacity"
                anim.values = scales.map { toView.layer.opacity + c * Float($0) }
            case .origin(var origin):
                let c = (origin.x - toView.frame.origin.x, origin.y - toView.frame.origin.y)
                let size = toView.bounds.size
                anim.keyPath = "position"
                anim.values = scales.map {
                    let point = (toView.layer.position.x + c.0 * CGFloat($0),
                                 toView.layer.position.y + c.1 * CGFloat($0))
                    return NSValue(cgPoint: CGPoint(x: point.0, y: point.1))
                }
            case .position(let position):
                let c = (position.x - toView.layer.position.x, position.y - toView.layer.position.y)
                
                anim.keyPath = "position"
                anim.values = scales.map {
                    let point = (toView.layer.position.x + c.0 * CGFloat($0),
                                 toView.layer.position.y + c.1 * CGFloat($0))
                    return NSValue(cgPoint: CGPoint(x: point.0, y: point.1))
                }
            case .rotation(let rotation):
                tAttrib.append(("angle", radians(from: rotation)))
                continue
            case .scale(let scale):
                tAttrib.append(("scale", scale))
                continue
            case .size(let size):
                let c = (size.width - toView.bounds.size.width, size.height - toView.bounds.size.height)
                
                anim.keyPath = "bounds.size"
                anim.values = scales.map {
                    let size = (toView.bounds.size.width + c.0 * CGFloat($0),
                                toView.bounds.size.height + c.1 * CGFloat($0))
                    return NSValue(cgSize: CGSize(width: size.0, height: size.1))
                }
            case .translation(let translation):
                tAttrib.append(("translation", translation))
                continue
            }
            
            animations.append(anim)
        }
        
        if let frame = frameAttrib {
            let posAnim = CAKeyframeAnimation(keyPath: "position")
            posAnim.values = [NSValue]()
            posAnim.duration = attributes.duration
            
            let sizeAnim = CAKeyframeAnimation(keyPath: "bounds.size")
            sizeAnim.values = [NSValue]()
            sizeAnim.duration = attributes.duration
            
            let posC = (frame.origin.x - toView.frame.origin.x, frame.origin.y - toView.frame.origin.y)
            let sizeC = (frame.size.width - toView.bounds.size.width, frame.size.height - toView.bounds.size.height)
            
            for s in scales {
                let offset = (sizeC.0 * toView.layer.anchorPoint.x * CGFloat(s),
                              sizeC.1 * toView.layer.anchorPoint.y * CGFloat(s))
                let point = (toView.layer.position.x + posC.0 * CGFloat(s) + offset.0,
                             toView.layer.position.y + posC.1 * CGFloat(s) + offset.1)
                let size = (toView.bounds.size.width + sizeC.0 * CGFloat(s),
                            toView.bounds.size.height + sizeC.1 * CGFloat(s))
                            
                posAnim.values?.append(NSValue(cgPoint: CGPoint(x: point.0, y: point.1)))
                sizeAnim.values?.append(NSValue(cgSize: CGSize(width: size.0, height: size.1)))
            }
            
            animations += [posAnim, sizeAnim]
        }
        
        if !tAttrib.isEmpty {
            if !self.isPresenting {
                tAttrib.reverse()
                
                let index = (rotation: tAttrib.index { $0.0 == "angle" },
                             translation: tAttrib.index { $0.0 == "translation" })
                if let rIndex = index.rotation, let tIndex = index.translation {
                    (tAttrib[rIndex], tAttrib[tIndex]) = (tAttrib[tIndex], tAttrib[rIndex])
                }
            }
            
            let anim = CAKeyframeAnimation(keyPath: "transform")
            anim.duration = attributes.duration
            anim.values = scales.map { (s) in
                let t = tAttrib.reduce(toView.layer.transform) { (t, attrib) in
                    switch attrib.0 {
                    case "angle":
                        return CATransform3DRotate(t, (attrib.1 as! CGFloat) * CGFloat(s), 0.0, 0.0, 1.0)
                    case "scale":
                        let scale = attrib.1 as! CGFloat
                        let value = 1.0 + (scale - 1.0) * CGFloat(s)
                        return CATransform3DScale(t, value, value, 1.0)
                    default:
                        let trans = attrib.1 as! CGSize
                        return CATransform3DTranslate(t, trans.width * CGFloat(s), trans.height * CGFloat(s), 0.0)
                    }
                }
                return NSValue(caTransform3D: t)
            }
            animations.append(anim)
        }
        
        return animations
    }
}
