//
//  UserInfoViewController.swift
//  ShopLiveDemo
//
//  Created by ShopLive on 2021/12/12.
//

import UIKit
import ShopLiveSDK
import ShopliveSDKCommon

final class UserInfoViewController: SideMenuItemViewController {

    private var secretKeyButtonTitle: String {
        guard let key = DemoSecretKeyTool.shared.currentKey()?.key, !key.isEmpty else {
            return "userinfo.button.chooseSecret.input.title".localized()
        }

        return "userinfo.button.chooseSecret.change.title".localized()
    }

    lazy var userIdInputField: UITextField = {
        let view = UITextField()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.placeholder = "userinfo.userid.placeholder".localized()
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.lightGray.cgColor
        view.layer.cornerRadius = 6
        view.textColor = .black
        view.leftViewMode = .always
        let paddingView = UIView(frame: .init(origin: .zero, size: .init(width: 10, height: view.frame.height)))
        view.leftView = paddingView
        view.setPlaceholderColor(.darkGray)
        return view
    }()

    lazy var userNameInputField: UITextField = {
        let view = UITextField()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.placeholder = "userinfo.userName.placeholder".localized()
        view.setPlaceholderColor(.darkGray)
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.lightGray.cgColor
        view.layer.cornerRadius = 6
        view.textColor = .black
        view.leftViewMode = .always
        let paddingView = UIView(frame: .init(origin: .zero, size: .init(width: 10, height: view.frame.height)))
        view.leftView = paddingView

        return view
    }()

    lazy var ageInputField: UITextField = {
        let view = UITextField()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.placeholder = "userinfo.age.placeholder".localized()
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.lightGray.cgColor
        view.layer.cornerRadius = 6
        view.textColor = .black
        view.leftViewMode = .always
        let paddingView = UIView(frame: .init(origin: .zero, size: .init(width: 10, height: view.frame.height)))
        view.leftView = paddingView
        view.setPlaceholderColor(.darkGray)
        view.keyboardType = .numberPad
        return view
    }()

    lazy var userScoreInputField: UITextField = {
        let view = UITextField()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.placeholder = "userinfo.userScore.placeholder".localized()
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.lightGray.cgColor
        view.layer.cornerRadius = 6
        view.textColor = .black
        view.leftViewMode = .always
        let paddingView = UIView(frame: .init(origin: .zero, size: .init(width: 10, height: view.frame.height)))
        view.leftView = paddingView
        view.setPlaceholderColor(.darkGray)
        view.keyboardType = .numberPad
        return view
    }()
    
    private lazy var addParameterButton: UIButton = {
        let view = UIButton()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 6
        view.backgroundColor = .red
        view.setTitle("userinfo.add.parameter.button.title".localized(), for: .normal)
        view.titleLabel?.textColor = .white
        view.addTarget(self, action: #selector(addParameter), for: .touchUpInside)
        return view
    }()
    
    private lazy var parameterTableView: UITableView = {
        let view = UITableView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.register(AddUserParameterCell.self, forCellReuseIdentifier: "AddUserParameterCell")
        view.backgroundColor = .white
        view.delegate = self
        view.rowHeight = 50
        view.allowsSelection = false
        view.dataSource = self
        view.separatorStyle = .singleLine
        view.isUserInteractionEnabled = true
        return view
    }()
    
    var radioGroup: [ShopLiveRadioButton] = []

    lazy var genderView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false

        let maleRadio: ShopLiveRadioButton = {
            let view = ShopLiveRadioButton()
            view.translatesAutoresizingMaskIntoConstraints = false
            view.configure(identifier: "m", description: "userinfo.gender.male".localized())
            view.delegate = self
            return view
        }()

        let femaleRadio: ShopLiveRadioButton = {
            let view = ShopLiveRadioButton()
            view.translatesAutoresizingMaskIntoConstraints = false
            view.configure(identifier: "f", description: "userinfo.gender.female".localized())
            view.delegate = self
            return view
        }()

        let noneRadio: ShopLiveRadioButton = {
            let view = ShopLiveRadioButton()
            view.translatesAutoresizingMaskIntoConstraints = false
            view.configure(identifier: "unknown", description: "userinfo.gender.none".localized())
            view.delegate = self
            view.updateRadio(selected: true)
            return view
        }()

        self.radioGroup = [maleRadio, femaleRadio, noneRadio]
        view.addSubview(maleRadio)
        view.addSubview(femaleRadio)
        view.addSubview(noneRadio)
        
        NSLayoutConstraint.activate([
            maleRadio.topAnchor.constraint(equalTo: view.topAnchor),
            maleRadio.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            maleRadio.heightAnchor.constraint(equalToConstant: 20),
            
            femaleRadio.topAnchor.constraint(equalTo: view.topAnchor),
            femaleRadio.leadingAnchor.constraint(equalTo: maleRadio.trailingAnchor,constant: 15),
            femaleRadio.heightAnchor.constraint(equalToConstant: 20),
            
            noneRadio.topAnchor.constraint(equalTo: view.topAnchor),
            noneRadio.leadingAnchor.constraint(equalTo: femaleRadio.trailingAnchor,constant: 15),
            noneRadio.heightAnchor.constraint(equalToConstant: 20)
        ])
        return view
    }()

