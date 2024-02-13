//
//  Reactor.swift
//  ShopliveCommonLibrary
//
//  Created by James Kim on 11/26/22.
//

import Foundation

public protocol ActionReceivable {
    associatedtype Action
    func action(_ action: Action)
}

public protocol SLReactor: ActionReceivable, SLResultObservable { }
