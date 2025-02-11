//
//  UserInfoViewController.swift
//  PlayerDemo2
//
//  Created by Tabber on 1/17/25.
//  Copyright © 2025 com.app. All rights reserved.
//

import UIKit
import ShopLiveSDK
import RxSwift
import RxCocoa
import ShopliveSDKCommon
import SnapKit

final class UserInfoViewController: UIViewController {
    
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
        return view
    }()
    
    private lazy var parameterTableView: UITableView = {
        let view = UITableView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.register(AddUserParameterCell.self, forCellReuseIdentifier: "AddUserParameterCell")
        view.backgroundColor = .white
        view.rowHeight = 50
        view.allowsSelection = false
        
        view.separatorStyle = .singleLine
        view.isUserInteractionEnabled = true
        return view
    }()
    
    lazy var genderView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false

        let maleRadio: ShopLiveRadioOptionButton = {
            let view = ShopLiveRadioOptionButton()
            view.translatesAutoresizingMaskIntoConstraints = false
            view.configure(identifier: "m", description: "userinfo.gender.male".localized())
            view.delegate = self
            return view
        }()

        let femaleRadio: ShopLiveRadioOptionButton = {
            let view = ShopLiveRadioOptionButton()
            view.translatesAutoresizingMaskIntoConstraints = false
            view.configure(identifier: "f", description: "userinfo.gender.female".localized())
            view.delegate = self
            return view
        }()

        let noneRadio: ShopLiveRadioOptionButton = {
            let view = ShopLiveRadioOptionButton()
            view.translatesAutoresizingMaskIntoConstraints = false
            view.configure(identifier: "n", description: "userinfo.gender.none".localized())
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
    
    private var viewModel: UserInfoViewModel
    private let disposeBag = DisposeBag()
    
    init(viewModel: UserInfoViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        viewModel.registerTableView(tableView: parameterTableView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    //MARK: - ViewDidLoad()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupEdgeGesture()
        setupTapGesture()
        setupBackButton()
        setupNaviItems()
        setupViews()
        
        bindViewModel()
    }
    
    private func bindViewModel() {
        
        let viewDidLoadPublish = PublishSubject<Void>()
        
        let input = UserInfoViewModel.Input(viewDidLoad: viewDidLoadPublish,
                                            userIdInputFieldChangeEvent: userIdInputField.rx.text,
                                            userNameInputFieldChangeEvent: userNameInputField.rx.text,
                                            userAgeInputFieldChangeEvent: ageInputField.rx.text,
                                            userScoreInputFieldChangeEvent: userScoreInputField.rx.text,
                                            jwtTokenChangeEvent: jwtInputField.rx.text,
                                            saveButtonTap: saveUserInfoButton.rx.tap,
                                            addParameterButtonTap: addParameterButton.rx.tap)
        
        let output = viewModel.transform(input: input)
        
        output.userDataSaved
            .drive(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.shopliveHideKeyboard_SL()
                if self.userIdInputField.text == nil || (self.userIdInputField.text ?? "").isEmpty {
                    UIWindow.showToast(message: "userinfo.msg.save.failed.noneId".localized())
                } else {
                    UIWindow.showToast(message: "userinfo.msg.save.success".localized())
                    self.handleNaviBack()
                }
            })
            .disposed(by: disposeBag)
        
        output.userParameter
            .drive(onNext: { [weak self] _ in
                self?.parameterTableView.reloadData()
            })
            .disposed(by: disposeBag)
        
        output.paramterAdded
            .drive(onNext: { _ in
                self.parameterTableView.reloadData()
            })
            .disposed(by: disposeBag)
        
        output.userDataUpdated
            .withUnretained(self)
            .subscribe(onNext: { owner, data in
                print("UserDataUpdated Called")
                owner.updateTextField(data: data)
            })
            .disposed(by: disposeBag)
        
        viewDidLoadPublish.onNext(())
        
    }
    
    deinit {
        removeTapGesture()
    }
    
}

//MARK: - layout
extension UserInfoViewController {
    private func setupViews() {
        view.addSubview(userIdInputField)
        view.addSubview(userNameInputField)
        view.addSubview(ageInputField)
        view.addSubview(userScoreInputField)
        view.addSubview(genderView)
        view.addSubview(saveUserInfoButton)
        view.addSubview(authTokenTitle)
        view.addSubview(jwtInputField)
        view.addSubview(jwtResultLabel)
        view.addSubview(jwtGenerateButton)
        view.addSubview(parameterTableView)
        view.addSubview(addParameterButton)
        view.addSubview(jwtQRScanButton)
        
        parameterTableView.snp.makeConstraints {
            $0.top.equalTo(genderView.snp.bottom).offset(15)
            $0.leading.equalTo(self.view.snp.leading).offset(15)
            $0.trailing.equalTo(self.view.snp.trailing).offset(-15)
            $0.height.equalTo(100)
        }
        
        addParameterButton.snp.makeConstraints {
            $0.top.equalTo(parameterTableView.snp.bottom).offset(10)
            $0.trailing.equalTo(self.view.snp.trailing).offset(-15)
            $0.width.equalTo(self.view.frame.width / 2 - 20)
            $0.height.greaterThanOrEqualTo(35)
        }
        
        userIdInputField.snp.makeConstraints {
            $0.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).offset(15)
            $0.leading.equalTo(self.view.snp.leading).offset(15)
            $0.trailing.equalTo(self.view.snp.trailing).offset(-15)
            $0.height.greaterThanOrEqualTo(35)
        }
        
