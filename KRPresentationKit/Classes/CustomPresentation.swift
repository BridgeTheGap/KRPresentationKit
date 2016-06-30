//
//  CustomPresentation.swift
//  Custom Presentation v 0.9.3 (Animatable Contents)
//
//  Created by Joshua Park on 4/5/16.
//  Copyright © 2016 Joshua Park. All rights reserved.
//

import UIKit


private typealias TransitionKey = String
private extension TransitionKey {
    static var FromVC: String { return UITransitionContextFromViewControllerKey }
    static var ToVC: String { return UITransitionContextToViewControllerKey }
    static var FromView: String { return UITransitionContextFromViewKey }
    static var ToView: String { return UITransitionContextToViewKey }
}

public enum PresentationStyle {
    case Default
    case Popup
    case SlideUp
    case SlideDown
    case SlideLeft
    case SlideRight
    case Custom(initialFrame: CGRect?, finalFrame: CGRect?)
    case NoAnimation
}

public func == (lhs: PresentationStyle, rhs: PresentationStyle) -> Bool {
    switch (lhs, rhs) {
    case (.Default, .Default): return true
    case (.Popup, .Popup): return true
    case (.SlideUp, .SlideUp): return true
    case (.SlideDown, .SlideDown): return true
    case (.SlideLeft, .SlideLeft): return true
    case (.SlideRight, .SlideRight): return true
    case (.Custom(initialFrame: let lhsFrame1, finalFrame: let lhsFrame2), .Custom(initialFrame: let rhsFrame1, finalFrame: let rhsFrame2)):
        return lhsFrame1 == rhsFrame1 && lhsFrame2 == rhsFrame2
    case (.NoAnimation, .NoAnimation): return true
    default: return false
    }
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
        didSet { self.contentViewFrame = self.contentView.frame }
    }
    
    public var constraints = [NSLayoutConstraint]()
    public var contentViewFrame: CGRect!
    
    public var customPresentingViewController: CustomPresentationViewController? {
        if let cpvc = self.presentingViewController as? CustomPresentationViewController {
            return cpvc
        }
        if let nc = self.presentingViewController as? UINavigationController {
            for vc in nc.viewControllers {
                if let cpvc = vc as? CustomPresentationViewController {
                    return cpvc
                }
            }
        }
        return nil
    }
    
    public var presentationStyle: PresentationStyle = .Default
    public var contentAnimation: ContentAnimation = .None
    public var contentAnimationDuration = 0.3
    
    override public init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        self.view.layoutIfNeeded()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override public func awakeFromNib() {
        super.awakeFromNib()
        
        self.view.layoutIfNeeded()
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        self.saveConstraints()
    }
    
    override public func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.view.addConstraints(self.constraints)
    }
    
    private func saveConstraints() {
        for c in self.view.constraints {
            if c.firstItem as? NSObject == self.contentView || c.secondItem as? NSObject == self.contentView {
                self.constraints.append(c)
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
            if let content = self.presentingContent {
                self.view.insertSubview(self.background!, belowSubview: content)
            } else if let content = self.dismissingContent {
                self.view.insertSubview(self.background!, belowSubview: content)
            } else {
                self.view.addSubview(self.background!)
            }
        }
    }
    public weak var presentingContent: UIView? {
        didSet {
            self.presentingContent!.hidden = true
            self.view.addSubview(self.presentingContent!)
        }
    }
    public weak var dismissingContent: UIView? {
        didSet {
            self.dismissingContent!.hidden = true
            self.view.addSubview(self.dismissingContent!)
        }
    }
}

extension CustomPresentationViewController: CustomPresentable {
    public func preparePresentation(viewController: BackgroundSeparableViewController) {
        if self.background == nil {
            let background = UIView(frame: viewController.view.frame)
            background.backgroundColor = viewController.view.backgroundColor
            self.background = background
        }
        
        if !self.isFading { self.background!.alpha = 0.0 }
        
        if self.presentingContent == nil {
            let content = viewController.contentView.snapshotViewAfterScreenUpdates(true)
            self.presentingContent = content
        }
        self.presentingContent!.frame = viewController.contentViewFrame
    }
    
