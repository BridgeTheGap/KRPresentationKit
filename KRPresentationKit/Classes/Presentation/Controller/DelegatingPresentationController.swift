//
//  DelegatingPresentationController.swift
//  KRPresentationKit
//
//  Created by Joshua Park on 11/06/2018.
//

import UIKit

/**
 A presentation controller provided when the source view controller
 conforms to `ContainerViewDelegate`.
 */
internal class DelegatingPresentationController: UIPresentationController {
    
    private typealias TransitionClosure = (UIViewControllerTransitionCoordinatorContext) -> Void
    
    weak var transitioner: KRTransitioner?
    
    private override init(presentedViewController: UIViewController,
                          presenting presentingViewController: UIViewController?)
    {
        fatalError("use `init(presentedViewController:presenting:transitioner:)`")
    }
    
    /**
     - Parameters:
        - presentedViewController: The presented view controller provided by UIKit.
        - presentingViewController: The presenting view controller provided by UIKit.
        - transitioner:
            The `transitioner` must have its `containerViewDelegate` set.
            Otherwise, other `UIPresentationController` types should be used.
     */
    init(presentedViewController: UIViewController,
         presenting presentingViewController: UIViewController?,
         transitioner: KRTransitioner)
    {
        assert(transitioner.containerViewDelegate != nil)
        
        super.init(presentedViewController: presentedViewController,
                   presenting: presentingViewController)
        
        self.transitioner = transitioner
    }
    
    override func presentationTransitionWillBegin() { transition() }
    
    override func dismissalTransitionWillBegin() { transition() }
    
    private func transition() {
        guard let coordinator = presentedViewController.transitionCoordinator else { return }
        guard let transitioner = transitioner else { return }
        guard let delegate = transitioner.containerViewDelegate else {
            let message = "[\(type(of: self))] The `transitioner` has been changed." +
                          "Check the VC under the presented VC to ensure " +
                          "`transitioner` isn't modified before the presented VC is dismissed."
            
            print(message)
            return
        }
        
        let anim: TransitionClosure = { [weak delegate, weak self] (context) in
            guard let delegate = delegate else { return }
            guard let transitioner = self?.transitioner else { return }
            
            UIView.animate(withDuration: context.transitionDuration) {
                delegate.animate(containerView: context.containerView,
                                 for: transitioner)
            }
        }
        let comp: TransitionClosure = { [weak delegate, weak self] (context) in
            guard let delegate = delegate else { return }
            guard let transitioner = self?.transitioner else { return }
            
            delegate.finalize(containerView: context.containerView,
                              for: transitioner)
        }
        
        delegate.prepare(containerView: containerView!,
                         for: transitioner)
        
        coordinator.animate(alongsideTransition: anim,
                            completion: comp)
    }
}
