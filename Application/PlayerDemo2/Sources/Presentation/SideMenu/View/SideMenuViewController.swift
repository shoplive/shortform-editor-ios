//
//  SideMenuViewController.swift
//  PlayerDemo2
//
//  Created by Tabber on 1/23/25.
//  Copyright © 2025 com.app. All rights reserved.
//


import UIKit
import ShopLiveSDK

final class SideMenuViewController: UIViewController {

    @IBOutlet weak var menuTableView: UITableView!
    @IBOutlet weak var demoVersionLabel: UILabel!
    @IBOutlet weak var sdkVersionLabel: UILabel!

    let items: [SideMenu] = ShopLiveSideMenu.sideMenus

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white

        let buildVersion: String? = Bundle.main.object(forInfoDictionaryKey: kCFBundleVersionKey as String) as? String
        let bundleVersion: String? = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
        
        var appVersion: String = ""
        if let version = bundleVersion {
            appVersion = version + (buildVersion != nil ? " (\(buildVersion ?? "x"))" : "")
        }
        demoVersionLabel.text = appVersion
        sdkVersionLabel.text = ShopLive.sdkVersion
        
        setupTableView()
    }

    func setupTableView() {
        self.menuTableView.backgroundColor = .white
        menuTableView.delegate = self
        menuTableView.dataSource = self
        menuTableView.separatorStyle = .none
        menuTableView.alwaysBounceVertical = false
        menuTableView.contentInset = .init(top: 15, left: 0, bottom: 0, right: 0)
        menuTableView.register(SideMenuCell.self, forCellReuseIdentifier: "SideMenuCell")
    }
}

extension SideMenuViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SideMenuCell", for: indexPath) as? SideMenuCell else {
            return UITableViewCell()
        }

        cell.configure(item: items[indexPath.row])

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        switch items[indexPath.row].identifier {
        case SideMenuTypes.options.identifier:
            let page = OptionsViewController()
            self.navigationController?.pushViewController(page, animated: true)
            break
        case SideMenuTypes.coupon.identifier:
            let page = CouponSettingsViewController()
            self.navigationController?.pushViewController(page, animated: true)
            break
        case SideMenuTypes.exit.identifier:
            ShopLive.close()
            break
        case SideMenuTypes.removeCache.identifier:
            UserDefaults.standard.removeObject(forKey: "shoplivedata")
            UserDefaults.standard.synchronize()
            UIWindow.showToast(message: "menu.msg.removeCache".localized())
            break
        default:
            break
        }
    }
}

