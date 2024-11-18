//
//  ShortsWebInterface.swift
//  matrix-shortform-ios
//
//  Created by 김우현 on 3/1/23.
//

import Foundation

extension ShopLiveShortform {
    class ShortsWebInterface {
        enum Bridge: String, CaseIterable {
            case SHOW_SHORTFORM_PREVIEW
            case HIDE_SHORTFORM_PREVIEW
            case PLAY_SHORTFORM_DETAIL
            case CLOSE_SHORTFORM_DETAIL
            case ON_SHORTFORM_CLIENT_INITIALIZED
            case ON_CHANGED_USER_AUTH
            case ON_CHANGED_USER_AUTH_WEB
            
            private var key: String {
                return self.rawValue
            }
            
            init?(rawValue: String) {
                guard let webInterface = Bridge.allCases.filter({ $0.key == rawValue }).first else { return nil }
                self = webInterface
            }
        }
        
        enum WebToSdk: String, CaseIterable {
            case ON_SHORTFORM_DETAIL_REMOVED
            case ON_SHORTFORM_CLIENT_INITIALIZED
            case ON_SHORTFORM_DETAIL_INITIALIZED
            case ON_CHANGED_USER_AUTH
            case ON_CHANGED_USER_AUTH_WEB
            case HIDDEN_COMMENT_INPUT
            case WRITE
            case WRITTEN
            case ENABLE_SWIPE_DOWN
            case DISABLE_SWIPE_DOWN
            
            case SET_VIDEO_MUTE
            case SET_VIDEO_PAUSE
            case NONE_INTERFACE
            case SET_VIDEO_SEEK_TIME
            case SET_VIDEO_CURRENT_TIME
            case PLAY_VIDEO
            case ON_USER_AUTHORIZATION_UPDATED
            
            case ON_CLICK_SHARE_BUTTON
            case ON_CLICK_PRODUCT_ITEM
            case ON_CLICK_PRODUCT_BANNER
            
            case SHOW_SHORTFORM_PREVIEW
            case HIDE_SHORTFORM_PREVIEW
            case PLAY_SHORTFORM_DETAIL
            case CLOSE_SHORTFORM_DETAIL
            
            case REQUEST_CLIENT_VERSION
            
            //youtube 전용
            case SDK_YOUTUBE_PLAYER_SUPPORT
            
            
            private var key: String {
                return self.rawValue
            }
            
            init?(rawValue: String) {
                guard let webInterface = WebToSdk.allCases.filter({ $0.key == rawValue }).first else { return nil }
                self = webInterface
            }
            
        }
        
        enum SdkToWeb  {
            
            case ON_VIDEO_DURATION_CHANGED
            case ON_VIDEO_TIME_UPDATED
            case ON_VIDEO_MUTED
            case ON_VIDEO_PAUSED
            case SET_COMMENT_LIST_MARGIN_BOTTOM
            case ON_CHANGED_SHORTFORM_DETAIL_PLAYER_SHOWN
            case ON_CHANGED_SAFE_AREA
            case ON_CHANGED_USER_AUTH_SDK
            case ON_SHORTFORM_DETAIL_PAGE_ACTIVE
            case ON_SHORTFORM_DETAIL_PAGE_INACTIVE
            case REQUEST_SHORTFORM_PREVIEW
            case ON_CHANGED_APPSTATE
            case SEND_SHORTFORM_COMMENT_INPUT_VALUE
            case ON_COMPLETE_SENDING_SHORTFORM_COMMENT
            case ON_SHORTFORM_PREVIEW_SHOWN
            case ON_SHORTFORM_PREVIEW_HIDDEN
            case ON_CLICK_SHORTFORM_PREVIEW_CLOSE
            case ON_CLICK_SHORTFORM_PREVIEW
            case SEND_CLIENT_VERSION
            case ON_CHANGED_SESSION_INFO
            case ON_VIDEO_LOOPED
            case SET_CUSTOM_SHORTFORM
            
            //youtube 전용
            case SDK_YTP_PLAY_VIDEO
            case SDK_YTP_PAUSE_VIDEO
            case SDK_YTP_MUTE
            case SDK_YTP_UNMUTE
            case SDK_YTP_GET_IS_MUTED
            case SDK_YTP_GET_PLAYER_STATE
            case SDK_YTP_GET_CURRENT_TIME
            case SDK_YTP_GET_DURATION
            case SDK_YTP_DESTROY_AND_RELOAD
            case SDK_YTP_SEEK_TO
            
            //Musinsa 요구사항, 고객이 직접 웹으로 command를 쓸때 사용
            case EXTERNAL_COMMAND(String)
            
