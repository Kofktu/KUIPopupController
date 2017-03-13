//
//  ViewController.swift
//  Example
//
//  Created by kofktu on 2017. 3. 10..
//  Copyright © 2017년 Kofktu. All rights reserved.
//

import UIKit
import KUIPopupController

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    // MARK: - Action
    @IBAction func onOpacityAnimator() {
        let view = ContentView(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 200.0, height: 200.0)))
        view.backgroundColor = UIColor.blue
        view.animator = OpacityAnimator()
        view.show()
    }
    
    @IBAction func onFromTopTranslationAnimator() {
        let view = ContentView(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 200.0, height: 200.0)))
        view.backgroundColor = UIColor.blue
        view.animator = FromTopTranslationAnimator()
        view.show()
    }
    
    @IBAction func onAutolayoutCustomView() {
        let view = ContentAutoLayoutView.view()
        view?.textLabel.text = "TEXT\nTEXT\nTEXT\nTEXTTEXTTEXT\nTEXT"
        view?.animator = FromTopTranslationAnimator()
        view?.show()
    }
}

class ContentView: UIView, KUIPopupContentViewProtocol {
    var animator: KUIPopupContentViewAnimator?
    var modalBackgroundColor: UIColor? {
        return UIColor.blue.withAlphaComponent(0.2)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        dismiss(true)
    }
}

class ContentAutoLayoutView: UIView, KUIPopupContentViewProtocol {
    var animator: KUIPopupContentViewAnimator?
    
    @IBOutlet weak var textLabel: UILabel!
    
    class func view() -> ContentAutoLayoutView? {
        let view = Bundle.main.loadNibNamed("ContentAutoLayoutView", owner: nil, options: nil)?.first as? ContentAutoLayoutView
        view?.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    
    // MARK: - Action
    @IBAction func onClose(_ sender: UIButton) {
        dismiss(true)
    }
}

// MARK: - Custom Animator
class OpacityAnimator: KUIPopupContentViewAnimator {
    func animate(_ parameter: KUIPopupContentViewAnimatorStateParameter, completion: @escaping (Bool) -> Void) {
        let isShow = parameter.isShow
        let containerView = parameter.containerView
        
        containerView.alpha = isShow ? 0.0 : 1.0
        UIView.animate(withDuration: 0.25, animations: {
            containerView.alpha = isShow ? 1.0 : 0.0
        }, completion: completion)
    }
}

class FromTopTranslationAnimator: KUIPopupContentViewAnimator {
    func animate(_ parameter: KUIPopupContentViewAnimatorStateParameter, completion: @escaping (Bool) -> Void) {
        let isShow = parameter.isShow
        let containerView = parameter.containerView
        let containerViewY = parameter.containerViewCenterY
        let screenHeight = UIScreen.main.bounds.height
        
        containerViewY.constant = isShow ? -screenHeight : 0.0
        containerView.superview?.layoutIfNeeded()
        
        containerViewY.constant = isShow ? 0.0 : -screenHeight
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.1, options: .allowUserInteraction, animations: {
            containerView.superview?.layoutIfNeeded()
            
            if !isShow {
                containerView.superview?.alpha = 0.0
            }
        }, completion: completion)
    }
}