    private lazy var saveUserInfoButton: UIButton = {
        let view = UIButton()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 6
        view.backgroundColor = .red
        view.setTitle("userinfo.jwt.button.usersave".localized(), for: .normal)
        view.titleLabel?.textColor = .white
        view.addTarget(self, action: #selector(saveAct), for: .touchUpInside)
        return view
    }()

    private lazy var authTokenTitle: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.numberOfLines = 1
        view.lineBreakMode = .byTruncatingTail
        view.textColor = .black
        view.font = .systemFont(ofSize: 18, weight: .bold)
        view.text = "userinfo.authToken.title".localized()
        return view
    }()

    lazy var jwtInputField: UITextField = {
        let view = UITextField()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.placeholder = "JWT Secret Key"
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.lightGray.cgColor
        view.layer.cornerRadius = 6
        view.textColor = .black
        view.leftViewMode = .always
        let paddingView = UIView(frame: .init(origin: .zero, size: .init(width: 10, height: view.frame.height)))
        view.leftView = paddingView
        view.setPlaceholderColor(.darkGray)
        view.text = DemoConfiguration.shared.jwtToken
        return view
    }()


    lazy var jwtResultLabel: UITextField = {
        let view = UITextField()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.textColor = .lightGray
        return view
    }()

    lazy var jwtGenerateButton: UIButton = {
        let view = UIButton()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setTitle("userinfo.jwt.button.generate".localized(), for: .normal)
        view.layer.cornerRadius = 6
        view.backgroundColor = .red
        view.addTarget(self, action: #selector(tokenGenerateSaveAct), for: .touchUpInside)
        return view
    }()
    
    lazy var scanQRButton: UIButton = {
        let view = UIButton()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setTitle("userinfo.jwt.button.generate".localized(), for: .normal)
        view.layer.cornerRadius = 6
        view.backgroundColor = .red
        view.addTarget(self, action: #selector(scanQR), for: .touchUpInside)
        
        return view
    }()
    
    private var parameterList: [String: String] = [:]
    private var keysArray: [Dictionary<String, String>.Keys.Element] = []
    private var valueArray: [Dictionary<String, String>.Values.Element] = []
    private var user: ShopLiveCommonUser = DemoConfiguration.shared.user
    private var newUser: ShopLiveCommonUser?
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNaviItems()
        setupViews()
        setupParameterList()
        updateUserInfo()
    }
    
    private func setupParameterList() {
        guard let param = DemoConfiguration.shared.userParameters else {
            return
        }
        param.forEach { (key: String, value: Any?) in
            parameterList[key] = "\(value ?? "null")"
        }
        keysArray = Array(parameterList.keys)
        valueArray = Array(parameterList.values)
    }

    func setupNaviItems() {
        self.title = "menu.userinfo".localized()

        let delete = UIBarButtonItem(title: "sdk.user.delete".localized(from: "shoplive"), style: .plain, target: self, action: #selector(deleteAct))

        delete.tintColor = .white

        self.navigationItem.rightBarButtonItems = [delete] //save,
    }

    func setupViews() {
        self.view.addSubview(userIdInputField)
        self.view.addSubview(userNameInputField)
        self.view.addSubview(ageInputField)
        self.view.addSubview(userScoreInputField)
        self.view.addSubview(genderView)
        self.view.addSubview(saveUserInfoButton)
        self.view.addSubview(authTokenTitle)
        self.view.addSubview(jwtInputField)
//        self.view.addSubview(jwtInputButton)
        self.view.addSubview(jwtResultLabel)
        self.view.addSubview(jwtGenerateButton)
        self.view.addSubview(parameterTableView)
        self.view.addSubview(addParameterButton)
        
        NSLayoutConstraint.activate([
            parameterTableView.topAnchor.constraint(equalTo: genderView.bottomAnchor, constant: 15),
            parameterTableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 15),
            parameterTableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -15),
            parameterTableView.heightAnchor.constraint(equalToConstant: 100),
            
            addParameterButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -15),
            addParameterButton.topAnchor.constraint(equalTo: parameterTableView.bottomAnchor,constant: 10),
            addParameterButton.widthAnchor.constraint(equalToConstant: self.view.frame.width / 2 - 20),
            addParameterButton.heightAnchor.constraint(greaterThanOrEqualToConstant: 35),
            
            userIdInputField.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 15),
            userIdInputField.leadingAnchor.constraint(equalTo: self.view.leadingAnchor,constant: 15),
            userIdInputField.trailingAnchor.constraint(equalTo: self.view.trailingAnchor,constant: -15),
            userIdInputField.heightAnchor.constraint(greaterThanOrEqualToConstant: 35),
            
            userNameInputField.topAnchor.constraint(equalTo: userIdInputField.bottomAnchor, constant: 10),
            userNameInputField.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 15),
            userNameInputField.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -15),
            userNameInputField.heightAnchor.constraint(greaterThanOrEqualToConstant: 35),
            
            ageInputField.topAnchor.constraint(equalTo: userNameInputField.bottomAnchor, constant: 10),
            ageInputField.leadingAnchor.constraint(equalTo: self.view.leadingAnchor,constant: 15),
            ageInputField.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -15),
            ageInputField.heightAnchor.constraint(greaterThanOrEqualToConstant: 35),
            
            userScoreInputField.topAnchor.constraint(equalTo: ageInputField.bottomAnchor, constant: 10),
            userScoreInputField.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 15),
            userScoreInputField.trailingAnchor.constraint(equalTo: self.view.trailingAnchor,constant: -15),
            userScoreInputField.heightAnchor.constraint(greaterThanOrEqualToConstant: 35),
            
            genderView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 15),
            genderView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -15),
            genderView.topAnchor.constraint(equalTo: userScoreInputField.bottomAnchor, constant: 15),
            genderView.heightAnchor.constraint(equalToConstant: 20),
            
            saveUserInfoButton.topAnchor.constraint(equalTo: parameterTableView.bottomAnchor, constant: 10),
            saveUserInfoButton.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 15),
            saveUserInfoButton.widthAnchor.constraint(equalToConstant: self.view.frame.width / 2 - 20),
            saveUserInfoButton.heightAnchor.constraint(equalToConstant: 35),
            
            authTokenTitle.topAnchor.constraint(equalTo: saveUserInfoButton.bottomAnchor, constant: 35),
            authTokenTitle.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 15),
            authTokenTitle.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -15),
            authTokenTitle.heightAnchor.constraint(equalToConstant: 30),
            
            jwtInputField.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 15),
            jwtInputField.topAnchor.constraint(equalTo: authTokenTitle.bottomAnchor, constant: 10),
            jwtInputField.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -15),
            jwtInputField.heightAnchor.constraint(equalToConstant: 35),
            
            jwtResultLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 15),
            jwtResultLabel.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -15),
            jwtResultLabel.topAnchor.constraint(equalTo: jwtInputField.bottomAnchor, constant: 5),
            jwtResultLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 20),
            
            jwtGenerateButton.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 15),
            jwtGenerateButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -15),
            jwtGenerateButton.topAnchor.constraint(equalTo: jwtResultLabel.bottomAnchor, constant: 5),
            jwtGenerateButton.heightAnchor.constraint(equalToConstant: 35),
            jwtGenerateButton.bottomAnchor.constraint(lessThanOrEqualTo: self.view.bottomAnchor)
        ])

    }

    @objc func deleteAct() {
        let alert = UIAlertController(title: "userinfo.msg.deleteAll.title".localized(), message: nil, preferredStyle: .alert)
        alert.addAction(.init(title: "alert.msg.no".localized(), style: .cancel, handler: { action in

        }))
        alert.addAction(.init(title: "alert.msg.ok".localized(), style: .default, handler: { action in
            DemoConfiguration.shared.user = ShopLiveCommonUser(userId: "")
            DemoConfiguration.shared.jwtToken = nil
            self.updateUserInfo()
        }))
        self.present(alert, animated: true, completion: nil)
    }

    private func save() {
        user.userId = userIdInputField.text ?? ""
        user.userName = userNameInputField.text
        user.gender = selectedGender()
        if let ageText = ageInputField.text, !ageText.isEmpty, let age = Int(ageText), age >= 0 {
            user.age = age
        } else {
            user.age = nil
        }
        user.userScore = Int(userScoreInputField.text ?? "") ?? 0
        self.saveParameterList()
        DemoConfiguration.shared.user = user
        ShopLiveCommon.setUser(user: user)
        UIWindow.showToast(message: "userinfo.msg.save.success".localized())
        handleNaviBack()
    }
    
    private func saveParameterList() {
        
        for index in 0..<keysArray.count {
            parameterList.updateValue(valueArray[index], forKey: keysArray[index])
        }
        for (key, value) in parameterList {
            user.custom?.updateValue(key, forKey: value)
        }
        DemoConfiguration.shared.userParameters = self.parameterList
    }

    @objc func saveAct() {
        shopliveHideKeyboard_SL()
        if userIdInputField.text == nil || (userIdInputField.text ?? "").isEmpty {
            UIWindow.showToast(message: "userinfo.msg.save.failed.noneId".localized())
        } else {
            save()
        }
    }

    @objc func tokenGenerateSaveAct() {
        DemoConfiguration.shared.jwtToken =  ShopLiveCommon.getAuthToken()
    }
    
    @objc func scanQR() {
        let qrReaderVC = SLQRReaderViewController()
        qrReaderVC.delegate = self
        self.present(qrReaderVC, animated: true)
    }

    private func updateUserInfo() {
        user = DemoConfiguration.shared.user
        userIdInputField.text = user.userId
        userNameInputField.text = user.userName ?? ""
        let age = user.age ?? -1
        ageInputField.text = age >= 0 ? "\(age)" : ""
        updateGender(identifier: user.gender?.rawValue ?? "unknown")
        let userScore = DemoConfiguration.shared.userScore
        userScoreInputField.text = userScore != nil ? "\(userScore!)" : ""
        ShopLiveCommon.setUser(user: user)
        jwtInputField.text = ShopLiveCommon.getAuthToken()
        
    }

    func updateJwtToken() {
        if let jwtToken = DemoConfiguration.shared.jwtToken, !jwtToken.isEmpty {
            jwtResultLabel.text = jwtToken
        } else {
            jwtResultLabel.text = "userinfo.jwt.result.message".localized()
        }
    }

    private func isEqualUser(user: ShopLiveCommonUser) -> Bool {
        if newUser == nil {
            return false
        }

        if let curUser = newUser,
            curUser.userId == user.userId &&
            curUser.userName == user.userName &&
            curUser.age == user.age &&
            curUser.userScore == user.userScore &&
            curUser.gender == user.gender {
            return true
        }

        return false
    }
}

