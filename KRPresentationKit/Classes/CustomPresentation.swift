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
    static var FromVC: String { return UITransitionContextViewControllerKey.from.rawValue }
    static var ToVC: String { return UITransitionContextViewControllerKey.to.rawValue }
    static var FromView: String { return UITransitionContextViewKey.from.rawValue }
    static var ToView: String { return UITransitionContextViewKey.to.rawValue }
}

public enum PresentationStyle {
    case slideUp(FunctionType?)
    case slideDown(FunctionType?)
    case slideLeft(FunctionType?)
    case slideRight(FunctionType?)
    case overlay(FunctionType?)
    case popup(FunctionType?)
    case custom((() -> Void) -> Void)
    case noAnimation
}

public protocol CustomPresentable: UIViewControllerTransitioningDelegate, UIViewControllerAnimatedTransitioning {}

open class BackgroundSeparableViewController: UIViewController {
    @IBOutlet open weak var contentView: UIView! {
        didSet { targetFrame = contentView.frame }
    }
    
    open var constraints = [NSLayoutConstraint]()
    open var targetFrame: CGRect!
    
    open var customPresentingViewController: CustomPresentationViewController? {
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
    
    open var presentationStyle: PresentationStyle = .slideUp(.easeOutCubic)
    open var contentAnimation: ContentAnimationStyle = .none
    open var contentAnimationDuration = 0.3
    
    override public init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        view.layoutIfNeeded()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override open func awakeFromNib() {
        super.awakeFromNib()
        
        view.layoutIfNeeded()
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        saveConstraints()
    }
    
    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        NSLayoutConstraint.activate(constraints)
    }
    
    private func saveConstraints() {
        for c in view.constraints {
            if c.firstItem as? UIView === contentView || c.secondItem as? UIView === contentView {
                constraints.append(c)
            }
        }
    }
}

open class CustomPresentationViewController: UIViewController {
    open var duration: Double = 0.3
    open var isFading: Bool = false
    open var presentationAnimation: ((_ presentingContent: UIView, _ background: UIView) -> Void)?
    open var dismissalAnimation: ((_ dismissingContent: UIView, _ background: UIView) -> Void)?
    
    open weak var background: UIView? {
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
    open weak var presentingContent: UIView? {
        didSet {
            presentingContent!.isHidden = true
            view.addSubview(presentingContent!)
        }
    }
    open weak var dismissingContent: UIView? {
        didSet {
            dismissingContent!.isHidden = true
            view.addSubview(dismissingContent!)
        }
    }
}

extension CustomPresentationViewController: CustomPresentable {
    public func preparePresentation(_ viewController: BackgroundSeparableViewController) {
        if background == nil {
            let background = UIView(frame: viewController.view.frame)
            background.backgroundColor = viewController.view.backgroundColor
            self.background = background
        }
        
        if !isFading { background!.alpha = 0.0 }
        
        if presentingContent == nil {
            let content = viewController.contentView.snapshotView(afterScreenUpdates: true)
            presentingContent = content
        }
        presentingContent!.frame = viewController.targetFrame
    }
    
    public func prepareDismissal(_ viewController: BackgroundSeparableViewController) {
        if isFading {
            presentingContent!.isHidden = true
        } else {
            if background == nil {
                let background = UIView(frame: viewController.view.frame)
                background.backgroundColor = viewController.view.backgroundColor
                self.background = background
            }
        }
        
        background!.isHidden = true
        
        if dismissingContent == nil {
            let content = viewController.contentView.snapshotView(afterScreenUpdates: true)
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
    
    final override public func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)?) {
        present(viewControllerToPresent, completion: completion)
    }
    
    public func present(_ viewController: UIViewController, style: PresentationStyle = .slideUp(.easeOutCubic), duration: Double = 0.3, completion: (() -> Void)?) {
        if let vc = viewController as? BackgroundSeparableViewController {
            self.duration = duration
            
            if !isFading { preparePresentation(vc) }
            
            viewController.modalPresentationStyle = .custom
            viewController.transitioningDelegate = self
        }
        
        super.present(viewController, animated: true, completion: {
            self.reset()
            completion?()
        })
    }
    
    public func fade(to viewController: UIViewController, duration: Double = 0.3, completion: (() -> Void)?) {
        isFading = true
        if let vc = viewController as? BackgroundSeparableViewController { preparePresentation(vc) }
        dismiss(duration: duration) {
            self.present(viewController, duration: duration) {
                self.isFading = false
                completion?()
            }
        }
    }
    
    final override public func dismiss(animated flag: Bool, completion: (() -> Void)?) {
        dismiss(flag, completion: completion)
    }
    
