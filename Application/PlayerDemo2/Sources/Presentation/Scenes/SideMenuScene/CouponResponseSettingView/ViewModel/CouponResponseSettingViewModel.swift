//
//  CouponResponseSettingViewModel.swift
//  PlayerDemo2
//
//  Created by sangmin han on 2/11/25.
//  Copyright © 2025 com.app. All rights reserved.
//

import Foundation
import RxSwift
import ShopLiveSDK







final class CouponResponseSettingViewModel : NSObject, ViewModelType {
    
    struct Input {
        let viewDidLoad : Observable<Void>
        let save : Observable<Void>
        let successRadioType : Observable<CouponResponseSettingContainer.RadioType>
        let failedRadioType : Observable<CouponResponseSettingContainer.RadioType>
        let successMessage : Observable<String>
        let failedMessage : Observable<String>
    }
    
    struct Output {
        let successContents : Observable<CouponResponseSettingContainerUIData>
        let failureContents : Observable<CouponResponseSettingContainerUIData>
        let successRadioType : Observable<CouponResponseSettingContainer.RadioType?>
        let failedRadioType : Observable<CouponResponseSettingContainer.RadioType?>
    }
    
    
    var disposeBag: DisposeBag = .init()
    private var successResultAlertType : ShopLiveResultAlertType = .ALERT
    private var successResultStatus : ShopLiveResultStatus = .SHOW
    private var successResultMessage : String = ""
    
    private var failedResultAlertType : ShopLiveResultAlertType = .ALERT
    private var failedResultStatus : ShopLiveResultStatus = .SHOW
    private var failedResultMessage : String = ""
    
    private let couponResponseSettingUseCase : CouponResponseSettingUseCase
    var routing : CouponResponseRouting
    
    init(couponResponseSettingUseCase : CouponResponseSettingUseCase,
         routing : CouponResponseRouting) {
        self.couponResponseSettingUseCase = couponResponseSettingUseCase
        self.routing = routing
        super.init()
        
    }
    
    
    func transform(input: Input) -> Output {
        
        
        let successContentsSubject = BehaviorSubject<CouponResponseSettingContainerUIData>(value: getSuccessContents())
        let failureContentsSubject = BehaviorSubject<CouponResponseSettingContainerUIData>(value: getFailureContents())
        
        let successRadioType = PublishSubject<CouponResponseSettingContainer.RadioType?>()
        let failedRadioType = PublishSubject<CouponResponseSettingContainer.RadioType?>()
        
        input.viewDidLoad
            .withUnretained(self)
            .subscribe(onNext : { owner, _ in
                let (_, successStatus, successAlert) = owner.couponResponseSettingUseCase.getSuccessResults()
                let (_, failedStatus, failedAlert) = owner.couponResponseSettingUseCase.getFailedResults()
                
                successRadioType.onNext(owner.parseResultStatusToRadioType(status: successStatus))
                successRadioType.onNext(owner.parseAlertTypeToRadioType(type: successAlert))
                
                failedRadioType.onNext(owner.parseResultStatusToRadioType(status: failedStatus))
                failedRadioType.onNext(owner.parseAlertTypeToRadioType(type: failedAlert))
            })
            .disposed(by: disposeBag)
        
        input.successRadioType
            .withUnretained(self)
            .subscribe(onNext : { owner, type in
                if let status = owner.parseRadioTypeToResultStatus(type: type) {
                    owner.successResultStatus = status
                }
                else if let alertType = owner.parseRadioTypeToResultAlertType(type: type) {
                    owner.successResultAlertType = alertType
                }
                successRadioType.onNext(type)
            })
            .disposed(by: disposeBag)
        
        input.failedRadioType
            .withUnretained(self)
            .subscribe(onNext : { owner, type in
                if let status = owner.parseRadioTypeToResultStatus(type: type) {
                    owner.failedResultStatus = status
                }
                else if let alertType = owner.parseRadioTypeToResultAlertType(type: type) {
                    owner.failedResultAlertType = alertType
                }
                failedRadioType.onNext(type)
            })
            .disposed(by: disposeBag)
        
        input.failedMessage
            .withUnretained(self)
            .subscribe(onNext : { owner, message in
                owner.failedResultMessage = message
            })
            .disposed(by: disposeBag)
        
        input.successMessage
            .withUnretained(self)
            .subscribe(onNext : { owner, message in
                owner.successResultMessage = message
            })
            .disposed(by: disposeBag)
        
        input.save
            .withUnretained(self)
            .subscribe(onNext : { owner, _ in
                owner.couponResponseSettingUseCase.setSuccessResults(message: owner.successResultMessage,
                                                                    status: owner.successResultStatus,
                                                                    alertType: owner.successResultAlertType)
                
                owner.couponResponseSettingUseCase.setFailedResults(message: owner.failedResultMessage,
                                                                    status: owner.failedResultStatus,
                                                                    alertType: owner.failedResultAlertType)
            })
            .disposed(by: disposeBag)
        
                    
        
        return .init(successContents: successContentsSubject.asObservable(),
                     failureContents: failureContentsSubject.asObservable(),
                     successRadioType: successRadioType,
                     failedRadioType: failedRadioType)
    }
    
    
    private func getSuccessContents() -> CouponResponseSettingContainerUIData {
        return .init(title: PlayerDemo2Strings.Couponresponse.Success.title,
                     messagePlaceHolder: PlayerDemo2Strings.Couponresponse.Success.default,
                     message: couponResponseSettingUseCase.getSuccessResults().message,
                     showRadioDescription: ShopLiveResultStatus.SHOW.name,
                     hideRadioDescription: ShopLiveResultStatus.HIDE.name,
                     keepRadioDescription: ShopLiveResultStatus.KEEP.name,
                     alertRadioDescription: ShopLiveResultAlertType.ALERT.name,
                     toastRadioDescription: ShopLiveResultAlertType.TOAST.name)
    }
    