            //웹뷰 413 에러 대응용 기존 webViewUrl query에 보내던 payload 그냥 보내면 됨
            case SET_SHORTS_SINGLE_DETAIL_VIEW
            
            var key: String {
                switch self {
                case .ON_VIDEO_DURATION_CHANGED:
                    return "ON_VIDEO_DURATION_CHANGED"
                case .ON_VIDEO_TIME_UPDATED:
                    return "ON_VIDEO_TIME_UPDATED"
                case .ON_VIDEO_MUTED:
                    return "ON_VIDEO_MUTED"
                case .ON_VIDEO_PAUSED:
                    return "ON_VIDEO_PAUSED"
                case .SET_COMMENT_LIST_MARGIN_BOTTOM:
                    return "SET_COMMENT_LIST_MARGIN_BOTTOM"
                case .ON_CHANGED_SHORTFORM_DETAIL_PLAYER_SHOWN:
                    return "ON_CHANGED_SHORTFORM_DETAIL_PLAYER_SHOWN"
                case .ON_CHANGED_SAFE_AREA:
                    return "ON_CHANGED_SAFE_AREA"
                case .ON_CHANGED_USER_AUTH_SDK:
                    return "ON_CHANGED_USER_AUTH_SDK"
                case .ON_SHORTFORM_DETAIL_PAGE_ACTIVE:
                    return "ON_SHORTFORM_DETAIL_PAGE_ACTIVE"
                case .ON_SHORTFORM_DETAIL_PAGE_INACTIVE:
                    return "ON_SHORTFORM_DETAIL_PAGE_INACTIVE"
                case .REQUEST_SHORTFORM_PREVIEW:
                    return "REQUEST_SHORTFORM_PREVIEW"
                case .ON_CHANGED_APPSTATE:
                    return "ON_CHANGED_APPSTATE"
                case .SEND_SHORTFORM_COMMENT_INPUT_VALUE:
                    return "SEND_SHORTFORM_COMMENT_INPUT_VALUE"
                case .ON_COMPLETE_SENDING_SHORTFORM_COMMENT:
                    return "ON_COMPLETE_SENDING_SHORTFORM_COMMENT"
                case .ON_SHORTFORM_PREVIEW_SHOWN:
                    return "ON_SHORTFORM_PREVIEW_SHOWN"
                case .ON_SHORTFORM_PREVIEW_HIDDEN:
                    return "ON_SHORTFORM_PREVIEW_HIDDEN"
                case .ON_CLICK_SHORTFORM_PREVIEW_CLOSE:
                    return "ON_CLICK_SHORTFORM_PREVIEW_CLOSE"
                case .ON_CLICK_SHORTFORM_PREVIEW:
                    return "ON_CLICK_SHORTFORM_PREVIEW"
                case .SEND_CLIENT_VERSION:
                    return "SEND_CLIENT_VERSION"
                case .ON_CHANGED_SESSION_INFO:
                    return "ON_CHANGED_SESSION_INFO"
                case .ON_VIDEO_LOOPED:
                    return "ON_VIDEO_LOOPED"
                case .SET_CUSTOM_SHORTFORM:
                    return "SET_CUSTOM_SHORTFORM"
                case .SDK_YTP_PLAY_VIDEO:
                    return "SDK_YTP_PLAY_VIDEO"
                case .SDK_YTP_PAUSE_VIDEO:
                    return "SDK_YTP_PAUSE_VIDEO"
                case .SDK_YTP_MUTE:
                    return "SDK_YTP_MUTE"
                case .SDK_YTP_UNMUTE:
                    return "SDK_YTP_UNMUTE"
                case .SDK_YTP_GET_IS_MUTED:
                    return "SDK_YTP_GET_IS_MUTED"
                case .SDK_YTP_GET_PLAYER_STATE:
                    return "SDK_YTP_GET_PLAYER_STATE"
                case .SDK_YTP_GET_CURRENT_TIME:
                    return "SDK_YTP_GET_CURRENT_TIME"
                case .SDK_YTP_GET_DURATION:
                    return "SDK_YTP_GET_DURATION"
                case .SDK_YTP_DESTROY_AND_RELOAD:
                    return "SDK_YTP_DESTROY_AND_RELOAD"
                case .SDK_YTP_SEEK_TO:
                    return "SDK_YTP_SEEK_TO"
                case .EXTERNAL_COMMAND(let command):
                    return command
                case .SET_SHORTS_SINGLE_DETAIL_VIEW:
                    return "SET_SHORTS_SINGLE_DETAIL_VIEW"
                }
            }
            