    public func prepareDismissal(viewController: BackgroundSeparableViewController) {
        if self.isFading {
            self.presentingContent!.hidden = true
        } else {
            if self.background == nil {
                let background = UIView(frame: viewController.view.frame)
                background.backgroundColor = viewController.view.backgroundColor
                self.background = background
            }
        }
        
        self.background!.hidden = true
        
        if self.dismissingContent == nil {
            let content = viewController.contentView.snapshotViewAfterScreenUpdates(true)
            self.dismissingContent = content
        }
        self.dismissingContent!.frame = viewController.contentViewFrame
    }
    
    public func reset() {
        if let background = self.background { background.removeFromSuperview() }
        if let presentingContent = self.presentingContent { presentingContent.removeFromSuperview() }
        if let dismissingContent = self.dismissingContent { dismissingContent.removeFromSuperview() }
        self.presentationAnimation = nil
        self.dismissalAnimation = nil
    }
    
    public func presentViewController(viewController: UIViewController, duration: Double, completion: (() -> Void)?) {
        if let vc = viewController as? BackgroundSeparableViewController {
            self.duration = duration
            
            if !self.isFading { self.preparePresentation(vc) }
            
            viewController.modalPresentationStyle = .Custom
            viewController.transitioningDelegate = self
        }
        super.presentViewController(viewController, animated: true, completion: {
            self.reset()
            completion?()
        })
    }
    
