//
//  DevInfoContainerView.swift
//  PlayerDemo2
//
//  Created by Tabber on 2/10/25.
//  Copyright © 2025 com.app. All rights reserved.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

class DevInfoContainerView: UIView {
    
    struct Input {
        var setData: PublishSubject<SDKConfiguration>
        var radioButtonSender: PublishSubject<ShopLiveButtonReceiveModel>
        var boxButtonSender: PublishSubject<ShopLiveButtonReceiveModel>
    }
    
    struct Output {
        var checkBoxObservable: PublishSubject<ShopLiveButtonType>
        var radioOptionObservable: PublishSubject<ShopLiveButtonType>
        var urlTextObservable: PublishSubject<String>
    }
    
    var input: Input?
    var output: Output?
    
    var viewModel: DevInfoViewModel
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "[개발정보]"
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.textColor = .black
        
        return label
    }()
    
    lazy var landingUrlTextField: UITextField = {
        let view = UITextField()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.textColor = .black
        view.placeholder = "landing url"
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
    
    private lazy var checkBoxContainer = ShopLiveCheckBoxContainer(
        axis: .vertical,
        buttons: [
        .webDebug,
        .useLockPortrait
    ])

    private lazy var radioOptionContainer = ShopLiveRadioOptionContainer(
        axis: .vertical,
        buttons: [
            .DEV,
            .QA,
            .STAGE,
            .REAL,
            .CUSTOM
        ])
    
    private var disposeBag = DisposeBag()
     
    override init(frame: CGRect) {
        self.viewModel = .init()
        super.init(frame: frame)
        setLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configurationContainer(input: DevInfoContainerView.Input, output: DevInfoContainerView.Output) {
        self.input = input
        self.output = output
        
        bind()
        bindViewModel()
    }
    
    private func bind() {
        guard let output else { return }
        
        // 상위뷰 -> 하위 컨테이너 -> 버튼 상태값 변경을 위한 Configure
        checkBoxContainer.configureContainer(receive: input?.boxButtonSender)
        radioOptionContainer.configureContainer(receive: input?.radioButtonSender)
        
        // 버튼 -> 하위 컨테이너 -> 상위뷰
        checkBoxContainer.buttonTapObserbvable
            .bind(to: output.checkBoxObservable)
            .disposed(by: disposeBag)
        radioOptionContainer.buttonTapObserbvable
            .bind(to: output.radioOptionObservable)
            .disposed(by: disposeBag)
    }
    
    private func bindViewModel() {
        
        let input = DevInfoViewModel.Input(setData: self.input?.setData ?? .init())
        let output = viewModel.transform(input: input)
        
        output.checkBox
            .subscribe(onNext: { [weak self] box in
                self?.checkBoxContainer.updateButtonSelection(id: box, isSelected: true)
            })
            .disposed(by: disposeBag)

        output.radioOption
            .subscribe(onNext: { [weak self] radio in
                self?.radioOptionContainer.updateButtonSelection(id: radio, isSelected: true)
            })
            .disposed(by: disposeBag)
        
        output.urlText
            .subscribe(onNext: { [weak self] url in
                self?.landingUrlTextField.text = url
            })
            .disposed(by: disposeBag)
    }
    
    func checkBoxGetCurrentSelections() -> [ShopLiveButtonType : Bool] {
        return checkBoxContainer.getCurrentSelections()
    }
    
    func radioOptionGetCurrentSelections() -> [ShopLiveButtonType : Bool] {
        return radioOptionContainer.getCurrentSelections()
    }
}



// MARK: - set layout
extension DevInfoContainerView {
    private func setLayout() {
        self.addSubview(titleLabel)
        self.addSubview(checkBoxContainer)
        self.addSubview(radioOptionContainer)
        self.addSubview(landingUrlTextField)
        
        landingUrlTextField.delegate = self
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(self.snp.top).offset(15)
            $0.leading.equalTo(self.snp.leading).offset(15)
            $0.height.equalTo(22)
        }
        
        checkBoxContainer.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(10)
            $0.leading.equalTo(self.snp.leading).offset(10)
            $0.trailing.equalTo(self.snp.trailing).offset(-10)
        }
        
        radioOptionContainer.snp.makeConstraints {
            $0.top.equalTo(checkBoxContainer.snp.bottom).offset(30)
            $0.leading.equalTo(self.snp.leading).offset(10)
            $0.trailing.equalTo(self.snp.trailing).offset(-10)
        }
        
        landingUrlTextField.snp.makeConstraints {
            $0.top.equalTo(radioOptionContainer.snp.bottom).offset(10)
            $0.leading.equalTo(self.snp.leading).offset(10)
            $0.trailing.equalTo(self.snp.trailing).offset(-10)
            $0.height.equalTo(30)
            $0.bottom.equalTo(self.snp.bottom)
        }
    }
}

extension DevInfoContainerView: UITextFieldDelegate {
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
        
        //DemoConfiguration.shared.customLandingUrl = predictedText
        
        output?.urlTextObservable.onNext(predictedText)
        
        return true
    }
}
