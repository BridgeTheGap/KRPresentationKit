//
//  KRViewController.swift
//  Pods
//
//  Created by Joshua Park on 7/1/16.
//
//

import UIKit
import KRAnimationKit

public enum ContentAnimationStyle {
    case None
    case FadeIn
    case FadeInOut
    case FadeOut
}

public protocol ContentAnimatable {
    var destinationFrame: CGRect { get set }
    var useSnapshot: Bool { get set }
    var viewAnimDuration: Double? { get set }
    var viewAnimStyle: ContentAnimationStyle { get set }
    weak var sourceVC: KRViewController? { get set }
}

public class KRContentViewController: UIViewController, ContentAnimatable {
    @IBInspectable public var destinationFrame: CGRect = CGRectZero
    @IBInspectable public var useSnapshot: Bool = false
    public var viewAnimDuration: Double?
    public var viewAnimStyle: ContentAnimationStyle = .None
    public weak var sourceVC: KRViewController?
}

public class KROverlayViewController: KRContentViewController {
    @IBOutlet public weak var contentView: UIView!
    public var backgroundAnim: ((Double, Bool) -> [AnimationDescriptor])!
}

public class KRViewController: UIViewController {
    var transitioner: KRTransitioningDelegate?
    
    override final public func presentViewController(viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)?) {
        if flag {
            presentViewController(viewControllerToPresent, style: .SlideUp(.EaseInOutCubic), completion: completion)
        } else {
            super.presentViewController(viewControllerToPresent, animated: flag, completion: completion)
        }
    }
    
    public func presentViewController(viewController: UIViewController, duration: Double = 0.5, style: KRTransitionStyle, completion: (() -> Void)?) {
        presentViewController(viewController, duration: duration, style: style, isFading: false, completion: completion)
    }
    
    private func presentViewController(viewController: UIViewController, duration: Double, style: KRTransitionStyle, isFading: Bool, completion: (() -> Void)?) {
        if let vc = viewController as? KRContentViewController {
            guard vc.destinationFrame != CGRectZero else {
                fatalError("\(vc.dynamicType).destinationFrame not set.\n`destinationFrame` needs to be set in order to use KRPresentationStyles.")
            }
            
            switch style {
            case .Overlay, .Popup:
                if !vc.useSnapshot {
                    print("\(style) manipulates transform, which in turn mangles the appearance of views using auto layout. `\(vc.dynamicType).useSnapshot` will be set to `true`.");
                    vc.useSnapshot = true
                }
            default: break
            }
            
            if let overlayVC = vc as? KROverlayViewController {
                overlayVC.loadView()
                guard overlayVC.contentView != nil else {
                    fatalError("\(vc.dynamicType).contentView not set.\n`contentView` needs to be set in order to use KRPresentationStyles.")
                }
                transitioner = KROverlayTransitioner(style, duration: duration)
            } else {
                if isFading {
                    transitioner!.transitionStyle = style
                } else {
                    transitioner = KRContentTransitioner(style, duration: duration)
                }
            }
            
            vc.sourceVC = self
            vc.modalPresentationStyle = .Custom
            vc.transitioningDelegate = transitioner
        }
        
        super.presentViewController(viewController, animated: true, completion: completion)
    }
    
    public func fadeToViewController(viewController: UIViewController, duration: Double = 0.5, style: KRTransitionStyle,  completion: (() -> Void)?) {
        if let transitioner = presentedViewController!.transitioningDelegate as? KRContentTransitioner {
            transitioner.isFading = true
        }

        dismissViewControllerAnimated(true) {
            self.presentViewController(viewController, duration: duration, style: style, isFading: true, completion: completion)
        }
    }
}