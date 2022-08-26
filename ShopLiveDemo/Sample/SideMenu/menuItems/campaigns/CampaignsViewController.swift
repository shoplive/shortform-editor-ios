//
//  CampaignsViewController.swift
//  ShopLiveDemo
//
//  Created by ShopLive on 2021/12/12.
//

import UIKit
import DropDown

final class CampaignsViewController: SideMenuItemViewController {

    var items: [ShopLiveKeySet] = []
    var selectKeySet: Bool = false

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
        items = ShopLiveDemoKeyTools.shared.keysets
        setupNaviItems()
        setupViews()
        self.title = SideMenuTypes.campaigns.stringKey.localized()

    }

    lazy var dropdown: DropDown = {
        let dropdown = DropDown()

        dropdown.width = 150
        return dropdown
    }()

    func setupViews() {
        self.view.addSubview(tableView)
        tableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

    func setupNaviItems() {
        let more = UIBarButtonItem(image: .init(named: "more_button"), style: .plain, target: self, action: #selector(moreMenus))

        more.tintColor = .white

        self.navigationItem.rightBarButtonItem = more

        let dropdownAnchor = UIView()
        dropdownAnchor.backgroundColor = .clear
        self.view.addSubview(dropdownAnchor)
        dropdownAnchor.snp.makeConstraints {
            $0.top.trailing.equalToSuperview()
            $0.width.height.equalTo(1)
        }

        dropdown.anchorView = dropdownAnchor
        dropdown.dataSource = SampleOptions.campaignNaviMoreOptions
        dropdown.selectionAction = SampleOptions.campaignNaviMoreSelectionAction
    }

    @objc func moreMenus() {
        dropdown.show()
    }

    func updateTableView() {
        self.items = ShopLiveDemoKeyTools.shared.keysets
        self.tableView.reloadData()
    }
}

extension CampaignsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CampaignCell", for: indexPath) as? CampaignCell, let item = items[safe: indexPath.row] else {
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
            if let item = items[safe: indexPath.row] {
                ShopLiveDemoKeyTools.shared.delete(alias: item.alias)
            }
            updateTableView()
            break
        default:
            break
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard selectKeySet else { return }

        guard let item = items[safe: indexPath.row] else { return }

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
    }
    
    func currentKeyUpdated() {
        updateTableView()
    }
}
