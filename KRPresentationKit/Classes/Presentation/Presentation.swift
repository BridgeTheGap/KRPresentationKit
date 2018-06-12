//
//  Presentation.swift
//  Pods
//
//  Created by Joshua Park on 23/11/2016.
//
//

import UIKit

/**
 The protocol to be adopted by the source VC for custom presentation;
 i.e. the VC on which `present(_:animated:completion:)` was called.
 
 - Requires: The adopting class must be a subtype of `UIViewController`.
 */
public protocol CustomPresenting: NSObjectProtocol {
    
    /**
     The object to handle transition and animations.
     */
    var transitioner: KRTransitioner? { get set }
    
}

// TODO: Check if `customPresenting` can be removed; i.e. remove the protocol.
/**
 The protocol to be adopted by the presented VC for custom presentation.
 
 - Requires: The adopting class must be a subtype of `UIViewController`.
 */
public protocol CustomPresented: NSObjectProtocol {
    
    var customPresenting: UIViewController? { get set }
    
}

/**
 The protocol to be adopted if it wants to control
 the decorative views outside the content view of the presented VC.
 
 It is natural to set the source VC as the `ContainerViewDelegate`,
 but it is not required.
 
 - Requires:
 The class implementing this protocol must set itself as
 the `containerViewDelegate` before the source VC calls
 `present(_:animated:completion:)`.
 */
public protocol ContainerViewDelegate: class {
    
    /**
     A preparation method called before the transition.
     
     The delegate object should perform any preparations,
     such as adding and setting decorative views in place, in this method.
     
     - Requires: `transitioner.containerViewDelegate = self`
     - Parameters:
        - containerView: The view that contains the presented view
            and all other decorative views.
        - transitioner: The object providing transition effects.
     */
    func prepare(containerView: UIView, for transitioner: KRTransitioner)
    
    /**
     The animated to be performed during the transition.
     
     The implementation of this block is the view animations
     to be performed with the transition animation.
     
     Setting view properties in this method results in an animation
     that is guaranteed to begin and end with the transition animation.
     
     - Requires: `transitioner.containerViewDelegate = self`
     - Parameters:
        - containerView: The view that contains the presented view
            and all other decorative views.
        - transitioner: The object providing transition effects.
     */
    func animate(containerView: UIView, for transitioner: KRTransitioner)
    
    /**
     A clean-up method called before ending the transition.
     
     The delegate object should perform any clean-up operations,
     such as removing any temporary views, in this method.
     
     - Requires: `transitioner.containerViewDelegate = self`
     - Parameters:
        - containerView: The view that contains the presented view
            and all other decorative views.
        - transitioner: The object providing transition effects.
     */
    func finalize(containerView: UIView, for transitioner: KRTransitioner)
    
}

/**
 The protocol to be adopted for VCs that provide
 a background view to cover the whole screen and a separate content view.
 
 **Discussion**
 
 Adopting this protocol means the presented VC will take the responsibility
 of controlling the background view,
 as the container view will only provide a transparent background
 that allows the view underneath to be seen.
 
 The `contentView` must contain all subviews related to content.
 The `view` property will be resized to cover the whole screen,
 and be seen as merely providing a background to the content.
 
 - Requires: The adopting class must be a subtype of `UIViewController`.
 */
public protocol CustomBackgroundProvider: NSObjectProtocol {
    
    /// The view that contains all content related subviews in the VC.
    var contentView: UIView! { get }
    
    /**
     The animation to be performed when the VC is being presented.
     
     **Discussion**
     
     Since most animations will involve manipulating views
     that are one of the properties of the VC,
     two methods can be employed to allow this at the time of initialization:
     
     1. Lazy stored property
        ````
        lazy var presentationAnimation: (() -> Void)? = { [weak self] in
            guard let weakSelf = self else { return }
            weakSelf.view.backgroundColor = UIColor(white: 0.0, alpha: 0.3)
        }
        ````
     
     2. Computed property
        ````
        var presentationAnimation: (() -> Void)? {
            return { [weak self] in
                guard let weakSelf = self else { return }
                weakSelf.view.backgroundColor = UIColor(white: 0.0, alpha: 0.3)
            }
        }
        ````
     
     - Warning:
        It is easy to strongly capture `self` in the animation block.
        This will result in a reference cycle and cause a memory leak.
        It could also result in unexpected bugs if the VC is removed from
        the window view hierarchy just before the animation is triggered.
     
        Make sure to capture `self` using only `weak`.
     */
    var presentationAnimation: (() -> Void)? { get }
    
    /**
     The animation to be performed when the VC is being presented.
     
     **Discussion**
     
     Since most animations will involve manipulating views
     that are one of the properties of the VC,
     two methods can be employed to allow this at the time of initialization:
     
     1. Lazy stored property
        ````
        lazy var dismissalAnimation: (() -> Void)? = { [weak self] in
            guard let weakSelf = self else { return }
            weakSelf.view.backgroundColor = UIColor.clear
        }
        ````
     
     2. Computed property
        ````
        var dismissalAnimation: (() -> Void)? {
            return { [weak self] in
                guard let weakSelf = self else { return }
                weakSelf.view.backgroundColor = UIColor.clear
            }
        }
        ````
     
     - Warning:
         It is easy to strongly capture `self` in the animation block.
         This will result in a reference cycle and cause a memory leak.
         It could also result in unexpected bugs if the VC is removed from
         the window view hierarchy just before the animation is triggered.
     
         Make sure to capture `self` using only `weak`.
     */
    var dismissalAnimation: (() -> Void)? { get }
    
}

/**
 A protocol to be adopted if the source VC needs to crossfade
 two VCs; i.e. present another VC while dismissing a VC.
 
 A default implementation is provided, so the source VC only has to
 include `CrossfadingTransition` in the type inheritance list.
 */
public protocol CrossfadingTransition: CustomPresenting {
    
    func fade(to viewController: UIViewController,
              using transitioner: KRTransitioner?,
              fadeInCompletion: (() -> Void)?,
              fadeOutCompletion: (() -> Void)?)
    
}

internal extension CrossfadingTransition {
    
    /**
     The default implementation.
     */
    func fade(to viewController: UIViewController,
              using transitioner: KRTransitioner?,
              fadeInCompletion: (() -> Void)? = nil,
              fadeOutCompletion: (() -> Void)? = nil)
    {
        var transitioner = transitioner
        
        if transitioner === self.transitioner { transitioner = self.transitioner!.copied() }
        
        self.transitioner?.fade(to: transitioner)
        
        (self as! UIViewController).dismiss(animated: true)
        { [weak self, weak viewController] in
            guard let weakSelf = self else { return }
            guard let viewController = viewController else { return }
            
            fadeInCompletion?()
            weakSelf.transitioner = transitioner
            
            viewController.transitioningDelegate = weakSelf.transitioner
            viewController.modalPresentationStyle = .custom
            (weakSelf as! UIViewController).present(viewController,
                                                    animated: true,
                                                    completion: fadeOutCompletion)
        }
    }
    
}
