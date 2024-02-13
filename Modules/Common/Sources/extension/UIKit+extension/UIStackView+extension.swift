//
//  UIStackView+extension.swift
//  ShopliveCommonLibrary
//
//  Created by James Kim on 11/27/22.
//

import UIKit

public extension UIStackView {
    func addArrangedSubviews_SL(_ views: UIView...) {
        views.forEach { view in
            self.addArrangedSubview(view)
        }
    }
}
