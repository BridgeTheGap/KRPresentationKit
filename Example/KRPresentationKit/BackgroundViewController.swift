//
//  BackgroundViewController.swift
//  KRPresentationKit
//
//  Created by Joshua Park on 7/4/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//
#if false
import UIKit
import KRPresentationKit

class BackgroundViewController: KROverlayViewController {
    @IBAction func hideAction(_ sender: AnyObject) {
        presentingViewController?.dismiss(animated: true, completion: nil)
    }
}
#endif
