//
//  PipPinPositionViewModel.swift
//  PlayerDemo2
//
//  Created by sangmin han on 2/6/25.
//  Copyright © 2025 com.app. All rights reserved.
//

import Foundation
import RxSwift
import ShopLiveSDK



final class PIPPinPositionViewModel : ViewModelType {
    
    struct Input {
        let viewDidAppear : PublishSubject<Void>
        let pipPinPosition : PublishSubject<Int>
    }
    
    struct Output {
        let pipPinPositions : PublishSubject<[Int]>
    }
    
    let pipPinsPositionsSubject = PublishSubject<[Int]>()
    
    
    private let useCase : PIPPinPositionUseCase
    var disposeBag: DisposeBag = .init()
    var routing : PipPinPositionRouting?
    

    init(useCase: PIPPinPositionUseCase,
         routing : PipPinPositionRouting) {
        self.useCase = useCase
        self.routing = routing
    }
    
    
    func transform(input: Input) -> Output {
        input.viewDidAppear
            .withUnretained(self)
            .subscribe(onNext : {  owner,_ in
                owner.pipPinsPositionsSubject.onNext(owner.useCase.getPIPPinPosition().map{ $0.rawValue })
            })
            .disposed(by: disposeBag)
        
        
        input.pipPinPosition
            .withUnretained(self)
            .map({ $0.0.numberToPipPinPosition($0.1)})
            .withUnretained(self)
            .subscribe(onNext : { owner,position in
                owner.useCase.setPIPPinPosition(pipPosition: position)
                
                owner.pipPinsPositionsSubject.onNext(owner.useCase.getPIPPinPosition().map{ $0.rawValue })
            })
            .disposed(by: disposeBag)
        
        
        return Output(pipPinPositions: pipPinsPositionsSubject)
    }
    
    private func numberToPipPinPosition(_ number: Int) -> ShopLive.PipPosition {
        return ShopLive.PipPosition(rawValue: number) ?? .bottomRight
    }
}
