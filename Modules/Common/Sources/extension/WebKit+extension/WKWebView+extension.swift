//
//  WKWebView+extension.swift
//  ShopliveCommonLibrary
//
//  Created by James Kim on 11/24/22.
//

import Foundation
import WebKit

public extension WKWebView {
    static let progressKeypath_SL: String = "estimatedProgress"
    static var urlErrors_SL: [Int] {
        return [
            NSURLErrorCancelledReasonUserForceQuitApplication,
            NSURLErrorCancelledReasonBackgroundUpdatesDisabled,
            NSURLErrorCancelledReasonInsufficientSystemResources,
            NSURLErrorUnknown,
            NSURLErrorCancelled,
            NSURLErrorBadURL,
            NSURLErrorTimedOut,
            NSURLErrorUnsupportedURL,
            NSURLErrorCannotFindHost,
            NSURLErrorCannotConnectToHost,
            NSURLErrorNetworkConnectionLost,
            NSURLErrorDNSLookupFailed,
            NSURLErrorHTTPTooManyRedirects,
            NSURLErrorResourceUnavailable,
            NSURLErrorNotConnectedToInternet,
            NSURLErrorRedirectToNonExistentLocation,
            NSURLErrorBadServerResponse,
            NSURLErrorUserCancelledAuthentication,
            NSURLErrorUserAuthenticationRequired,
            NSURLErrorZeroByteResource,
            NSURLErrorCannotDecodeRawData,
            NSURLErrorCannotDecodeContentData,
            NSURLErrorCannotParseResponse,
            NSURLErrorAppTransportSecurityRequiresSecureConnection,
            NSURLErrorFileDoesNotExist,
            NSURLErrorFileIsDirectory,
            NSURLErrorNoPermissionsToReadFile,
            NSURLErrorDataLengthExceedsMaximum,
            NSURLErrorFileOutsideSafeArea,
            NSURLErrorSecureConnectionFailed,
            NSURLErrorServerCertificateHasBadDate,
            NSURLErrorServerCertificateUntrusted,
            NSURLErrorServerCertificateHasUnknownRoot,
            NSURLErrorServerCertificateNotYetValid,
            NSURLErrorClientCertificateRejected,
            NSURLErrorClientCertificateRequired,
            NSURLErrorCannotLoadFromNetwork,
            NSURLErrorCannotCreateFile,
            NSURLErrorCannotOpenFile,
            NSURLErrorCannotCloseFile,
            NSURLErrorCannotWriteToFile,
            NSURLErrorCannotRemoveFile,
            NSURLErrorCannotMoveFile,
            NSURLErrorDownloadDecodingFailedMidStream,
            NSURLErrorDownloadDecodingFailedToComplete,
            NSURLErrorInternationalRoamingOff,
            NSURLErrorCallIsActive,
            NSURLErrorDataNotAllowed,
            NSURLErrorRequestBodyStreamExhausted,
            NSURLErrorBackgroundSessionRequiresSharedContainer,
            NSURLErrorBackgroundSessionInUseByAnotherProcess,
            NSURLErrorBackgroundSessionWasDisconnected
        ]
    }
    
}
