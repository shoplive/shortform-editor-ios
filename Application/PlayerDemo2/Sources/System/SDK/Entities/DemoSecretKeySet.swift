//
//  DemoSecretKeySet.swift
//  PlayerDemo2
//
//  Created by Tabber on 1/17/25.
//  Copyright © 2025 com.app. All rights reserved.
//

import Foundation

final class DemoSecretKeySet: NSObject, NSCoding {
    var name: String
    var key: String

    init(name:String, key: String) {
        self.name = name
        self.key = key
        super.init()
    }

    func encode(with coder: NSCoder) {
        coder.encode(self.name, forKey: "name")
        coder.encode(self.key, forKey: "key")
    }

    required init?(coder: NSCoder) {
        self.name = ""
        self.key = ""
        if let name = coder.decodeObject(forKey: "name") as? String {
            self.name = name
        }

        if let key = coder.decodeObject(forKey: "key") as? String {
            self.key = key
        }

        super.init()
    }
}
