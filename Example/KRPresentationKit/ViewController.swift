//
//  ViewController.swift
//  KRPresentationKit
//
//  Created by Joshua Park on 06/30/2016.
//  Copyright (c) 2016 Joshua Park. All rights reserved.
//

import UIKit
import KRPresentationKit

let attrib1: [Attribute] = [
    .position(CGPoint(x: UIScreen.main.bounds.midX,
                      y: -UIScreen.main.bounds.midY)),
]

let attrib2: [Attribute] = [
    .alpha(0.0),
    .scale(1.5),
]

let attrib3: [Attribute] = [
    .alpha(0.0),
    .scale(0.01),
    .rotation(-360.0),
]

let color1 = UIColor(white: 0.0, alpha: 0.4)
let color2 = UIColor(white: 1.0, alpha: 0.75)
let color3 = UIColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 0.3)

class ViewController: UIViewController, CrossfadingTransition, ContainerViewDelegate, UIGestureRecognizerDelegate {
    
    var transitioner: KRTransitioner?
    weak var containerView: UIView?
    
    @IBOutlet weak var typeSelector: UISegmentedControl!
    @IBOutlet weak var colorSelector: UISegmentedControl!
    @IBOutlet weak var durationSlider: UISlider!
    
    @IBOutlet weak var animationSwitch: UISwitch!
    @IBOutlet weak var functionSelector: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - 
    
    private func getAttributes(sender: Any) -> TransitionAttributes {
        let attrib: [Attribute] = {
            switch typeSelector.selectedSegmentIndex {
            case 0: return attrib1
            case 1: return attrib2
            default:
                var attrib = attrib3
                let position = (sender as! UIButton).center
                attrib.append(.position(position))
                return attrib
            }
        }()
        
        var attribs = TransitionAttributes(initial: attrib)
        attribs.duration = Double(durationSlider.value)
        
        switch functionSelector.selectedSegmentIndex {
        case 0: attribs.timingFunction = .easeOutCubic
        case 1: attribs.timingFunction = .easeOutBounce
        default: attribs.timingFunction = .easeOutBack
        }
        
        return attribs
    }
    
    private func getAnimation(sender: Any) -> TransitionAnimation {
        let attrib: [Attribute] = {
            switch typeSelector.selectedSegmentIndex {
            case 0: return attrib1
            case 1: return attrib2
            default:
                var attrib = attrib3
                let position = (sender as! UIButton).center
                attrib.append(.position(position))
                return attrib
            }
        }()
        
        return TransitionAnimation(initial: attrib, options: [], duration: Double(durationSlider.value))
    }
    
    private func chromeColor() -> UIColor? {
        switch colorSelector.selectedSegmentIndex {
        case 0: return color1
        case 1: return color2
        default: return color3
        }
    }
    
    @IBAction func toggleAnimation(_ sender: Any) {
        functionSelector.isEnabled = animationSwitch.isOn
    }

    @IBAction func presentAction(_ sender: Any) {
        let attribs: TransitionDataType = animationSwitch.isOn ? getAttributes(sender: sender) : getAnimation(sender: sender)
        
        transitioner = KRTransitioner(attributes: attribs)
        transitioner!.transitionID = "PresentedVC"
        transitioner!.containerViewDelegate = self
        
        let size = CGSize(width: min(UIScreen.main.bounds.width * 0.8, 450.0),
                          height: UIScreen.main.bounds.height * 0.5)
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PresentedVC")
        vc.transitioningDelegate = transitioner
        vc.modalPresentationStyle = .custom
        vc.view.frame = CGRect(origin: CGPoint.zero, size: size)
        vc.view.center = self.view.center
        
        present(vc, animated: true, completion: nil)
    }
    
    @IBAction func presentBGAction(_ sender: Any) {
        let attribs: TransitionDataType = animationSwitch.isOn ? getAttributes(sender: sender) : getAnimation(sender: sender)
        
        transitioner = KRTransitioner(attributes: attribs)
        transitioner?.transitionID = "BackgroundVC"
        
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "BackgroundVC")
        vc.transitioningDelegate = transitioner
        vc.modalPresentationStyle = .custom
        vc.view.layoutIfNeeded()
        
        present(vc, animated: true, completion: nil)
    }
    
    @IBAction func action(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Container view delegate
    
    func prepare(containerView: UIView, for transitioner: KRTransitioner) {
        switch transitioner.state {
        case .presenting, .fadingIn:
            let tapGR = UITapGestureRecognizer(target: self, action: #selector(action(_:)))
            tapGR.delegate = self
            containerView.addGestureRecognizer(tapGR)
            containerView.backgroundColor = UIColor.clear
            
            self.containerView = containerView
            
            if transitioner.state == .fadingIn {
                containerView.backgroundColor = transitioner.transitioningBackground?.backgroundColor
                transitioner.transitioningBackground?.backgroundColor = UIColor.clear
            }
        case .fadingOut:
            transitioner.transitioningBackground?.backgroundColor = containerView.backgroundColor
            containerView.backgroundColor = UIColor.clear
        default: break
        }
    }
    
    func animate(containerView: UIView, for transitioner: KRTransitioner) {
        switch transitioner.state {
        case .presenting:
            containerView.backgroundColor = chromeColor()
        case .fadingIn:
            switch transitioner.transitionID ?? "" {
            case "fade1": containerView.backgroundColor = color1
            case "fade2": containerView.backgroundColor = color2
            default: containerView.backgroundColor = color3
            }
            transitioner.transitioningBackground?.backgroundColor = UIColor.clear
        case.dismissing:
            containerView.backgroundColor = UIColor.clear
        default: break
        }
    }
    
    func finalize(containerView: UIView, for transitioner: KRTransitioner) {
        
    }
    
    // MARK: - Gesture recognizer delegate
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return touch.view === containerView ? true : false
    }
}
