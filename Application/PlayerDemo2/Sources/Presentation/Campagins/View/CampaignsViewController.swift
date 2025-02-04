//
//  CampaignsViewController.swift
//  PlayerDemo2
//
//  Created by Tabber on 1/17/25.
//  Copyright © 2025 com.app. All rights reserved.
//

import UIKit
import ShopliveSDKCommon
import iOSDropDown
import SnapKit

final class CampaignsViewController: UIViewController {
    
    var tapGesture: UITapGestureRecognizer?

    private lazy var tableView: UITableView = {
        let view = UITableView(frame: .zero, style: .plain)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        view.contentInset = .init(top: 0, left: 0, bottom: ((UIApplication.shared.windows.first?.safeAreaInsets.bottom ?? 0) + 16), right: 0)
        return view
    }()
    
    lazy var dropdown: DropDown = {
        let dropdown = DropDown()
        dropdown.translatesAutoresizingMaskIntoConstraints = false
        return dropdown
    }()
    
    var viewModel: CampaignsViewModel
    
    init(viewModel: CampaignsViewModel) {
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
        removeTapGesture()
        self.view.backgroundColor = .white
        setupViews()
        configureSampleOptions()
        setupNaviItems()
        self.title = "menu.campaigns".localized()
        
        dropdown.listDidDisappear { [weak self] in
            self?.dropdown.isHidden = true
        }
        
        dropdown.listWillAppear { [weak self] in
            self?.dropdown.isHidden = false
        }
        
    }
    
    func setupViews() {
        self.view.addSubview(tableView)
        tableView.snp.makeConstraints {
            $0.top.leading.trailing.bottom.equalTo(self.view)
        }
    }
    
    func removeTapGesture() {
        guard let gestureRecognizers = self.view.gestureRecognizers,
                gestureRecognizers.contains(where: {$0 == tapGesture}) else { return }
        self.view.removeGestureRecognizer(tapGesture!)
    }

    func setupBackButton() {
        let backButton = UIBarButtonItem(image: PlayerDemo2Asset.back.image, style: .plain, target: self, action: #selector(handleNaviBack))
        backButton.tintColor = .white
        self.navigationItem.leftBarButtonItem = backButton

        self.navigationController?.navigationBar.topItem?.backBarButtonItem = nil
    }
    
    @objc func handleNaviBack() {
        shopliveHideKeyboard_SL()
        viewModel.dismiss()
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
    
    func configureSampleOptions() {
        
        SampleOptions.campaignNaviMoreSelectionAction = { (item : String, index: Int, id: Int) in
            let sourceScheme = "shopliveplayer"
            switch index {
            case 0: // Direct input
                let vc = CampaignInputAlertController()
                vc.delegate = self
                vc.modalPresentationStyle = .overCurrentContext
                self.navigationController?.present(vc, animated: false, completion: nil)
                break
            case 1: // QR-code
                let qrReaderVC = SLQRReaderViewController()
                qrReaderVC.delegate = self
                self.present(qrReaderVC, animated: true)
                break
            case 2: // Dev-Admin
                // getkey
                DeepLinkManager.shared.sendDeepLink("shoplivestudiodev://getkey?source=\(sourceScheme)")
                break
            case 3: // Admin
                // getkey
                DeepLinkManager.shared.sendDeepLink("shoplivestudio://getkey?source=\(sourceScheme)")
                break
            case 4: // Remove all
                guard self.viewModel.getKeyCount() > 0 else {
                    return
                }
                let alert = UIAlertController(title: "campaign.msg.deleteAll.title".localized(), message: nil, preferredStyle: .alert)
                alert.addAction(.init(title: "alert.msg.no".localized(), style: .cancel, handler: { action in
                    
                }))
                alert.addAction(.init(title: "alert.msg.ok".localized(), style: .default, handler: { action in
                    self.viewModel.removeAll()
                }))
                
                self.present(alert, animated: true, completion: nil)
                break
            default:
                break
            }
        }
    }
}

extension CampaignsViewController: CampaignsViewModelDelegate {
    func reloadTableView(dismiss: Bool) {
        tableView.reloadData()
        if dismiss {
            viewModel.dismiss()
        }
    }
}

extension CampaignsViewController: CampaignInputAlertDelegate {
    func saveData(data: ShopLiveKeySet) {
        viewModel.appendItems(keySet: data)
    }
}

extension CampaignsViewController: QRKeyReaderDelegate {
    func updateUserJWTFromQR(userJWT: String?) {}
    
    func updateKeyFromQR(keyset: ShopLiveKeySet?) {
        guard let keyset = keyset else { return }
        let vc = CampaignInputAlertController(keyset: keyset)
        vc.delegate = self
        vc.modalPresentationStyle = .overCurrentContext
        self.navigationController?.present(vc, animated: false, completion: nil)
    }
}
