//
//  UserInfoViewModel.swift
//  PlayerDemo2
//
//  Created by Tabber on 1/21/25.
//  Copyright © 2025 com.app. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import ShopLiveSDK
import ShopliveSDKCommon

class UserInfoViewModel: NSObject, ViewModelType {
    
    struct Input {
        let viewDidLoad: Observable<Void>
        let userIdInputFieldChangeEvent: ControlProperty<String?>
        let userNameInputFieldChangeEvent: ControlProperty<String?>
        let userAgeInputFieldChangeEvent: ControlProperty<String?>
        let userScoreInputFieldChangeEvent: ControlProperty<String?>
        let jwtTokenChangeEvent: ControlProperty<String?>
        let saveButtonTap: ControlEvent<Void>
        let addParameterButtonTap: ControlEvent<Void>
    }
    
    struct Output {
        let userDataUpdated: PublishSubject<UserInfoViewLoadData>
        let userParameter: Driver<[UserInfoParameter]>
        let paramterAdded: Driver<Void>
        let userDataSaved: Driver<Void>
    }
    
    private var userDataUpdated = PublishSubject<UserInfoViewLoadData>()
    private var user = ShopLiveCommonUser(userId: "")
    
    private(set) var jwtToken: String = ""
    private(set) var parameters = BehaviorSubject<[UserInfoParameter]>(value: [])
    
    private var sendParameters: [String : Any] {
        do {
            let data = try parameters.value()
            let dic: [String : Any] = Dictionary(data.map { ($0.key , $0.value)}, uniquingKeysWith: { (first, last) in last })
            return dic
        } catch {
            return [:]
        }
    }
    
    var secretKeyButtonTitle: String {
        guard let key = DemoSecretKeyTool.shared.currentKey()?.key, !key.isEmpty else {
            return "userinfo.button.chooseSecret.input.title".localized()
        }
        
        return "userinfo.button.chooseSecret.change.title".localized()
    }
    
    private(set) var radioGroup: [ShopLiveRadioOptionButton] = []
    
    private var useCase: UserInfoUseCase
    
    var disposeBag: DisposeBag = DisposeBag()
    
    private let tableViewAdapter: UserInfoTableViewAdpater = UserInfoTableViewAdpater()
    
    init(userInfoUseCase: UserInfoUseCase) {
        self.useCase = userInfoUseCase
        super.init()
        tableViewAdapter.delegate = self
        tableViewAdapter.dataSource = self
    }
    
    func registerTableView(tableView: UITableView) {
        tableViewAdapter.registerTableView(tableView: tableView)
    }
    
