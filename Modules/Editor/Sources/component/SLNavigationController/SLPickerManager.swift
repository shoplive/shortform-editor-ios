//
//  SLPickerManager.swift
//  matrix-shortform-ios
//
//  Created by 김우현 on 4/11/23.
//

import Foundation
import UIKit

class SLPickerNavigationController: UINavigationController {
    override var childForStatusBarHidden: UIViewController? {
        return topViewController
    }
}
