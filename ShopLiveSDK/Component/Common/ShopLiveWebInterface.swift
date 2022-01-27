//
//  ShopLiveWebInterface.swift
//  ShopLiveSDK
//
//  Created by ShopLive on 2021/02/05.
//

import Foundation
import WebKit

enum WebInterface {
    static var allFunctions: [WebFunction] {
        return WebFunction.allCases
    }
    
    case systemInit
    case setPosterUrl(url: URL)
    case setLiveStreamUrl(url: URL)
    case setVideoMute(isMuted: Bool)
    case setIsPlayingVideo(isPlaying: Bool)
    case reloadVideo
    case startPictureInPicture
    case close
    case navigation(url: URL)
    case coupon(id: String)
    case playVideo
    case pauseVideo
    case clickShareButton(url: URL?)
    case replay(width: CGFloat, height: CGFloat)
    case downKeyboard
    case onPipModeChanged
    case setIsMute
    case completeDownloadCoupon
    case completeCustomAction
    case videoInitialized
    case showChatInput
    case hiddenChatInput
    case setConf
    case write
    case written
    case setChatListMarginBottom
    case setVideoCurrentTime(to: Double)
    case onVideoDurationChanged
    case onVideoTimeUpdated
    case reloadBtn
    case onTerminated
    case onBackground
    case onForeground
    case customAction(id: String, type: String, payload: Any?)
    case onCampaignStatusChanged(status: String)
    case disableSwipeDown
    case enableSwipeDown
    case setParam(key: String, value: String)
    case delParam(key: String)
    case showNativeDebug
    case debuglog(log: String)
    case onVideoMetadataUpdated
    case downloadCouponResult
    case customActionResult
    case setUserName(payload: [String: Any?])
    case error(code: String, message: String)
    case command(command: String, payload: Any?)

    var functionString: String {
        switch self {
        case .systemInit:
            return WebFunction.systemInit.rawValue
        case .setPosterUrl:
            return WebFunction.setPosterUrl.rawValue
        case .setLiveStreamUrl:
            return WebFunction.setLiveStreamUrl.rawValue
        case .setVideoMute:
            return WebFunction.setVideoMute.rawValue
        case .setIsPlayingVideo:
            return WebFunction.setIsPlayingVideo.rawValue
        case .reloadVideo:
            return WebFunction.reloadVideo.rawValue
        case .startPictureInPicture:
            return WebFunction.startPictureInPicture.rawValue
        case .close:
            return WebFunction.close.rawValue
        case .navigation:
            return WebFunction.navigation.rawValue
        case .coupon:
            return WebFunction.coupon.rawValue
        case .playVideo:
            return WebFunction.playVideo.rawValue
        case .pauseVideo:
            return WebFunction.pauseVideo.rawValue
        case .clickShareButton:
            return WebFunction.clickShareButton.rawValue
        case .replay:
            return WebFunction.replay.rawValue
        case .downKeyboard:
            return WebFunction.downKeyboard.rawValue
        case .onPipModeChanged:
            return WebFunction.onPipModeChanged.rawValue
        case .setIsMute:
            return WebFunction.setIsMute.rawValue
        case .completeDownloadCoupon:
            return WebFunction.completeDownloadCoupon.rawValue
        case .completeCustomAction:
            return WebFunction.completeCustomAction.rawValue
        case .videoInitialized:
            return WebFunction.videoInitialized.rawValue
        case .showChatInput:
            return WebFunction.showChatInput.rawValue
        case .hiddenChatInput:
            return WebFunction.hiddenChatInput.rawValue
        case .setConf:
            return WebFunction.setConf.rawValue
        case .write:
            return WebFunction.write.rawValue
        case .written:
            return WebFunction.written.rawValue
        case .setChatListMarginBottom:
            return WebFunction.setChatListMarginBottom.rawValue
        case .setVideoCurrentTime:
            return WebFunction.setVideoCurrentTime.rawValue
        case .onVideoDurationChanged:
            return WebFunction.onVideoDurationChanged.rawValue
        case .onVideoTimeUpdated:
            return WebFunction.onVideoTimeUpdated.rawValue
        case .reloadBtn:
            return WebFunction.reloadBtn.rawValue
        case .onTerminated:
            return WebFunction.onTerminated.rawValue
        case .onBackground:
            return WebFunction.onBackground.rawValue
        case .onForeground:
            return WebFunction.onForeground.rawValue
        case .customAction:
            return WebFunction.customAction.rawValue
        case .onCampaignStatusChanged:
            return WebFunction.onCampaignStatusChanged.rawValue
        case .disableSwipeDown:
            return WebFunction.disableSwipeDown.rawValue
        case .enableSwipeDown:
            return WebFunction.enableSwipeDown.rawValue
        case .setParam:
            return WebFunction.setParam.rawValue
        case .delParam:
            return WebFunction.delParam.rawValue
        case .showNativeDebug:
            return WebFunction.showNativeDebug.rawValue
        case .debuglog:
            return WebFunction.debuglog.rawValue
        case .onVideoMetadataUpdated:
            return WebFunction.onVideoMetadataUpdated.rawValue
        case .downloadCouponResult:
            return WebFunction.downloadCouponResult.rawValue
        case .customActionResult:
            return WebFunction.customActionResult.rawValue
        case .setUserName:
            return WebFunction.setUserName.rawValue
        case .error:
            return WebFunction.error.rawValue
        case .command:
            return WebFunction.command.rawValue
        }
    }
    