    private func getFailureContents() -> CouponResponseSettingContainerUIData {
        return .init(title: PlayerDemo2Strings.Couponresponse.Failed.title,
                     messagePlaceHolder: PlayerDemo2Strings.Couponresponse.Failed.default,
                     message: couponResponseSettingUseCase.getFailedResults().message,
                     showRadioDescription: ShopLiveResultStatus.SHOW.name,
                     hideRadioDescription: ShopLiveResultStatus.HIDE.name,
                     keepRadioDescription: ShopLiveResultStatus.KEEP.name,
                     alertRadioDescription: ShopLiveResultAlertType.ALERT.name,
                     toastRadioDescription: ShopLiveResultAlertType.TOAST.name)
    }
    
    
    private func parseRadioTypeToResultStatus(type : CouponResponseSettingContainer.RadioType) -> ShopLiveResultStatus? {
        switch type {
        case .show:
            return .SHOW
        case .hide:
            return .HIDE
        case .keep:
            return .KEEP
        default:
            return nil
        }
    }
    
    private func parseResultStatusToRadioType(status : ShopLiveResultStatus?) -> CouponResponseSettingContainer.RadioType? {
        guard let status = status else {
            return nil
        }
        switch status {
        case .SHOW:
            return .show
        case .HIDE:
            return .hide
        case .KEEP:
            return .keep
        }
    }
    
    private func parseRadioTypeToResultAlertType(type : CouponResponseSettingContainer.RadioType) -> ShopLiveResultAlertType? {
        switch type {
        case .toast:
            return .TOAST
        case .alert:
            return .ALERT
        default:
            return nil
        }
    }
    
    private func parseAlertTypeToRadioType(type : ShopLiveResultAlertType?) -> CouponResponseSettingContainer.RadioType? {
        guard let type = type else {
            return nil
        }
        switch type {
        case .ALERT:
            return .alert
        case .TOAST:
            return .toast
        }
    }
}
