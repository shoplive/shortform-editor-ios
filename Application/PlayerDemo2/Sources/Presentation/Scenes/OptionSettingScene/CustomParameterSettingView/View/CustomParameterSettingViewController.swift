//
//  SettingCustomParameterViewController.swift
//  PlayerDemo2
//
//  Created by Tabber on 1/20/25.
//  Copyright © 2025 com.app. All rights reserved.
//


import UIKit
import RxCocoa
import RxSwift
import SnapKit

class CustomParameterSettingViewController: UIViewController {
   
    lazy private var backButton : UIBarButtonItem = {
        let button = UIBarButtonItem(image: PlayerDemo2Asset.back.image, style: .plain, target: self, action: nil)
        button.tintColor = .white
        return button
    }()
    
    lazy private var addParameterBarButtonItem : UIBarButtonItem = {
        let button = UIBarButtonItem(title: PlayerDemo2Strings.Sdk.Menu.add, style: .plain, target: self, action: #selector(addParameterButtonTapped))
        button.tintColor = .white
        return button
    }()
    
    private lazy var tableView: UITableView = {
        let view = UITableView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        view.rowHeight = 60
        view.separatorStyle = .singleLine
        view.isUserInteractionEnabled = true
        return view
    }()
    
    
    private var viewModel : CustomParameterSettingViewModel
    private let reloadTableViewSubject = PublishSubject<UITableView>()
    private let addItemSubject = PublishSubject<Void>()
    private var disposeBag = DisposeBag()
    
    required init(viewModel: CustomParameterSettingViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        bindViewModel()
        reloadTableViewSubject.onNext(tableView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
   
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.setUpNavigationItems()
        self.setLayout()
        tableView.reloadData()
    }
    
    //rightBarButton.rx.tap이 안됨....
    @objc private func addParameterButtonTapped() {
        addItemSubject.onNext(())
    }
    
    private func bindViewModel() {
        //stream
        let saveSubject = PublishSubject<Void>()
       
        
        //action
        backButton.rx.tap
            .withUnretained(self)
            .subscribe(onNext : { owner, _ in
                saveSubject.onNext(())
                owner.navigationController?.popViewController(animated: true)
            })
            .disposed(by: disposeBag)
        
        //input
        let output = viewModel.transform(input: .init(registerTableView: reloadTableViewSubject,
                                                      save: saveSubject,
                                                      addItem: addItemSubject))
        
        //output
        output.reloadTableView
            .observe(on: MainScheduler.instance)
            .withUnretained(self)
            .subscribe(onNext : { owner, _ in
                owner.tableView.reloadData()
            })
            .disposed(by: disposeBag)
    }
    
}
extension CustomParameterSettingViewController {
    func setUpNavigationItems() {
        self.title = PlayerDemo2Strings.Sdk.Page.AddParam.title
        self.navigationItem.leftBarButtonItem = backButton
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = nil
        self.navigationItem.rightBarButtonItems = [addParameterBarButtonItem]
    }
    
    private func setLayout() {
        self.view.addSubview(tableView)
        
        tableView.snp.makeConstraints {
            $0.top.equalTo(self.view.safeAreaLayoutGuide)
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
    }
}
