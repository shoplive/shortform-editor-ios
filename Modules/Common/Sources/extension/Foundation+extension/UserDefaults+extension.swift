//
//  UserDefaults+extension.swift
//  ShopliveSDKCommon
//
//  Created by Vincent on 1/25/23.
//

import Foundation
import UIKit

public extension UserDefaults {
  func set_SL(_ value: UIEdgeInsets, forKey key: String) {
    let rectDataArray = [value.top, value.left, value.bottom, value.right]
    set(rectDataArray, forKey: key)
  }

  func cgRect_SL(forKey key: String) -> UIEdgeInsets? {
      guard let rectDataArray = array(forKey: key) as? [CGFloat] else { return nil }
      guard rectDataArray.count == 4 else { return nil }

      return UIEdgeInsets(top: rectDataArray[0], left: rectDataArray[1], bottom: rectDataArray[2], right: rectDataArray[3])
  }
}
