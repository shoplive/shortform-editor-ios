//
//  UserInfoViewController.swift
//  PlayerDemo2
//
//  Created by Tabber on 1/17/25.
//  Copyright © 2025 com.app. All rights reserved.
//

import UIKit
import ShopLiveSDK
import ShopliveSDKCommon
import SnapKit

final class UserInfoViewController: UIViewController {
    
    private var viewModel: UserInfoViewModel
    
    init(viewModel: UserInfoViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var tapGesture: UITapGestureRecognizer?

    var userIdInputField: UITextField = {
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

    var userNameInputField: UITextField = {
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

        viewModel.setRadioGroup([maleRadio, femaleRadio, noneRadio])
        
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
        view.setTitle(PlayerDemo2Strings.Userinfo.Jwt.Button.generate, for: .normal)
        view.layer.cornerRadius = 6
        view.backgroundColor = .red
        view.addTarget(self, action: #selector(tokenGenerateSaveAct), for: .touchUpInside)
        return view
    }()
    
    lazy var jwtQRScanButton: UIButton = {
        let view = UIButton()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setTitle("userinfo.jwt.button.qrscan".localized(), for: .normal)
        view.layer.cornerRadius = 6
        view.backgroundColor = .red
        view.addTarget(self, action: #selector(scanJWTToken), for: .touchUpInside)
        return view
    }()

    //MARK: - ViewDidLoad()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupEdgeGesture()
        setupTapGesture()
        setupBackButton()
        setupNaviItems()
        setupViews()
        viewModel.setupParameterList()
        updateUserInfo()
    }
    
    private func setupEdgeGesture() {
        let edgePanGesture = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(handleEdgeGesture(_:)))
        edgePanGesture.edges = .left
        self.view.addGestureRecognizer(edgePanGesture)
    }

    private func setupTapGesture() {
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture(_:)))
        self.view.addGestureRecognizer(tapGesture!)
    }
    
    func setupBackButton() {
        let backButton = UIBarButtonItem(image: PlayerDemo2Asset.back.image, style: .plain, target: self, action: #selector(handleNaviBack)
        )
        backButton.tintColor = .white
        self.navigationItem.leftBarButtonItem = backButton

        self.navigationController?.navigationBar.topItem?.backBarButtonItem = nil
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
        self.view.addSubview(jwtQRScanButton)
        
        parameterTableView.snp.makeConstraints {
            $0.top.equalTo(genderView.snp.bottom).offset(15)
            $0.leading.equalTo(self.view.snp.leading).offset(15)
            $0.trailing.equalTo(self.view.snp.trailing).inset(15)
            $0.height.equalTo(100)
        }
        
        addParameterButton.snp.makeConstraints {
            $0.top.equalTo(parameterTableView.snp.bottom).offset(10)
            $0.trailing.equalTo(self.view.snp.trailing).inset(15)
            $0.width.equalTo(self.view.frame.width / 2 - 20)
            $0.height.greaterThanOrEqualTo(35)
        }
        
        userIdInputField.snp.makeConstraints {
            $0.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).offset(15)
            $0.leading.equalTo(self.view.snp.leading).offset(15)
            $0.trailing.equalTo(self.view.snp.trailing).inset(15)
            $0.height.greaterThanOrEqualTo(35)
        }
        
        userNameInputField.snp.makeConstraints {
            $0.top.equalTo(userIdInputField.snp.bottom).offset(10)
            $0.leading.equalTo(self.view.snp.leading).offset(15)
            $0.trailing.equalTo(self.view.snp.trailing).inset(15)
            $0.height.greaterThanOrEqualTo(35)
        }
        
        ageInputField.snp.makeConstraints {
            $0.top.equalTo(userNameInputField.snp.bottom).offset(10)
            $0.leading.equalTo(self.view.snp.leading).offset(15)
            $0.trailing.equalTo(self.view.snp.trailing).inset(15)
            $0.height.greaterThanOrEqualTo(35)
        }
        
        userScoreInputField.snp.makeConstraints {
            $0.top.equalTo(ageInputField.snp.bottom).offset(10)
            $0.leading.equalTo(self.view.snp.leading).offset(15)
            $0.trailing.equalTo(self.view.snp.trailing).inset(15)
            $0.height.greaterThanOrEqualTo(35)
        }
        
        genderView.snp.makeConstraints {
            $0.top.equalTo(userScoreInputField.snp.bottom).offset(15)
            $0.leading.equalTo(self.view.snp.leading).offset(15)
            $0.trailing.equalTo(self.view.snp.trailing).inset(15)
            $0.height.equalTo(20)
        }
        
        saveUserInfoButton.snp.makeConstraints {
            $0.top.equalTo(parameterTableView.snp.bottom).offset(10)
            $0.leading.equalTo(self.view.snp.leading).offset(15)
            $0.width.equalTo(self.view.frame.width / 2 - 20)
            $0.height.equalTo(35)
        }
        
        authTokenTitle.snp.makeConstraints {
            $0.top.equalTo(saveUserInfoButton.snp.bottom).offset(35)
            $0.leading.equalTo(self.view.snp.leading).offset(15)
            $0.trailing.equalTo(self.view.snp.trailing).inset(15)
            $0.height.equalTo(30)
        }
        
        jwtInputField.snp.makeConstraints {
            $0.top.equalTo(authTokenTitle.snp.bottom).offset(10)
            $0.leading.equalTo(self.view.snp.leading).offset(15)
            $0.trailing.equalTo(self.view.snp.trailing).inset(15)
            $0.height.equalTo(35)
        }
        
        jwtResultLabel.snp.makeConstraints {
            $0.top.equalTo(jwtInputField.snp.bottom).offset(5)
            $0.leading.equalTo(self.view.snp.leading).offset(15)
            $0.trailing.equalTo(self.view.snp.trailing).inset(15)
            $0.height.greaterThanOrEqualTo(20)
        }
        
