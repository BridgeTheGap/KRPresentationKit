//
//  CrossfadingTransition.swift
//  KRPresentationKit
//
//  Created by Joshua Park on 11/06/2018.
//

import UIKit

public protocol CrossfadingTransition: CustomPresenting {
    
    func fade(to viewController: UIViewController,
              using transitioner: KRTransitioner?,
              fadeIncompletion: (() -> Void)?,
              fadeOutCompletion: (() -> Void)?)
}

public extension CrossfadingTransition {
    
    func fade(to viewController: UIViewController,
              using transitioner: KRTransitioner?,
              fadeIncompletion: (() -> Void)? = nil,
              fadeOutCompletion: (() -> Void)? = nil)
    {
        let me = self as! UIViewController
        var transitioner = transitioner
        
        if transitioner === self.transitioner { transitioner = self.transitioner!.copied() }
        
        self.transitioner?.fade(to: transitioner)
        
        me.dismiss(animated: true, completion: {
            fadeIncompletion?()
            self.transitioner = transitioner
            
            viewController.transitioningDelegate = self.transitioner
            viewController.modalPresentationStyle = .custom
            me.present(viewController, animated: true, completion: fadeOutCompletion)
        })
    }
}