    final override public func presentViewController(viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)?) {
        self.presentViewController(viewControllerToPresent, duration: 0.3, completion: completion)
    }
    
    public func fadeToViewController(viewController: UIViewController, duration: Double, completion: (() -> Void)?) {
        self.isFading = true
        if let vc = viewController as? BackgroundSeparableViewController { self.preparePresentation(vc) }
        self.dismissViewControllerAnimated(true, duration: duration) {
            self.presentViewController(viewController, duration: duration) {
                self.isFading = false
                completion?()
            }
        }
    }
    
    public func dismissViewControllerAnimated(flag: Bool, duration: Double, completion: (() -> Void)?) {
        if let vc = self.presentedViewController as? BackgroundSeparableViewController { self.prepareDismissal(vc) }
        self.duration = duration
        
        super.dismissViewControllerAnimated(flag, completion: {
            if !self.isFading { self.reset() }
            completion?()
        })
    }
    
    final override public func dismissViewControllerAnimated(flag: Bool, completion: (() -> Void)?) {
        self.dismissViewControllerAnimated(flag, duration: 0.3, completion: completion)
    }
    
    public func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
    }
    
    public func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
    }
    
    public func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        func completeTransition() {
            let success = !transitionContext.transitionWasCancelled()
            transitionContext.completeTransition(success)
        }
        
        let toVC = transitionContext.viewControllerForKey(TransitionKey.ToVC)!
        let containerView = transitionContext.containerView()!
        
        if toVC.isBeingPresented() {    // Presentation
            let presentedVC = toVC as! BackgroundSeparableViewController
            
            self.animatePresentation(presentedVC) {
                switch presentedVC.contentAnimation {
                case .FadeIn, .FadeInOut:
                    presentedVC.contentView.alpha = 0.0
                    containerView.addSubview(presentedVC.contentView)
                    
                    UIView.animateWithDuration(presentedVC.contentAnimationDuration, animations: {
                        presentedVC.contentView.alpha = 1.0
                        }, completion: { (complete) in
                            self.background!.removeFromSuperview()
                            
                            presentedVC.view.addSubview(presentedVC.contentView)
                            containerView.addSubview(toVC.view)
                            completeTransition()
                    })
                default:
                    self.background!.removeFromSuperview()
                    
                    containerView.addSubview(toVC.view)
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
    
    public func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval { return self.duration }
    
    private func animatePresentation(presentedVC: BackgroundSeparableViewController, completion: () -> Void) {
        if !self.isFading { self.background!.animateOpacity(1.0, duration: self.duration) }
        let style = presentedVC.presentationStyle
        switch style  {
        case .Popup:
            self.presentingContent!.transform = CGAffineTransformMakeScale(0.1, 0.1)
            self.presentingContent!.hidden = false
            
            self.presentingContent!.animateScale2D(1.0, duration: self.duration, function: .EaseOutBack, completion: completion)
        case .SlideUp, .SlideDown:
            let targetY = presentedVC.contentViewFrame.origin.y
            
            self.presentingContent!.frame.origin.y = style == .SlideUp ? Screen.bounds.endPoint.y : -Screen.bounds.endPoint.y
            self.presentingContent!.hidden = false
            
            self.presentingContent!.animateY(targetY, duration: self.duration, completion: completion)
        case .SlideLeft, .SlideRight:
            let targetX = presentedVC.contentViewFrame.origin.x
            
            self.presentingContent!.frame.origin.x = style == .SlideLeft ? Screen.bounds.endPoint.x : -Screen.bounds.endPoint.x
            self.presentingContent!.hidden = false
            
            self.presentingContent!.animateX(targetX, duration: self.duration, function: .EaseInOutCirc, completion: completion)
        case .NoAnimation:
            completion()
        case .Custom(let initialFrame, let finalFrame):
            if initialFrame != nil { self.presentingContent!.frame = initialFrame! }
            self.presentingContent!.hidden = false

            UIView.animateWithDuration(self.duration, animations: {
                if finalFrame != nil { self.presentingContent!.frame = finalFrame! }
                self.presentationAnimation?(presentingContent: self.presentingContent!, background: self.background!)
                }, completion: { if $0 { completion() } })
        default:
            self.presentingContent!.transform = CGAffineTransformMakeScale(2.0, 2.0)
            self.presentingContent!.hidden = false
            self.presentingContent!.alpha = 0.0
            
            UIView.animateWithDuration(self.duration, delay: 0.05, usingSpringWithDamping: 1.0, initialSpringVelocity: 2.0, options: .CurveEaseIn, animations: {
                self.presentingContent!.alpha = 1.0
                self.presentingContent!.transform = CGAffineTransformMakeScale(1.0, 1.0)
                }, completion: { if $0 { completion() }})
        }
    }
    
    private func animateDismissal(dismissedVC: BackgroundSeparableViewController, completion: () -> Void) {
        if !self.isFading { self.background!.animateOpacity(0.0, duration: self.duration) }
        
        switch dismissedVC.presentationStyle {
        case .Popup:
            self.dismissingContent!.animateScale2D(0.0, duration: self.duration, function: .EaseInOutCubic, completion: completion)
        case .SlideUp:
            self.dismissingContent!.animateY(Screen.bounds.endPoint.y, duration: self.duration, function: .EaseInOutCirc, completion: completion)
        case .SlideDown:
            self.dismissingContent!.animateY(-Screen.bounds.endPoint.y, duration: self.duration, function: .EaseInOutCirc, completion: completion)
        case .SlideLeft:
            self.dismissingContent!.animateX(Screen.bounds.endPoint.x, duration: self.duration, function: .EaseInOutCirc, completion: completion)
        case .SlideRight:
            self.dismissingContent!.animateX(-Screen.bounds.endPoint.x, duration: self.duration, function: .EaseInOutCirc, completion: completion)
        case .NoAnimation:
            self.dismissingContent!.removeFromSuperview()
            completion()
        case .Custom(let initialFrame, _):
            UIView.animateWithDuration(self.duration, animations: {
                if let initialFrame = initialFrame { self.dismissingContent!.frame = initialFrame }
                self.dismissalAnimation?(dismissingContent: self.dismissingContent!, background: self.background!)
                }, completion: { if $0 { self.dismissingContent!.removeFromSuperview(); completion() }})
        default:
            UIView.animateWithDuration(self.duration, delay: 0.05, usingSpringWithDamping: 1.0, initialSpringVelocity: 2.0, options: .CurveEaseIn, animations: {
                self.dismissingContent!.alpha = 0.0
                self.dismissingContent!.transform = CGAffineTransformMakeScale(2.0, 2.0)
                }, completion: { if $0 { completion() }})
        }
    }
}
