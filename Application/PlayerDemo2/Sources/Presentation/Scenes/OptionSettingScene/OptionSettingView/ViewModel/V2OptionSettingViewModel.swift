//
//  V2OptionSettingViewModel.swift
//  PlayerDemo2
//
//  Created by sangmin han on 1/28/25.
//  Copyright © 2025 com.app. All rights reserved.
//

import Foundation
import UIKit
import ShopliveSDKCommon
import ShopLiveSDK

protocol OptionSettingViewModelDelegate : NSObjectProtocol {
    func showDropDown(with source : [String], indexPath : IndexPath, cell : UITableViewCell, completion : @escaping( (String,Int) -> Void ))
    func showAlertTextInputBox(header : String, data : String?, placeHolder : String, completion : @escaping(String) -> Void)
    func reloadTableView()
}

final class OptionSettingViewModel : NSObject {
    
    private let optionSettingUseCase : OptionSettingUseCase
    private let sdkConfigureMapperUseCase : SDKConfigurationMapperUseCase
    
    private let tableViewAdapter : OptionTableViewAdapter = OptionTableViewAdapter()
    
    private let numberFormatter = NumberFormatter()
    
    private var sdkConfiguration : SDKConfiguration?
    private var items : [SDKOption] = []
    var routing : OptionSettingRouting?
    weak var delegate : OptionSettingViewModelDelegate?
    
    init(optionSettingUseCase : OptionSettingUseCase,
         sdkConfigureMapperUseCase : SDKConfigurationMapperUseCase,
         routing : OptionSettingRouting) {
        self.optionSettingUseCase = optionSettingUseCase
        self.sdkConfigureMapperUseCase = sdkConfigureMapperUseCase
        super.init()
        self.routing = routing
        tableViewAdapter.delegate = self
        tableViewAdapter.dataSource = self
        loadSDKConfiguration()
        makeTableViewData()
    }
    
    deinit {
        print("\(Self.className) deinit")
    }
    
    func registerTableView(tableView : UITableView) {
        tableViewAdapter.registerTableView(tableView: tableView)
    }
    
    private func loadSDKConfiguration() {
        self.sdkConfiguration = optionSettingUseCase.getOptions()
    }
    
    private func makeTableViewData() {
        guard let sdkConfig = self.sdkConfiguration else { return }
        
        let dataMaker = OptionSettingTableViewDataMaker()
        self.items = dataMaker.getDataSource().map { option in
            let newItems = option.optionItems.map{ item in
                let value = sdkConfigureMapperUseCase.getValue(by: item.optionType,
                                                               from: sdkConfig)
                return SDKOptionItem(name: item.name,
                                     optionDescription: item.optionDescription,
                                     optionType: item.optionType,
                                     value: value)
            }
            return SDKOption(optionTitle: option.optionTitle, optionItems: newItems)
        }
    }
    
    
}
extension OptionSettingViewModel : OptionTableViewAdapterDelegate, OptionTableViewAdapterDataSource {
    
    var numberOfSection: Int {
        return self.items.count
    }
    
    func numberOfItems(at section: Int) -> Int {
        return self.items[section].optionItems.count
    }
    
    func headerData(at section: Int) -> SDKOption {
        return self.items[section]
    }
    
    func data(at indexPath: IndexPath) -> SDKOptionItem? {
        return self.items[safe: indexPath.section]?.optionItems[safe : indexPath.row]
    }
    
    func tableViewDidTapRouteToCell(indexPath: IndexPath) {
        guard let optionType = items[safe : indexPath.section]?.optionItems[indexPath.row].optionType else { return }
        switch optionType {
        case .pipFloatingOffset:
            routing?.showSetPipFloatingOffsetViewController()
        case .addParameter:
            routing?.showAddCustomQueryParameterViewController()
        case .pipPinPosition:
            routing?.showSetPipPinPositionViewController()
        default:
            break
        }
    }
    
    //MARK: - DropDown Action
    func tableViewDidTapDropBoxCell(cell: UITableViewCell, indexPath: IndexPath) {
        guard let optionType = items[safe : indexPath.section]?.optionItems[indexPath.row].optionType else { return }
        
        if optionType == .nextActionOnHandleNavigation {
            handleNextActionHandleDropBoxAction(cell: cell, indexPath: indexPath)
        }
        else if optionType == .pipPosition {
            handlePipPositionDropBoxAction(cell: cell, indexPath: indexPath)
        }
        else if optionType == .resizeMode {
            handleResizeModeDropBoxAction(cell: cell, indexPath: indexPath)
        }
        else if optionType == .previewResolution {
            handlePreviewResolutionDropBoxAction(cell: cell, indexPath: indexPath)
        }
    }
    
