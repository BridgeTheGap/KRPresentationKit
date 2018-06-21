//
//  Attribute.swift
//  KRPresentationKit
//
//  Created by Joshua Park on 11/06/2018.
//

import UIKit

/**
 The attribute to apply to view in transition.
 
 - Note: Using `rotation`, `scale`, and `translation` requires
    careful handling of the order in which they are listed.
    Further documentation will be provided in the next versions.
 */
public enum Attribute {
    
    case alpha(CGFloat)
    
    case frame(CGRect)
    
    case position(CGPoint)
    
    case opacity(Float)
    
    case origin(CGPoint)
    
    case rotation(CGFloat)
    
    case scale(CGFloat)
    
    case size(CGSize)
    
    case translation(CGSize)
    
    /**
     Applies the attribute to the view that is passed in.
     
     - Parameter view: The view whose attribute to update.
     - Returns: The old value of the updated attribute.
     */
    func apply(to view: UIView) -> Attribute {
        var oldValue: Attribute
        
        switch self {
            
        case .alpha(let alpha):
            oldValue = .alpha(view.alpha)
            view.alpha = alpha
            
        case .frame(let frame):
            oldValue = .frame(view.frame)
            view.frame = frame
            
        case .opacity(let opacity):
            oldValue = .opacity(view.layer.opacity)
            view.layer.opacity = opacity
            
        case .origin(let origin):
            oldValue = .origin(view.frame.origin)
            view.frame.origin = origin
            
        case .position(let position):
            oldValue = .position(view.layer.position)
            view.layer.position = position
            
        case .rotation(let rotation):
            oldValue = .rotation(-rotation)
            let angle = radians(from: rotation)
            view.layer.transform = CATransform3DRotate(view.layer.transform, angle, 0.0, 0.0, 1.0)
            
        case .scale(let scale):
            oldValue = .scale(1.0/scale)
            view.layer.transform = CATransform3DScale(view.layer.transform, scale, scale, 1.0)
            
        case .size(let size):
            oldValue = .size(view.bounds.size)
            view.bounds.size = size
            
        case .translation(let translation):
            oldValue = .translation(CGSize(width: -translation.width,
                                           height: -translation.height))
            view.layer.transform = CATransform3DTranslate(view.layer.transform,
                                                          translation.width,
                                                          translation.height, 0.0)
            
        }
        
        return oldValue
    }
    
}
