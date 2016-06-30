//
//  ViewController.swift
//  KRPresentationKit
//
//  Created by Joshua Park on 06/30/2016.
//  Copyright (c) 2016 Joshua Park. All rights reserved.
//

import UIKit
import KRPresentationKit

class ViewController: CustomPresentationViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func presentAction(sender: AnyObject) {
        let pvc = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("PresentedVC")
        presentViewController(pvc, completion: nil)
    }
}

