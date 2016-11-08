//
//  KRView.swift
//  Pods
//
//  Created by Joshua Park on 7/5/16.
//
//

import UIKit

open class KRView: UIView {

    open weak var sender: AnyObject! {
        willSet {
            guard newValue is UIView else { fatalError("Only decendants UIView can be assisnged to KRView.sender.") }
        }
    }
    
    open var allowsUserInteraction: Bool = false
    
    @IBInspectable open var insets: UIEdgeInsets?
    
    override open var backgroundColor: UIColor? {
        get {
            return fillLayer.fillColor?.getUIColor()
        }
        set {
            fillLayer.fillColor = newValue?.cgColor
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
        self.init(frame: CGRect.zero, sender: sender)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        
        if fillLayer.superlayer !== self { layer.insertSublayer(fillLayer, at: 0) }
        
        let path = UIBezierPath(rect: bounds)
        let subPath: UIBezierPath = {
            var frame = sender.frame
            if let insets = insets {
                frame?.origin.x -= insets.left
                frame?.origin.y -= insets.top
                frame?.size.width += insets.left + insets.right
                frame?.size.height += insets.top + insets.bottom
            }
            
            return UIBezierPath(roundedRect: frame!, cornerRadius: sender.layer.cornerRadius)
        }()
        path.append(subPath)
        
        fillLayer.frame = bounds
        fillLayer.path = path.cgPath
        fillLayer.fillRule = kCAFillRuleEvenOdd
    }
    
    override open func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let view = sender as! UIView
        let localFrame = superview!.convert(view.frame, from: view.superview)
        if localFrame.contains(point) {
            let convertedPoint = convert(point, to: view.superview)
            return view.superview?.hitTest(convertedPoint, with: event)
        } else {
            return super.hitTest(point, with: event)
        }
    }
}