    enum WebFunction: String, CustomStringConvertible, CaseIterable {
        var description: String { return self.rawValue }
        
        case systemInit = "SYSTEM_INIT"
        case setPosterUrl = "SET_POSTER_URL"
        case setLiveStreamUrl = "SET_LIVE_STREAM_URL"
        case setVideoMute = "SET_VIDEO_MUTE"
        case setIsPlayingVideo = "SET_IS_PLAYING_VIDEO"
        case reloadVideo = "RELOAD_VIDEO"
        case startPictureInPicture = "ENTER_PIP"
        case close = "CLOSE"
        case navigation = "NAVIGATION"
        case coupon = "DOWNLOAD_COUPON"
        case playVideo = "PLAY_VIDEO"
        case pauseVideo = "PAUSE_VIDEO"
        case clickShareButton = "CLICK_SHARE_BTN"
        case replay = "REPLAY"
        case downKeyboard = "DOWN_KEYBOARD"
        case onPipModeChanged = "ON_PIP_MODE_CHANGED"
        case setIsMute = "SET_IS_MUTE"
        case completeDownloadCoupon = "COMPLETE_DOWNLOAD_COUPON"
        case completeCustomAction = "COMPLETE_CUSTOM_ACTION"
        case videoInitialized = "VIDEO_INITIALIZED"
        case command = "COMMAND"
        case showChatInput = "SHOW_CHAT_INPUT"
        case hiddenChatInput = "HIDDEN_CHAT_INPUT"
        case setConf = "SET_CONF"
        case write = "WRITE"
        case written = "WRITTEN"
        case setChatListMarginBottom = "SET_CHAT_LIST_MARGIN_BOTTOM"
        case setVideoCurrentTime = "SET_VIDEO_CURRENT_TIME"
        case onVideoDurationChanged = "ON_VIDEO_DURATION_CHANGED"
        case onVideoTimeUpdated = "ON_VIDEO_TIME_UPDATED"
        case reloadBtn = "RELOAD_BTN"
        case onTerminated = "ON_TERMINATED"
        case onBackground = "ON_BACKGROUND"
        case onForeground = "ON_FOREGROUND"
        case customAction = "CUSTOM_ACTION"
        case onCampaignStatusChanged = "ON_CAMPAIGN_STATUS_CHANGED"
        case disableSwipeDown = "DISABLE_SWIPE_DOWN"
        case enableSwipeDown = "ENABLE_SWIPE_DOWN"
        case setParam = "SET_PARAM"
        case delParam = "DEL_PARAM"
        case showNativeDebug = "SHOW_NATIVE_DEBUG"
        case debuglog = "DEBUG_LOG"
        case onVideoMetadataUpdated = "ON_VIDEO_METADATA_UPDATED"
        case downloadCouponResult = "DOWNLOAD_COUPON_RESULT"
        case customActionResult = "CUSTOM_ACTION_RESULT"
        case setUserName = "SET_USER_NAME"
        case error = "ERROR"
    }
}

