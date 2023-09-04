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
    
    lazy var lockPortrait: ShopLiveCheckBoxButton = {
        let view = ShopLiveCheckBoxButton(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.configure(identifier: "useLockPortrait", description: "세로방향 고정하기")
        view.delegate = self
        return view
    }()

    lazy var landingField: UITextField = {
        let view = UITextField()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.textColor = .black
        view.placeholder = "landing url"
        view.text = DemoConfiguration.shared.customLandingUrl ?? ""
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.lightGray.cgColor
        view.layer.cornerRadius = 6
        view.textColor = .black
        view.setPlaceholderColor(.darkGray)
        view.leftViewMode = .always
        let paddingView = UIView(frame: .init(origin: .zero, size: .init(width: 10, height: view.frame.height)))
        view.leftView = paddingView
        view.delegate = self
        return view
    }()
    
    lazy var phaseView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false

        let devRadio: ShopLiveRadioButton = {
            let view = ShopLiveRadioButton()
            view.translatesAutoresizingMaskIntoConstraints = false
            view.configure(identifier: "DEV", description: "DEV player")
            view.delegate = self
            return view
        }()

        let qaRadio : ShopLiveRadioButton = {
            let view = ShopLiveRadioButton()
            view.translatesAutoresizingMaskIntoConstraints = false
            view.configure(identifier: "QA", description: "QA player")
            view.delegate = self
            return view
        }()
        
        let stageRadio: ShopLiveRadioButton = {
            let view = ShopLiveRadioButton()
            view.translatesAutoresizingMaskIntoConstraints = false
            view.configure(identifier: "STAGE", description: "STAGE player")
            view.delegate = self
            return view
        }()

        let realRadio: ShopLiveRadioButton = {
            let view = ShopLiveRadioButton()
            view.translatesAutoresizingMaskIntoConstraints = false
            view.configure(identifier: "REAL", description: "REAL player")
            view.delegate = self
            return view
        }()
        
        let setRadio: ShopLiveRadioButton = {
            let view = ShopLiveRadioButton()
            view.translatesAutoresizingMaskIntoConstraints = false
            view.configure(identifier: "CUSTOM", description: "랜딩 Url 직접 입력")
            view.delegate = self
            return view
        }()
        
        self.radioGroup = [devRadio,qaRadio, stageRadio, realRadio, setRadio]
        view.addSubview(devRadio)
        view.addSubview(qaRadio)
        view.addSubview(stageRadio)
        view.addSubview(realRadio)
        view.addSubview(setRadio)
        view.addSubview(landingField)

        devRadio.snp.makeConstraints {
            $0.top.equalToSuperview().offset(20)
            $0.leading.equalToSuperview()
            $0.bottom.lessThanOrEqualToSuperview()
            $0.trailing.lessThanOrEqualToSuperview()
            $0.height.equalTo(20)
        }
        
        qaRadio.snp.makeConstraints {
            $0.top.equalTo(devRadio.snp.bottom).offset(10)
            $0.bottom.lessThanOrEqualToSuperview()
            $0.leading.equalToSuperview()
            $0.trailing.lessThanOrEqualToSuperview()
            $0.height.equalTo(20)
        }

        stageRadio.snp.makeConstraints {
            $0.top.equalTo(qaRadio.snp.bottom).offset(10)
            $0.bottom.lessThanOrEqualToSuperview()
            $0.leading.equalToSuperview()
            $0.trailing.lessThanOrEqualToSuperview()
            $0.height.equalTo(20)
        }

        realRadio.snp.makeConstraints {
            $0.top.equalTo(stageRadio.snp.bottom).offset(10)
            $0.bottom.lessThanOrEqualToSuperview()
            $0.leading.equalToSuperview()
            $0.trailing.lessThanOrEqualToSuperview()
            $0.height.equalTo(20)
        }
        
        setRadio.snp.makeConstraints {
            $0.top.equalTo(realRadio.snp.bottom).offset(10)
            $0.bottom.lessThanOrEqualToSuperview()
            $0.leading.equalToSuperview()
            $0.trailing.lessThanOrEqualToSuperview()
            $0.height.equalTo(20)
        }

        landingField.snp.makeConstraints {
            $0.top.equalTo(setRadio.snp.bottom).offset(10)
            $0.bottom.lessThanOrEqualToSuperview()
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.height.equalTo(30)
        }
        
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
        let demoConfig = DemoConfiguration.shared
        ShopLiveDevConfiguration.shared.addConfigurationObserver(observer: self)
        updateWebDebugSetting()
        updateAppDebugSetting()
        demoConfig.customLandingInput = demoConfig.customLandingUrl
        landingField.text = demoConfig.customLandingInput
        updatePhase(identifier: ShopLiveDevConfiguration.shared.phase)
        updateLockPortrait()
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
        itemView.addSubview(lockPortrait)
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
        
        lockPortrait.snp.makeConstraints {
            $0.top.equalTo(checkButton.snp.bottom).offset(10)
            $0.leading.equalToSuperview().offset(10)
            $0.trailing.equalToSuperview().offset(-10)
        }

        phaseView.backgroundColor = .clear
        phaseView.snp.makeConstraints {
            $0.top.equalTo(lockPortrait.snp.bottom).offset(10)
            $0.leading.equalToSuperview().offset(10)
            $0.trailing.equalToSuperview().offset(-10)
            $0.bottom.equalToSuperview().offset(-10)
        }

        self.setSectionTitle(title: "개발정보")
    }

}

