//
//  ErrorView.swift
//  EssentialFeediOS
//
//  Created by Roman Bozhenko on 15.01.2022.
//

import UIKit

public final class ErrorView: UIView {
    @IBOutlet private var errorButton: UIButton?
    
    public var errorMessage: String? {
        get { isVisible ? errorButton?.title(for: .normal) : nil }
        set { setMessageAnimated(newValue) }
    }
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        
        errorButton?.setTitle(nil, for: .normal)
        alpha = 0
    }
    
    private var isVisible: Bool {
        return alpha > 0
    }
    
    private func setMessageAnimated(_ message: String?) {
        if let message = message {
            showAnimated(message)
        } else {
            hideMessageAnimated()
        }
    }
    
    private func showAnimated(_ message: String) {
        errorButton?.setTitle(message, for: .normal)
        
        UIView.animate(withDuration: 0.25) {
            self.alpha = 1
        }
    }
    
    private func hideMessageAnimated() {
        UIView.animate(
            withDuration: 0.25,
            animations: { self.alpha = 0 },
            completion: { completed in
                if completed { self.errorButton?.setTitle(nil, for: .normal) }
            })
    }
}
