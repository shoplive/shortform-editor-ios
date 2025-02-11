//
//  MainViewModel.swift
//  PlayerDemo2
//
//  Created by Tabber on 1/17/25.
//  Copyright © 2025 com.app. All rights reserved.
//

import Foundation
import ShopliveSDKCommon
import RxSwift

class MainViewModel: ViewModelType {
    
    struct Input {
        // 상위뷰 -> 하위뷰
        var viewDidLoad: PublishSubject<Void>
    }
    
    struct Output {
        // 상위뷰 -> 하위뷰
        var updatedData: PublishSubject<UserInfoViewLoadData>
        
        // 하위뷰 -> 상위뷰
        let showUserInfoViewController: PublishSubject<Void>
        let updatedUserMode: PublishSubject<UserMode>
    }
    
    private var showVCSubject = PublishSubject<Void>()
    private var updatedDataSubject = PublishSubject<UserInfoViewLoadData>()
    private var updatedUserMode = PublishSubject<UserMode>()
    
    var disposeBag: DisposeBag = DisposeBag()
    
    func transform(input: Input) -> Output {
        
        input.viewDidLoad
            .withUnretained(self)
            .subscribe(onNext: { owner, _ in
                let (user, jwt, mode) = owner.loadUserData()
                owner.updatedDataSubject.onNext(.init(user: user, jwt: jwt, userMode: mode ?? .Guest))
            })
            .disposed(by: disposeBag)
        
        showVCSubject
            .withUnretained(self)
            .subscribe(onNext: { owner, _ in
                owner.routing?.showUserInfo()
            })
            .disposed(by: disposeBag)
        
        updatedUserMode
            .withUnretained(self)
            .subscribe(onNext: { owner, data in
                owner.updateUserMode(userMode: data)
            })
            .disposed(by: disposeBag)
        
        return .init(updatedData: updatedDataSubject,
                     showUserInfoViewController: showVCSubject,
                     updatedUserMode: updatedUserMode)
    }
    
    private let useCase: MainUseCase
    private let routing: MainRouting?
    
    private(set) var keyset: ShopLiveKeySet?
    private(set) var items: [String] = ["UserInfoCell"]
    
    init(useCase: MainUseCase, actions: MainRouting? = nil) {
        self.useCase = useCase
        self.routing = actions
    }
    
    func controlItems(action: ItemAction, value: String, at: Int?) {
        switch action {
        case .insert:
            if let at {
                items.insert(value, at: at)
                return
            }
            
            items.append(value)
            break
        case .delete:
            if let at, items.count-1 >= at {
                items.remove(at: at)
                return
            }
        }
    }
    
    func getCurrentKeySet() -> ShopLiveKeySet? {
        if let keyset = keyset, !keyset.hasEmptyValue() {
            if let currentKeySet = loadCurrentCampaign() {
                if currentKeySet.isEqual(keyset) {
                    return currentKeySet
                } else {
                    saveCurrentCampaign(keySet: keyset)
                    return keyset
                }
            } else {
                return keyset
            }
        } else {
            if let currentKeySet = loadCurrentCampaign() {
                return currentKeySet
            } else {
                return nil
            }
        }
    }
    
    func updateNoti() -> Observable<Void> {
        useCase.updateNoti
    }
    
    func updateCurrentCampaign() -> Bool {
        
        let value = useCase.loadCurrentCampaign()
        if value?.alias != self.keyset?.alias || self.keyset == nil || value == nil {
            keyset = value
            return true
        }
        
        return false
    }
    
    func loadCurrentCampaign() -> ShopLiveKeySet? {
        let value = useCase.loadCurrentCampaign()
        return value
    }
    
    func updateSetKey(value: ShopLiveKeySet?) {
        self.keyset = value
    }
    
    func saveCurrentCampaign(keySet: ShopLiveKeySet) {        
        let allCampaigns = useCase.loadAllCampaigns()
        
        if let _ = allCampaigns?.shopLiveKetSets.firstIndex(where: { $0.alias == keySet.alias }) {
            useCase.updateCampaign(keySet: keySet)
        } else {
            useCase.saveCurrentCampaign(keySet: keySet)
        }
    }
    
    func updatedUserData() {
        let userData = loadUserData()
        updatedDataSubject.onNext(.init(user: userData.0 ?? .init(userId: ""), jwt: userData.1, userMode: userData.2 ?? .Guest))
    }
    
    func loadUserData() -> (ShopLiveCommonUser?, String?, UserMode?) {
        let data = useCase.loadUserInfo()
        return (data.0, data.1, useCase.loadUserMode())
    }
    
    func updateUserMode(userMode: UserMode) {
        useCase.fetchUserMode(userMode: userMode)
    }
    
    func showUserInfoViewController() {
        routing?.showUserInfo()
    }
    
    func showOptionSettingViewController() {
        routing?.showOptionSetting()
    }
    
    func showCampaignsViewController() {
        routing?.showCampaigns()
    }
}
