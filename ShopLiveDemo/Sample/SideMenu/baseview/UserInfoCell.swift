//
//  UserInfoCell.swift
//  ShopLiveDemo
//
//  Created by ShopLive on 2021/12/14.
//

import UIKit
#if SDK_MODULE
import ShopLiveSDK
#endif

final class UserInfoCell: SampleBaseCell {

    private var user = DemoConfiguration.shared.user

    private var userButtonTitle: String {

        guard !isNonUser(user) else {
            return "base.section.userinfo.button.chooseCampaign.input.title".localized()
        }
        return "base.section.userinfo.button.chooseCampaign.change.title".localized()
    }

    private var userDescription: String {

        let id = user.id ?? ""
        let name = user.name ?? ""
        let gender = user.gender?.description ?? ""
        let age = user.age
        let score = user.userScore

        if (id.isEmpty && name.isEmpty && !(gender == "m" || gender == "f") && age == nil && score == nil) {
            return "base.section.userinfo.none.title".localized()
        }

        var description: String = "userId: \(id)\n"
        description += "userName: \(user.name ?? "userName: ")\n"
        description += "age: \(user.ageText)\n"
        description += "userScore: \(user.scoreText)\n"

        var userGender: String = "userinfo.gender.none".localized()

        if let gender = user.gender {
            switch gender {
            case .male:
                userGender = "userinfo.gender.male".localized()
                break
            case .female:
                userGender = "userinfo.gender.female".localized()
                break
            default:
                break
            }
        }

        description += "gender: \(userGender)"

        return description
    }

    lazy var userinfoTitleLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.numberOfLines = 0
        view.font = .systemFont(ofSize: 16, weight: .medium)
        view.textColor = .black
        view.text = "base.section.userinfo.none.title".localized()
        return view
    }()

    lazy var jwtTokenTitleLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.numberOfLines = 0
        view.font = .systemFont(ofSize: 16, weight: .medium)
        view.textColor = .black
        view.text = DemoConfiguration.shared.jwtToken
        return view
    }()

    lazy var chooseButton: UIButton = {
        let view = UIButton()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .red
        view.layer.cornerRadius = 6
        view.contentEdgeInsets = .init(top: 7, left: 9, bottom: 7, right: 9)
        view.titleLabel?.font = .systemFont(ofSize: 15, weight: .medium)
        view.addTarget(self, action: #selector(didTouchButton), for: .touchUpInside)
        view.setTitle("base.section.userinfo.button.chooseCampaign.input.title".localized(), for: .normal)
        return view
    }()

    var radioGroup: [ShopLiveRadioButton] = []

    lazy var authView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false

        let commonRadio: ShopLiveRadioButton = {
            let view = ShopLiveRadioButton()
            view.translatesAutoresizingMaskIntoConstraints = false
            view.configure(identifier: "common", description: "userinfo.auth.type.common".localized())
            view.delegate = self
            return view
        }()

        let tokenRadio: ShopLiveRadioButton = {
            let view = ShopLiveRadioButton()
            view.translatesAutoresizingMaskIntoConstraints = false
            view.configure(identifier: "token", description: "userinfo.auth.type.jwt".localized())
            view.delegate = self
            return view
        }()

        self.radioGroup = [commonRadio, tokenRadio]
        view.addSubview(commonRadio)
        view.addSubview(tokenRadio)

        commonRadio.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview()
            $0.height.equalTo(20)
        }

        tokenRadio.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalTo(commonRadio.snp.trailing).offset(15)
            $0.trailing.lessThanOrEqualToSuperview()
            $0.height.equalTo(20)
        }

        return view
    }()

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        updateUserInfo()
        DemoConfiguration.shared.addConfigurationObserver(observer: self)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func setupViews() {
        super.setupViews()
        self.titleMenuView.addSubview(authView)
        self.itemView.addSubview(userinfoTitleLabel)
        self.itemView.addSubview(jwtTokenTitleLabel)
        self.itemView.addSubview(chooseButton)

        authView.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.trailing.lessThanOrEqualToSuperview()
            $0.centerY.equalToSuperview()
            $0.height.equalTo(20)
        }
        userinfoTitleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(15)
            $0.top.equalToSuperview().offset(15)
            $0.trailing.equalTo(chooseButton.snp.leading).offset(-15)
        }

        chooseButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-15)
            $0.top.equalToSuperview().offset(5)
            $0.width.equalTo(80)
            $0.height.greaterThanOrEqualTo(35)
        }

        jwtTokenTitleLabel.snp.makeConstraints {
            $0.leading.equalTo(userinfoTitleLabel)
            $0.trailing.equalToSuperview().offset(-15)
            $0.top.equalTo(userinfoTitleLabel.snp.bottom).offset(15)
            $0.top.greaterThanOrEqualTo(chooseButton.snp.bottom).offset(15)
            $0.bottom.equalToSuperview().offset(-15)
        }

        self.setSectionTitle(title: "base.section.userinfo.title".localized())
    }

    @objc private func didTouchButton() {
        let page = UserInfoViewController()
        self.parent?.navigationController?.pushViewController(page, animated: true)
    }

    private func updateUserInfo() {
        updateAuthType(identifier: DemoConfiguration.shared.useJWT ? "token" : "common")
        user = DemoConfiguration.shared.user
        userinfoTitleLabel.text = userDescription
        jwtTokenTitleLabel.text = DemoConfiguration.shared.jwtToken ?? ""
        chooseButton.setTitle(userButtonTitle, for: .normal)
    }

    private func isNonUser(_ user: ShopLiveUser) -> Bool {

        if let id = user.id, !id.isEmpty {
            return false
        }

        if let name = user.name, !name.isEmpty {
            return false
        }

        if user.age != nil {
            return false
        }

        if user.userScore != nil {
            return false
        }

        if let gender = user.gender, (gender.description == "m" || gender.description == "f") {
            return false
        }

        return true
    }
}

extension ShopLiveUser {
    var userScore: Int? {
        if let userScoreObj = self.getParams().first(where: { $0.key == "userScore" }) {
            return Int(userScoreObj.value)
        } else {
            return nil
        }
    }

    var scoreText: String {
        guard let scoreValue = self.userScore else {
            return ""
        }
        return "\(scoreValue)"
    }

    var ageText: String {
        guard let ageValue = self.age, ageValue >= 0 else {
            return ""
        }
        return "\(ageValue)"
    }
}

extension UserInfoCell: DemoConfigurationObserver {
    var identifier: String {
        "UserInfoCell"
    }

    func updatedValues(keys: [String]) {
         updateUserInfo()
    }
}

extension UserInfoCell: ShopLiveRadioButtonDelegate {

    func updateAuthType(identifier: String) {
        radioGroup.forEach { radio in
            radio.updateRadio(selected: radio.identifier == identifier)
        }
    }

    func didSelectRadioButton(_ sender: ShopLiveRadioButton) {
        updateAuthType(identifier: sender.identifier)
        guard let selected = radioGroup.first(where: {$0.isSelected == true}) else {
            DemoConfiguration.shared.useJWT = false
            return
        }

        DemoConfiguration.shared.useJWT = (selected.identifier == "token")
    }

    var selectedIdentifier: String {
        guard let selected = radioGroup.first(where: {$0.isSelected == true}) else {
            return ""
        }

        return selected.identifier
    }
}
