//
//  TransitionParameterType.swift
//  KRPresentationKit
//
//  Created by Joshua Park on 11/06/2018.
//

import Foundation

public protocol TransitionParameterType {
    
    var initial: [Attribute] { get set }
    
    var duration: Double { get set }
    
}
