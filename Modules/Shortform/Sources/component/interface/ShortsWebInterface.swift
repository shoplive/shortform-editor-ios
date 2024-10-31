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
        
        enum SdkToWeb: String, CaseIterable {
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
            
            //웹뷰 413 에러 대응용 기존 webViewUrl query에 보내던 payload 그냥 보내면 됨
            case SET_SHORTS_SINGLE_DETAIL_VIEW
            
            private var key: String {
                return self.rawValue
            }
            
            init?(rawValue: String) {
                guard let webInterface = SdkToWeb.allCases.filter({ $0.key == rawValue }).first else { return nil }
                self = webInterface
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

