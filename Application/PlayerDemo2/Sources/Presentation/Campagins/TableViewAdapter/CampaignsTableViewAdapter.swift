//
//  CampaignsTableViewAdapter.swift
//  PlayerDemo2
//
//  Created by Tabber on 1/31/25.
//  Copyright © 2025 com.app. All rights reserved.
//

import Foundation
import UIKit
import ShopLiveSDK
import ShopliveSDKCommon

protocol CampaignsTableViewAdapterDelegate: NSObjectProtocol {
    func tableViewDidTap(indexPath: IndexPath)
    func removeAction(data: ShopLiveKeySet)
    func tableViewUpdate(dismiss: Bool)
    func dismiss()
}

protocol CampaignsTableViewAdapterDataSource: NSObjectProtocol {
    var selectKeyValue: Bool { get }
    
    func numberOfItems(at section: Int) -> Int
    func data(at indexPath: IndexPath) -> ShopLiveKeySet?
}

final class CampaignsTableViewAdapter: NSObject {
    weak var delegate: CampaignsTableViewAdapterDelegate?
    weak var dataSource: CampaignsTableViewAdapterDataSource?
    
    func registerTableView(tableView: UITableView) {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(CampaignCell.self, forCellReuseIdentifier: CampaignCell.cellId)
    }
}

extension CampaignsTableViewAdapter: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource?.numberOfItems(at: section) ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let item = self.dataSource?.data(at: indexPath) else {
            fatalError("CampaignsTableViewAdapter: dataSource not set")
        }
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CampaignCell.cellId) as? CampaignCell else { return UITableViewCell() }
        
        cell.configure(keySet: item)
        return cell
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        switch editingStyle {
        case .delete:
            
            if let item = dataSource?.data(at: indexPath) {
                delegate?.removeAction(data: item)
            }
            
            delegate?.tableViewUpdate(dismiss: false)
            break
        default:
            break
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let value = dataSource?.selectKeyValue, value else { return }
        delegate?.tableViewDidTap(indexPath: indexPath)
        delegate?.dismiss()
    }
}
