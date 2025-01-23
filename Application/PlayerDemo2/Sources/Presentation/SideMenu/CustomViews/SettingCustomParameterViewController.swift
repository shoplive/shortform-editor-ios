//
//  SettingCustomParameterViewController.swift
//  PlayerDemo2
//
//  Created by Tabber on 1/20/25.
//  Copyright © 2025 com.app. All rights reserved.
//


import UIKit

class SettingCustomParameterViewController: UIViewController {

    var tapGesture: UITapGestureRecognizer?
    
    private var paramArray: [CustomParam] = []
    
    private lazy var parameterTableView: UITableView = {
        let view = UITableView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.register(AddParameterCell.self, forCellReuseIdentifier: "AddParameterCell")
        view.backgroundColor = .white
        view.delegate = self
        view.rowHeight = 50
        view.allowsSelection = false
        view.dataSource = self
        view.separatorStyle = .singleLine
        view.isUserInteractionEnabled = true
        return view
    }()
    
    private func setupParameterList() {
        paramArray = DemoConfiguration.shared.customParameters
    }
    
    func setupBackButton() {
        let backButton = UIBarButtonItem(image: PlayerDemo2Asset.back.image, style: .plain, target: self, action: #selector(handleNaviBack)
        )
        backButton.tintColor = .white
        self.navigationItem.leftBarButtonItem = backButton

        self.navigationController?.navigationBar.topItem?.backBarButtonItem = nil
    }
    
    @objc func handleNaviBack() {
        self.saveParameterList()
        shopliveHideKeyboard_SL()
        self.navigationController?.popViewController(animated: true)
    }
    
    func setupNaviItems() {
        self.title = "sdk.page.addParam.title".localized()
        
        let addParam = UIBarButtonItem(title: "sdk.menu.add".localized(from: "shoplive"), style: .plain, target: self, action: #selector(addParameter))

        addParam.tintColor = .white

        self.navigationItem.rightBarButtonItems = [addParam]
    }
    
    private func setupEdgeGesture() {
        let edgePanGesture = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(handleEdgeGesture(_:)))
        edgePanGesture.edges = .left
        self.view.addGestureRecognizer(edgePanGesture)
    }
    
    @objc private func handleEdgeGesture(_ gesture: UIScreenEdgePanGestureRecognizer) {
        guard gesture.state == .recognized else {
            return
        }
        shopliveHideKeyboard_SL()
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc private func handleTapGesture(_ gesture: UITapGestureRecognizer) {
        guard gesture.state == .recognized else {
            return
        }
        shopliveHideKeyboard_SL()
    }

    private func setupTapGesture() {
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture(_:)))
        self.view.addGestureRecognizer(tapGesture!)
    }
    
    func removeTapGesture() {
        guard let gestureRecognizers = self.view.gestureRecognizers,
                gestureRecognizers.contains(where: {$0 == tapGesture}) else { return }

        self.view.removeGestureRecognizer(tapGesture!)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        setupParameterList()
        setupView()
        parameterTableView.reloadData()
        setupEdgeGesture()
        setupTapGesture()
        setupBackButton()
        setupNaviItems()
    }
    
    private func setupView() {
        self.view.addSubview(parameterTableView)
        parameterTableView.fit()
    }
    
    private func saveParameterList() {
        DemoConfiguration.shared.customParameters = self.paramArray
    }
    
}
extension UIView {
    func fit() {
        guard let superview = self.superview else { return }
        self.translatesAutoresizingMaskIntoConstraints = false
        superview.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[subview]-0-|", options: .directionLeadingToTrailing, metrics: nil, views: ["subview": self]))
        superview.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[subview]-0-|", options: .directionLeadingToTrailing, metrics: nil, views: ["subview": self]))
    }
}

extension SettingCustomParameterViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return paramArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "AddParameterCell", for: indexPath) as? AddParameterCell else { return UITableViewCell(style: .default, reuseIdentifier: "Cell") }
        if let param = paramArray[safe: indexPath.row] {
            cell.configure(key: param.paramKey, value: param.paramValue ?? "null", isUse: param.isUseParam)
        }
        cell.delegate = self
        cell.keyInputField.delegate = self
        cell.valueInputField.delegate = self
        cell.keyInputField.tag = indexPath.row
        cell.valueInputField.tag = indexPath.row
        return cell
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            self.paramArray.remove(at: indexPath.row)
            self.parameterTableView.deleteRows(at: [indexPath], with: .fade)
            saveParameterList()
        }
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    @objc func addParameter() {
        self.paramArray.append(CustomParam(paramKey: "", paramValue: "", isUseParam: false))
        self.parameterTableView.reloadData()
    }
}


extension SettingCustomParameterViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let text = textField.text else {
            return
        }
        
        switch(textField.accessibilityIdentifier) {
        case "keyInputField":
            self.paramArray[safe: textField.tag]?.paramKey = text
            break
        case "valueInputField":
            self.paramArray[safe: textField.tag]?.paramValue = text
            break
        case _:
            break
        }
        
        
        
    }
}

extension SettingCustomParameterViewController: AddParameterCellDelegate {
    func parameter(index: Int, key: String, value: String, isUse: Bool) {
        self.paramArray[safe: index]?.paramKey = key
        self.paramArray[safe: index]?.paramValue = value
        self.paramArray[safe: index]?.isUseParam = isUse
    }
}

