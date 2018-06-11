//
//  TransitionAnimation.swift
//  KRPresentationKit
//
//  Created by Joshua Park on 11/06/2018.
//

import UIKit

public struct TransitionAnimation: TransitionDataType {
    
    public var initial: [Attribute]
    
    public var options: UIViewAnimationOptions
    
    public var duration: Double
    
    public init(initial: [Attribute],
                options: UIViewAnimationOptions = [],
                duration: Double)
    {
        (self.initial, self.options, self.duration) = (initial, options, duration)
    }
}