            static func ==(lhs: SdkToWeb, rhs: SdkToWeb) -> Bool {
                switch (lhs, rhs) {
                case (.ON_VIDEO_DURATION_CHANGED, .ON_VIDEO_DURATION_CHANGED),
                    (.ON_VIDEO_TIME_UPDATED, .ON_VIDEO_TIME_UPDATED),
                    (.ON_VIDEO_MUTED, .ON_VIDEO_MUTED),
                    (.ON_VIDEO_PAUSED, .ON_VIDEO_PAUSED),
                    (.SET_COMMENT_LIST_MARGIN_BOTTOM, .SET_COMMENT_LIST_MARGIN_BOTTOM),
                    (.ON_CHANGED_SHORTFORM_DETAIL_PLAYER_SHOWN, .ON_CHANGED_SHORTFORM_DETAIL_PLAYER_SHOWN),
                    (.ON_CHANGED_SAFE_AREA, .ON_CHANGED_SAFE_AREA),
                    (.ON_CHANGED_USER_AUTH_SDK, .ON_CHANGED_USER_AUTH_SDK),
                    (.ON_SHORTFORM_DETAIL_PAGE_ACTIVE, .ON_SHORTFORM_DETAIL_PAGE_ACTIVE),
                    (.ON_SHORTFORM_DETAIL_PAGE_INACTIVE, .ON_SHORTFORM_DETAIL_PAGE_INACTIVE),
                    (.REQUEST_SHORTFORM_PREVIEW, .REQUEST_SHORTFORM_PREVIEW),
                    (.ON_CHANGED_APPSTATE, .ON_CHANGED_APPSTATE),
                    (.SEND_SHORTFORM_COMMENT_INPUT_VALUE, .SEND_SHORTFORM_COMMENT_INPUT_VALUE),
                    (.ON_COMPLETE_SENDING_SHORTFORM_COMMENT, .ON_COMPLETE_SENDING_SHORTFORM_COMMENT),
                    (.ON_SHORTFORM_PREVIEW_SHOWN, .ON_SHORTFORM_PREVIEW_SHOWN),
                    (.ON_SHORTFORM_PREVIEW_HIDDEN, .ON_SHORTFORM_PREVIEW_HIDDEN),
                    (.ON_CLICK_SHORTFORM_PREVIEW_CLOSE, .ON_CLICK_SHORTFORM_PREVIEW_CLOSE),
                    (.ON_CLICK_SHORTFORM_PREVIEW, .ON_CLICK_SHORTFORM_PREVIEW),
                    (.SEND_CLIENT_VERSION, .SEND_CLIENT_VERSION),
                    (.ON_CHANGED_SESSION_INFO, .ON_CHANGED_SESSION_INFO),
                    (.ON_VIDEO_LOOPED, .ON_VIDEO_LOOPED),
                    (.SET_CUSTOM_SHORTFORM, .SET_CUSTOM_SHORTFORM),
                    (.SDK_YTP_PLAY_VIDEO, .SDK_YTP_PLAY_VIDEO),
                    (.SDK_YTP_PAUSE_VIDEO, .SDK_YTP_PAUSE_VIDEO),
                    (.SDK_YTP_MUTE, .SDK_YTP_MUTE),
                    (.SDK_YTP_UNMUTE, .SDK_YTP_UNMUTE),
                    (.SDK_YTP_GET_IS_MUTED, .SDK_YTP_GET_IS_MUTED),
                    (.SDK_YTP_GET_PLAYER_STATE, .SDK_YTP_GET_PLAYER_STATE),
                    (.SDK_YTP_GET_CURRENT_TIME, .SDK_YTP_GET_CURRENT_TIME),
                    (.SDK_YTP_GET_DURATION, .SDK_YTP_GET_DURATION),
                    (.SDK_YTP_DESTROY_AND_RELOAD, .SDK_YTP_DESTROY_AND_RELOAD),
                    (.SDK_YTP_SEEK_TO, .SDK_YTP_SEEK_TO),
                    (.SET_SHORTS_SINGLE_DETAIL_VIEW, .SET_SHORTS_SINGLE_DETAIL_VIEW):
                    return true
                case let (.EXTERNAL_COMMAND(lhsCommand), .EXTERNAL_COMMAND(rhsCommand)):
                    return lhsCommand == rhsCommand
                default:
                    return false
                }
            }
        }
        
        enum YoutubeToSdk : String {
            case SDK_YTP_ON_PLAYER_READY
            case SDK_YTP_ON_PLAYER_STATE_CHANGE
            case SDK_YTP_ON_ERROR
            case SDK_YTP_GET_IS_MUTED
            case SDK_YTP_GET_PLAYER_STATE
            case SDK_YTP_GET_CURRENT_TIME
            case SDK_YTP_GET_DURATION
        }
    }
    
}