        jwtGenerateButton.snp.makeConstraints {
            $0.top.equalTo(jwtResultLabel.snp.bottom).offset(5)
            $0.leading.equalTo(self.view.snp.leading).offset(15)
            $0.trailing.equalTo(self.view.snp.trailing).inset(15)
            $0.height.equalTo(30)
        }

        jwtQRScanButton.snp.makeConstraints {
            $0.top.equalTo(jwtGenerateButton.snp.bottom).offset(10)
            $0.leading.equalTo(self.view.snp.leading).offset(15)
            $0.trailing.equalTo(self.view.snp.trailing).inset(15)
            $0.height.equalTo(30)
            $0.bottom.lessThanOrEqualTo(self.view.snp.bottom)
        }
        
    }
    
    private func updateUserInfo() {
        
        viewModel.setUserModel(DemoConfiguration.shared.user)
        
        let user = viewModel.user
        let age = user.age ?? -1
        let userScore = DemoConfiguration.shared.userScore
        
        userIdInputField.text = user.userId
        userNameInputField.text = user.userName ?? ""
        ageInputField.text = age >= 0 ? "\(age)" : ""
        updateGender(identifier: user.gender?.rawValue ?? "unknown")
        userScoreInputField.text = userScore != nil ? "\(userScore!)" : ""
        
        ShopLiveCommon.setUser(user: user)
        
        jwtInputField.text = ShopLiveCommon.getAuthToken()
        
    }
    
    private func save() {
        
        viewModel.setUser(userId: userIdInputField.text ?? "",
                          userName: userNameInputField.text ?? "",
                          gender: selectedGender(),
                          age: ageInputField.text,
                          userScore: userScoreInputField.text ?? "")
        
        viewModel.saveParameterList()
        
        DemoConfiguration.shared.user = viewModel.user
        ShopLiveCommon.setUser(user: viewModel.user)
        
        UIWindow.showToast(message: "userinfo.msg.save.success".localized())
        handleNaviBack()
    }

    func updateJwtToken() {
        if let jwtToken = DemoConfiguration.shared.jwtToken, !jwtToken.isEmpty {
            jwtResultLabel.text = jwtToken
        } else {
            jwtResultLabel.text = "userinfo.jwt.result.message".localized()
        }
    }

    func removeTapGesture() {
        guard let gestureRecognizers = self.view.gestureRecognizers,
                gestureRecognizers.contains(where: {$0 == tapGesture}) else { return }

        self.view.removeGestureRecognizer(tapGesture!)
    }
    
    deinit {
        removeTapGesture()
    }
    
}

// MARK: - ShopLiveRadioButtonDelegate
extension UserInfoViewController: ShopLiveRadioButtonDelegate {

    func updateGender(identifier: String) {
        viewModel.radioGroup.forEach { radio in
            radio.updateRadio(selected: radio.identifier == identifier)
        }
    }

    func didSelectRadioButton(_ sender: ShopLiveRadioButton) {
        updateGender(identifier: sender.identifier)
    }

    func selectedGender() -> ShopliveCommonUserGender {
        guard let selected = viewModel.radioGroup.first(where: {$0.isSelected == true}) else {
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

// MARK: - UITableViewDelegate, UITableViewDataSource
extension UserInfoViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.keysArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "AddUserParameterCell", for: indexPath) as? AddUserParameterCell else { return UITableViewCell(style: .default, reuseIdentifier: "Cell") }
        
        let key = viewModel.keysArray[indexPath.row]
        let value = viewModel.valueArray[indexPath.row]
        
        cell.configure(key: key, value: value)
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
                viewModel.deleteDatas(indexPath.row)
                self.parameterTableView.deleteRows(at: [indexPath], with: .fade)
                viewModel.saveParameterList()
        }
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    
}

// MARK: - UITextFieldDelegate
extension UserInfoViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let text = textField.text else {
            return
        }
        
        switch(textField.accessibilityIdentifier) {
        case "keyInputField":
            viewModel.appendKey(text: text)
            break
        case "valueInputField":
            viewModel.appendValue(text: text)
            break
        case _:
            break
        }
        if viewModel.keysArray.count == viewModel.valueArray.count {
            viewModel.saveParameterList()
        }
    }
}


// MARK: - Objc func
extension UserInfoViewController {
    @objc func addParameter() {
        viewModel.appendData()
        self.parameterTableView.reloadData()
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
    
    @objc func handleNaviBack() {
        shopliveHideKeyboard_SL()
        self.navigationController?.popViewController(animated: true)
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
        ShopLiveCommon.setAuthToken(authToken: jwtInputField.text ?? "")
        DemoConfiguration.shared.jwtToken =  ShopLiveCommon.getAuthToken()
    }
    
    @objc func scanJWTToken() {
        let qrReaderVC = SLQRReaderViewController()
        qrReaderVC.delegate = self
        self.present(qrReaderVC, animated: true)
    }
    
    @objc private func handleEdgeGesture(_ gesture: UIScreenEdgePanGestureRecognizer) {
        guard gesture.state == .recognized else {
            return
        }
        shopliveHideKeyboard_SL()
        self.navigationController?.popViewController(animated: true)
    }

    @objc private func handleTapGesture(_ gesture: UITapGestureRecognizer) {
        guard gesture.state == .recognized else {
            return
        }
        shopliveHideKeyboard_SL()
    }
}


extension UserInfoViewController: QRKeyReaderDelegate {
    func updateKeyFromQR(keyset: ShopLiveKeySet?) { }
    
    func updateUserJWTFromQR(userJWT: String?) {
        jwtInputField.text = userJWT
    }
    
    
}
