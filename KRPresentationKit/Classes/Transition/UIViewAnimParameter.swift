//
//  UIViewAnimParameter.swift
//  KRPresentationKit
//
//  Created by Joshua Park on 11/06/2018.
//

import UIKit

public struct UIViewAnimParameter: TransitionParameterType {
    
    public var initial: [Attribute]
    
    public var options: UIView.AnimationOptions
    
    public var duration: Double
    
    public init(initial: [Attribute],
                options: UIView.AnimationOptions = [],
                duration: Double)
    {
        self.initial = initial
        self.options = options
        self.duration = duration
    }
}
