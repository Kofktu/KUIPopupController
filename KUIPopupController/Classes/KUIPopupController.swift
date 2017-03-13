//
//  KUIPopupController.swift
//  KUIPopupController
//
//  Created by kofktu on 2017. 3. 10..
//  Copyright © 2017년 Kofktu. All rights reserved.
//

import UIKit

public protocol KUIPopupContentViewProtocol {
    var modalBackgroundColor: UIColor? { get }
    var animator: KUIPopupContentViewAnimator? { get }
}

public extension KUIPopupContentViewProtocol {
    var modalBackgroundColor: UIColor? {
        return UIColor.black.withAlphaComponent(0.6)
    }
}
