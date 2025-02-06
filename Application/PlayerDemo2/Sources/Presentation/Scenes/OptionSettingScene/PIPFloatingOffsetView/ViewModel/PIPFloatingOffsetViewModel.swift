//
//  PIPFloatingOffsetViewModel.swift
//  PlayerDemo2
//
//  Created by sangmin han on 2/5/25.
//  Copyright © 2025 com.app. All rights reserved.
//

import Foundation
import UIKit
import RxSwift




final class PIPFloatingOffsetViewModel : NSObject, ViewModelType {
    struct StringEdgeInset {
        let top : String
        let left : String
        let right : String
        let bottom : String
        
        init(top: String, left: String, right: String, bottom: String) {
            self.top = top
            self.left = left
            self.right = right
            self.bottom = bottom
        }
        
        func toUIEdgeInsets() -> UIEdgeInsets {
            return UIEdgeInsets(top: CGFloat(Double(top) ?? 20),
                                left: CGFloat(Double(left) ?? 20),
                                bottom: CGFloat(Double(bottom) ?? 20),
                                right: CGFloat(Double(right) ?? 20))
        }
    }
    
    struct Input {
        let viewDidLoad : PublishSubject<Void>
        let padding : PublishSubject<StringEdgeInset>
        let floatingOffset : PublishSubject<StringEdgeInset>
        let resetValue : PublishSubject<Void>
    }
    
    struct Output {
        let padding : PublishSubject<StringEdgeInset>
        let floatingOffset : PublishSubject<StringEdgeInset>
    }
   
    private var pipFloatingOffsetUseCase : PIPFloatingUseCase
    weak var routing : PIPFloatingOffsetRouting?
    
    
    private let paddingSubject = PublishSubject<StringEdgeInset>()
    private let floatingOffsetSubject = PublishSubject<StringEdgeInset>()
    
    var disposeBag: DisposeBag = .init()

    init(pipFloatingOffsetUseCase: PIPFloatingUseCase,
         routing: PIPFloatingOffsetRouting?) {
        self.pipFloatingOffsetUseCase = pipFloatingOffsetUseCase
        self.routing = routing
    }
    
    deinit {
        print("\(Self.className) deinit")
    }
    
    func transform(input: Input) -> Output {
        input.viewDidLoad
            .withUnretained(self)
            .subscribe(onNext : { owner, _ in
                let paddingValue = owner.pipFloatingOffsetUseCase.getPipPaddingInset()
                let floatingOffsetValue = owner.pipFloatingOffsetUseCase.getPipFloatingOffset()
                
                owner.paddingSubject.onNext(owner.uiEdgeInsettToStringEdgeInset(edgeInset: paddingValue))
                owner.floatingOffsetSubject.onNext(owner.uiEdgeInsettToStringEdgeInset(edgeInset: floatingOffsetValue))
            })
            .disposed(by: disposeBag)
        
        input.padding
            .withUnretained(self)
            .subscribe(onNext : { owner, stringEdgeInset in
                owner.pipFloatingOffsetUseCase
                    .setPipPaddingInset(inset: stringEdgeInset.toUIEdgeInsets())
            })
            .disposed(by: disposeBag)
        
        input.floatingOffset
            .withUnretained(self)
            .subscribe(onNext : { owner, stringEdgeInset in
                owner.pipFloatingOffsetUseCase
                    .setPipFloatingOffset(inset: stringEdgeInset.toUIEdgeInsets())
            })
            .disposed(by: disposeBag)
        
        input.resetValue
            .withUnretained(self)
            .subscribe(onNext : { owner,_ in
                
            })
            .disposed(by: disposeBag)
        
        return Output(
            padding: paddingSubject,
            floatingOffset: floatingOffsetSubject
        )
    }
    
    
    private func uiEdgeInsettToStringEdgeInset(edgeInset : UIEdgeInsets) -> StringEdgeInset {
        return .init(top: "\(edgeInset.top)" ,
                     left: "\(edgeInset.left)",
                     right: "\(edgeInset.right)",
                     bottom: "\(edgeInset.bottom)")
    }
    
}
