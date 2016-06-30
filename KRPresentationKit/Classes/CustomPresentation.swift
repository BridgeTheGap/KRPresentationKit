//
//  CustomPresentation.swift
//  Custom Presentation v 0.9.3 (Animatable Contents)
//
//  Created by Joshua Park on 4/5/16.
//  Copyright © 2016 Joshua Park. All rights reserved.
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

public enum PresentationStyle {
    case SlideUp(FunctionType?)
    case SlideDown(FunctionType?)
    case SlideLeft(FunctionType?)
    case SlideRight(FunctionType?)
    case Overlay(FunctionType?)
    case Popup(FunctionType?)
    case Custom((() -> Void) -> Void)
    case NoAnimation
}

public enum ContentAnimation {
    case None
    case FadeIn
    case FadeInOut
    case FadeOut
}

public protocol CustomPresentable: UIViewControllerTransitioningDelegate, UIViewControllerAnimatedTransitioning {}

public class BackgroundSeparableViewController: UIViewController {
    @IBOutlet public weak var contentView: UIView! {
        didSet { targetFrame = contentView.frame }
    }
    
    public var constraints = [NSLayoutConstraint]()
    public var targetFrame: CGRect!
    
    public var customPresentingViewController: CustomPresentationViewController? {
        if let cpvc = presentingViewController as? CustomPresentationViewController {
            return cpvc
        }
        if let nc = presentingViewController as? UINavigationController {
            for vc in nc.viewControllers {
                if let cpvc = vc as? CustomPresentationViewController {
                    return cpvc
                }
            }
        }
        return nil
    }
    
    public var presentationStyle: PresentationStyle = .SlideUp(.EaseOutCubic)
    public var contentAnimation: ContentAnimation = .None
    public var contentAnimationDuration = 0.3
    
    override public init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        view.layoutIfNeeded()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override public func awakeFromNib() {
        super.awakeFromNib()
        
        view.layoutIfNeeded()
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        saveConstraints()
    }
    
    override public func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        NSLayoutConstraint.activateConstraints(constraints)
    }
    
    private func saveConstraints() {
        for c in view.constraints {
            if c.firstItem as? UIView === contentView || c.secondItem as? UIView === contentView {
                constraints.append(c)
            }
        }
    }
}

public class CustomPresentationViewController: UIViewController {
    public var duration: Double = 0.3
    public var isFading: Bool = false
    public var presentationAnimation: ((presentingContent: UIView, background: UIView) -> Void)?
    public var dismissalAnimation: ((dismissingContent: UIView, background: UIView) -> Void)?
    
    public weak var background: UIView? {
        didSet {
            if let content = presentingContent {
                view.insertSubview(background!, belowSubview: content)
            } else if let content = dismissingContent {
                view.insertSubview(background!, belowSubview: content)
            } else {
                view.addSubview(background!)
            }
        }
    }
    public weak var presentingContent: UIView? {
        didSet {
            presentingContent!.hidden = true
            view.addSubview(presentingContent!)
        }
    }
    public weak var dismissingContent: UIView? {
        didSet {
            dismissingContent!.hidden = true
            view.addSubview(dismissingContent!)
        }
    }
}

extension CustomPresentationViewController: CustomPresentable {
    public func preparePresentation(viewController: BackgroundSeparableViewController) {
        if background == nil {
            let background = UIView(frame: viewController.view.frame)
            background.backgroundColor = viewController.view.backgroundColor
            self.background = background
        }
        
        if !isFading { background!.alpha = 0.0 }
        
        if presentingContent == nil {
            let content = viewController.contentView.snapshotViewAfterScreenUpdates(true)
            presentingContent = content
        }
        presentingContent!.frame = viewController.targetFrame
    }
    
    public func prepareDismissal(viewController: BackgroundSeparableViewController) {
        if isFading {
            presentingContent!.hidden = true
        } else {
            if background == nil {
                let background = UIView(frame: viewController.view.frame)
                background.backgroundColor = viewController.view.backgroundColor
                self.background = background
            }
        }
        
        background!.hidden = true
        
        if dismissingContent == nil {
            let content = viewController.contentView.snapshotViewAfterScreenUpdates(true)
            dismissingContent = content
        }
        dismissingContent!.frame = viewController.targetFrame
    }
    
