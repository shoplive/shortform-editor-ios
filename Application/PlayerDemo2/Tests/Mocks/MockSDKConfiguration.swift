//
//  MockSDKConfiguration.swift
//  PlayerDemo2Tests
//
//  Created by sangmin han on 2/5/25.
//  Copyright © 2025 com.app. All rights reserved.
//

import Foundation
@testable import PlayerDemo2



final class MockSDKConfiguration {
    
    class func getDummySDKConfiguration() -> SDKConfiguration {
        return SDKConfiguration(isGuestMode: false,
                                useJWTToken: false,
                                stopVideoOnHeadphoneDisconnected: false,
                                muteVideoOnHeadphoneDisconnected: false,
                                useCallOption: false,
                                useCustomShare: false,
                                useCustomProgress: false,
                                useCustomChatInputFont: false,
                                useCustomChatSendButtonFont: false,
                                pipPadding: .init(top: 20, left: 20, bottom: 20, right: 20),
                                pipFloatingOffset: .init(top: 20, left: 20, bottom: 20, right: 20),
                                pipEnableSwipeOut: true,
                                enablePip: true,
                                enableOSPip: true,
                                usePlayWhenPreviewTapped: true,
                                useInAppPipCloseButton: true,
                                isMuted: false,
                                enablePreviewSound: false,
                                isEnabledVolumeKey: true,
                                useKeepWindowStateOnPlayExecuted: false,
                                usePipKeepWindowStyle: false,
                                useManualRotation: false,
                                useMixAudio: false,
                                statusBarVisibility: true,
                                resizeMode: .CENTER_CROP,
                                previewResolution: .LIVE)
    }
    
}
