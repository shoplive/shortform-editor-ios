//
//  DevInfoCell.swift
//  PlayerDemo2
//
//  Created by Tabber on 1/17/25.
//  Copyright © 2025 com.app. All rights reserved.
//

import UIKit
import ShopliveSDKCommon

final class DevInfoCell: SampleBaseCell {

    var radioGroup: [ShopLiveRadioButton] = []

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
        
        
        NSLayoutConstraint.activate([
            devRadio.topAnchor.constraint(equalTo: view.topAnchor,constant: 20),
            devRadio.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            devRadio.bottomAnchor.constraint(lessThanOrEqualTo: view.bottomAnchor),
            devRadio.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor),
            devRadio.heightAnchor.constraint(equalToConstant: 20),
            
            qaRadio.topAnchor.constraint(equalTo: devRadio.bottomAnchor, constant: 10),
            qaRadio.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            qaRadio.bottomAnchor.constraint(lessThanOrEqualTo: view.bottomAnchor),
            qaRadio.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor),
            qaRadio.heightAnchor.constraint(equalToConstant: 20),
            
            stageRadio.topAnchor.constraint(equalTo: qaRadio.bottomAnchor, constant: 10),
            stageRadio.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            stageRadio.bottomAnchor.constraint(lessThanOrEqualTo: view.bottomAnchor),
            stageRadio.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor),
            stageRadio.heightAnchor.constraint(equalToConstant: 20),
            
            realRadio.topAnchor.constraint(equalTo: stageRadio.bottomAnchor, constant: 10),
            realRadio.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            realRadio.bottomAnchor.constraint(lessThanOrEqualTo: view.bottomAnchor),
            realRadio.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor),
            realRadio.heightAnchor.constraint(equalToConstant: 20),
        
            setRadio.topAnchor.constraint(equalTo: realRadio.bottomAnchor, constant: 10),
            setRadio.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            setRadio.bottomAnchor.constraint(lessThanOrEqualTo: view.bottomAnchor),
            setRadio.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor),
            setRadio.heightAnchor.constraint(equalToConstant: 20),
            
            landingField.topAnchor.constraint(equalTo: setRadio.bottomAnchor, constant: 10),
            landingField.bottomAnchor.constraint(lessThanOrEqualTo: view.bottomAnchor),
            landingField.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            landingField.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            landingField.heightAnchor.constraint(equalToConstant: 30)
        ])

//        devRadio.snp.makeConstraints {
//            $0.top.equalToSuperview().offset(20)
//            $0.leading.equalToSuperview()
//            $0.bottom.lessThanOrEqualToSuperview()
//            $0.trailing.lessThanOrEqualToSuperview()
//            $0.height.equalTo(20)
//        }
//
//        qaRadio.snp.makeConstraints {
//            $0.top.equalTo(devRadio.snp.bottom).offset(10)
//            $0.bottom.lessThanOrEqualToSuperview()
//            $0.leading.equalToSuperview()
//            $0.trailing.lessThanOrEqualToSuperview()
//            $0.height.equalTo(20)
//        }
//
//        stageRadio.snp.makeConstraints {
//            $0.top.equalTo(qaRadio.snp.bottom).offset(10)
//            $0.bottom.lessThanOrEqualToSuperview()
//            $0.leading.equalToSuperview()
//            $0.trailing.lessThanOrEqualToSuperview()
//            $0.height.equalTo(20)
//        }
//
//        realRadio.snp.makeConstraints {
//            $0.top.equalTo(stageRadio.snp.bottom).offset(10)
//            $0.bottom.lessThanOrEqualToSuperview()
//            $0.leading.equalToSuperview()
//            $0.trailing.lessThanOrEqualToSuperview()
//            $0.height.equalTo(20)
//        }
//
//        setRadio.snp.makeConstraints {
//            $0.top.equalTo(realRadio.snp.bottom).offset(10)
//            $0.bottom.lessThanOrEqualToSuperview()
//            $0.leading.equalToSuperview()
//            $0.trailing.lessThanOrEqualToSuperview()
//            $0.height.equalTo(20)
//        }
//
//        landingField.snp.makeConstraints {
//            $0.top.equalTo(setRadio.snp.bottom).offset(10)
//            $0.bottom.lessThanOrEqualToSuperview()
//            $0.leading.equalToSuperview()
//            $0.trailing.equalToSuperview()
//            $0.height.equalTo(30)
//        }
        
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
        let demoConfig = DemoConfiguration.shared
        ShopLiveDevConfiguration.shared.addConfigurationObserver(observer: self)
        updateWebDebugSetting()
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

        itemView.addSubview(checkButton)
        itemView.addSubview(lockPortrait)
        itemView.addSubview(phaseView)
        
        phaseView.backgroundColor = .clear
        
        NSLayoutConstraint.activate([
            
            checkButton.topAnchor.constraint(equalTo: itemView.topAnchor, constant: 10),
            checkButton.leadingAnchor.constraint(equalTo: itemView.leadingAnchor, constant: 10),
            checkButton.trailingAnchor.constraint(equalTo: itemView.trailingAnchor, constant: -10),
            
            lockPortrait.topAnchor.constraint(equalTo: checkButton.bottomAnchor, constant: 10),
            lockPortrait.leadingAnchor.constraint(equalTo: itemView.leadingAnchor,constant: 10),
            lockPortrait.trailingAnchor.constraint(equalTo: itemView.trailingAnchor, constant: 10),
            
            phaseView.topAnchor.constraint(equalTo: lockPortrait.bottomAnchor, constant: 10),
            phaseView.leadingAnchor.constraint(equalTo: itemView.leadingAnchor,constant: 10),
            phaseView.trailingAnchor.constraint(equalTo: itemView.trailingAnchor, constant: -10),
            phaseView.bottomAnchor.constraint(equalTo: itemView.bottomAnchor,constant: -10)
        ])
        
        self.setSectionTitle(title: "개발정보")
    }

}

extension DevInfoCell: ShopLiveCheckBoxButtonDelegate {
    func didChecked(_ sender: ShopLiveCheckBoxButton) {
        if sender.identifier == "webDebug" {
            ShopLiveDevConfiguration.shared.useWebLog = sender.isChecked
        } else if sender.identifier == "appDebug" {
        } else if sender.identifier == "useLockPortrait" {
            ShopLiveDevConfiguration.shared.useLockPortrait = sender.isChecked
        }
        
    }

    func updateWebDebugSetting() {
        checkButton.isSelected = ShopLiveDevConfiguration.shared.useWebLog
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

