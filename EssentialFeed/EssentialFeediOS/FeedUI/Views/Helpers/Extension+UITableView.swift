//
//  Extension+UITableView.swift
//  EssentialFeediOS
//
//  Created by Roman Bozhenko on 25.03.2022.
//

import UIKit

extension UITableView {
    func sizeTableHeaderToFit() {
        guard let header = tableHeaderView else { return }
        
        let size = header.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        
        let needsUpdate = header.frame.height != size.height
        
        if needsUpdate {
            header.frame.size.height = size.height
            tableHeaderView = header
        }
    }
}
