//
//  Error+extension.swift
//  ShopliveCommon
//
//  Created by James Kim on 2022/11/21.
//

import Foundation

public extension Error {
    var errorCode_SL: Int {
        let nsErr = self as NSError
        return nsErr.code
    }
    
    func getErrorMsg_SL() -> String {
        let nsErr = self as NSError
        let invalidDomains = ["SLAlamofire.AFError"]
        let notContainErrorMessage = nsErr.domain.isEmpty || invalidDomains.contains(nsErr.domain)
        // let errorMsg = notContainErrorMessage ? "\(Strings.Error.Msg.base)" : nsErr.domain
        let errorMsg = nsErr.domain
        return errorMsg
    }

    var userInfoString_SL: String {
        let nsError = self as NSError
        var userInfoString = ""

        nsError.userInfo.forEach { (key: String, value: Any) in
            userInfoString += "\(key) : \(value)"
        }

        return userInfoString
    }
}
