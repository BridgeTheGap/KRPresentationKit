//
//  TransitionAttributes.swift
//  KRPresentationKit
//
//  Created by Joshua Park on 11/06/2018.
//

import KRTimingFunction

public struct TransitionAttributes: TransitionDataType {
    
    public var initial: [Attribute]
    
    public var duration: Double
    
    public var timingFunction: FunctionType
    
    public var shouldInvertForDismissal: Bool = true
    
    public init() {
        self.initial = [Attribute]()
        self.timingFunction = .easeInOutCubic
        self.duration = 0.3
    }
    
    public init(initial: [Attribute],
                timingFunction: FunctionType = .easeInOutCubic,
                duration: Double = 0.3)
    {
        (self.initial, self.timingFunction, self.duration) = (initial, timingFunction, duration)
    }
}

