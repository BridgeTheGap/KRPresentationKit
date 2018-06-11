//
//  Presentation.swift
//  Pods
//
//  Created by Joshua Park on 23/11/2016.
//
//

import UIKit

public protocol CustomPresenting: class {
    
    var transitioner: KRTransitioner? { get set }
    
}

public protocol CustomPresented: class {
    
    var customPresenting: UIViewController? { get set }
    
}

public protocol ContainerViewDelegate: class {
    
    func prepare(containerView: UIView, for transitioner: KRTransitioner)
    
    func animate(containerView: UIView, for transitioner: KRTransitioner)
    
    func finalize(containerView: UIView, for transitioner: KRTransitioner)
    
}

public protocol CustomBackgroundProvider: class {
    
    var contentView: UIView! { get }
    
    var presentationAnimation: (() -> Void)? { get }
    
    var dismissalAnimation: (() -> Void)? { get }
    
}