    private func handleNextActionHandleDropBoxAction(cell : UITableViewCell, indexPath : IndexPath) {
        let source = ["sdkoption.nextActionTypeOnNavigation.item1".localized(),
                      "sdkoption.nextActionTypeOnNavigation.item2".localized(),
                      "sdkoption.nextActionTypeOnNavigation.item3".localized()]
        
        delegate?.showDropDown(with: source, indexPath: indexPath, cell: cell, completion: { [weak self] text, index in
            let newValue = ActionType(rawValue: index) ?? .PIP
            self?.saveNewSDkConfig(optionType: .nextActionOnHandleNavigation, value: newValue)
        })
    }
    
    private func handlePipPositionDropBoxAction(cell : UITableViewCell, indexPath : IndexPath) {
        let source = ["topLeft", "topRight", "bottomLeft","bottomRight"]
        
        delegate?.showDropDown(with: source, indexPath: indexPath, cell: cell, completion: { [weak self] text, index in
            var newValue : ShopLive.PipPosition = .bottomRight
            switch text {
            case "topLeft":
                newValue = .topLeft
            case "topRight":
                newValue = .topRight
            case "bottomLeft":
                newValue = .bottomLeft
            case "bottomRight":
                newValue = .bottomRight
            default:
                newValue = .bottomRight
            }
            self?.saveNewSDkConfig(optionType: .pipPosition, value: newValue)
        })
    }
    
    private func handleResizeModeDropBoxAction(cell : UITableViewCell, indexPath : IndexPath) {
        let source = ["CENTER_CROP", "FIT", "AUTO"]
        delegate?.showDropDown(with: source, indexPath: indexPath, cell: cell, completion: { [weak self] text, index in
            var newValue : ShopLiveResizeMode = .AUTO
            switch text {
            case "CENTER_CROP":
                newValue = .CENTER_CROP
            case "FIT":
                newValue = .FIT
            case "AUTO":
                newValue = .AUTO
            default:
                newValue = .AUTO
            }
            self?.saveNewSDkConfig(optionType: .resizeMode, value: newValue)
        })
    }
    
    private func handlePreviewResolutionDropBoxAction(cell : UITableViewCell, indexPath : IndexPath) {
        let source = ["LIVE", "PREVIEW"]
        delegate?.showDropDown(with: source, indexPath: indexPath, cell: cell, completion: { [weak self] text, index in
            var newValue : ShopLivePlayerPreviewResolution = .LIVE
            switch text {
            case "LIVE":
                newValue = .LIVE
            case "PREVIEW":
                newValue = .PREVIEW
            default:
                newValue = .LIVE
            }
            self?.saveNewSDkConfig(optionType: .previewResolution, value: newValue)
        })
    }
    
    
    //MARK: - Alert Action
    func tableViewDidTapAlertCell(indexPath: IndexPath) {
        guard let optionType = items[safe : indexPath.section]?.optionItems[indexPath.row].optionType else { return }
        switch optionType {
        case .shareScheme:
            self.handleShareSchemeAlert()
        case .progressColor:
            self.handleProgressColorAlert()
        case .maxPipSize:
            self.handleMaxPipSizeAlert()
        case .fixedHeightPipSize:
            self.handlefixedHeightPipSize()
        case .fixedWidthPipSize:
            self.handlefixedWidthPipSize()
        case .pipCornerRadius:
            self.handlePipCornerRadius()
        default:
            break
        }
    }
    
    private func handleShareSchemeAlert() {
        let header : String = "sdkoption.section.share.title".localized()
        let data : String = sdkConfiguration?.customShareScheme ?? ""
        let placeHolder : String = "Url"
        self.delegate?.showAlertTextInputBox(header: header, data: data, placeHolder: placeHolder, completion: { [weak self] scheme in
            self?.saveNewSDkConfig(optionType: .shareScheme, value: scheme)
            self?.delegate?.reloadTableView()
        })
    }
    
