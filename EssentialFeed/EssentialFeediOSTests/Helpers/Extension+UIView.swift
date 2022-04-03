//
//  Extension+UIView.swift
//  EssentialFeediOS
//
//  Created by Roman Bozhenko on 03.04.2022.
//

import UIKit

extension UIView {
    func enforceLayoutCycle() {
        layoutIfNeeded()
        RunLoop.current.run(until: Date())
    }
}
