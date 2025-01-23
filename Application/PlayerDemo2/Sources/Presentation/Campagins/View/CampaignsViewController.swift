//
//  CampaignsViewController.swift
//  PlayerDemo2
//
//  Created by Tabber on 1/17/25.
//  Copyright © 2025 com.app. All rights reserved.
//

import UIKit
import iOSDropDown

class SampleOptions {
    static var campaignNaviMoreOptions: [String] = []
    static var campaignNaviMoreSelectionAction: ( (String,Int,Int) -> Void ) = { _,_,_ in }
}


final class CampaignsViewController: UIViewController {

    var viewModel: ViewModel = .init()
    
    var tapGesture: UITapGestureRecognizer?

    private lazy var tableView: UITableView = {
        let view = UITableView(frame: .zero, style: .plain)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.delegate = self
        view.dataSource = self
        view.register(CampaignCell.self, forCellReuseIdentifier: "CampaignCell")
        view.backgroundColor = .white
        view.contentInset = .init(top: 0, left: 0, bottom: ((UIApplication.shared.windows.first?.safeAreaInsets.bottom ?? 0) + 16), right: 0)
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        removeTapGesture()
        ShopLiveDemoKeyTools.shared.addKeysetObserver(observer: self)
        viewModel.items = ShopLiveDemoKeyTools.shared.keysets
        self.view.backgroundColor = .white
        setupViews()
        setupNaviItems()
        self.title = "menu.campaigns".localized()
        
        dropdown.listDidDisappear { [weak self] in
            self?.dropdown.isHidden = true
        }
        
        dropdown.listWillAppear { [weak self] in
            self?.dropdown.isHidden = false
        }
    }
    
    
    func removeTapGesture() {
        guard let gestureRecognizers = self.view.gestureRecognizers,
                gestureRecognizers.contains(where: {$0 == tapGesture}) else { return }

        self.view.removeGestureRecognizer(tapGesture!)
    }

    lazy var dropdown: DropDown = {
        let dropdown = DropDown()
//        dropdown.width = 150
        dropdown.translatesAutoresizingMaskIntoConstraints = false
        return dropdown
    }()

    func setupViews() {
        self.view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: self.view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])
        
    }

    func setupBackButton() {
        let backButton = UIBarButtonItem(image: PlayerDemo2Asset.back.image, style: .plain, target: self, action: #selector(handleNaviBack)
        )
        backButton.tintColor = .white
        self.navigationItem.leftBarButtonItem = backButton

        self.navigationController?.navigationBar.topItem?.backBarButtonItem = nil
    }
    
    @objc func handleNaviBack() {
        shopliveHideKeyboard_SL()
        self.navigationController?.popViewController(animated: true)
    }

    
    func setupNaviItems() {
        
        
        setupBackButton()
        let more = UIBarButtonItem(image: .init(named: "more_button"), style: .plain, target: self, action: #selector(moreMenus))

        more.tintColor = .white

        self.navigationItem.rightBarButtonItem = more

        let dropdownAnchor = UIView()
        dropdownAnchor.translatesAutoresizingMaskIntoConstraints = false
        dropdownAnchor.backgroundColor = .clear
        self.view.addSubview(dropdownAnchor)
        self.view.addSubview(dropdown)
        dropdown.isHidden = true
        
        
        NSLayoutConstraint.activate([
            dropdownAnchor.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            dropdownAnchor.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            dropdownAnchor.widthAnchor.constraint(equalToConstant: 1),
            dropdownAnchor.heightAnchor.constraint(equalToConstant: 1),
            
            dropdown.topAnchor.constraint(equalTo: dropdownAnchor.topAnchor,constant: -20),
            dropdown.trailingAnchor.constraint(equalTo: dropdownAnchor.trailingAnchor),
            dropdown.widthAnchor.constraint(equalToConstant: 150),
            dropdown.heightAnchor.constraint(equalToConstant: 20),
        ])
        dropdown.optionArray = SampleOptions.campaignNaviMoreOptions
        
        dropdown.didSelect(completion: SampleOptions.campaignNaviMoreSelectionAction)
    }

    @objc func moreMenus() {
        dropdown.showList()
    }

    func updateTableView() {
        self.viewModel.items = ShopLiveDemoKeyTools.shared.keysets
        self.tableView.reloadData()
    }
}

extension CampaignsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CampaignCell", for: indexPath) as? CampaignCell, let item = viewModel.items[safe: indexPath.row] else {
            return UITableViewCell()
        }

        cell.configure(keySet: item)
        return cell
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        switch editingStyle {
        case .delete:
            if let item = viewModel.items[safe: indexPath.row] {
                ShopLiveDemoKeyTools.shared.delete(alias: item.alias)
            }
            updateTableView()
            break
        default:
            break
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard viewModel.selectKeySet else { return }

        guard let item = viewModel.items[safe: indexPath.row] else { return }

        ShopLiveDemoKeyTools.shared.saveCurrentKey(alias: item.alias)
        self.navigationController?.popViewController(animated: true)
    }
}

extension CampaignsViewController: KeySetObserver {
    var identifier: String {
        get {
            return "CampaignsViewController"
        }
    }

    func keysetUpdated() {
        updateTableView()
        guard viewModel.items.count > 0 else { return }
        self.navigationController?.popViewController(animated: true)
    }
    
    func currentKeyUpdated() {
        updateTableView()
    }
}
