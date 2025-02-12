//
//  SideMenuViewModel.swift
//  PlayerDemo2
//
//  Created by sangmin han on 2/11/25.
//  Copyright © 2025 com.app. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import ShopliveSDKCommon


//case SideMenuTypes.removeCache.identifier:
//    UserDefaults.standard.removeObject(forKey: "shoplivedata")
//    UserDefaults.standard.synchronize()
//    UIWindow.showToast(message: "menu.msg.removeCache".localized())


final class SideMenuViewModel : NSObject,ViewModelType {
    enum Route {
        case option
        case coupon
    }
    
    struct Input {
        let routeTo : Observable<Route>
        let exitPlayer : Observable<Void>
        let removeWebViewStorage : Observable<Void>
    }
    
    struct Output {
        let appVersion : Observable<String>
        let sdkVersion : Observable<String>
    }
    

    var disposeBag: DisposeBag = .init()
    var routing : SideMenuRouting?
    
    
    init(routing : SideMenuRouting) {
        self.routing = routing
    }

   
    func transform(input: Input) -> Output {
        let appVersionSubject = BehaviorSubject<String>(value: "App Version : \(getAppVersion())")
        let sdkVersionSubject = BehaviorSubject<String>(value: "SDK Version : \(getSDKVersion())")
        
        
        input.routeTo
            .withUnretained(self)
            .subscribe(onNext : { owner, route in
                switch route {
                case .coupon:
                    owner.routing?.showCouponRespondSettingViewController()
                case .option:
                    owner.routing?.showOptionSettingViewController()
                }
            })
            .disposed(by: disposeBag)
        
        input.exitPlayer
            .withUnretained(self)
            .subscribe(onNext : { owner, _ in
                
            })
            .disposed(by: disposeBag)
        
        input.removeWebViewStorage
            .withUnretained(self)
            .subscribe(onNext : { owner, _ in
                
            })
            .disposed(by: disposeBag)
        
        
        return .init(
            appVersion: appVersionSubject.asObservable(),
            sdkVersion: sdkVersionSubject.asObservable()
        )
    }
    
    
    private func getAppVersion() -> String {
        let buildVersion: String? = Bundle.main.object(forInfoDictionaryKey: kCFBundleVersionKey as String) as? String
        let bundleVersion: String? = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
        
        var appVersion: String = ""
        if let version = bundleVersion {
            appVersion = version + (buildVersion != nil ? " (\(buildVersion ?? "x"))" : "")
        }
        return appVersion
    }
    
    private func getSDKVersion() -> String {
        return ShopLiveCommon.playerSdkVersion
    }
}