extension WebInterface {
    init?(message: WKScriptMessage) {
        guard message.name == ShopLiveDefines.webInterface else { return nil }
        guard let body = message.body as? [String: Any] else { return nil }
        guard let command = body["action"] as? String else { return nil }
        let function = WebFunction(rawValue: command)
        let parameters = body["payload"] as? [String: Any]
//        ShopLiveLogger.debugLog("WebInterface  \(String(describing: function))")
        ShopLiveLogger.debugLog("from Web [Interface: \(String(describing: function))]: [payload: \(String(describing: parameters))]")
        ShopLiveViewLogger.shared.addLog(log: .init(logType: .interface, log: "from Web [Interface: \(String(describing: function))]: [payload: \(String(describing: parameters))]"))
        switch function {
        case .systemInit:
            self = .systemInit
        case .setPosterUrl:
            guard let urlString = parameters?["posterUrl"] as? String else { return nil }
            guard let url = URL(string: urlString) else { return nil }
            self = .setPosterUrl(url: url)
        case .setLiveStreamUrl:
            if let urlString = parameters?["liveStreamUrl"] as? String {
                guard !urlString.isEmpty, let url = URL(string: urlString) else {
                    ShopLiveLogger.debugLog("setLiveStreamUrl stop")
                    ShopLiveController.streamUrl = nil
                    ShopLiveController.shared.releasePlayer = true
                    return nil
                }
                self = .setLiveStreamUrl(url: url)
            } else {
                ShopLiveController.streamUrl = nil
                ShopLiveController.shared.releasePlayer = true
                return nil
            }
        case .setVideoMute:
            guard let isMuted = parameters?["isMuted"] as? Bool else { return nil }
            self = .setVideoMute(isMuted: isMuted)
        case .setIsPlayingVideo:
            guard let isPlaying = parameters?["isPlaying"] as? Bool else { return nil }
            self = .setIsPlayingVideo(isPlaying: isPlaying)
        case .reloadVideo:
            self = .reloadVideo
        case .startPictureInPicture:
            self = .startPictureInPicture
        case .close:
            self = .close
        case .navigation:
            guard let urlString = parameters?["url"] as? String else { return nil }
            var navUrl: URL? = nil
            if let url = URL(string: urlString) {
                navUrl = url
            } else if let encodedStr = urlString.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed), let encodedUrl = URL(string: encodedStr) {
                navUrl = encodedUrl
            }

            guard let url = navUrl else { return nil }

            self = .navigation(url: url)
        case .coupon:
            guard let couponId = parameters?["coupon"] as? String else { return nil }
            self = .coupon(id: couponId)
        case .playVideo:
            self = .playVideo
        case .pauseVideo:
            self = .pauseVideo
        case .clickShareButton:
            var shareUrl:URL? = nil
            if let urlString = parameters?["url"] as? String, let url = URL(string: urlString) {
                shareUrl = url
            }
            self = .clickShareButton(url:  shareUrl)
        case .replay:
            guard let width = parameters?["width"] as? CGFloat else { return nil }
            guard let height = parameters?["height"] as? CGFloat else { return nil }
            self = .replay(width: width, height: height)
        case .downKeyboard:
            self = .downKeyboard
        case .onPipModeChanged:
            self = .onPipModeChanged
        case .setIsMute:
            self = .setIsMute
        case .completeDownloadCoupon:
            self = .completeDownloadCoupon
        case .videoInitialized:
            self = .videoInitialized
        case .showChatInput:
            self = .command(command: command, payload: nil)
        case .hiddenChatInput:
            self = .hiddenChatInput
        case .write:
            self = .write
        case .written:
            self = .command(command: WebFunction.written.rawValue, payload: parameters?["_s"])
        case .setConf:
            self = .command(command: WebFunction.setConf.rawValue, payload: parameters)
        case .setChatListMarginBottom:
            self = .setChatListMarginBottom
        case .setVideoCurrentTime:
            guard let time = parameters?["value"] as? Double else { return nil }
            self = .setVideoCurrentTime(to: time)
        case .onVideoDurationChanged:
            self = .onVideoDurationChanged
        case .onVideoTimeUpdated:
            self = .onVideoTimeUpdated
        case .reloadBtn:
            self = .reloadBtn
        case .onTerminated:
            self = .onTerminated
        case .onBackground:
            self = .onBackground
        case .onForeground:
            self = .onForeground
        case .customAction:
            guard let id = parameters?["id"] as? String else { return nil }
            guard let type = parameters?["type"] as? String else { return nil }
            guard let payload = parameters?["payload"] as? Any? else { return nil }
            self = .customAction(id: id, type: type, payload: payload)
        case .onCampaignStatusChanged:
            guard let status = parameters?["status"] as? String else { return nil }
            ShopLiveLogger.debugLog("campaign status: \(status)")
            self = .onCampaignStatusChanged(status: status)
        case .disableSwipeDown:
            self = .disableSwipeDown
        case .enableSwipeDown:
            self = .enableSwipeDown
        case .setParam:
            ShopLiveLogger.debugLog("receive setparam \(parameters?["key"])  \(parameters?["value"])")
            guard let key = parameters?["key"] as? String else { return nil }
            guard let value = parameters?["value"] as? String else { return nil }
            self = .setParam(key: key, value: value)
        case .delParam:
            ShopLiveLogger.debugLog("receive delparam \(parameters?["key"])")
            guard let key = parameters?["key"] as? String else { return nil }
            self = .delParam(key: key)
        case .showNativeDebug:
            self = .showNativeDebug
        case .debuglog:
            guard let log = parameters?["payload"] as? String else { return nil }
            self = .debuglog(log: log)
        case .onVideoMetadataUpdated:
            self = .onVideoMetadataUpdated
        case .downloadCouponResult:
            self = .downloadCouponResult
        case .customActionResult:
            self = .customActionResult
        case .setUserName:
            self = .setUserName(payload: parameters ?? [:])
        case .error:
            guard let code = parameters?["code"] as? String else { return nil }
            guard let message = parameters?["msg"] as? String else { return nil }
            self = .error(code: code, message: message)
        case .command:
            guard let customCommand = parameters?["action"] as? String else { return nil }
            let customPayload = parameters?["payload"]
            self = .command(command: customCommand, payload: customPayload)
        case .none:
            self = .command(command: command, payload: body["payload"])
        case .completeCustomAction:
            self = .completeCustomAction
        }
    }
}