    public func dismiss(_ flag: Bool = true, style: PresentationStyle = .slideUp(.easeInCubic), duration: Double = 0.3, completion: (() -> Void)?) {
        if let vc = presentedViewController as? BackgroundSeparableViewController { prepareDismissal(vc) }
        self.duration = duration
        
        super.dismiss(animated: flag, completion: {
            if !self.isFading { self.reset() }
            completion?()
        })
    }
    
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
    }
    
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
    }
    
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval { return duration }
    
    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        func completeTransition() {
            let success = !transitionContext.transitionWasCancelled
            transitionContext.completeTransition(success)
        }
        
        let toVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey(rawValue: TransitionKey.ToVC))!
        let containerView = transitionContext.containerView
        
        if toVC.isBeingPresented {    // Presentation
            let presentedVC = toVC as! BackgroundSeparableViewController
            
            animate(presentedVC: presentedVC) {
                switch presentedVC.contentAnimation {
                case .fadeIn, .fadeInOut:
                    presentedVC.contentView.alpha = 0.0
                    containerView.addSubview(presentedVC.contentView)
                    
                    presentedVC.contentView.animate(alpha: 1.0, duration: presentedVC.contentAnimationDuration) {
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
            let fromVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey(rawValue: TransitionKey.FromVC)) as! BackgroundSeparableViewController
            
            switch fromVC.contentAnimation {
            case .fadeInOut, .fadeOut:
                self.view.addSubview(fromVC.contentView)
                
                fromVC.view.removeFromSuperview()
                self.background!.isHidden = false
                self.dismissingContent!.isHidden = false
                
                UIView.animate(withDuration: fromVC.contentAnimationDuration, animations: {
                    fromVC.contentView.alpha = 0.0
                    
                    }, completion: { (complete) in
                        fromVC.contentView.removeFromSuperview()
                        
                        self.animate(dismissedVC: fromVC) {
                            completeTransition()
                        }
                })
            default:
                fromVC.view.removeFromSuperview()
                self.background!.isHidden = false
                self.dismissingContent!.isHidden = false
                
                self.animate(dismissedVC: fromVC) {
                    completeTransition()
                }
            }
        }
    }
    
    private func animate(presentedVC: BackgroundSeparableViewController, completion: @escaping () -> Void) {
        if !isFading { background!.animate(opacity: 1.0, duration: duration) }
        
        switch presentedVC.presentationStyle {
        case .slideUp(let function):
            let targetY = presentedVC.targetFrame.origin.y
            
            presentingContent!.frame.origin.y = Screen.bounds.height
            presentingContent!.isHidden = false
            
            presentingContent!.animate(y: targetY, duration: duration, function: function ?? .easeOutCubic, completion: completion)
            
        case .slideDown(let function):
            let targetY = presentedVC.targetFrame.origin.y
            
            presentingContent!.frame.origin.y = -Screen.bounds.height
            presentingContent!.isHidden = false
            
            presentingContent!.animate(y: targetY, duration: duration, function: function ?? .easeOutCubic, completion: completion)
        case .slideLeft(let function):
            let targetX = presentedVC.targetFrame.origin.x
            
            presentingContent!.frame.origin.x = Screen.bounds.width
            presentingContent!.isHidden = false
            
            presentingContent!.animate(x: targetX, duration: duration, function: function ?? .easeOutCubic, completion: completion)
        case .slideRight(let function):
            let targetX = presentedVC.targetFrame.origin.x
            
            presentingContent!.frame.origin.x = -Screen.bounds.width
            presentingContent!.isHidden = false
            
            presentingContent!.animate(x: targetX, duration: duration, function: function ?? .easeOutCubic, completion: completion)
        case .popup(let function):
            presentingContent!.transform = CGAffineTransform(scaleX: 0.0, y: 0.0)
            presentingContent!.isHidden = false
            
            presentingContent!.animate(scale2D: 1.0, duration: duration, function: function ?? .easeOutBack, completion: completion)
        case .overlay(let function):
            let function = function ?? .easeOutCubic
            presentingContent!.transform = CGAffineTransform(scaleX: 2.0, y: 2.0)
            presentingContent!.isHidden = false
            presentingContent!.alpha = 0.0
            
            KRAnimation.chain(
                presentingContent!.chain(alpha: 1.0, duration: duration, function: function) + presentingContent!.chain(scale: 1.0, duration: duration, function: function)
            ) {
                completion()
            }
        case .custom(let animClosure):
            animClosure(completion)
        case .noAnimation:
            completion()
        }
    }
    
    private func animate(dismissedVC: BackgroundSeparableViewController, completion: @escaping () -> Void) {
        if !isFading { background!.animate(opacity: 0.0, duration: duration) }
        
        switch dismissedVC.presentationStyle {
        case .slideUp(let function):
            dismissingContent!.animate(y: Screen.bounds.height, duration: duration, function: function ?? .easeInCubic, completion: completion)
        case .slideDown(let function):
            dismissingContent!.animate(y: -Screen.bounds.height, duration: duration, function: function ?? .easeInCubic, completion: completion)
        case .slideLeft(let function):
            dismissingContent!.animate(x: Screen.bounds.width, duration: duration, function: function ?? .easeInCubic, completion: completion)
        case .slideRight(let function):
            dismissingContent!.animate(x: -Screen.bounds.width, duration: duration, function: function ?? .easeInCubic, completion: completion)
        case .popup(let function):
            dismissingContent!.animate(scale2D: 0.0, duration: duration, function: function ?? .easeInCubic, completion: completion)
        case .overlay(let function):
            let function = function ?? .easeInCubic
            KRAnimation.chain(
                dismissingContent!.chain(alpha: 0.0, duration: duration, function: function) + dismissingContent!.chain(scale2D: 2.0, duration: duration, function: function)
            ) {
                completion()
            }
        case .custom(let animClosure):
            animClosure(completion)
        case .noAnimation:
            self.dismissingContent!.removeFromSuperview()
            completion()
            
        }
    }
}
