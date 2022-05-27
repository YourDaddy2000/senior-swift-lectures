//
//  UITableView+Dequeueing.swift
//  EssentialFeediOS
//
//  Created by Roman Bozhenko on 27.12.2021.
//

import UIKit

extension UITableView {
    func dequeueReusableCell<T: UITableViewCell>() -> T {
        let identifier = String(describing: T.self)
        return dequeueReusableCell(withIdentifier: identifier) as! T
    }
}
