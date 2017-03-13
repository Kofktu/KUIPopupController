//
//  KUIPopupModalViewController.swift
//  KUIPopupController
//
//  Created by kofktu on 2017. 3. 10..
//  Copyright © 2017년 Kofktu. All rights reserved.
//

import UIKit

fileprivate final class KUIPopupModalViewController: UIViewController {
    fileprivate lazy var containerView: UIView = {
        let containerView = UIView(frame: CGRect.zero)
        containerView.backgroundColor = UIColor.clear
        containerView.translatesAutoresizingMaskIntoConstraints = false
        return containerView
    }()
    fileprivate var containerViewCenterX: NSLayoutConstraint!
    fileprivate var containerViewCenterY: NSLayoutConstraint!
    
    fileprivate var contentView: UIView!
    fileprivate var contentViewAnimator: KUIPopupContentViewAnimator?
    
    public override func loadView() {
        super.loadView()
        
        view.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        view.addSubview(containerView)
        containerViewCenterX = NSLayoutConstraint(item: containerView, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1.0, constant: 0.0)
        containerViewCenterY = NSLayoutConstraint(item: containerView, attribute: .centerY, relatedBy: .equal, toItem: view, attribute: .centerY, multiplier: 1.0, constant: 0.0)
        view.addConstraints([containerViewCenterX, containerViewCenterY])
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|->=0-[view]->=0-|", options: [], metrics: nil, views: ["view": containerView]))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|->=0-[view]->=0-|", options: [], metrics: nil, views: ["view": containerView]))
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    // MARK: - Private
    fileprivate func show(_ parentViewController: UIViewController) {
        parentViewController.present(self, animated: false) {
            self.setupContentView()
            
            guard let animator = self.contentViewAnimator else { return }
            let parameter = self.animatorParameter(isShow: true)
            animator.animate(parameter, completion: { [unowned self] (finished) in
                _ = self // for warning... (never used)
            })
        }
    }
    
    fileprivate func dismiss(_ animated: Bool) {
        if let animator = contentViewAnimator, animated {
            let parameter = self.animatorParameter(isShow: false)
            animator.animate(parameter, completion: { [unowned self] (finished) in
                self.dismiss(animated: false, completion: nil)
            })
        } else {
            self.dismiss(animated: false, completion: nil)
        }
    }
    
    private func setupContentView() {
        containerView.addSubview(contentView)
        
        if contentView.translatesAutoresizingMaskIntoConstraints {
            let size = contentView.bounds.size
            contentView.translatesAutoresizingMaskIntoConstraints = false
            contentView.addConstraint(NSLayoutConstraint(item: contentView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: size.width))
            contentView.addConstraint(NSLayoutConstraint(item: contentView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: size.height))
        }
        
        containerView.addConstraint(NSLayoutConstraint(item: contentView, attribute: .top, relatedBy: .equal, toItem: containerView, attribute: .top, multiplier: 1.0, constant: 0.0))
        containerView.addConstraint(NSLayoutConstraint(item: contentView, attribute: .leading, relatedBy: .equal, toItem: containerView, attribute: .leading, multiplier: 1.0, constant: 0.0))
        containerView.addConstraint(NSLayoutConstraint(item: containerView, attribute: .bottom, relatedBy: .equal, toItem: contentView, attribute: .bottom, multiplier: 1.0, constant: 0.0))
        containerView.addConstraint(NSLayoutConstraint(item: containerView, attribute: .trailing, relatedBy: .equal, toItem: contentView, attribute: .trailing, multiplier: 1.0, constant: 0.0))
        
        // if contentView is KUIPopupContentViewProtocol, set dismiss handler
        if contentView is KUIPopupContentViewProtocol {
            if let contentViewProtocol = contentView as? KUIPopupContentViewProtocol {
                view.backgroundColor = contentViewProtocol.modalBackgroundColor
                contentViewAnimator = contentViewProtocol.animator
            }
            
            contentView.onDismissHandler = { [weak self] (animated) in
                self?.dismiss(animated)
            }
        }
    }
}

fileprivate extension KUIPopupModalViewController {
    func animatorParameter(isShow: Bool) -> KUIPopupContentViewAnimatorStateParameter {
        return (isShow, contentView, containerView, containerViewCenterX, containerViewCenterY)
    }
}

// http://stackoverflow.com/questions/29106891/how-do-i-pass-in-a-void-block-to-objc-setassociatedobject-in-swift
fileprivate typealias DismissHandler = ((Bool) -> Void)
fileprivate class KUIPopupContentViewDismissHandlerWrapper {
    var closure: DismissHandler?
    init(_ closure: DismissHandler?) {
        self.closure = closure
    }
}

fileprivate extension UIView {
    struct AssociatedKeys {
        static var onDismissHandler = "onDismissHandler"
    }

    fileprivate var onDismissHandler: DismissHandler? {
        get {
            return (objc_getAssociatedObject(self, &AssociatedKeys.onDismissHandler) as? KUIPopupContentViewDismissHandlerWrapper)?.closure
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.onDismissHandler, KUIPopupContentViewDismissHandlerWrapper(newValue), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}

public extension KUIPopupContentViewProtocol where Self: UIView {
    public func show(_ parentViewController: UIViewController? = nil) {
        guard let parent = parentViewController ?? UIApplication.shared.keyWindow?.rootViewController?.topMostViewController else {
            fatalError("parentViewController is null")
        }
        
        let viewController = KUIPopupModalViewController()
        viewController.modalPresentationStyle = .overCurrentContext
        viewController.contentView = self
        viewController.show(parent)
    }
    
    public func dismiss(_ animated: Bool) {
        onDismissHandler?(animated)
    }
}

fileprivate extension UIViewController {
    fileprivate var topMostViewController: UIViewController {
        return topViewControllerWithRootViewController(self)
    }
    
    fileprivate func topViewControllerWithRootViewController(_ rootViewController: UIViewController) -> UIViewController {
        if let tabBarController = rootViewController as? UITabBarController {
            return topViewControllerWithRootViewController(tabBarController.selectedViewController!)
        } else if let naviController = rootViewController as? UINavigationController {
            return topViewControllerWithRootViewController(naviController.viewControllers.last!)
        } else if let viewController = rootViewController.presentedViewController {
            return topViewControllerWithRootViewController(viewController)
        }
        
        return rootViewController
    }
}
