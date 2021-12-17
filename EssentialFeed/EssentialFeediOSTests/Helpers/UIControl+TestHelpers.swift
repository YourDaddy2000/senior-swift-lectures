//
//  UIControl+TestHelpers.swift
//  EssentialFeediOSTests
//
//  Created by Roman Bozhenko on 17.12.2021.
//

import UIKit

extension UIButton {
    func simulateTap() {
        simulate(.touchUpInside)
    }
}

extension UIRefreshControl {
    func simulatePullToRefresh() {
        simulate(.valueChanged)
    }
}

extension UIControl {
    func simulate(_ event: UIControl.Event) {
        allTargets.forEach { target in
            actions(forTarget: target, forControlEvent: event)?.forEach {
                (target as NSObject).perform(Selector($0))
            }
        }
    }
}
