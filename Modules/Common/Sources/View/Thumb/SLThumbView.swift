//
//  SLThumbView.swift
//  ShopliveSDKCommon
//
//  Created by Tabber on 3/18/25.
//  Copyright © 2025 com.app. All rights reserved.
//

import UIKit

public class SLThumbView: UIView {
    let touchAreaPadding: CGFloat = 20
    
    public override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let expandedBounds = bounds.insetBy(dx: -touchAreaPadding, dy: -touchAreaPadding)
        return expandedBounds.contains(point)
    }
}
