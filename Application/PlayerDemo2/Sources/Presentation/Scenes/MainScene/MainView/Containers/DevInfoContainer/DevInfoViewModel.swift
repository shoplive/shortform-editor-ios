//
//  DevInfoViewModel.swift
//  PlayerDemo2
//
//  Created by Tabber on 2/10/25.
//  Copyright © 2025 com.app. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import ShopliveSDKCommon

class DevInfoViewModel: ViewModelType {
    
    struct Input {
        let setData: PublishSubject<SDKConfiguration>
    }
    
    struct Output {
        var checkBox: PublishSubject<ShopLiveButtonType>
        var radioOption: PublishSubject<ShopLiveButtonType>
        var urlText: PublishSubject<String>
    }
    
    var disposeBag: DisposeBag = DisposeBag()
    
    func transform(input: Input) -> Output {
        
        let checkBoxPublish = PublishSubject<ShopLiveButtonType>()
        let radioOptionPublish = PublishSubject<ShopLiveButtonType>()
        let urlTextPublish = PublishSubject<String>()
        
        input.setData
            .withUnretained(self)
            .subscribe(onNext: { owner, data in
                if ShopLiveDevConfiguration.shared.useLockPortrait {
                    checkBoxPublish.onNext(.useLockPortrait)
                }
                if ShopLiveDevConfiguration.shared.useWebLog {
                    checkBoxPublish.onNext(.webDebug)
                }
                
                if let phase = ShopLiveButtonType.convert(ShopLiveDevConfiguration.shared.phase) {
                    radioOptionPublish.onNext(phase)
                }
                
                if let url = data.customLandingUrl {
                    urlTextPublish.onNext(url)
                }
            })
            .disposed(by: disposeBag)
        
        return .init(checkBox: checkBoxPublish,
                     radioOption: radioOptionPublish,
                     urlText: urlTextPublish)
    }
        
}
