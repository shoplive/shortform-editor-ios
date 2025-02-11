//
//  CustomParameterTableViewAdapater.swift
//  PlayerDemo2
//
//  Created by sangmin han on 2/6/25.
//  Copyright © 2025 com.app. All rights reserved.
//

import Foundation
import UIKit




protocol CustomParameterSettingTableViewAdapterDelegate : NSObjectProtocol {
    func customParameterValueChanged(at customParameterId : Int, key : String, value : String, isUse : Bool)
    func removeCustomParamter(at customParamterId : Int)
}

protocol CustomParameterSettingTableViewAdapterDataSource : NSObjectProtocol {
    var numberOfItem : Int { get }
    
    func data(at indexPath : IndexPath) -> CustomParameter
}


final class CustomParameterSettingTableViewAdapter : NSObject {
   
    weak var delegate : CustomParameterSettingTableViewAdapterDelegate?
    weak var dataSource : CustomParameterSettingTableViewAdapterDataSource?
    
    func registerTableView(tableView : UITableView) {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(CustomParameterSettingTableViewCell.self, forCellReuseIdentifier: CustomParameterSettingTableViewCell.cellId)
    }
   
}
extension CustomParameterSettingTableViewAdapter : UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource?.numberOfItem ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CustomParameterSettingTableViewCell.cellId, for: indexPath) as? CustomParameterSettingTableViewCell else {
            fatalError()
        }
        
        if let data = dataSource?.data(at: indexPath) {
            cell.configure(customParameterId: data.customParameterId, key: data.paramKey, value: data.paramValue ?? "", isUse: data.isUseParam)
            cell.delegate = self
        }
       
        return cell
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            guard let data = dataSource?.data(at: indexPath) else { return }
            self.delegate?.removeCustomParamter(at: data.customParameterId)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
}
extension CustomParameterSettingTableViewAdapter : CustomParameterSettingTableViewCellDelegate {
    func customParameterValueChanged(at customParamterId: Int, key: String, value: String, isUse: Bool) {
        self.delegate?.customParameterValueChanged(at: customParamterId, key: key, value: value, isUse: isUse)
    }
    
}
