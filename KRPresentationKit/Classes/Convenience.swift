//
//  Convenience.swift
//  Pods
//
//  Created by Joshua Park on 6/29/16.
//
//

import UIKit

internal extension CGColor {
    var uiColor: UIColor {
        return UIColor(cgColor: self)
    }
}

internal func radians(from degrees: Double) -> Double {
    return degrees * M_PI / 180.0
}

internal func radians(from degrees: CGFloat) -> CGFloat {
    return degrees * CGFloat(M_PI) / 180.0
}
