//
//  Bindable.swift
//  ShopLiveShortformUploadSDK
//
//  Created by sangmin han on 2023/07/27.
//

import Foundation

final class Bindable<T> {
    var listener: ((T) -> Void)?

    var value: T {
        didSet { listener?(value) }
    }

    init(_ value: T) {
        self.value = value
    }

    func bind(listener: ((T) -> Void)?) {
        self.listener = listener
        listener?(value)
    }
}
