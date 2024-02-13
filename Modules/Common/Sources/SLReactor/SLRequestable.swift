//
//  Requestable.swift
//  ShopliveCommon
//
//  Created by James Kim on 11/15/22.
//

import Foundation

public protocol SLRequestable {
    associatedtype Request
    func request(_ request: Request)
}
