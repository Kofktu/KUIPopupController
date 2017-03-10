//
//  KUIPopupContentViewAnimator.swift
//  KUIPopupController
//
//  Created by kofktu on 2017. 3. 10..
//  Copyright © 2017년 Kofktu. All rights reserved.
//

import UIKit

public typealias KUIPopupContentViewAnimatorStateParameter = (isShow: Bool, contentView: UIView, containerView: UIView, containerViewCenterX: NSLayoutConstraint, containerViewCenterY: NSLayoutConstraint)
public protocol KUIPopupContentViewAnimator {
    func animate(_ parameter: KUIPopupContentViewAnimatorStateParameter, completion: @escaping (Bool) -> Void)
}
