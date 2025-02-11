//
//  UserInfoTableViewAdpater.swift
//  PlayerDemo2
//
//  Created by Tabber on 2/6/25.
//  Copyright © 2025 com.app. All rights reserved.
//

import UIKit
import ShopliveSDKCommon

protocol UserInfoTableViewAdapterDelegate: NSObjectProtocol {
    func removeAction(indexPath: IndexPath)
    func appendKey(text: String)
    func appendValue(text: String)
}

protocol UserInfoTableViewAdapterDataSource: NSObjectProtocol {
    func numberOfItems(at section: Int) -> Int
    func data(at indexPath: IndexPath) -> UserInfoParameter
}

final class UserInfoTableViewAdpater: NSObject {
    weak var delegate: UserInfoTableViewAdapterDelegate?
    weak var dataSource: UserInfoTableViewAdapterDataSource?
    
    func registerTableView(tableView: UITableView) {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(AddUserParameterCell.self, forCellReuseIdentifier: AddUserParameterCell.cellId)
    }
}


extension UserInfoTableViewAdpater: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource?.numberOfItems(at: section) ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let item = self.dataSource?.data(at: indexPath) else {
            fatalError("UserInfoTableViewAdpater: dataSource not set")
        }
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: AddUserParameterCell.cellId) as? AddUserParameterCell else { return UITableViewCell(style: .default, reuseIdentifier: "Cell") }
        
        cell.configure(key: item.key, value: item.value)
        
        cell.keyInputField.delegate = self
        cell.valueInputField.delegate = self
        cell.keyInputField.tag = indexPath.row
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
            if editingStyle == .delete {
                delegate?.removeAction(indexPath: indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    
}
// MARK: - UITextFieldDelegate
extension UserInfoTableViewAdpater: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let text = textField.text else {
            return
        }
        
        switch(textField.accessibilityIdentifier) {
        case "keyInputField":
            delegate?.appendKey(text: text)
            break
        case "valueInputField":
            delegate?.appendValue(text: text)
            break
        case _:
            break
        }
    }
}

