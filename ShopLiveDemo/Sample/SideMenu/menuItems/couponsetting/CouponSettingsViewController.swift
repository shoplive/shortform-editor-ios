//
//  CouponSettingsViewController.swift
//  ShopLiveDemo
//
//  Created by ShopLive on 2021/12/12.
//

import UIKit

final class CouponSettingsViewController: SideMenuItemViewController {

    var resultAlertType: ResultAlertType = .ALERT
    var resultStatus: ResultStatus = .SHOW
    var resultMessage: String = ""

    private lazy var successSettingView: CouponResponseSettingView = {
        let view = CouponResponseSettingView(isSuccess: true)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.radioDelegate = self
        return view
    }()

    private lazy var failedSettingView: CouponResponseSettingView = {
        let view = CouponResponseSettingView(isSuccess: false)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.radioDelegate = self
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = SideMenuTypes.coupon.stringKey.localized()
        setupNaviItems()
        setupViews()
    }

    func setupNaviItems() {
        self.title = SideMenuTypes.coupon.stringKey.localized()

        let save = UIBarButtonItem(title: "sdk.user.save".localized(from: "shoplive"), style: .plain, target: self, action: #selector(saveAct))

        save.tintColor = .white

        self.navigationItem.rightBarButtonItem = save
    }

    @objc func saveAct() {
        let successSetting = successSettingView.getSetting()
        let failedSetting = failedSettingView.getSetting()

        DemoConfiguration.shared.downloadCouponSuccessMessage = successSetting.message
        DemoConfiguration.shared.downloadCouponSuccessStatus = successSetting.resultStatus
        DemoConfiguration.shared.downloadCouponSuccessAlertType = successSetting.resultalertType

        DemoConfiguration.shared.downloadCouponFailedMessage = failedSetting.message
        DemoConfiguration.shared.downloadCouponFailedStatus = failedSetting.resultStatus
        DemoConfiguration.shared.downloadCouponFailedAlertType = failedSetting.resultalertType

        handleNaviBack()
    }

    func setupViews() {
        self.view.addSubview(successSettingView)
        self.view.addSubview(failedSettingView)
        successSettingView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
        }
        failedSettingView.snp.makeConstraints {
            $0.top.equalTo(successSettingView.snp.bottom).offset(15)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.lessThanOrEqualToSuperview()
        }
    }

}

extension CouponSettingsViewController: ShopLiveRadioButtonDelegate {
    func didSelectRadioButton(_ sender: ShopLiveRadioButton) {

        let identifier = sender.identifier
        let isSuccess = identifier.last == "s"

        let setting = isSuccess ? successSettingView : failedSettingView
        if setting.alertRadioGroup.contains(where:  {$0.identifier == identifier}) {
            setting.updateAlertSetting(identifier: identifier)
        } else {
            setting.updateShowSetting(identifier:  identifier)
        }
    }
}
