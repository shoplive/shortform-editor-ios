//
//  SLUploadableResponse.swift
//  shortform-upload
//
//  Created by 김우현 on 5/16/23.
//

import Foundation
import ShopliveSDKCommon

struct SLUploadableResponse: BaseResponsable {
    var _s: Int?
    var _e: String?
    let _d : String?
    
    
    let sessionSecret: String?
    let uploadApiEndpoint: String?
}
