//
//  V2OptionSettingViewController.swift
//  PlayerDemo2
//
//  Created by sangmin han on 1/28/25.
//  Copyright © 2025 com.app. All rights reserved.
//

import Foundation
import iOSDropDown
import SnapKit
import UIKit



final class V2OptionSettingViewController : UIViewController {
    
    
    private lazy var dropdown : DropDown = {
        let dropdown = DropDown()
        return dropdown
    }()
    
    private lazy var tableView: UITableView = {
        let view = UITableView(frame: .zero, style: .plain)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        view.separatorStyle = .none
        view.contentInsetAdjustmentBehavior = .never
        view.estimatedRowHeight = UITableView.automaticDimension
        view.alwaysBounceVertical = false
        return view
    }()
    
    private let viewModel  : OptionSettingViewModel
    
    init(viewModel: OptionSettingViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        self.viewModel.delegate = self
        viewModel.registerTableView(tableView: tableView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        setLayout()
        setDropDownListener()
    }
    
    private func setDropDownListener() {
        dropdown.listWillAppear { [weak self] in
            self?.dropdown.isHidden = false
        }
        dropdown.listDidAppear { [weak self] in
            self?.dropdown.isHidden = false
        }
        dropdown.listWillDisappear { [weak self] in
            self?.dropdown.isHidden = true
        }
        dropdown.listDidDisappear { [weak self] in
            self?.dropdown.isHidden = true
        }
    }
    
}
extension V2OptionSettingViewController : OptionSettingViewModelDelegate {
    func showDropDown(with source: [String], indexPath: IndexPath, cell: UITableViewCell, completion: @escaping ((String, Int) -> Void)) {
        let cellRect = view.convert(tableView.rectForRow(at: indexPath), from: tableView)
        let anchorView = UIView(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
        view.backgroundColor = .clear
        self.view.addSubview(anchorView)
        anchorView.frame = CGRect(origin: .init(x: 20, y: cellRect.origin.y + cell.frame.height), size: anchorView.frame.size)
        dropdown.frame = CGRect(origin: .init(x: 20, y: cellRect.origin.y + cell.frame.height), size: CGSize(width: 200, height: 20))
        dropdown.optionArray = source
        dropdown.didSelect { selectedText, index, id in
            completion(selectedText,index)
        }
        dropdown.showList()
    }
    
    func showAlertTextInputBox(header: String, data: String?, placeHolder: String, completion: @escaping (String) -> Void) {
        let alert = TextItemInputAlertController(header: header, data: data, placeHolder: placeHolder, saveClosure: completion)
        alert.modalPresentationStyle = .overCurrentContext
        self.present(alert, animated: true)
    }
    
    func reloadTableView() {
        tableView.reloadData()
    }
}
extension V2OptionSettingViewController {
    private func setLayout() {
        self.view.addSubview(tableView)
        self.view.addSubview(dropdown)
        
        tableView.snp.makeConstraints {
            $0.top.equalTo(self.view.safeAreaLayoutGuide)
            $0.leading.equalTo(self.view)
            $0.trailing.equalTo(self.view)
            $0.bottom.equalTo(self.view)
        }
        
    }
}
