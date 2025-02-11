//
//  CustomParamterViewModel.swift
//  PlayerDemo2
//
//  Created by sangmin han on 2/6/25.
//  Copyright © 2025 com.app. All rights reserved.
//

import Foundation
import UIKit
import RxSwift





final class CustomParameterSettingViewModel :  NSObject, ViewModelType {
    
    struct Input {
        let registerTableView : PublishSubject<UITableView>
        let save : PublishSubject<Void>
        let addItem : PublishSubject<Void>
        
    }
    
    struct Output {
        let reloadTableView : PublishSubject<Void>
    }
    
    
    private var dataList : [CustomParameter] = []
    var disposeBag: DisposeBag = .init()
    
    private let tableViewAdapter = CustomParameterSettingTableViewAdapter()
    private let useCase : CustomParameterSettingUseCase
    var routing : CustomParameterSettingRouting?
    
    
    //subjects
    private let reloadTableViewSubject = PublishSubject<Void>()
    
    init(useCase: CustomParameterSettingUseCase,
         routing : CustomParameterSettingRouting) {
        self.useCase = useCase
        super.init()
        self.routing = routing
        loadCustomParamter()
        setTableViewAdapter()
    }
    
    private func loadCustomParamter() {
        self.dataList = useCase.getCustomParameters()
    }
    
    private func setTableViewAdapter() {
        tableViewAdapter.delegate = self
        tableViewAdapter.dataSource = self
    }
    
    func transform(input: Input) -> Output {
        
        input.registerTableView
            .withUnretained(self)
            .subscribe(onNext : { owner, tableView in
                owner.tableViewAdapter.registerTableView(tableView: tableView)
            })
            .disposed(by: disposeBag)
        
        input.save
            .withUnretained(self)
            .subscribe(onNext : { owner, _ in
                owner.useCase.saveCustomParameters(customParamter: owner.dataList)
            })
            .disposed(by: disposeBag)
        
        
        input.addItem
            .withUnretained(self)
            .subscribe(onNext : { owner, _ in
                var newId : Int = 0
                if let lastId = owner.dataList.map({ $0.customParameterId }).max()  {
                    newId = lastId + 1
                }
                let newCustomParameter = CustomParameter(customParameterId: newId, paramKey: "", paramValue: "",isUseParam: false)
                owner.dataList.append(newCustomParameter)
                owner.reloadTableViewSubject.onNext(())
            })
            .disposed(by: disposeBag)
        
        
        return .init(reloadTableView: reloadTableViewSubject)
    }
}
extension CustomParameterSettingViewModel : CustomParameterSettingTableViewAdapterDataSource, CustomParameterSettingTableViewAdapterDelegate {
    
    var numberOfItem: Int {
        return dataList.count
    }
    
    func data(at indexPath: IndexPath) -> CustomParameter {
        return dataList[indexPath.row]
    }
    
    func customParameterValueChanged(at customParameterId: Int, key: String, value: String, isUse: Bool) {
        guard let targetIndex = dataList.firstIndex(where: { $0.customParameterId == customParameterId }) else { return }
        let newCustomParameter = CustomParameter(customParameterId : customParameterId, paramKey: key, paramValue: value, isUseParam: isUse)
        dataList.remove(at: targetIndex)
        dataList.insert(newCustomParameter, at: targetIndex)
    }
    
    func removeCustomParamter(at customParamterId: Int) {
        dataList.removeAll(where: { $0.customParameterId == customParamterId })
    }
}
