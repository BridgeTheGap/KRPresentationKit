//
//  Transitioner.swift
//  Pods
//
//  Created by Joshua Park on 23/11/2016.
//
//

import UIKit
import KRTimingFunction

public enum TransitionState {
    case idle
    case presenting
    case dismissing
    case fadingIn
    case fadingOut
}

/**
 The class that handles transition and animation
 in the presentation and dismissal process.
 */
public class KRTransitioner: NSObject, NSCopying,
                             UIViewControllerTransitioningDelegate,
                             UIViewControllerAnimatedTransitioning
{
    
    /// An identifier that allows clients to distinguish an instance from another.
    public var transitionID: String?
    
    /// The attributes to be applied to the presented VC during transition.
    public var attributes: TransitionParameterType
    
    /// The delegate object to handle the background container view during presentation.
    public weak var containerViewDelegate: ContainerViewDelegate?
    
    // TODO: Consider removing or hiding from public?
    /// The current state of the transitioner object.
    public private(set) var state: TransitionState = .idle
    
    /// The background view that is used during crossfading transition.
    public private(set) var transitioningBackground: UIView?
    
    /// The presentation controller handling transition
    internal private(set) var presenter: UIPresentationController?
    
    public required init(attributes: TransitionParameterType) {
        self.attributes = attributes
    }
    
    public override convenience init() {
        self.init(attributes: KRTransitionParameter())
    }
    
    public func copied() -> KRTransitioner {
        return copy() as! KRTransitioner
    }
    
    public func copy(with zone: NSZone? = nil) -> Any {
        let t = type(of: self).init(attributes: attributes)
        t.transitionID = transitionID
        t.containerViewDelegate = containerViewDelegate
        t.state = state
        t.transitioningBackground = transitioningBackground
        t.presenter = presenter
        
        return t
    }
    
    internal func fade(to transitioner: KRTransitioner?) {
        state = .fadingOut
        transitioner?.state = .fadingIn
        
        guard transitioner != nil else { return }
        
        let frame = presenter!.containerView!.frame
        let view = UIView(frame: frame)
        
        presenter!.presentingViewController.view.addSubview(view)
        transitioningBackground = view
        
        transitioner?.transitioningBackground = view
        transitioner?.presenter = nil
    }
    
    // MARK: - Transitioning delegate
    
    public func animationController(forPresented presented: UIViewController,
                                    presenting: UIViewController,
                                    source: UIViewController)
        -> UIViewControllerAnimatedTransitioning?
    {
        if state == .idle { state = .presenting }
        return self
    }
    
    public func animationController(forDismissed dismissed: UIViewController)
        -> UIViewControllerAnimatedTransitioning?
    {
        if state == .idle { state = .dismissing }
        return self
    }
    
    public func presentationController(forPresented presented: UIViewController,
                                       presenting: UIViewController?,
                                       source: UIViewController)
        -> UIPresentationController?
    {
        if let presented = presented as? CustomPresented, source is CustomPresenting {
            presented.customPresenting = source
        }
        
        presenter = {
            if containerViewDelegate != nil {
                return DelegatingPresentationController(presentedViewController: presented,
                                                        presenting: presenting,
                                                        transitioner: self)
            } else if presented is CustomBackgroundProvider {
                let p = BackgroundPresentationController(presentedViewController: presented,
                                                         presenting: presenting)
                p.transitioner = self
                
                return p
            }
            return UIPresentationController(presentedViewController: presented,
                                            presenting: presenting)
        }()
        
        return presenter
    }
    
    // MARK: - Animated transitioning
    
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?)
        -> TimeInterval
    {
        return attributes.duration
    }
    
    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        
        switch state {
            
        case .presenting,
             .fadingIn:
            
            let toVC = transitionContext.viewController(forKey: .to)
            let toView = transitionContext.view(forKey: .to)!
            
            let targetAttrib = apply(attributes: attributes.initial,
                                     to: toView)
            
            let completion = { (didComplete: Bool) in
                if !didComplete { toView.removeFromSuperview() }
                transitionContext.completeTransition(didComplete)
            }
            
            if !(toVC is CustomBackgroundProvider) { containerView.addSubview(toView) }
            
            if let animation = attributes as? UIViewAnimParameter {
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
            
        case .dismissing,
             .fadingOut:
            
            let fromView = transitionContext.view(forKey: .from)!
            let completion = { (didComplete: Bool) in
                if didComplete { fromView.removeFromSuperview() }
                transitionContext.completeTransition(didComplete)
            }
            
            if let animation = attributes as? UIViewAnimParameter {
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
                    animGroup.fillMode = CAMediaTimingFillMode.forwards
                    animGroup.isRemovedOnCompletion = false
                    
                    fromView.layer.add(animGroup, forKey: animKey)
                }
                
                CATransaction.commit()
            }
            
        default:
            
            let didComplete = !transitionContext.transitionWasCancelled
            transitionContext.completeTransition(didComplete)
            
        }
    }
    
    public func animationEnded(_ transitionCompleted: Bool) {
        switch state {
        case .fadingIn:
            transitioningBackground?.removeFromSuperview()
            transitioningBackground = nil
        case .dismissing, .fadingOut:
            presenter = nil
        default: break
        }
        
        state = .idle
    }
    
    // MARK: - Private
    
    /**
     Applies attributes to view and returns the old attributes of the view.
     
     - Parameters:
        - attributes: The list of attributes to be applied.
        - view: The view to apply `attributes` to.
     
     - Returns: The original attributes of `view` before applying `attributes`.
     */
    @discardableResult
    private func apply(attributes: [Attribute],
                       to view: UIView) -> [Attribute]
    {
        var targetAttrib = [Attribute]()
        
        attributes.forEach { targetAttrib.append($0.apply(to: view)) }
        
        return targetAttrib
    }
    
    private func animation(for toView: UIView,
                           using targetAttributes: [Attribute])
        -> [CAAnimation]
    {
        guard let attributes = attributes as? KRTransitionParameter else {
            fatalError("<KRPresentationKit> - Failed to cast `attributes` as TransitionAttributes.")
        }
        
        var animations = [CAAnimation]()
        let numberOfFrames = attributes.duration * 60.0
        var scales = [Double]()
        
        let shouldInvertFunction = (state == .dismissing || state == .fadingOut) && attributes.shouldInvertForDismissal
        
        for i in 0 ... Int(numberOfFrames) {
            let rt = Double(i) / numberOfFrames
            let function = shouldInvertFunction ? attributes.timingFunction.inverse : attributes.timingFunction
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
            case .origin(let origin):
                let c = (origin.x - toView.frame.origin.x, origin.y - toView.frame.origin.y)
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
            if state == .dismissing || state == .fadingOut {
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
