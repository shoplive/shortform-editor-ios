//
//  PIPFloatingOffsetViewController.swift
//  PlayerDemo2
//
//  Created by sangmin han on 2/5/25.
//  Copyright © 2025 com.app. All rights reserved.
//

import Foundation
import UIKit
import RxCocoa
import RxSwift




final class PIPFloatingOffsetViewController : UIViewController {
    
    private lazy var saveButton : UIBarButtonItem = {
        let btn =  UIBarButtonItem(title: PlayerDemo2Strings.Sdk.User.save,
                                   style: .plain, target: self, action: nil)
        btn.tintColor = .white
        return btn
    }()
    
    
    private lazy var paddingTitle: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.numberOfLines = 1
        view.font = .systemFont(ofSize: 15, weight: .bold)
        view.textColor = .black
        view.text = "Padding"
        return view
    }()
    
    private lazy var paddingTopInput: UITextField = {
        let view = UITextField()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.textColor = .black
        view.placeholder = "top"
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.lightGray.cgColor
        view.layer.cornerRadius = 6
        view.textColor = .black
        view.setPlaceholderColor(.darkGray)
        return view
    }()
    
    private lazy var paddingLeftInput: UITextField = {
        let view = UITextField()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.textColor = .black
        view.placeholder = "left"
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.lightGray.cgColor
        view.layer.cornerRadius = 6
        view.setPlaceholderColor(.darkGray)
        return view
    }()
    
    private lazy var paddingRightInput: UITextField = {
        let view = UITextField()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.textColor = .black
        view.placeholder = "right"
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.lightGray.cgColor
        view.layer.cornerRadius = 6
        view.setPlaceholderColor(.darkGray)
        return view
    }()
    
    private lazy var paddingBottomInput: UITextField = {
        let view = UITextField()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.textColor = .black
        view.placeholder = "bottom"
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.lightGray.cgColor
        view.layer.cornerRadius = 6
        view.setPlaceholderColor(.darkGray)
        return view
    }()
    
    private lazy var marginTitle: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.numberOfLines = 1
        view.font = .systemFont(ofSize: 15, weight: .bold)
        view.textColor = .black
        view.text = "FloatingOffset"
        return view
    }()
    
    private lazy var marginTopInput: UITextField = {
        let view = UITextField()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.textColor = .black
        view.placeholder = "top"
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.lightGray.cgColor
        view.layer.cornerRadius = 6
        view.setPlaceholderColor(.darkGray)
        return view
    }()
    
    private lazy var marginBottomInput: UITextField = {
        let view = UITextField()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.textColor = .black
        view.placeholder = "bottom"
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.lightGray.cgColor
        view.layer.cornerRadius = 6
        view.setPlaceholderColor(.darkGray)
        return view
    }()
    
    private lazy var marginLeftInput: UITextField = {
        let view = UITextField()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.textColor = .black
        view.placeholder = "left"
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.lightGray.cgColor
        view.layer.cornerRadius = 6
        view.setPlaceholderColor(.darkGray)
        return view
    }()
    
    private lazy var marginRightInput: UITextField = {
        let view = UITextField()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.textColor = .black
        view.placeholder = "right"
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.lightGray.cgColor
        view.layer.cornerRadius = 6
        view.setPlaceholderColor(.darkGray)
        return view
    }()
    
    
    private lazy var resetButton: UIButton = {
        let view = UIButton()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setTitle("초기화", for: .normal)
        view.backgroundColor = .lightGray
        return view
    }()
    
    private let viewModel : PIPFloatingOffsetViewModel
    private let viewDidLoadSubject = PublishSubject<Void>()
    
    private var disposeBag = DisposeBag()
    
    required init(viewModel : PIPFloatingOffsetViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        bindViewModel()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationItems()
        setLayout()
        viewDidLoadSubject.onNext(())
    }
    
    deinit {
        print("\(Self.className) deinit")
    }
     
    private func bindViewModel() {
        
        let paddingSubject : PublishSubject<PIPFloatingOffsetViewModel.StringEdgeInset> = .init()
        let floatingOffsetSubject : PublishSubject<PIPFloatingOffsetViewModel.StringEdgeInset> = .init()
        let resetSubject = PublishSubject<Void>()
        //action
        saveButton.rx.tap
            .withUnretained(self)
            .subscribe { owner,_ in
                paddingSubject.onNext(.init(top: owner.paddingTopInput.text ?? "20",
                                            left: owner.paddingLeftInput.text ?? "20",
                                            right: owner.paddingRightInput.text ?? "20",
                                            bottom: owner.paddingBottomInput.text ?? "20"))
                
                floatingOffsetSubject.onNext(.init(top: owner.marginTopInput.text ?? "20",
                                                   left: owner.marginLeftInput.text ?? "20",
                                                   right: owner.marginRightInput.text ?? "20",
                                                   bottom: owner.marginBottomInput.text ?? "20"))
                
            }
            .disposed(by: disposeBag)
            
           
        
        
        resetButton.rx.tap
            .bind(to: resetSubject)
            .disposed(by: disposeBag)
        
        
        
        
        // input output
        let output = viewModel.transform(input: .init(viewDidLoad: viewDidLoadSubject,
                                                      padding: paddingSubject,
                                                      floatingOffset: floatingOffsetSubject,
                                                      resetValue: resetSubject))
        
        output.floatingOffset
            .observe(on: MainScheduler.instance)
            .withUnretained(self)
            .subscribe(onNext : { owner, floatingOffsetValue in
                owner.marginTopInput.text = floatingOffsetValue.top
                owner.marginLeftInput.text = floatingOffsetValue.left
                owner.marginRightInput.text = floatingOffsetValue.right
                owner.marginBottomInput.text = floatingOffsetValue.bottom
            })
            .disposed(by: disposeBag)
        
        output.padding
            .observe(on: MainScheduler.instance)
            .withUnretained(self)
            .subscribe(onNext : { owner, paddingValue in
                owner.paddingTopInput.text = paddingValue.top
                owner.paddingLeftInput.text = paddingValue.left
                owner.paddingRightInput.text = paddingValue.right
                owner.paddingBottomInput.text = paddingValue.bottom
            })
            .disposed(by: disposeBag)
    }
}
//MARK: - layout
extension PIPFloatingOffsetViewController {
    private func setNavigationItems() {
        self.title = PlayerDemo2Strings.Sdkoption.PipFloatingOffset.title
        self.navigationItem.rightBarButtonItem = saveButton
    }
    
