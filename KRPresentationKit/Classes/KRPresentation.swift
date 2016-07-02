//
//  KRPresentation.swift
//  Pods
//
//  Created by Joshua Park on 7/1/16.
//
//

import UIKit

public enum ContentAnimationStyle {
    case None
    case FadeIn
    case FadeInOut
    case FadeOut
}

public class KRContentViewController: UIViewController {
    @IBInspectable public var destinationFrame: CGRect = CGRectZero
    @IBInspectable public var useSnapshot: Bool = false
    public var viewAnimDuration: Double?
    public var viewAnimStyle: ContentAnimationStyle = .None
}

public class KRViewController: UIViewController {
    var transitioner: KRTransitioner?
    
    override final public func presentViewController(viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)?) {
        presentViewController(viewControllerToPresent, style: .SlideUp(.EaseInOutCubic), completion: completion)
    }
    
    public func presentViewController(viewController: UIViewController, duration: Double = 0.5, style: KRTransitionStyle, completion: (() -> Void)?) {
        if let vc = viewController as? KRContentViewController {
            guard vc.destinationFrame != CGRectZero else {
                fatalError("\(vc.dynamicType).destinationFrame not set.\n`destinationFrame` needs to be set in order to use KRPresentationStyles.")
            }
            transitioner = KRTransitioner(style, duration: duration)
            vc.modalPresentationStyle = .Custom
            vc.transitioningDelegate = transitioner
        }
            
        super.presentViewController(viewController, animated: true, completion: completion)
    }
    
    public func fadeToViewController(viewController: UIViewController, duration: Double = 0.5, style: KRTransitionStyle,  completion: (() -> Void)?) {
        dismissViewController(duration: duration) {
            self.presentViewController(viewController, duration: duration, style: style, completion: completion)
        }
    }
    
    final override public func dismissViewControllerAnimated(flag: Bool, completion: (() -> Void)?) {
        dismissViewController(flag, completion: completion)
    }
    
    public func dismissViewController(flag: Bool = true, duration: Double = 0.5, completion: (() -> Void)?) {
        super.dismissViewControllerAnimated(flag, completion: completion)
    }
}