    func transform(input: Input) -> Output {

        input.viewDidLoad
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                let (user, token) = self.useCase.loadUserData()
                
                // TextField 세팅
                self.userDataUpdated.onNext(.init(user: user, jwt: token, userMode: .Common))
                
                // 성별 세팅
                self.radioGroup = self.radioGroup.map { data in
                    let updatedData = data
                    
                    if data.identifier == user?.gender?.rawValue {
                        updatedData.radioButton.isSelected = true
                    } else {
                        updatedData.radioButton.isSelected = false
                    }
                    
                    return updatedData
                }
                
                let parameters: [UserInfoParameter] = user?.custom?.map { UserInfoParameter(key: $0.key, value: ($0.value as? String) ?? "") } ?? []
                
                self.parameters.onNext(parameters)
                self.user = user ?? .init(userId: "")
                self.jwtToken = token ?? ""
            })
            .disposed(by: disposeBag)
        
        Observable.combineLatest(
            input.userIdInputFieldChangeEvent,
            input.userNameInputFieldChangeEvent,
            input.userAgeInputFieldChangeEvent,
            input.userScoreInputFieldChangeEvent
        )
        .subscribe(onNext: { [weak self] id, name, age, score in
            self?.updateUser(id: id, name: name, age: age, score: score)
        })
        .disposed(by: disposeBag)
        
        input.jwtTokenChangeEvent
            .subscribe(onNext: { [weak self] value in
                guard let self = self else { return }
                self.jwtToken = value ?? ""
            })
            .disposed(by: disposeBag)
        
        let userDataSaved = input.saveButtonTap
            .do(onNext: { [weak self] _ in
                if self?.user.userId != "" {
                    self?.user.gender = ShopliveCommonUserGender(rawValue: self?.radioGroup.first(where: { $0.isSelected })?.identifier ?? "")
                    self?.user.custom = self?.sendParameters
                    self?.useCase.fetchUserData(user: self?.user, userToken: self?.jwtToken)
                }
            })
            .asDriver(onErrorJustReturn: ())
        
        let itemAdded = input.addParameterButtonTap
            .do(onNext: { [weak self] _ in
                var currentItems = try self?.parameters.value()
                currentItems?.append(.init(key: "", value: ""))
                self?.parameters.onNext(currentItems ?? [])
            })
            .asDriver(onErrorJustReturn: ())
        
        
        return .init(
            userDataUpdated: userDataUpdated.asObserver(),
            userParameter: parameters.asDriver(onErrorJustReturn: []),
                     paramterAdded: itemAdded,
                     userDataSaved: userDataSaved)
    }
    
    private func updateUser(id: String?, name: String?, age: String?, score: String?) {

        if id != user.userId {
            user.userId = id ?? ""
        }
        
        if name != user.userName {
            user.userName = name
        }
        
        if Int(age ?? "") != user.age {
            user.age = Int(age ?? "")
        }
        
        if Int(score ?? "") != user.userScore {
            user.userScore = Int(score ?? "")
        }
        
    }
    
    func setRadioGroup(_ data: [ShopLiveRadioOptionButton]) {
        radioGroup = data
    }
    
    func deleteDatas(_ indexPath: Int) {
        do {
            var updatedValue = try parameters.value()
            updatedValue.remove(at: indexPath)
            parameters.onNext(updatedValue)
        } catch {
            print("DeleteDatas Error")
        }
    }
    
    func appendData() {
        do {
            var updatedValue = try parameters.value()
            updatedValue.append(.init(key: "", value: ""))
            parameters.onNext(updatedValue)
        } catch {
            print("appendData Error")
        }
    }
    
    
    func updateJwt(text: String) {
        self.jwtToken = text
    }
    
    func allRemoveData() {
        user = .init(userId: "")
        jwtToken = ""
        parameters.onNext([])
        userDataUpdated.onNext(.init(user: nil, jwt: nil, userMode: .Common))
        
        useCase.fetchUserData(user: .init(userId: ""), userToken: "")
    }
}

extension UserInfoViewModel: UserInfoTableViewAdapterDelegate, UserInfoTableViewAdapterDataSource {
    
    func appendKey(text: String) {
        do {
            var updatedValue = try parameters.value()
            updatedValue[updatedValue.firstIndex(where: { $0.key == "" }) ?? updatedValue.endIndex - 1].key = text
            parameters.onNext(updatedValue)
        } catch {
            print("appendKey Error")
        }
    }
    
    func appendValue(text: String) {
        do {
            var updatedValue = try parameters.value()
            updatedValue[updatedValue.firstIndex(where: { $0.value == "" }) ?? updatedValue.endIndex - 1].value = text
            parameters.onNext(updatedValue)
        } catch {
            print("appendValue Error")
        }
    }
    
    
    func removeAction(indexPath: IndexPath) {
        deleteDatas(indexPath.row)
    }
    
    func numberOfItems(at section: Int) -> Int {
        do {
            let count = try parameters.value().count
            return count
        } catch {
            print("error")
        }
        
        return 0
    }
    
    func data(at indexPath: IndexPath) -> UserInfoParameter {
        do {
            let value = try parameters.value()
            let item = value[indexPath.row]
            
            return item
        } catch {
            print("Error")
        }
        
        return .init(key: "", value: "")
    }
    
    
}
