//
//  ErrorView.swift
//  EssentialFeediOS
//
//  Created by Roman Bozhenko on 15.01.2022.
//

import UIKit

public final class ErrorView: UIView {
    @IBOutlet private var errorButton: UIButton?
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        
        errorButton?.setTitle(nil, for: .normal)
    }
    
    public var errorMessage: String? {
        get { errorButton?.title(for: .normal) }
        set { errorButton?.setTitle(newValue, for: .normal) }
    }
}
