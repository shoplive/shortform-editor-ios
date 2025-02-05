//
//  ViewModelType.swift
//  PlayerDemo2
//
//  Created by Tabber on 2/5/25.
//  Copyright © 2025 com.app. All rights reserved.
//

import Foundation
import RxSwift

protocol ViewModelType {
    associatedtype Input
    associatedtype Output
    
    var disposeBag: DisposeBag { get set }
    
    func transform(input: Input) -> Output
}