extension UserInfoViewController: ShopLiveRadioButtonDelegate {

    func updateGender(identifier: String) {
        radioGroup.forEach { radio in
            radio.updateRadio(selected: radio.identifier == identifier)
        }
    }

    func didSelectRadioButton(_ sender: ShopLiveRadioButton) {
        updateGender(identifier: sender.identifier)
    }

    func selectedGender() -> ShopliveCommonUserGender {
        guard let selected = radioGroup.first(where: {$0.isSelected == true}) else {
            return .netural
        }

        switch selected.identifier {
        case ShopliveCommonUserGender.male.rawValue:
            return .male
        case ShopliveCommonUserGender.female.rawValue:
            return .female
        default:
            return .netural
        }

    }
}

extension UserInfoViewController: QRKeyReaderDelegate {
    func updateKeyFromQR(keyset: ShopLiveKeySet?) { }
    func updateuserJWTFromQR(userJWT: String?) {
        print("data", userJWT)
        
    }
}

extension UserInfoViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return keysArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "AddUserParameterCell", for: indexPath) as? AddUserParameterCell else { return UITableViewCell(style: .default, reuseIdentifier: "Cell") }
        cell.configure(key: keysArray[indexPath.row], value: valueArray[indexPath.row])
        cell.keyInputField.delegate = self
        cell.valueInputField.delegate = self
        cell.keyInputField.tag = indexPath.row
        return cell
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
            if editingStyle == .delete {
                self.parameterList.removeValue(forKey: keysArray[indexPath.row])
                self.keysArray.remove(at: indexPath.row)
                self.valueArray.remove(at: indexPath.row)
                self.parameterTableView.deleteRows(at: [indexPath], with: .fade)
                saveParameterList()
        }
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    @objc func addParameter() {
        self.keysArray.append("")
        self.valueArray.append("")
        self.parameterTableView.reloadData()
    }
}

extension UserInfoViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let text = textField.text else {
            return
        }
        
        switch(textField.accessibilityIdentifier) {
        case "keyInputField":
            self.keysArray[self.keysArray.firstIndex(of: "") ?? self.keysArray.endIndex - 1] = text
            break
        case "valueInputField":
            self.valueArray[self.valueArray.firstIndex(of: "") ?? self.valueArray.endIndex - 1] = text
            break
        case _:
            break
        }
        if keysArray.count == valueArray.count {
            self.saveParameterList()
        }
    }
}
