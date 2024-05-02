//
//  SLShortformModel.swift
//  ShopLiveShortformSDK
//
//  Created by sangmin han on 4/17/24.
//  Copyright © 2024 com.app. All rights reserved.
//

import Foundation
import UIKit
import ShopliveSDKCommon



extension ShopLiveShortform {
    class SLShortFormWindowReactor {
        var enablePanGesture: Bool {
            return shortsMode == .preview
        }
        
        var enableTapExplicit: Bool = false
        
        var enableTapGesture: Bool {
            return shortsMode == .preview && enableTapExplicit
        }
        
        var enableKeyboardEvent: Bool {
            return shortsMode == .preview
        }
        
        var isKeyboardShow: Bool = false
        var keyboardHeight: CGFloat = 0
        
        private let defaultPanGestureInitialCenter: CGPoint = .zero
        
        private var lastPreviewPosition: ShopLiveShortform.PreviewPosition?
        
        private var previewOptionDTO : ShortformPreviewOptionDTO?
        
        var previewPosition: ShopLiveShortform.PreviewPosition {
            set {
                lastPreviewPosition = newValue
            }
            
            get {
                if let lastPreviewPosition = self.lastPreviewPosition {
                    return lastPreviewPosition
                }
                if let dto = previewOptionDTO, let value = dto.previewPosition {
                    return value
                }
                return ShortFormConfigurationInfosManager.shared.shortsConfiguration.previewPosition
            }
        }
        
        var previewScale: CGFloat {
            if let dto = previewOptionDTO, let value = dto.previewScale {
                return value
            }
            return ShortFormConfigurationInfosManager.shared.shortsConfiguration.previewScale
        }
        
        var previewEdgeInsets: UIEdgeInsets {
            if let dto = previewOptionDTO, let value = dto.previewEdgeInset {
                return value
            }
            return ShortFormConfigurationInfosManager.shared.shortsConfiguration.previewEdgeInsets
        }
        
        var previewFloatingOffset: UIEdgeInsets {
            if let dto = previewOptionDTO, let value = dto.previewFloatingOffset {
                return value
            }
            return ShortFormConfigurationInfosManager.shared.shortsConfiguration.previewFloatingOffset
        }
        
        var previewSwipeOutEnabled : Bool {
            if let dto = previewOptionDTO, let value = dto.enableSwipeOut {
                return value
            }
            return ShortFormConfigurationInfosManager.shared.shortsConfiguration.enabledSwipeOut
        }
        
        var previewCornerRadius : CGFloat {
            if let dto = previewOptionDTO, let value = dto.previewRadius {
                return value
            }
            return ShortFormConfigurationInfosManager.shared.shortsConfiguration.previewRadius
        }
        
        var shortsMode: ShopLiveShortform.ShortsMode = .detail
        
        private var _panGestureInitialCenter: CGPoint?
        
        var panGestureInitialCenter: CGPoint {
            set {
                self._panGestureInitialCenter = newValue
            }
            
            get {
                guard let panGestureInitialCenter = self._panGestureInitialCenter else {
                    return defaultPanGestureInitialCenter
                }
                
                return panGestureInitialCenter
            }
        }
        
        var panGestureRecognizer: UIPanGestureRecognizer?
        var tapGestureRecognizer: UITapGestureRecognizer?
        
        func resetProperties() {
            shortsMode = .detail
            
            lastPreviewPosition = nil
            
            _panGestureInitialCenter = nil
            enableTapExplicit = false
        }
        
    }
}
extension ShopLiveShortform.SLShortFormWindowReactor {
    func triggerPreviewCustomClickCallBackEvent() {
        previewOptionDTO?.clickEventCallback?()
    }
}
//MARK: - setter
extension ShopLiveShortform.SLShortFormWindowReactor {
    func setPreviewOptionDTO(dto : ShortformPreviewOptionDTO?) {
        self.previewOptionDTO = dto
    }
    
}
//MARK: - getter
extension ShopLiveShortform.SLShortFormWindowReactor {
    func getPreviewUseCustomAction() -> Bool {
        return self.previewOptionDTO?.useCustomAction ?? false
    }
}
