//
//  SideMenuViewController.swift
//  ShopLiveDemo
//
//  Created by ShopLive on 2021/12/12.
//

import UIKit
#if SDK_MODULE
import ShopLiveSDK
#endif

struct SideMenu {
    var identifier: String
    var stringKey: String
}

enum SideMenuTypes: String, CaseIterable {
    case campaigns
    case userinfo
    case options
    case exit
    case coupon
    case removeCache
//    case removeCache

    var identifier: String {
        return self.rawValue
    }

    var stringKey: String {
        return "menu.\(identifier)"
    }

    var sideMenu: SideMenu {
        return SideMenu(identifier: identifier, stringKey: stringKey)
    }
}

final class ShopLiveSideMenu {
    static var sideMenus: [SideMenu] = [
        SideMenuTypes.campaigns.sideMenu,
        SideMenuTypes.userinfo.sideMenu,
        SideMenuTypes.options.sideMenu,
        SideMenuTypes.coupon.sideMenu,
        SideMenuTypes.exit.sideMenu,
        SideMenuTypes.removeCache.sideMenu
    ]
}

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
        case SideMenuTypes.campaigns.identifier:
            let page = CampaignsViewController()
            self.navigationController?.pushViewController(page, animated: true)
            break
        case SideMenuTypes.userinfo.identifier:
            let page = UserInfoViewController()
            self.navigationController?.pushViewController(page, animated: true)
            break
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
