//
//  UseCase.swift
//  PlayerDemo2
//
//  Created by Tabber on 1/22/25.
//  Copyright © 2025 com.app. All rights reserved.
//

import Foundation

protocol Cancellable {
    func cancel()
}

protocol UseCase {
    @discardableResult
    func start() -> Cancellable?
}
