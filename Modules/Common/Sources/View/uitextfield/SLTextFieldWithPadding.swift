//
//  SLTextFieldWithPadding.swift
//  matrix-shortform-ios
//
//  Created by 김우현 on 4/30/23.
//

import Foundation
import UIKit

public class SLTextFieldWithPadding: UITextField {
    private var textPadding: UIEdgeInsets
    
    public init(textPadding: UIEdgeInsets) {
        self.textPadding = textPadding
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func textRect(forBounds bounds: CGRect) -> CGRect {
        let rect = super.textRect(forBounds: bounds)
        return rect.inset(by: textPadding)
    }

    public override func editingRect(forBounds bounds: CGRect) -> CGRect {
        let rect = super.editingRect(forBounds: bounds)
        return rect.inset(by: textPadding)
    }
}