        userNameInputField.snp.makeConstraints {
            $0.top.equalTo(userIdInputField.snp.bottom).offset(10)
            $0.leading.equalTo(self.view.snp.leading).offset(15)
            $0.trailing.equalTo(self.view.snp.trailing).offset(-15)
            $0.height.greaterThanOrEqualTo(35)
        }
        
        ageInputField.snp.makeConstraints {
            $0.top.equalTo(userNameInputField.snp.bottom).offset(10)
            $0.leading.equalTo(self.view.snp.leading).offset(15)
            $0.trailing.equalTo(self.view.snp.trailing).offset(-15)
            $0.height.greaterThanOrEqualTo(35)
        }
        
        userScoreInputField.snp.makeConstraints {
            $0.top.equalTo(ageInputField.snp.bottom).offset(10)
            $0.leading.equalTo(self.view.snp.leading).offset(15)
            $0.trailing.equalTo(self.view.snp.trailing).offset(-15)
            $0.height.greaterThanOrEqualTo(35)
        }
        
        genderView.snp.makeConstraints {
            $0.top.equalTo(userScoreInputField.snp.bottom).offset(15)
            $0.leading.equalTo(self.view.snp.leading).offset(15)
            $0.trailing.equalTo(self.view.snp.trailing).offset(-15)
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
            $0.trailing.equalTo(self.view.snp.trailing).offset(-15)
            $0.height.equalTo(30)
        }
        
        jwtInputField.snp.makeConstraints {
            $0.top.equalTo(authTokenTitle.snp.bottom).offset(10)
            $0.leading.equalTo(self.view.snp.leading).offset(15)
            $0.trailing.equalTo(self.view.snp.trailing).offset(-15)
            $0.height.equalTo(35)
        }
        
        jwtResultLabel.snp.makeConstraints {
            $0.top.equalTo(jwtInputField.snp.bottom).offset(5)
            $0.leading.equalTo(self.view.snp.leading).offset(15)
            $0.trailing.equalTo(self.view.snp.trailing).offset(-15)
            $0.height.greaterThanOrEqualTo(20)
        }
        
        jwtGenerateButton.snp.makeConstraints {
            $0.top.equalTo(jwtResultLabel.snp.bottom).offset(5)
            $0.leading.equalTo(self.view.snp.leading).offset(15)
            $0.trailing.equalTo(self.view.snp.trailing).offset(-15)
            $0.height.equalTo(30)
        }

        jwtQRScanButton.snp.makeConstraints {
            $0.top.equalTo(jwtGenerateButton.snp.bottom).offset(10)
            $0.leading.equalTo(self.view.snp.leading).offset(15)
            $0.trailing.equalTo(self.view.snp.trailing).offset(-15)
            $0.height.equalTo(30)
            $0.bottom.lessThanOrEqualTo(self.view.snp.bottom)
        }
    }
}

// MARK: - setup / reset
extension UserInfoViewController {
    
    private func updateTextField(data: UserInfoViewLoadData) {
        userIdInputField.text = data.user?.userId ?? ""
        userNameInputField.text = data.user?.userName ?? ""
        ageInputField.text = data.user?.age != nil ? String(data.user?.age ?? 0) : ""
        userScoreInputField.text = data.user?.userScore != nil ? String(data.user?.userScore ?? 0) : ""
        jwtInputField.text = data.jwt ?? ""
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

        self.navigationItem.rightBarButtonItems = [delete]
    }
    
    func removeTapGesture() {
        guard let gestureRecognizers = self.view.gestureRecognizers,
                gestureRecognizers.contains(where: {$0 == tapGesture}) else { return }

        self.view.removeGestureRecognizer(tapGesture!)
    }
    
}

// MARK: - ShopLiveRadioButtonDelegate
extension UserInfoViewController: ShopLiveRadioOptionButtonDelegate {

    func updateGender(identifier: String) {
        viewModel.radioGroup.forEach { radio in
            radio.updateRadio(selected: radio.identifier == identifier)
        }
    }

    func didSelectRadioButton(_ sender: ShopLiveRadioOptionButton) {
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

// MARK: - Objc func
extension UserInfoViewController {
    
    @objc func deleteAct() {
        let alert = UIAlertController(title: "userinfo.msg.deleteAll.title".localized(), message: nil, preferredStyle: .alert)
        alert.addAction(.init(title: "alert.msg.no".localized(), style: .cancel, handler: { action in

        }))
        alert.addAction(.init(title: "alert.msg.ok".localized(), style: .default, handler: { action in
            self.viewModel.allRemoveData()
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func handleNaviBack() {
        shopliveHideKeyboard_SL()
        self.navigationController?.popViewController(animated: true)
    }

    @objc func tokenGenerateSaveAct() {
        ShopLiveCommon.setAuthToken(authToken: jwtInputField.text ?? "")
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


// MARK: - QR Reader Delegate
extension UserInfoViewController: QRKeyReaderDelegate {
    func updateKeyFromQR(keyset: ShopLiveKeySet?) { }
    
    func updateUserJWTFromQR(userJWT: String?) {
        jwtInputField.text = userJWT
        viewModel.updateJwt(text: userJWT ?? "")
    }
    
    
}
