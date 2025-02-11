//
//  UserInfoContainerViewModel.swift
//  PlayerDemo2
//
//  Created by Tabber on 2/7/25.
//  Copyright © 2025 com.app. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import ShopLiveSDK
import ShopliveSDKCommon

class UserInfoContainerViewModel: ViewModelType {
    
    struct Input {
        let updatedData: PublishSubject<UserInfoViewLoadData>
        let userInfoBtnTap: ControlEvent<Void>
    }
    
    struct Output {
        let showUserInfoViewController: Observable<Void>
        let updateData: Observable<UserMode>
        
        let updateUI: Observable<UserInfoViewLoadData>
        let isInitUI: Observable<UserMode>
    }
    
    private var updateUISubject = PublishSubject<UserInfoViewLoadData>()
    private var isInitSubject = PublishSubject<UserMode>()
    private var updatedUserModeSubject = PublishSubject<UserMode>()
    
    private var user: ShopLiveCommonUser = .init(userId: "")
    private var jwtToken: String = ""
    private var isInit: Bool = true
    
    var userMode: UserMode = .Guest
    var jwtText: String { return jwtToken }
    var userDescription: String { return getUserDescripition() }
    
    var disposeBag: DisposeBag = DisposeBag()
    
    func transform(input: Input) -> Output {
        
        input.updatedData
            .withUnretained(self)
            .subscribe(onNext: { owner, data in
                owner.user = data.user ?? .init(userId: "")
                owner.jwtToken = data.jwt ?? ""
                owner.userMode = data.userMode
                
                if owner.isInit {
                    owner.isInit = false
                    owner.isInitSubject.onNext(data.userMode)
                }
                
                owner.updateUISubject.onNext(data)
            })
            .disposed(by: disposeBag)
        
        let buttonTap = input.userInfoBtnTap.asObservable()
        
        return Output(showUserInfoViewController: buttonTap,
                      updateData: updatedUserModeSubject,
                      updateUI: updateUISubject,
                      isInitUI: isInitSubject)
    }
    
}

// MARK: - Change / Update Data
extension UserInfoContainerViewModel {
    private func getUserDescripition() -> String {
        let id = user.userId
        let name = user.userName ?? ""
        let gender = user.gender?.rawValue ?? ""
        let age = user.age
        let score = user.userScore

        if (id.isEmpty && name.isEmpty && !(gender == "m" || gender == "f") && age == nil && score == nil) {
            return "base.section.userinfo.none.title".localized()
        }

        var description: String = "userId: \(id)\n"
        description += "userName: \(user.userName ?? "userName: ")\n"
        description += "age: \(user.age ?? 0)\n"
        description += "userScore: \(user.userScore ?? 0)\n"

        var userGender: String = "userinfo.gender.none".localized()

        if let gender = user.gender {
            switch gender {
            case .male:
                userGender = "userinfo.gender.male".localized()
                break
            case .female:
                userGender = "userinfo.gender.female".localized()
                break
            default:
                break
            }
        }

        description += "gender: \(userGender)"

        return description
    }
    
    func updateMode(_ mode: UserMode) {
        self.updatedUserModeSubject.onNext(mode)
    }
}
