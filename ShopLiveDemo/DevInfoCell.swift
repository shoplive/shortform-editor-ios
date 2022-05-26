//
//  DevInfoCell.swift
//  ShopLiveDemo
//
//  Created by ShopLive on 2021/12/16.
//

import UIKit

final class DevInfoCell: SampleBaseCell {

    var radioGroup: [ShopLiveRadioButton] = []

    lazy var loggerViewButton: ShopLiveCheckBoxButton = {
        let view = ShopLiveCheckBoxButton(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.configure(identifier: "appDebug", description: "앱 디버깅 로그 출력하기")
        view.delegate = self
        return view
    }()

    lazy var checkButton: ShopLiveCheckBoxButton = {
        let view = ShopLiveCheckBoxButton(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.configure(identifier: "webDebug", description: "웹 디버깅 로그 출력하기")
        view.delegate = self
        return view
    }()

    lazy var localLandingButton: ShopLiveCheckBoxButton = {
        let view = ShopLiveCheckBoxButton(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.configure(identifier: "localLanding", description: "로컬 랜딩 사용하기")
        view.delegate = self
        return view
    }()

    lazy var phaseView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false

        let devRadio: ShopLiveRadioButton = {
            let view = ShopLiveRadioButton()
            view.translatesAutoresizingMaskIntoConstraints = false
            view.configure(identifier: ShopLive.Phase.DEV.name, description: "DEV player")
            view.delegate = self
            return view
        }()

        let stageRadio: ShopLiveRadioButton = {
            let view = ShopLiveRadioButton()
            view.translatesAutoresizingMaskIntoConstraints = false
            view.configure(identifier: ShopLive.Phase.STAGE.name, description: "STAGE player")
            view.delegate = self
            return view
        }()

        let realRadio: ShopLiveRadioButton = {
            let view = ShopLiveRadioButton()
            view.translatesAutoresizingMaskIntoConstraints = false
            view.configure(identifier: ShopLive.Phase.REAL.name, description: "REAL player")
            view.delegate = self
            return view
        }()

        self.radioGroup = [devRadio, stageRadio, realRadio]
        view.addSubview(devRadio)
        view.addSubview(stageRadio)
        view.addSubview(realRadio)

        devRadio.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview()
            $0.bottom.lessThanOrEqualToSuperview()
            $0.height.equalTo(20)
        }

        stageRadio.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.bottom.lessThanOrEqualToSuperview()
            $0.leading.equalTo(devRadio.snp.trailing).offset(30)
            $0.height.equalTo(20)
        }

        realRadio.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.bottom.lessThanOrEqualToSuperview()
            $0.leading.equalTo(stageRadio.snp.trailing).offset(30)
            $0.trailing.lessThanOrEqualToSuperview()
            $0.height.equalTo(20)
        }

        return view
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
        ShopLiveDevConfiguration.shared.addConfigurationObserver(observer: self)
        updateWebDebugSetting()
        updateAppDebugSetting()
        updateLocalLandingSetting()
        updatePhase(identifier: ShopLiveDevConfiguration.shared.phase)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    override func setupViews() {
        super.setupViews()

        itemView.addSubview(loggerViewButton)
        itemView.addSubview(checkButton)
        itemView.addSubview(phaseView)
        
        loggerViewButton.snp.makeConstraints {
            $0.top.equalToSuperview().offset(10)
            $0.leading.equalToSuperview().offset(10)
            $0.trailing.equalToSuperview().offset(-10)
        }

        checkButton.snp.makeConstraints {
            $0.top.equalTo(loggerViewButton.snp.bottom).offset(10)
            $0.leading.equalToSuperview().offset(10)
            $0.trailing.equalToSuperview().offset(-10)
        }

        phaseView.backgroundColor = .clear
#if LOCAL_LANDING
        itemView.addSubviews(localLandingButton)
        localLandingButton.snp.makeConstraints {
            $0.top.equalTo(checkButton.snp.bottom).offset(10)
            $0.leading.equalToSuperview().offset(10)
            $0.trailing.equalToSuperview().offset(-10)
        }
        phaseView.snp.makeConstraints {
            $0.top.equalTo(localLandingButton.snp.bottom).offset(10)
            $0.leading.equalToSuperview().offset(10)
            $0.trailing.equalToSuperview().offset(-10)
            $0.bottom.equalToSuperview().offset(-10)
        }
#else
        phaseView.snp.makeConstraints {
            $0.top.equalTo(checkButton.snp.bottom).offset(10)
            $0.leading.equalToSuperview().offset(10)
            $0.trailing.equalToSuperview().offset(-10)
            $0.bottom.equalToSuperview().offset(-10)
        }
#endif

        

        self.setSectionTitle(title: "개발정보")
    }

}

extension DevInfoCell: ShopLiveCheckBoxButtonDelegate {
    func didChecked(_ sender: ShopLiveCheckBoxButton) {
        if sender.identifier == "webDebug" {
            ShopLiveDevConfiguration.shared.useWebLog = sender.isChecked
        } else if sender.identifier == "appDebug" {
            ShopLiveViewLogger.shared.setVisible(show: sender.isChecked)
        } else if sender.identifier == "localLanding" {
        #if LOCAL_LANDING
            ShopLive.setUsingLocalLanding(sender.isChecked)
            ShopLiveDevConfiguration.shared.useLocalLanding = sender.isChecked
        #endif
        }
        
    }

    func updateWebDebugSetting() {
        checkButton.isSelected = ShopLiveDevConfiguration.shared.useWebLog
    }

    func updateAppDebugSetting() {
        if ShopLiveDevConfiguration.shared.useAppLog {
            if !ShopLiveViewLogger.shared.isVisible() {
                ShopLiveViewLogger.shared.setVisible(show: true)
            }
        }

        loggerViewButton.isSelected = ShopLiveDevConfiguration.shared.useAppLog
    }
    
    func updateLocalLandingSetting() {
        #if LOCAL_LANDING
        localLandingButton.isSelected = ShopLiveDevConfiguration.shared.useLocalLanding
        #endif
    }
}

extension DevInfoCell: ShopLiveRadioButtonDelegate {
    func didSelectRadioButton(_ sender: ShopLiveRadioButton) {
        guard let phase = ShopLive.Phase(name: sender.identifier) else {
            return
        }

        ShopLiveDevConfiguration.shared.phase = phase.name
        updatePhase(identifier: sender.identifier)
    }

    func updatePhase(identifier: String) {
        radioGroup.forEach { radio in
            radio.updateRadio(selected: radio.identifier == identifier)
        }
    }
}


extension DevInfoCell: DevConfigurationObserver {
    var identifier: String {
        "DevInfoCell"
    }

    func updatedValues(keys: [String]) {
        updateWebDebugSetting()
        updateAppDebugSetting()
        updateLocalLandingSetting()
    }
}