    public func reset() {
        if let background = background { background.removeFromSuperview() }
        if let presentingContent = presentingContent { presentingContent.removeFromSuperview() }
        if let dismissingContent = dismissingContent { dismissingContent.removeFromSuperview() }
        presentationAnimation = nil
        dismissalAnimation = nil
    }
    
    final override public func presentViewController(viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)?) {
        presentViewController(viewControllerToPresent, completion: completion)
    }
    
    public func presentViewController(viewController: UIViewController, style: PresentationStyle = .SlideUp(.EaseOutCubic), duration: Double = 0.3, completion: (() -> Void)?) {
        if let vc = viewController as? BackgroundSeparableViewController {
            self.duration = duration
            
            if !isFading { preparePresentation(vc) }
            
            viewController.modalPresentationStyle = .Custom
            viewController.transitioningDelegate = self
        }
        
        super.presentViewController(viewController, animated: true, completion: {
            self.reset()
            completion?()
        })
    }
    
    public func fadeToViewController(viewController: UIViewController, duration: Double = 0.3, completion: (() -> Void)?) {
        isFading = true
        if let vc = viewController as? BackgroundSeparableViewController { preparePresentation(vc) }
        dismissViewController(duration: duration) {
            self.presentViewController(viewController, duration: duration) {
                self.isFading = false
                completion?()
            }
        }
    }
    
    final override public func dismissViewControllerAnimated(flag: Bool, completion: (() -> Void)?) {
        dismissViewController(flag, completion: completion)
    }
    
    public func dismissViewController(flag: Bool = true, style: PresentationStyle = .SlideUp(.EaseInCubic), duration: Double = 0.3, completion: (() -> Void)?) {
        if let vc = presentedViewController as? BackgroundSeparableViewController { prepareDismissal(vc) }
        self.duration = duration
        
        super.dismissViewControllerAnimated(flag, completion: {
            if !self.isFading { self.reset() }
            completion?()
        })
    }
    
    public func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
    }
    
    public func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
    }
    
    public func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval { return duration }
    
    public func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        func completeTransition() {
            let success = !transitionContext.transitionWasCancelled()
            transitionContext.completeTransition(success)
        }
        
        let toVC = transitionContext.viewControllerForKey(TransitionKey.ToVC)!
        let containerView = transitionContext.containerView()!
        
        if toVC.isBeingPresented() {    // Presentation
            let presentedVC = toVC as! BackgroundSeparableViewController
            
            animatePresentation(presentedVC) {
                switch presentedVC.contentAnimation {
                case .FadeIn, .FadeInOut:
                    presentedVC.contentView.alpha = 0.0
                    containerView.addSubview(presentedVC.contentView)
                    
                    presentedVC.contentView.animateAlpha(1.0, duration: presentedVC.contentAnimationDuration) {
                        self.background!.removeFromSuperview()
                        
                        presentedVC.view.addSubview(presentedVC.contentView)
                        containerView.addSubview(presentedVC.view)
                        completeTransition()
                    }
                default:
                    self.background!.removeFromSuperview()
                    
                    containerView.addSubview(presentedVC.view)
                    completeTransition()
                }
            }
        } else {    // Dismissal
            let fromVC = transitionContext.viewControllerForKey(TransitionKey.FromVC) as! BackgroundSeparableViewController
            
            switch fromVC.contentAnimation {
            case .FadeInOut, .FadeOut:
                self.view.addSubview(fromVC.contentView)
                
                fromVC.view.removeFromSuperview()
                self.background!.hidden = false
                self.dismissingContent!.hidden = false
                
                UIView.animateWithDuration(fromVC.contentAnimationDuration, animations: {
                    fromVC.contentView.alpha = 0.0
                    
                    }, completion: { (complete) in
                        fromVC.contentView.removeFromSuperview()
                        
                        self.animateDismissal(fromVC) {
                            completeTransition()
                        }
                })
            default:
                fromVC.view.removeFromSuperview()
                self.background!.hidden = false
                self.dismissingContent!.hidden = false
                
                self.animateDismissal(fromVC) {
                    completeTransition()
                }
            }
        }
    }
    
    private func animatePresentation(presentedVC: BackgroundSeparableViewController, completion: () -> Void) {
        if !isFading { background!.animateOpacity(1.0, duration: duration) }
        
        switch presentedVC.presentationStyle {
        case .SlideUp(let function):
            let targetY = presentedVC.targetFrame.origin.y
            
            presentingContent!.frame.origin.y = Screen.bounds.height
            presentingContent!.hidden = false
            
            presentingContent!.animateY(targetY, duration: duration, function: function ?? .EaseOutCubic, completion: completion)
            
        case .SlideDown(let function):
            let targetY = presentedVC.targetFrame.origin.y
            
            presentingContent!.frame.origin.y = -Screen.bounds.height
            presentingContent!.hidden = false
            
            presentingContent!.animateY(targetY, duration: duration, function: function ?? .EaseOutCubic, completion: completion)
        case .SlideLeft(let function):
            let targetX = presentedVC.targetFrame.origin.x
            
            presentingContent!.frame.origin.x = Screen.bounds.width
            presentingContent!.hidden = false
            
            presentingContent!.animateX(targetX, duration: duration, function: function ?? .EaseOutCubic, completion: completion)
        case .SlideRight(let function):
            let targetX = presentedVC.targetFrame.origin.x
            
            presentingContent!.frame.origin.x = -Screen.bounds.width
            presentingContent!.hidden = false
            
            presentingContent!.animateX(targetX, duration: duration, function: function ?? .EaseOutCubic, completion: completion)
        case .Popup(let function):
            presentingContent!.transform = CGAffineTransformMakeScale(0.0, 0.0)
            presentingContent!.hidden = false
            
            presentingContent!.animateScale2D(1.0, duration: duration, function: function ?? .EaseOutBack, completion: completion)
        case .Overlay(let function):
            let function = function ?? .EaseOutCubic
            presentingContent!.transform = CGAffineTransformMakeScale(2.0, 2.0)
            presentingContent!.hidden = false
            presentingContent!.alpha = 0.0
            
            KRAnimation.chain(
                presentingContent!.chainAlpha(1.0, duration: duration, function: function) + presentingContent!.chainScale(1.0, duration: duration, function: function)
            ) {
                completion()
            }
        case .Custom(let animClosure):
            animClosure(completion)
        case .NoAnimation:
            completion()
        }
    }
    
    private func animateDismissal(dismissedVC: BackgroundSeparableViewController, completion: () -> Void) {
        if !isFading { background!.animateOpacity(0.0, duration: duration) }
        
        switch dismissedVC.presentationStyle {
        case .SlideUp(let function):
            dismissingContent!.animateY(Screen.bounds.height, duration: duration, function: function ?? .EaseInCubic, completion: completion)
        case .SlideDown(let function):
            dismissingContent!.animateY(-Screen.bounds.height, duration: duration, function: function ?? .EaseInCubic, completion: completion)
        case .SlideLeft(let function):
            dismissingContent!.animateX(Screen.bounds.width, duration: duration, function: function ?? .EaseInCubic, completion: completion)
        case .SlideRight(let function):
            dismissingContent!.animateX(-Screen.bounds.width, duration: duration, function: function ?? .EaseInCubic, completion: completion)
        case .Popup(let function):
            dismissingContent!.animateScale2D(0.0, duration: duration, function: function ?? .EaseInCubic, completion: completion)
        case .Overlay(let function):
            let function = function ?? .EaseInCubic
            KRAnimation.chain(
                dismissingContent!.chainAlpha(0.0, duration: duration, function: function) + dismissingContent!.chainScale2D(2.0, duration: duration, function: function)
            ) {
                completion()
            }
        case .Custom(let animClosure):
            animClosure(completion)
        case .NoAnimation:
            self.dismissingContent!.removeFromSuperview()
            completion()
            
        }
    }
}
