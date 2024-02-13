//
//  SLBundle+SPM.swift
//  
//
//  Created by wade.hawk on 2020/09/20.
//

import Foundation
import UIKit

open class SLBundle {
    open class func slPhotoPickerBundleImage() -> UIImage? {
        podBundleImage(named: "SLPhotoPickerController")
    }
    
    open class func podBundleImage(named: String) -> UIImage? {
        let podBundle = Bundle(for: SLBundle.self)
        if let url = podBundle.url(forResource: named, withExtension: "bundle") {
            let bundle = Bundle(url: url)
            return UIImage(named: named, in: bundle, compatibleWith: nil)
        }
        return nil
    }
    
    class func bundle() -> Bundle {
        let podBundle = Bundle(for: SLBundle.self)
        if let url = podBundle.url(forResource: "SLPhotoPickerController", withExtension: "bundle") {
            let bundle = Bundle(url: url)
            return bundle ?? podBundle
        }
        return podBundle
    }
}
