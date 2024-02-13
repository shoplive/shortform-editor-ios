//
//  ShopLiveCommonError.swift
//  ShopLiveSDKCommon
//
//  Created by sangmin han on 11/10/23.
//

import Foundation


public enum ShopLiveErrorCases {
    
    case AuthenticationFailed
    case GuestLoginNotAllowed
    case CustomAccountNotFound
    case CustomAccountExpired
    case InvalidSignature
    case ExpiredSession
    case ServerError
    case CampaignNotFound
    case CampaignNotOnAir
    case DuplicateSession
    
    case NotInitializedAccessKey
    case NotInitializedShareURL
    case NotInitializedShortformConfig
    case FailedEncoding
    case RemovedVideo
    case UnsupportedMedia
    case UnsupportedOSpipMode
    case FailedNetwork
    case FailedJSONParsing
    case UnexpectedError
    
    
    func getErrorCodeAndMessage() -> (Int,String) {
        switch self {
        case .AuthenticationFailed:
            return (-102, "Authentication Fail")
        case .GuestLoginNotAllowed:
            return (-115, "Gest Login is Not Allowed")
        case .CustomAccountNotFound:
            return (-200, "Customer Account Not Found")
        case .CustomAccountExpired:
            return (-201, "Customer Account Expired")
        case .InvalidSignature:
            return (-204, "Invalid Signature")
        case .ExpiredSession:
            return (-412, "ExpiredSession")
        case .ServerError:
            return (-500, "Server Error")
        case .CampaignNotFound:
            return (-710, "Campaign Not Found")
        case .CampaignNotOnAir:
            return (-711, "Campaign Not OnAir")
        case .DuplicateSession:
            return (-411, "Duplicated Session")
        case .NotInitializedAccessKey:
            return (9000, "There is no accessKey")
        case .NotInitializedShareURL:
            return (9001, "There is no shared URL")
        case .NotInitializedShortformConfig:
            return (9002, "To use Shoplive Short-form, please contact ask@shoplive.cloud")
        case .FailedEncoding:
            return (9300, "Failed encoding")
        case .RemovedVideo:
            return (9310, "Removed Video")
        case .UnsupportedMedia:
            return (9501, "Unsupported media")
        case .UnsupportedOSpipMode:
            return (9500, "Unsupported OS version to use OS PIP mode")
        case .FailedNetwork:
            return (9900, "Failed Network")
        case .FailedJSONParsing:
            return (9901, "Failed json parsing")
        case .UnexpectedError:
            return (10000, "Unexpected error")
        }
        
        
    }
}



public class ShopLiveCommonError : Error {
    public var code : Int
    public var message : String?
    public var error : Error?
    
    public init(code : Int, message : String?, error : Error?){
        self.code = code
        self.message = message
        self.error = error
    }
}

public class ShopLiveCommonErrorGenerator {
    
    public class func generateError(errorCase : ShopLiveErrorCases,error : Error?, message : String?) -> ShopLiveCommonError {
        let (code, defaultMessage) = errorCase.getErrorCodeAndMessage()
        if let message = message {
            return .init(code: code, message: message, error: error)
        }
        else {
            return .init(code: code, message: defaultMessage, error: error)
        }
    }
    
    
    public class func generateErrorFromNetwork(statusCode : Int, error : Error?, responseData : Data?) -> ShopLiveCommonError? {
        if let responseData = responseData, let decoded = try? JSONDecoder().decode(ShopLiveCommonNetworkBaseErrorResponse.self, from: responseData) {
            guard let s = decoded._s, s != 0 else {
                return nil
            }
            return .init(code: s, message: decoded._e, error: error)
        }
        
        guard (200...399).contains(statusCode) == false, let error = error else {
            return nil
        }
        
        return .init(code: statusCode, message: "[HTTP status code]", error: error)
    }
    
    
    
}

