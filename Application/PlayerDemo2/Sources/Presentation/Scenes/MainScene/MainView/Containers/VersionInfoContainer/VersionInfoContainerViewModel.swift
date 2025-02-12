//
//  VersionInfoContainerViewModel.swift
//  PlayerDemo2
//
//  Created by Tabber on 2/10/25.
//  Copyright © 2025 com.app. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import ShopliveSDKCommon


class VersionInfoContainerViewModel: ViewModelType {
    struct Input {
        let setData: PublishSubject<SDKConfiguration>
    }
    
    struct Output {
        let presentData: PublishSubject<SDKConfiguration>
    }
    
    var currentData: SDKConfiguration? = nil
    
    var disposeBag: DisposeBag = DisposeBag()
    
    func transform(input: Input) -> Output {
        
        let presentDataSubject = PublishSubject<SDKConfiguration>()
        
        input.setData
            .do(onNext: { [weak self] data in self?.currentData = data })
            .bind(to: presentDataSubject)
            .disposed(by: disposeBag)
        
        return .init(presentData: presentDataSubject)
    }
    
    func getCurrentData(_ type: VersionInfoButtonType) -> String {
        switch type {
            case .AppVersion: return currentData?.customerAppVersion ?? ""
            case .Referrer: return currentData?.referrer ?? ""
            case .AdId: return currentData?.adId ?? ""
            case .AnonId: return currentData?.anonId ?? ""
            case .UtmSource: return currentData?.utmSource ?? ""
            case .UtmContent: return currentData?.utmContent ?? ""
            case .UtmCampaign: return currentData?.utmCampaign ?? ""
            case .UtmMedium: return currentData?.utmMedium ?? ""
            default: return ""
        }
    }
}