extension DevInfoCell: ShopLiveCheckBoxButtonDelegate {
    func didChecked(_ sender: ShopLiveCheckBoxButton) {
        if sender.identifier == "webDebug" {
            ShopLiveDevConfiguration.shared.useWebLog = sender.isChecked
        } else if sender.identifier == "appDebug" {
            ShopLiveViewLogger.shared.setVisible(show: sender.isChecked)
        } else if sender.identifier == "useLockPortrait" {
            ShopLiveDevConfiguration.shared.useLockPortrait = sender.isChecked
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
    
    func updateLockPortrait() {
        if ShopLiveDevConfiguration.shared.useLockPortrait {
            DemoAppUtility.lockOrientation(.portrait)
        } else {
            DemoAppUtility.lockOrientation(.all)
        }

        lockPortrait.isSelected = ShopLiveDevConfiguration.shared.useLockPortrait
    }
}

extension DevInfoCell: ShopLiveRadioButtonDelegate {
    func didSelectRadioButton(_ sender: ShopLiveRadioButton) {
//        guard let phase = ShopLive.Phase(name: sender.identifier) else {
//            return
//        }

        ShopLiveDevConfiguration.shared.phase = sender.identifier
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
        updateLockPortrait()
    }
}

extension DevInfoCell: UITextFieldDelegate {
    
    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {

        /// newText: 새로 입력된 텍스트
        let newText = string.trimmingCharacters(in: .whitespacesAndNewlines)

        /// text: 기존에 입력되었던 text
        /// predictRange: 입력으로 예상되는 text의 range값 추측 > range값을 알면 기존 문자열에 새로운 문자를 위치에 알맞게 추가 가능
        guard let text = textField.text, let predictRange = Range(range, in: text) else { return true }

        /// predictedText: 기존에 입력되었던 text에 새로 입력된 newText를 붙여서, 현재까지 입력된 전체 텍스트
        let predictedText = text.replacingCharacters(in: predictRange, with: newText)
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        ShopLiveLogger.debugLog("update customLandingInput \(predictedText)")
        DemoConfiguration.shared.customLandingInput = predictedText
//
//        if predictedText.isEmpty {
//            rightViewMode = .never
//        } else {
//            rightViewMode = .whileEditing
//        }

        return true
    }
    
}
