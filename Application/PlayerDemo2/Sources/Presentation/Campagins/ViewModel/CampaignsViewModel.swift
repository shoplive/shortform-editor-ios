//
//  CampaignsViewModel.swift
//  PlayerDemo2
//
//  Created by Tabber on 1/17/25.
//  Copyright © 2025 com.app. All rights reserved.
//

import UIKit

extension CampaignsViewController {
    class ViewModel: ObservableObject {
        var items: [ShopLiveKeySet] = []
        var selectKeySet: Bool = false
    }
}
