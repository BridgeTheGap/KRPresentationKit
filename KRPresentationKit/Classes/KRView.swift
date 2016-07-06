//
//  KRView.swift
//  Pods
//
//  Created by Joshua Park on 7/5/16.
//
//

import UIKit

public class KRView: UIView {

    public weak var sender: AnyObject! {
        willSet {
            guard newValue is UIView else { fatalError("Only decendants UIView can be assisnged to KRView.sender.") }
        }
    }
    
    public var allowsUserInteraction: Bool = false
    
    @IBInspectable public var insets: UIEdgeInsets?
    
    override public var backgroundColor: UIColor? {
        get {
            return fillLayer.fillColor?.getUIColor()
        }
        set {
            fillLayer.fillColor = newValue?.CGColor
        }
    }
    
    private let fillLayer = CAShapeLayer()
    
    public init?(frame: CGRect, sender: AnyObject?) {
        guard let sender = sender else { return nil }
        super.init(frame: frame)
        self.sender = sender
    }
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    convenience public init?(sender: AnyObject?) {
        self.init(frame: CGRectZero, sender: sender)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        if fillLayer.superlayer !== self { layer.insertSublayer(fillLayer, atIndex: 0) }
        
        let path = UIBezierPath(rect: bounds)
        let subPath: UIBezierPath = {
            var frame = sender.frame
            if let insets = insets {
                frame.origin.x -= insets.left
                frame.origin.y -= insets.top
                frame.size.width += insets.left + insets.right
                frame.size.height += insets.top + insets.bottom
            }
            
            return UIBezierPath(roundedRect: frame, cornerRadius: sender.layer.cornerRadius)
        }()
        path.appendPath(subPath)
        
        fillLayer.frame = bounds
        fillLayer.path = path.CGPath
        fillLayer.fillRule = kCAFillRuleEvenOdd
    }
    
    override public func hitTest(point: CGPoint, withEvent event: UIEvent?) -> UIView? {
        let view = sender as! UIView
        let localFrame = superview!.convertRect(view.frame, fromView: view.superview)
        if localFrame.contains(point) {
            let convertedPoint = convertPoint(point, toView: view.superview)
            return view.superview?.hitTest(convertedPoint, withEvent: event)
        } else {
            return super.hitTest(point, withEvent: event)
        }
    }
}
