//
//  Convenience.swift
//  Pods
//
//  Created by Joshua Park on 6/29/16.
//
//

import UIKit

internal var Screen: UIScreen {
    return UIScreen.mainScreen()
}

internal extension CGRect {
    var endPoint: CGPoint {
        get {
            return CGPoint(x: self.origin.x + self.width, y: self.origin.y + self.height)
        }
        set {
            self.origin.x = newValue.x - self.width
            self.origin.y = newValue.y - self.height
        }
    }
}
