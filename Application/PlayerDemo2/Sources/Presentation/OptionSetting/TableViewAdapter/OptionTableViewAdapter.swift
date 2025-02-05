//
//  OptionTableViewAdapter.swift
//  PlayerDemo2
//
//  Created by sangmin han on 1/29/25.
//  Copyright © 2025 com.app. All rights reserved.
//

import Foundation
import UIKit
import ShopLiveSDK
import ShopliveSDKCommon


protocol OptionTableViewAdapterDelegate : NSObjectProtocol {
    func tableViewDidTapRouteToCell(indexPath : IndexPath)
    func tableViewDidTapDropBoxCell(cell : UITableViewCell, indexPath : IndexPath)
    func tableViewDidTapAlertCell(indexPath : IndexPath)
    func tableViewDidTapSwitchCell(indexPath : IndexPath, isOn : Bool)
}

protocol OptionTableViewAdapterDataSource : NSObjectProtocol {
    var numberOfSection : Int { get }
    
    func numberOfItems(at section : Int) -> Int
    func data(at indexPath : IndexPath) -> SDKOptionItem?
    func headerData(at section : Int) -> SDKOption
}

final class OptionTableViewAdapter : NSObject {
   
    weak var delegate : OptionTableViewAdapterDelegate?
    weak var dataSource : OptionTableViewAdapterDataSource?
    
    
    func registerTableView(tableView : UITableView) {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(OptionSwitchCell.self, forCellReuseIdentifier: OptionSwitchCell.cellId)
        tableView.register(OptionRoutingCell.self, forCellReuseIdentifier: OptionRoutingCell.cellId)
        tableView.register(OptionDropDownCell.self, forCellReuseIdentifier: OptionDropDownCell.cellId)
        tableView.register(OptionAlertCell.self, forCellReuseIdentifier: OptionAlertCell.cellId)
        tableView.register(OptionSectionHeader.self, forHeaderFooterViewReuseIdentifier: OptionSectionHeader.headerId)
    }
    
}
extension OptionTableViewAdapter : UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return dataSource?.numberOfSection ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource?.numberOfItems(at: section) ?? 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: OptionSectionHeader.headerId ) as? OptionSectionHeader, let item = dataSource?.headerData(at: section) else { return nil }
        header.configure(headerTitle: item.optionTitle, section: section)
        return header
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let optionItem = self.dataSource?.data(at: indexPath) else {
            fatalError("OptionTableViewAdapter: dataSource not set")
        }
        if optionItem.optionType.settingType == .routeTo {
            let cell = tableView.dequeueReusableCell(withIdentifier: OptionRoutingCell.cellId) as! OptionRoutingCell
            cell.configure(title: optionItem.name, description: optionItem.optionDescription)
            return cell
        }
        else if optionItem.optionType.settingType == .dropdown {
            let cell = tableView.dequeueReusableCell(withIdentifier: OptionDropDownCell.cellId) as! OptionDropDownCell
            cell.configureCell(title: optionItem.name, description: optionItem.optionDescription, value: optionValueToEnumRawValue(value : optionItem.value, type : optionItem.optionType))
            return cell
        }
        else if optionItem.optionType.settingType == .showAlert {
            let cell = tableView.dequeueReusableCell(withIdentifier: OptionAlertCell.cellId) as! OptionAlertCell
            var value : String = "no value"
            if let temp = optionItem.value {
                value = "\(temp)"
            }
            cell.configureCell(title: optionItem.name, description: optionItem.optionDescription, value: value)
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: OptionSwitchCell.cellId) as! OptionSwitchCell
            cell.configureCell(title: optionItem.name, description: optionItem.optionDescription, isOn: optionItem.value as? Bool ?? false, indexPath: indexPath)
            cell.delegate = self
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) else { return }
        switch cell {
        case is OptionRoutingCell:
            self.delegate?.tableViewDidTapRouteToCell(indexPath: indexPath)
        case is OptionDropDownCell:
            self.delegate?.tableViewDidTapDropBoxCell(cell: cell, indexPath: indexPath)
        case is OptionAlertCell:
            self.delegate?.tableViewDidTapAlertCell(indexPath: indexPath)
        default:
            break
        }
    }
    
    private func optionValueToEnumRawValue(value : Any?, type : SDKOptionType) -> String {
        guard let value = value else {
            return ""
        }
        switch type {
        case .pipPosition:
            return (value as? ShopLive.PipPosition ?? .bottomRight).name
        case .nextActionOnHandleNavigation:
            return (value as? ActionType ?? .PIP).name
        case .resizeMode:
            return getShopLiveResizeModeName(resizeMode: (value as? ShopLiveResizeMode ?? .CENTER_CROP))
        case .previewResolution:
            return getShopLivePlayerPreviewResolution(resolution: value as? ShopLivePlayerPreviewResolution ?? .LIVE)
        default:
            break
        }
        return ""
    }
    
    private func getShopLiveResizeModeName(resizeMode : ShopLiveResizeMode) -> String {
        switch resizeMode {
        case .AUTO:
            return "AUTO"
        case .CENTER_CROP:
            return "CENTER_CROP"
        case .FIT:
            return "FIT"
        }
    }
    
    private func getShopLivePlayerPreviewResolution(resolution : ShopLivePlayerPreviewResolution) -> String {
        switch resolution {
        case .LIVE:
            return "Live"
        case .PREVIEW:
            return "PREVIEW"
        }
    }
}
extension OptionTableViewAdapter : OptionSwitchCellDelegate {
    func optionSwitchCellDidChangeValue(at indexPath : IndexPath, isOn: Bool) {
        self.delegate?.tableViewDidTapSwitchCell(indexPath: indexPath, isOn: isOn)
    }
}

