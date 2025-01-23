//
//  UserDefaults+Extension.swift
//  PlayerDemo2
//
//  Created by Tabber on 1/17/25.
//  Copyright © 2025 com.app. All rights reserved.
//

import UIKit

extension UserDefaults {
  func set(_ value: UIEdgeInsets, forKey key: String) {
    let rectDataArray = [value.top, value.left, value.bottom, value.right]
    set(rectDataArray, forKey: key)
  }

  func cgRect(forKey key: String) -> UIEdgeInsets? {
      guard let rectDataArray = array(forKey: key) as? [CGFloat] else { return nil }
      guard rectDataArray.count == 4 else { return nil }

      return UIEdgeInsets(top: rectDataArray[0], left: rectDataArray[1], bottom: rectDataArray[2], right: rectDataArray[3])
  }
}
