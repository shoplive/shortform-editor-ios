//
//  SLBackspaceDetectingTextField.swift
//  SLWSTagsField
//
//  Created by Ilya Seliverstov on 11/07/2017.
//  Copyright © 2017 Whitesmith. All rights reserved.
//

import UIKit

protocol SLSLBackspaceDetectingTextFieldDelegate: UITextFieldDelegate {
    /// Notify whenever the backspace key is pressed
    func textFieldDidDeleteBackwards(_ textField: UITextField)
}

open class SLBackspaceDetectingTextField: UITextField {

    open var onDeleteBackwards: (() -> Void)?
    
    private let maxLength : Int = 30

    init() {
        super.init(frame: CGRect.zero)
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    open override func deleteBackward() {
        onDeleteBackwards?()
        // Call super afterwards. The `text` property will return text prior to the delete.
        super.deleteBackward()
    }

    override open func paste(_ sender: Any?) {
        if var paste = UIPasteboard.general.string {
            let availableLength = max(0,maxLength - (self.text ?? "").count - 1)
            paste = String(paste.prefix(availableLength))
            UIPasteboard.general.string = paste
        }
        super.paste(sender)
    }
}