    private func handleProgressColorAlert() {
        let header : String = "로딩 프로그레스 색상"
        let data : String = sdkConfiguration?.customProgressColor ?? ""
        let placeHolder : String = "ex) #FF0000"
        
        self.delegate?.showAlertTextInputBox(header: header, data: data, placeHolder: placeHolder, completion: { [weak self] color in
            self?.saveNewSDkConfig(optionType: .customProgress, value: color)
            self?.delegate?.reloadTableView()
        })
    }
    
    private func handleMaxPipSizeAlert() {
        let header : String = "sdkOption.pipMaxSize.title".localized()
        let data : String = sdkConfiguration?.maxPipSize == nil ? "" : String(format: "%.0f",  sdkConfiguration!.maxPipSize!)
        let placeHolder : String = "ex) 200"
        
        self.delegate?.showAlertTextInputBox(header: header, data: data, placeHolder: placeHolder, completion: { [weak self] maxPipSize in
            self?.saveNewSDkConfig(optionType: .maxPipSize, value: CGFloat(Double(maxPipSize) ?? 200) )
            self?.delegate?.reloadTableView()
        })
    }
    
    private func handlefixedHeightPipSize() {
        let header : String = "sdkOption.pipFixedHeight.title".localized()
        let data : String = sdkConfiguration?.fixedHeightPipSize == nil ? "" : String(format: "%.0f",  sdkConfiguration!.fixedHeightPipSize!)
        let placeHolder : String = "ex) 200"
        
        self.delegate?.showAlertTextInputBox(header: header, data: data, placeHolder: placeHolder, completion: { [weak self] pipHeight in
            self?.saveNewSDkConfig(optionType: .fixedHeightPipSize, value: CGFloat(Double(pipHeight) ?? 200))
            self?.delegate?.reloadTableView()
        })
    }
    
    private func handlefixedWidthPipSize() {
        let header : String = "sdkOption.pipFixedWidth.title".localized()
        let data : String = sdkConfiguration?.fixedWidthPipSize == nil ? "" : String(format: "%.0f",  sdkConfiguration!.fixedWidthPipSize!)
        let placeHolder : String = "ex) 200"
        
        self.delegate?.showAlertTextInputBox(header: header, data: data, placeHolder: placeHolder, completion: { [weak self] pipWidth in
            self?.saveNewSDkConfig(optionType: .fixedWidthPipSize, value: CGFloat(Double(pipWidth) ?? 200))
            self?.delegate?.reloadTableView()
        })
    }
    
    private func handlePipCornerRadius() {
        let header : String = "sdkOption.pipCornerRadius.title".localized()
        let data : String = sdkConfiguration?.pipCornerRadius == nil ? "" : String(format: "%.0f",  sdkConfiguration!.pipCornerRadius!)
        let placeHolder : String = "ex) 10"
        
        self.delegate?.showAlertTextInputBox(header: header, data: data, placeHolder: placeHolder, completion: { [weak self] pipCornerRadius in
            self?.saveNewSDkConfig(optionType: .pipCornerRadius, value: CGFloat(Double(pipCornerRadius) ?? 200))
            self?.delegate?.reloadTableView()
        })
    }
    
    //MARK: - switch action
    func tableViewDidTapSwitchCell(indexPath: IndexPath, isOn: Bool) {
        guard let optionType = items[safe : indexPath.section]?.optionItems[indexPath.row].optionType else { return }
        saveNewSDkConfig(optionType: optionType, value: isOn)
    }
    
    
    private func saveNewSDkConfig(optionType : SDKOptionType, value : Any) {
        guard let sdkConfig = sdkConfiguration else { return }
        let newValue = sdkConfigureMapperUseCase.setValue(by: optionType, to: sdkConfig, value: value)
        self.sdkConfiguration = newValue
        optionSettingUseCase.saveOptions(data: newValue)
        var section : Int = 0
        var index : Int? = 0
        for i in 0...items.count - 1 {
            if let value = items[i].optionItems.firstIndex(where: { $0.optionType == optionType }) {
                index = value
                break
            }
            section += 1
        }
        guard let index = index else { return }
        
        let oldItem = items[section].optionItems[index]
        
        self.items[section].optionItems.remove(at: index)
        self.items[section].optionItems.insert(.init(name: oldItem.name,
                                                     optionDescription: oldItem.optionDescription,
                                                     optionType: optionType,
                                                     value: value), at: index)
        
        delegate?.reloadTableView()
    }
}