    private func setLayout() {
        self.view.backgroundColor = .white
        self.view.addSubview(paddingTitle)
        self.view.addSubview(paddingTopInput)
        self.view.addSubview(paddingLeftInput)
        self.view.addSubview(paddingRightInput)
        self.view.addSubview(paddingBottomInput)
        self.view.addSubview(marginTitle)
        self.view.addSubview(marginTopInput)
        self.view.addSubview(marginBottomInput)
        self.view.addSubview(marginLeftInput)
        self.view.addSubview(marginRightInput)
        self.view.addSubview(resetButton)
        
        
        paddingTitle.snp.makeConstraints {
            $0.top.equalTo(self.view.safeAreaLayoutGuide).offset(20)
            $0.leading.equalTo(self.view).offset(20)
            $0.trailing.equalTo(self.view).offset(-20)
            $0.height.equalTo(20)
        }

        paddingTopInput.snp.makeConstraints {
            $0.top.equalTo(paddingTitle.snp.bottom).offset(20)
            $0.centerX.equalTo(self.view)
            $0.width.equalTo(120)
            $0.height.equalTo(30)
        }

        paddingLeftInput.snp.makeConstraints {
            $0.top.equalTo(paddingTopInput.snp.bottom).offset(20)
            $0.leading.equalTo(self.view).offset(20)
            $0.width.equalTo(120)
            $0.height.equalTo(30)
        }

        paddingRightInput.snp.makeConstraints {
            $0.top.equalTo(paddingTopInput.snp.bottom).offset(20)
            $0.trailing.equalTo(self.view).offset(-20)
            $0.width.equalTo(120)
            $0.height.equalTo(30)
        }

        paddingBottomInput.snp.makeConstraints {
            $0.top.equalTo(paddingLeftInput.snp.bottom).offset(20)
            $0.centerX.equalTo(self.view)
            $0.width.equalTo(120)
            $0.height.equalTo(30)
        }

        marginTitle.snp.makeConstraints {
            $0.top.equalTo(paddingBottomInput.snp.bottom).offset(20)
            $0.leading.equalTo(self.view).offset(20)
            $0.trailing.equalTo(self.view).offset(-20)
            $0.height.equalTo(20)
        }

        marginTopInput.snp.makeConstraints {
            $0.top.equalTo(marginTitle.snp.bottom).offset(20)
            $0.centerX.equalTo(self.view)
            $0.width.equalTo(120)
            $0.height.equalTo(30)
        }

        marginLeftInput.snp.makeConstraints {
            $0.top.equalTo(marginTopInput.snp.bottom).offset(20)
            $0.leading.equalTo(self.view).offset(20)
            $0.width.equalTo(120)
            $0.height.equalTo(30)
        }

        marginRightInput.snp.makeConstraints {
            $0.top.equalTo(marginTopInput.snp.bottom).offset(20)
            $0.trailing.equalTo(self.view).offset(-20)
            $0.width.equalTo(120)
            $0.height.equalTo(30)
        }

        marginBottomInput.snp.makeConstraints {
            $0.top.equalTo(marginRightInput.snp.bottom).offset(20)
            $0.centerX.equalTo(self.view)
            $0.width.equalTo(120)
            $0.height.equalTo(30)
        }

        resetButton.snp.makeConstraints {
            $0.top.equalTo(marginBottomInput.snp.bottom).offset(20)
            $0.centerX.equalTo(self.view)
            $0.width.equalTo(120)
            $0.height.equalTo(34)
        }
        
    }
}
