//
//  BackgroundViewController.swift
//  KRPresentationKit
//
//  Created by Joshua Park on 7/4/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import UIKit
import KRPresentationKit

class BackgroundViewController: KROverlayViewController {
    @IBAction func hideAction(sender: AnyObject) {
        presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
}
