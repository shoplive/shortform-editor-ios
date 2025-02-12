//
//  ShopLiveRadioOptionContainer.swift
//  PlayerDemo2
//
//  Created by Tabber on 2/10/25.
//  Copyright © 2025 com.app. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

final class ShopLiveRadioOptionContainer: UIView {
    
    // 외부 발신용 Observable
    var buttonTapObserbvable: Observable<ShopLiveButtonType> {
        return buttonTapSubject.asObservable()
    }
    
    // 외부 수신용 Observable
    var buttonReceiveObservable: PublishSubject<ShopLiveButtonReceiveModel>?
    
    private var buttons: [ShopLiveButtonType]
    private var font: UIFont
    private var stackView = UIStackView()
    private var axis: NSLayoutConstraint.Axis
    private var buttonTapSubject = PublishSubject<ShopLiveButtonType>()
    
    private var buttonMap: [ShopLiveButtonType: ShopLiveRadioOptionCustomButton] = [:] // 버튼 참조 저장
    
    private var disposeBag = DisposeBag()
    
    init(axis: NSLayoutConstraint.Axis = .horizontal,
         buttons: [ShopLiveButtonType],
         font: UIFont = .systemFont(ofSize: 12, weight: .medium)) {
        self.axis = axis
        self.buttons = buttons
        self.font = font
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureContainer(receive: PublishSubject<ShopLiveButtonReceiveModel>?) {
        self.buttonReceiveObservable = receive
        setLayout()
        bind()
    }
    
    private func bind() {
        buttonReceiveObservable?
            .withUnretained(self)
            .subscribe(onNext: { owner, value in
                owner.updateButtonSelection(id: value.type, isSelected: value.isSelected)
                owner.updateButtonSelection(type: value.type)
        })
        .disposed(by: disposeBag)
    }
    
    private func setLayout() {
        stackView.axis = axis
        
        buttons.forEach { value in
            let button = ShopLiveRadioOptionCustomButton(id: value)
            button.setImage(PlayerDemo2Asset.radioNotSelected.image, for: .normal)
            button.setImage(PlayerDemo2Asset.radioSelected.image, for: .selected)
            button.setTitle(value.description ?? "", for: .selected)
            button.setTitle(value.description ?? "", for: .normal)
            button.setTitleColor(.black, for: .normal)
            button.setTitleColor(.black, for: .selected)
            button.setInsets(forContentPadding: .init(top: 0, left: 10, bottom: 0, right: 0), imageTitlePadding: 10)
            
            button.titleLabel?.numberOfLines = 1
            button.titleLabel?.adjustsFontSizeToFitWidth = true
            button.titleLabel?.minimumScaleFactor = 0.5
            button.translatesAutoresizingMaskIntoConstraints = false
            // 버튼 참조 저장
            buttonMap[value] = button
            
            button.rx.tap
                .map({ value })
                .bind(to: buttonTapSubject)
                .disposed(by: disposeBag)
            
            stackView.addArrangedSubview(button)
        }
        
        self.addSubview(stackView)
        
        stackView.spacing = 8
        stackView.alignment = .leading
        
        stackView.snp.makeConstraints {
            $0.top.equalTo(self.snp.top)
            $0.leading.equalTo(self.snp.leading)
            $0.trailing.equalTo(self.snp.trailing)
            $0.bottom.equalTo(self.snp.bottom)
        }
    }
    
    private func updateButtonSelection(type: ShopLiveButtonType) {
        buttonMap.values.forEach { btn in
            btn.isSelected = (btn.id == type)
        }
    }
    
    // 외부에서 특정 버튼의 선택 상태를 변경할 수 있는 메서드
    func updateButtonSelection(id: ShopLiveButtonType, isSelected: Bool) {
        buttonMap[id]?.isSelected = isSelected
    }
    
    // 모든 버튼의 현재 선택 상태를 반환
    func getCurrentSelections() -> [ShopLiveButtonType: Bool] {
        return buttonMap.mapValues { $0.isSelected }
    }
}

