//
//  SideMenuBaseViewController.swift
//  ShopLiveDemo
//
//  Created by ShopLive on 2021/12/12.
//

import UIKit

class SideMenuBaseViewController: UIViewController {

    var keyset: ShopLiveKeySet?
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
            action: #selector(UIViewController.shopliveHideKeyboard_SL))

        view.addGestureRecognizer(tap)
        NotificationCenter.default.addObserver(self, selector: #selector(handleNotification(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleNotification(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        ShopLiveDemoKeyTools.shared.addKeysetObserver(observer: self)
        setupBaseUI()
        setupNavigation()
        setupSDKButtons()
        setupSideMenu()
        DemoConfiguration.shared.addConfigurationObserver(observer: self)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func handleNotification(_ notification: Notification) {
        switch notification.name {
        case UIResponder.keyboardWillShowNotification:
            self.setKeyboard(notification: notification)
            break
        case UIResponder.keyboardWillHideNotification:
            self.setKeyboard(notification: notification)
            break
        default:
            break
        }
    }
    
    private func setKeyboard(notification: Notification) {
        guard let keyboardFrameEndUserInfo = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        let keyboardScreenEndFrame = keyboardFrameEndUserInfo.cgRectValue
        
        switch notification.name.rawValue {
        case "UIKeyboardWillHideNotification":
            tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            break
        case "UIKeyboardWillShowNotification":
            tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardScreenEndFrame.height, right: 0)
            break
        default:
            break
        }
        scrollToBottom()
    }
    
    func scrollToBottom(){
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            let indexPath = IndexPath(row: self.items.count-1, section: 0)
            self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
        }
    }
}

extension SideMenuBaseViewController: UITableViewDelegate, UITableViewDataSource {
    func setupBaseUI() {
        self.view.backgroundColor = .white

        self.view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: self.view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])
//        tableView.snp.makeConstraints {
//            $0.edges.equalToSuperview()
//        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let item = items[safe: indexPath.row], let cell = tableView.dequeueReusableCell(withIdentifier: item, for: indexPath) as? SampleBaseCell else {
            return UITableViewCell()
        }
        cell.configure(parent: self)
        cell.baseDelegate = self
        
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

extension SideMenuBaseViewController: CampaignInfoCellDelegate {
    func getCurrentKeySet() -> ShopLiveKeySet? {
        if let keyset = keyset, !keyset.hasEmptyValue() {
            if let currentKeySet = ShopLiveDemoKeyTools.shared.currentKey() {
                if currentKeySet.isEqual(keyset) {
                    return currentKeySet
                } else {
                    ShopLiveDemoKeyTools.shared.save(key: keyset)
                    ShopLiveDemoKeyTools.shared.saveCurrentKey(alias: keyset.alias)
                    return keyset
                }
            } else {
                return keyset
            }
        } else {
            if let currentKeySet = ShopLiveDemoKeyTools.shared.currentKey() {
                return currentKeySet
            } else {
                return nil
            }
        }
    }
    
    func updateKeySet(_ keyset: ShopLiveKeySet) {
        self.keyset = keyset
    }
    
    func keysetFieldSelected() {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: self.view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])
//        self.tableView.snp.remakeConstraints {
//            $0.left.right.top.equalToSuperview()
//            $0.bottom.equalToSuperview().offset(-200)
//        }
    }
}

extension SideMenuBaseViewController: SampleBaseCellDelegate {
    func updateDatas() {
        self.tableView.reloadData()
    }
}
