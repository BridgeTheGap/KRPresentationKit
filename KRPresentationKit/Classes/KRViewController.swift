#if false
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
    case none
    case fadeIn
    case fadeInOut
    case fadeOut
}

public protocol ContentAnimatable {
    var destinationFrame: CGRect { get set }
    var useSnapshot: Bool { get set }
    var viewAnimDuration: Double? { get set }
    var viewAnimStyle: ContentAnimationStyle { get set }
    weak var sourceVC: KRViewController? { get set }
}

open class KRContentViewController: UIViewController, ContentAnimatable {
    @IBInspectable open var destinationFrame: CGRect = CGRect.zero
    @IBInspectable open var useSnapshot: Bool = false
    open var viewAnimDuration: Double?
    open var viewAnimStyle: ContentAnimationStyle = .none
    open weak var sourceVC: KRViewController?
    open weak var sender: AnyObject?
}

open class KROverlayViewController: KRContentViewController {
    @IBOutlet open weak var contentView: UIView!
    open var backgroundAnim: ((Double, Bool) -> [AnimationDescriptor])!
}

open class KRViewController: UIViewController {
    var transitioner: KRTransitioningDelegate?
    
    override final public func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)?) {
        if flag {
            present(viewControllerToPresent, style: .slideUp(.easeInOutCubic), completion: completion)
        } else {
            super.present(viewControllerToPresent, animated: flag, completion: completion)
        }
    }
    
    open func present(_ viewController: UIViewController, duration: Double = 0.5, style: KRTransitionStyle, completion: (() -> Void)?) {
        present(viewController, duration: duration, style: style, isFading: false, completion: completion)
    }
    
    private func present(_ viewController: UIViewController, duration: Double, style: KRTransitionStyle, isFading: Bool, completion: (() -> Void)?) {
        if let vc = viewController as? KRContentViewController {
            guard vc.destinationFrame != CGRect.zero else {
                fatalError("\(type(of: vc)).destinationFrame not set.\n`destinationFrame` needs to be set in order to use KRPresentationStyles.")
            }
            
            switch style {
            case .overlay, .popup:
                if !vc.useSnapshot {
                    print("\(style) manipulates transform, which in turn mangles the appearance of views using auto layout. `\(type(of: vc)).useSnapshot` will be set to `true`.");
                    vc.useSnapshot = true
                }
            default: break
            }
            
            if let overlayVC = vc as? KROverlayViewController {
                let sender = (overlayVC.view as! KRView).sender
                overlayVC.loadView()
                (overlayVC.view as! KRView).sender = sender
                guard overlayVC.contentView != nil else {
                    fatalError("\(type(of: vc)).contentView not set.\n`contentView` needs to be set in order to use KRPresentationStyles.")
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
            vc.modalPresentationStyle = .custom
            vc.transitioningDelegate = transitioner
        }
        
        super.present(viewController, animated: true, completion: completion)
    }
    
    open func fade(to viewController: UIViewController, duration: Double = 0.5, style: KRTransitionStyle,  completion: (() -> Void)?) {
        if let transitioner = presentedViewController!.transitioningDelegate as? KRContentTransitioner {
            transitioner.isFading = true
        }

        dismiss(animated: true) {
            self.present(viewController, duration: duration, style: style, isFading: true, completion: completion)
        }
    }
}
#endif
