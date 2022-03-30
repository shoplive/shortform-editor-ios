//
//  SideMenuBaseViewController.swift
//  ShopLiveDemo
//
//  Created by ShopLive on 2021/12/12.
//

import UIKit

class SideMenuBaseViewController: UIViewController {

    var items: [String] = ["CampaignInfoCell", "UserInfoCell"]

    lazy var tableView: UITableView = {
        let view = UITableView(frame: .zero, style: .plain)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.delegate = self
        view.dataSource = self
        view.separatorStyle = .none
        view.backgroundColor = .white
        view.register(CampaignInfoCell.self, forCellReuseIdentifier: "CampaignInfoCell")
        view.register(UserInfoCell.self, forCellReuseIdentifier: "UserInfoCell")
        view.alwaysBounceVertical = false
        view.rowHeight = UITableView.automaticDimension

        view.contentInset = .init(top: 0, left: 0, bottom: ((UIApplication.shared.windows.first?.safeAreaInsets.bottom ?? 0) + 16), right: 0)
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        let tap: UITapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(UIViewController.shopliveHideKeyboard))

        view.addGestureRecognizer(tap)
        ShopLiveDemoKeyTools.shared.addKeysetObserver(observer: self)
        setupBaseUI()
        setupNavigation()
        setupSDKButtons()
        setupSideMenu()
        DemoConfiguration.shared.addConfigurationObserver(observer: self)
    }
}

extension SideMenuBaseViewController: UITableViewDelegate, UITableViewDataSource {
    func setupBaseUI() {
        self.view.backgroundColor = .white

        self.view.addSubview(tableView)
        tableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let item = items[safe: indexPath.row], let cell = tableView.dequeueReusableCell(withIdentifier: item, for: indexPath) as? SampleBaseCell else {
            return UITableViewCell()
        }
        cell.configure(parent: self)
        return cell
    }
}

extension SideMenuBaseViewController {
    @objc func setupNavigation() {
        // navigation background color
        let naviBgColor = UIColor(red: 238/255, green: 52/255, blue: 52/255, alpha: 1)
        if #available(iOS 13.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = naviBgColor
            self.navigationController?.navigationBar.standardAppearance = appearance;
            self.navigationController?.navigationBar.scrollEdgeAppearance = self.navigationController?.navigationBar.standardAppearance
        } else {
            self.navigationController?.isNavigationBarHidden = false
            self.navigationController?.navigationBar.tintColor = naviBgColor
        }
    }

    @objc private func handleEdgeGesture(_ gesture: UIScreenEdgePanGestureRecognizer) {
        guard gesture.state == .recognized else {
            return
        }
        openSideMenuAct()
    }

    @objc private func openSideMenu(_ sender: UIButton) {
        sender.debounce()
        openSideMenuAct()
    }

    private func openSideMenuAct() {
        let menu: ShopliveSideMenuNavagation = UIStoryboard(name: "Sample", bundle: nil).instantiateViewController(withIdentifier: "ShopliveSideMenuNavagation") as! ShopliveSideMenuNavagation

        present(menu, animated: true, completion: nil)
    }

    private func setupSideMenu() {
        setupSideMenuButton()
        setupSideMenuEdgeGesture()
    }

    private func setupSideMenuEdgeGesture() {
        let edgePanGesture = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(handleEdgeGesture(_:)))
        edgePanGesture.edges = .left
        self.view.addGestureRecognizer(edgePanGesture)
    }

    private func setupSideMenuButton() {
        let menuButton = UIButton.init(frame: CGRect.init(x: 0, y: 0, width: 30, height: 30))

        let spacing: CGFloat = 8.0
        menuButton.contentEdgeInsets = UIEdgeInsets(top: spacing, left: spacing, bottom: spacing, right: spacing)
        menuButton.setImage(UIImage.init(named:"ic_hamburger"), for: .normal)
        menuButton.addTarget(self, action: #selector(openSideMenu(_:)), for: .touchUpInside)
        menuButton.debounce()
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(customView: menuButton)
        let desiredWidth = 35.0
        let desiredHeight = 35.0

        let widthConstraint = NSLayoutConstraint(item: menuButton, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: desiredWidth)
        let heightConstraint = NSLayoutConstraint(item: menuButton, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: desiredHeight)

        menuButton.addConstraints([widthConstraint, heightConstraint])
    }
}

/// SDK Action Buttons
extension SideMenuBaseViewController {
    func setupSDKButtons() {
        let preview = UIBarButtonItem(title: "sdk.preview".localized(from: "shoplive"), style: .plain, target: self, action: #selector(preview))

        let play = UIBarButtonItem(title: "sdk.play".localized(from: "shoplive"), style: .plain, target: self, action: #selector(play))

        preview.tintColor = .white
        play.tintColor = .white

        self.navigationItem.rightBarButtonItems = [play, preview]
    }

    @objc func preview() {
        print("preview")
    }

    @objc func play() {
        print("play")
    }
}

extension SideMenuBaseViewController: DemoConfigurationObserver, KeySetObserver {
    func keysetUpdated() {
        tableView.reloadData()
    }

    func currentKeyUpdated() {
        tableView.reloadData()
    }

    var identifier: String {
        "SideMenuBaseViewController"
    }

    func updatedValues(keys: [String]) {
        if keys.contains(where: {$0 == "user"}) || keys.contains(where: {$0 == "jwtToken"}) {
            tableView.reloadData()
        }
    }


}
