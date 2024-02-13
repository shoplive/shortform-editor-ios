//
//  ResultObservable.swift
//  ShopliveCommon
//
//  Created by James Kim on 11/15/22.
//

import Foundation

public protocol SLResultObservable {
    associatedtype Result
    var resultHandler: ((Result) -> ())? { get set }
}
