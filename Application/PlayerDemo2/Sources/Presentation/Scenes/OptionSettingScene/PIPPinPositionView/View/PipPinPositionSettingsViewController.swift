//
//  PipPinSettingsViewController.swift
//  PlayerDemo2
//
//  Created by Tabber on 1/20/25.
//  Copyright © 2025 com.app. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import ShopLiveSDK
import ShopliveSDKCommon

class PipPinPositionSettingsViewController : UIViewController {
        
    private var stack : UIStackView?
    
    
    private let viewModel : PIPPinPositionViewModel
    
    private let viewDidAppearSubject : PublishSubject<Void> = .init()
    private var disposeBag = DisposeBag()
    
    required init(stack: UIStackView? = nil, viewModel: PIPPinPositionViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        setLayout()
        bindViewModel()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewDidAppearSubject.onNext(())
    }
    
    
    private func bindViewModel() {
        let pipPinsPositionsSubject = PublishSubject<Int>()
        
        guard let btns = (stack?.arrangedSubviews as? [UIStackView])?
            .compactMap({ $0.arrangedSubviews as? [UIButton] })
            .flatMap({ $0 }) else { return }
        
        
        let btnTapStreams = btns.map { btn in
            return btn.rx.tap.map{ btn.tag }
        }
        
        //actions
        Observable.merge(btnTapStreams)
            .bind(to: pipPinsPositionsSubject)
            .disposed(by: disposeBag)
        
        
        //input
        let output = viewModel.transform(input: .init(viewDidAppear: viewDidAppearSubject,
                                                      pipPinPosition: pipPinsPositionsSubject))
        
        //output
        output.pipPinPositions
            .observe(on: MainScheduler.instance)
            .withUnretained(self)
            .subscribe(onNext :{ owner,positions in
                btns.forEach { btn in
                    if positions.contains(where: { $0 == btn.tag }) {
                        btn.backgroundColor = .clear
                        btn.isSelected = false
                    }
                    else {
                        btn.backgroundColor = .lightGray
                        btn.isSelected = true
                    }
                }
            })
            .disposed(by: disposeBag)
        
    }
}

extension PipPinPositionSettingsViewController {
    
    private func setLayout() {
        let firstRow = UIStackView(arrangedSubviews: self.makeBtns(from: 1, to: 3))
        let secondRow = UIStackView(arrangedSubviews: self.makeBtns(from: 4, to: 6))
        let thirdRow = UIStackView(arrangedSubviews: self.makeBtns(from: 7, to: 9))
        
        firstRow.axis = .horizontal
        firstRow.distribution = .fillEqually
        firstRow.spacing = 10
        
        secondRow.axis = .horizontal
        secondRow.distribution = .fillEqually
        secondRow.spacing = 10
        
        thirdRow.axis = .horizontal
        thirdRow.distribution = .fillEqually
        thirdRow.spacing = 10
        
        let stack = UIStackView(arrangedSubviews: [firstRow,secondRow,thirdRow])
        stack.axis = .vertical
        stack.distribution = .fillEqually
        stack.spacing = 10
        stack.translatesAutoresizingMaskIntoConstraints = false
        self.stack = stack
        
        self.view.addSubview(stack)
        
        stack.snp.makeConstraints {
            $0.top.equalTo(self.view.safeAreaLayoutGuide)
            $0.leading.equalTo(self.view)
            $0.trailing.equalTo(self.view)
            $0.bottom.equalTo(self.view)
        }
    }
    
    private func makeBtns(from : Int, to : Int) -> [UIButton] {
        return (from...to).map { tag in
            let btn = UIButton()
            btn.translatesAutoresizingMaskIntoConstraints = false
            btn.isUserInteractionEnabled = true
            btn.setTitle(String(tag), for: .normal)
            btn.setTitleColor(.white, for: .selected)
            btn.setTitleColor(.lightGray, for: .normal)
            btn.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .bold)
            btn.tag = tag - 1
            btn.contentHorizontalAlignment = .center
            btn.contentVerticalAlignment = .center
            return btn
        }
    }
    
    
}

