//
//  CampaignsViewModel.swift
//  PlayerDemo2
//
//  Created by Tabber on 1/17/25.
//  Copyright © 2025 com.app. All rights reserved.
//

import UIKit
import ShopliveSDKCommon

protocol CampaignsViewModelDelegate: NSObjectProtocol {
    func reloadTableView(dismiss: Bool)
}

class CampaignsViewModel: NSObject {
    
    let useCase: CampaignsUseCase
    var selectKeySet: Bool = true
    
    private var item: ShopLiveCampaignsKey = .init(currentSelectKey: "", shopLiveKetSets: [])
    
    private let tableViewAdapter: CampaignsTableViewAdapter = CampaignsTableViewAdapter()
    
    weak var routing: CampaignsRouting?
    weak var delegate: CampaignsViewModelDelegate?
    
    init(useCase: CampaignsUseCase, routing: CampaignsRouting) {
        self.useCase = useCase
        self.routing = routing
        super.init()
        tableViewAdapter.delegate = self
        tableViewAdapter.dataSource = self
        loadItems()
    }
    
    func registerTableView(tableView: UITableView) {
        tableViewAdapter.registerTableView(tableView: tableView)
    }
    
    func getKeyCount() -> Int {
        return item.shopLiveKetSets.count
    }
    
    func removeAll() {
        item = .init(currentSelectKey: "", shopLiveKetSets: [])
        useCase.applyKetSet(keySet: item)
        tableViewUpdate(dismiss: true)
    }
    
    func appendItems(keySet: ShopLiveKeySet) {
        item.shopLiveKetSets.append(keySet)
        setCurrentKey(keyName: keySet.alias)
        tableViewUpdate(dismiss: true)
    }
    
    func setItems(keySet: ShopLiveCampaignsKey) {
        useCase.applyKetSet(keySet: keySet)
        item = useCase.getKeySet() ?? .init(currentSelectKey: "", shopLiveKetSets: [])
    }
    
    func setCurrentKey(keyName: String) {
        item.currentSelectKey = keyName
        useCase.applyKetSet(keySet: item)
    }
    
    func removeKey(alias: String) {
        var items = item.shopLiveKetSets
        if let index = item.shopLiveKetSets.firstIndex(where: { $0.alias == alias }) {
            
            let item = item.shopLiveKetSets[index]
            
            items.remove(at: index)
            
            if item.alias == self.item.currentSelectKey {
                self.item.currentSelectKey = ""
            }
            
        }
        item.shopLiveKetSets = items
        useCase.applyKetSet(keySet: item)
        tableViewUpdate(dismiss: false)
    }
    
    func loadItems() {
        self.item = useCase.getKeySet() ?? .init(currentSelectKey: "", shopLiveKetSets: [])
    }
    
    func getItems() -> [ShopLiveKeySet] {
        return item.shopLiveKetSets
    }
}

extension CampaignsViewModel: CampaignsTableViewAdapterDelegate, CampaignsTableViewAdapterDataSource {
    
    var selectKeyValue: Bool {
        return self.selectKeySet
    }
    
    func removeAction(data: ShopLiveKeySet) {
        removeKey(alias: data.alias)
    }
    
    func tableViewDidTap(indexPath: IndexPath) {
        setCurrentKey(keyName: item.shopLiveKetSets[indexPath.row].alias)
        routing?.dismissViewController()
    }
    
    func tableViewUpdate(dismiss: Bool) {
        delegate?.reloadTableView(dismiss: dismiss)
    }
    
    func dismiss() {
        routing?.dismissViewController()
    }
    
    
    func numberOfItems(at section: Int) -> Int {
        return item.shopLiveKetSets.count
    }
    
    func data(at indexPath: IndexPath) -> ShopLiveKeySet? {
        return self.item.shopLiveKetSets[safe: indexPath.row]
    }
    
    
}
