//
//  SLShortsWindow.swift
//  matrix-shortform-ios
//
//  Created by 김우현 on 2/22/23.
//

import Foundation
import UIKit
import ShopliveSDKCommon

protocol SLShortsWindowItemViewable {
    var itemView: ShopLiveWindowItemView { get }
}

class ShopLiveWindowItemView: UIView {}

extension ShopLiveShortform {
    class SLShortFormWindow {
        
        weak var shortsCollectionView : ShortsCollectionBaseView?
        weak var shortformDelegate : ShopLiveShortformReceiveHandlerDelegate?
        
        private lazy var rootViewController: ShortFormDetailRootViewController = {
            let viewController = ShortFormDetailRootViewController()
            viewController.delegate = self
            return viewController
        }()
        
        private var reactor = SLShortFormWindowReactor()
        
        private var isCurrentOrientationLandScape : Bool = UIScreen.isLandscape_SL
        
        init(delegate : ShopLiveShortformReceiveHandlerDelegate?) {
            self.shortformDelegate = delegate
            customerWindow = UIApplication.shared.keyWindow
            setupWindow()
        }
        
        deinit {
            ShopLiveLogger.debugLog("SLShortsWindow deinited")
        }
        
        
        
        private func setupWindow() {
            setupGesture()
            setupObserver()
        }
        
        func teardownWindow() {
            reactor.resetProperties()
            self.shortformWindow.resignKey()
            self.customerWindow?.makeKey()
            teardownGesture()
            teardownObserver()
        }
        
        private func setupGesture() {
            let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panGestureHandler))
            reactor.panGestureRecognizer = panGesture
            shortformWindow.addGestureRecognizer(panGesture)
            
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapGestureHandler))
            tapGesture.cancelsTouchesInView = false
            tapGesture.delegate = shortformWindow
            reactor.tapGestureRecognizer = tapGesture
            shortformWindow.addGestureRecognizer(tapGesture)
        }
        
        
        private func teardownGesture() {
            if let panGestureRecognizer = self.reactor.panGestureRecognizer {
                shortformWindow.removeGestureRecognizer(panGestureRecognizer)
                reactor.panGestureRecognizer = nil
                reactor.panGestureInitialCenter = .zero
            }
            
            if let tapGestureRecognizer = self.reactor.tapGestureRecognizer {
                shortformWindow.removeGestureRecognizer(tapGestureRecognizer)
                reactor.tapGestureRecognizer = nil
            }
        }
        
        @objc func tapGestureHandler(_ recognizer: UITapGestureRecognizer) {
            guard reactor.enableTapGesture else { return }
            
            
            reactor.triggerPreviewCustomClickCallBackEvent()
            guard reactor.getPreviewUseCustomAction() == false else {
                ShopLiveShortform.close()
                return
            }
            
            if let shorts = self.shortsCollectionView?.getCurrentShortsModel() {
                ShopLiveShortform.BridgeInterface.clickPreview(shorts: shorts)
            }
            if shortsCollectionView?.getCurrentShowType() == .related && shortsCollectionView?.getIsFullNative() == true {
                //preview -> detail 들어갈때 새로 발급받아서 preview_click_show 페이로드에 담아서 보내줘야 함
                let shopLiveSessionId = ShopLiveCommon.makeShopLiveSessionId()
                let previewEventTraceSrn = self.shortsCollectionView?.getPreviewEventTraceSrn()
                //MARK: -TODO 나중에 preview_SHOWN/HIDDEN 이랑 PREVIEW_CLICK_SHOW/CLOSE랑 이벤트 분리해서 호출해야 함
                ShortformEventTraceManager.processPreviewShownHidden(shortsCollectionSrn: self.shortsCollectionView?.getPreviewEventTraceSrn(), isShown: true, isClick: true, shopliveSessionId: shopLiveSessionId)
                ShortformEventTraceManager.processPreviewShownHidden(shortsCollectionSrn: previewEventTraceSrn, isShown: false, isClick: false, shopliveSessionId: shopLiveSessionId)
                let shortsId = self.shortsCollectionView?.getCurrentShortsId()
                let shortsDetail = self.shortsCollectionView?.getCurrentShortsDetail()
                ShortformNativeOnEventsManager.sendNativeOnEvents(delegate: shortformDelegate,command: .preview_click_show, payload: nil, shortsId: shortsId, shortsDetail: shortsDetail)
                ShortformNativeOnEventsManager.sendNativeOnEvents(delegate: shortformDelegate,command: .preview_hidden, payload: nil, shortsId: shortsId, shortsDetail: shortsDetail)
                shortsCollectionView?.setShopLiveSessionId(sessionId: shopLiveSessionId)
            }
            fullScreen(animated: true, reset: true)
        }
        
        @objc func panGestureHandler(_ recognizer: UIPanGestureRecognizer) {
            guard let liveWindow = recognizer.view else { return }
            guard self.reactor.enablePanGesture else { return }
            
            liveWindow.layer.masksToBounds = true
            let translation = recognizer.translation(in: liveWindow)
            
            switch recognizer.state {
            case .began:
                self.reactor.panGestureInitialCenter = liveWindow.center
            case .changed:
                let centerX = self.reactor.panGestureInitialCenter.x + translation.x
                let centerY = self.reactor.panGestureInitialCenter.y + translation.y
                liveWindow.center = CGPoint(x: centerX, y: centerY)
            case .ended:
                guard let mainWindow = UIApplication.topWindow_SL else { return }
                liveWindow.layer.masksToBounds = true
                let velocity = recognizer.velocity(in: liveWindow)
                
                let safeAreaInset = mainWindow.safeAreaInsets
                let previewFloatingOffsetBottom: CGFloat = self.reactor.isKeyboardShow ? 0 : self.reactor.previewFloatingOffset.bottom
                
                let isKeyboardShow: Bool = self.reactor.isKeyboardShow
                let keyboardHeight: CGFloat = self.reactor.keyboardHeight
                
                let previewEdgeInsets: UIEdgeInsets = self.reactor.previewEdgeInsets
                let previewFloatingOffset: UIEdgeInsets = self.reactor.previewFloatingOffset
                let panGestureInitialCenter: CGPoint = self.reactor.panGestureInitialCenter
                
                let previewPosition: ShopLiveShortform.PreviewPosition = self.reactor.previewPosition
                
                let mainWindowHeight: CGFloat = mainWindow.bounds.height - (isKeyboardShow ? keyboardHeight : 0)
                let minX = (liveWindow.bounds.width / 2.0) + previewEdgeInsets.left + safeAreaInset.left + liveWindow.bounds.origin.x + previewFloatingOffset.left
                let maxX = mainWindow.bounds.width - ((liveWindow.bounds.width / 2.0) + previewEdgeInsets.right + safeAreaInset.right + previewFloatingOffset.right)
                let minY = liveWindow.bounds.height / 2.0 + previewEdgeInsets.top + safeAreaInset.top + previewFloatingOffset.top + liveWindow.bounds.origin.y - (isKeyboardShow ? keyboardHeight : 0)
                let maxY = mainWindowHeight - ((liveWindow.bounds.height / 2.0) + previewEdgeInsets.bottom + previewFloatingOffsetBottom + safeAreaInset.bottom)
                
                var centerX = panGestureInitialCenter.x + translation.x
                var centerY = panGestureInitialCenter.y + translation.y
                
                let xRange = (previewFloatingOffset.left + previewEdgeInsets.left)...(mainWindow.bounds.width - previewFloatingOffset.right - previewEdgeInsets.right)
                let yRange = (previewFloatingOffset.top + previewEdgeInsets.top + safeAreaInset.top)...(mainWindowHeight - (safeAreaInset.bottom + previewFloatingOffset.bottom + previewEdgeInsets.bottom)) + (isKeyboardShow ? liveWindow.frame.height * 0.2 : 0)
                
                //범위밖으로 나가면 stop
                var checkCenterX = centerX
                var checkCenterY = centerY
                
                if previewPosition == .topLeft || previewPosition == .bottomLeft {
                    if velocity.x < 0 {
                        if velocity.x.magnitude > 600 {
                            if checkCenterX + velocity.x < minX {
                                checkCenterX = minX - liveWindow.frame.width
                            }
                        }
                    }
                } else if previewPosition == .topRight || previewPosition == .bottomRight {
                    if velocity.x > 0 {
                        if velocity.x.magnitude > 600 {
                            if checkCenterX + velocity.x > maxX {
                                checkCenterX = maxX + liveWindow.frame.width
                            }
                        }
                    }
                }

                if previewPosition == .topLeft || previewPosition == .topRight {
                    if velocity.y > 0 {
                        if velocity.y.magnitude > 600 {
                            if checkCenterY + velocity.y < minY {
                                checkCenterY = minY - liveWindow.frame.height
                            }
                        }
                    }
                } else if previewPosition == .bottomLeft || previewPosition == .bottomRight {
                    if velocity.y < 0 {
                        if velocity.y.magnitude > 600 {
                            if checkCenterY + velocity.y > maxY {
                                checkCenterY = maxY + liveWindow.frame.height
                            }
                        }
                    }
                }
                
                if reactor.previewSwipeOutEnabled {
                    guard xRange.contains(checkCenterX), yRange.contains(checkCenterY) else {
                        if shortsCollectionView?.getCurrentShowType() == .related && shortsCollectionView?.getIsFullNative() == true {
                            ShortformEventTraceManager.processPreviewShownHidden(shortsCollectionSrn: self.shortsCollectionView?.getPreviewEventTraceSrn(),isShown: false, isClick: false, shopliveSessionId: nil)
                            let shortsId = self.shortsCollectionView?.getCurrentShortsId()
                            let shortsDetail = self.shortsCollectionView?.getCurrentShortsDetail()
                            ShortformNativeOnEventsManager.sendNativeOnEvents(delegate: shortformDelegate, command: .preview_hidden, payload: nil, shortsId: shortsId, shortsDetail: shortsDetail)
                        }
                        ShopLiveShortform.close()
                        return
                    }
                }
                
                let animationDuration: CGFloat = 0.7
                
                if velocity.x.magnitude > 600 {
                    if centerX + velocity.x < minX {
                        centerX = minX
                    } else if centerX + velocity.x > maxX {
                        centerX = maxX
                    }
                }
                
                if velocity.y.magnitude > 600 {
                    if centerY + velocity.y < minY {
                        centerY = minY
                    } else if centerY + velocity.y > maxY {
                        centerY = maxY
                    }
                }
                
                switch alignPreviewPosition(previewCenter: .init(x: centerX, y: centerY)) {
                case .bottomLeft:
                    centerX = minX
                    centerY = maxY
                    break
                case .topLeft:
                    centerX = minX
                    centerY = minY
                case .topRight:
                    centerX = maxX
                    centerY = minY
                    break
                case .bottomRight:
                    centerX = maxX
                    centerY = maxY
                    break
                case .default:
                    centerX = maxX
                    centerY = maxY
                    break
                }
                
                let destination = CGPoint(x: centerX, y: centerY)
                let parameters = UISpringTimingParameters(dampingRatio: 1, initialVelocity: .init(dx: 0, dy: 0))
                let animator = UIViewPropertyAnimator(duration: TimeInterval(animationDuration), timingParameters: parameters)

                animator.addAnimations {
                    liveWindow.center = destination
                    self.alignPreviewView()
                }

                animator.startAnimation()
            default:
                break
            }
            
        }
        
        private func setupObserver() {
            NotificationCenter.default.addObserver(self, selector: #selector(handleNotification(_:)), name: NSNotification.Name("presentViewController"), object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(handleNotification(_:)), name: NSNotification.Name("enableTap"), object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(handleNotification(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(handleNotification(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        }
        
        private func teardownObserver() {
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name("presentViewController"), object: nil)
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name("enableTap"), object: nil)
            NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
            NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
            NotificationCenter.default.removeObserver(self)
        }
        
        @objc func handleNotification(_ notification: Notification) {
            switch notification.name {
            case UIResponder.keyboardWillShowNotification:
                guard self.reactor.enableKeyboardEvent else { return }
                self.reactor.isKeyboardShow = true
                self.handleKeyboardNoti(notification: notification)
                break
            case UIResponder.keyboardWillHideNotification:
                guard self.reactor.enableKeyboardEvent else { return }
                self.reactor.isKeyboardShow = false
                self.handleKeyboardNoti(notification: notification)
                break
            case Notification.Name("presentViewController"):
                guard let vc = notification.userInfo?["vc"] as? UIViewController else {
                    return
                }
                vc.modalPresentationStyle = .overFullScreen
                rootViewController.present(vc, animated: false)
                break
            case Notification.Name("enableTap"):
                guard let enable = notification.userInfo?["enable"] as? Bool else {
                    return
                }
                self.reactor.enableTapExplicit = enable
                break
            default:
                break
            }
        }
        
        private func handleKeyboardNoti(notification: Notification? = nil) {
            
            if let notification = notification, let keyboardFrameEndUserInfo = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
                let keyboardScreenEndFrame = keyboardFrameEndUserInfo.cgRectValue
                    
                let bottomPadding = UIApplication.topWindow_SL?.safeAreaInsets.bottom ?? 0
            
                self.reactor.keyboardHeight = keyboardScreenEndFrame.height - bottomPadding
            }
            
            let previewPosition: CGRect = self.previewPosition(with: self.reactor.previewScale, position: self.reactor.previewPosition)
            
            UIView.animate(withDuration: 0.3, delay: 0, options: []) { [weak self] in
                guard let self = self else { return }
                self.shortformWindow.frame = previewPosition
                self.shortformWindow.setNeedsLayout()
                self.shortformWindow.layoutIfNeeded()
            }
        }
        
        private func fullScreen(animated: Bool = false, reset: Bool = false) {
            self.reactor.shortsMode = .detail
            if animated { // animated 가 true면 preview click해서 전체 화면 진입
                self.shortsCollectionView?.setPreviewToDetailMaintainTimeInfo()
                UIView.animate(withDuration: 0.3, delay: 0) { [weak self] in
                    guard let self = self else { return }
                    self.shortsCollectionView?.takeSnapShot()
                    self.shortsCollectionView?.updateItemSize(UIScreen.main.bounds.size)
                    self.shortformWindow.frame = UIScreen.main.bounds
                    self.shortformWindow.isHidden  = false
                    self.shortsCollectionView?.modeChange(mode: .detail)
                    self.shortsCollectionView?.setCurrentCellVideoLayerGravity()
                    self.shortformWindow.layer.cornerRadius = 0
                    self.shortformWindow.layoutIfNeeded()
                } completion : { [weak self] _ in
                    guard let self = self else { return }
                    self.shortsCollectionView?.viewTappedInPreviewMode(reset: reset, shortsId: self.shortsCollectionView?.getCurrentShortsId(), srn: self.shortsCollectionView?.getCurrentShortsSrn())  {
                        self.shortsCollectionView?.setAudioSessionManager()
                        let sessionId = self.shortsCollectionView?.getCurrentShopliveSessionId()
                        ShortformEventTraceManager.processDetailOnPlayerShow(shortsCollectionSrn: self.shortsCollectionView?.getCurrentShortsSrn(), shopliveSessionId: sessionId)
                        ShortformNativeOnEventsManager.sendNativeOnEvents(delegate: self.shortformDelegate,command: .detail_on_player_shown, payload: nil, shortsId: nil, shortsDetail: nil)
                        self.shortformDelegate?.onDidAppear?()
//                        ShopLiveShortform.Delegate.receiveHandler.delegate?.onDidAppear?()
                    }
                }
            }
            else {
                self.shortsCollectionView?.updateItemSize(UIScreen.main.bounds.size)
                self.shortformWindow.frame = UIScreen.main.bounds
                self.shortformWindow.isHidden  = false
                self.shortformWindow.layer.cornerRadius = 0
                self.shortformWindow.layoutIfNeeded()
                shortformDelegate?.onDidAppear?()
//                ShopLiveShortform.Delegate.receiveHandler.delegate?.onDidAppear?()
            }
        }
        
        private func preview() {
            self.shortsCollectionView?.updateItemSize(self.previewPosition().size)
            self.reactor.shortsMode = .preview
            self.shortformWindow.frame = self.previewPosition()
            self.shortformWindow.isHidden  = false
            self.shortformWindow.layer.cornerRadius = reactor.previewCornerRadius
            self.shortformWindow.layoutIfNeeded()

        }
        
        func showPreview(_ item: ShortsCollectionBaseView?) {
            guard let item = item else { return }
            self.shortformWindow.resignKey()
            self.customerWindow?.makeKey()
            setItem(item) { [weak self] in
                self?.preview()
            }
        }
        
        //showPlay 불리는 조건이 무조건 ShortsCollectionBaseView init()임
        //따라서 fullScreen(aniamted : false)에서 eventTrace를 날릴 필요가 없음
        func showPlay(_ item: ShortsCollectionBaseView?) {
            guard let item = item else { return }
            self.shortformWindow.makeKey()
            setItem(item) { [weak self] in
                self?.fullScreen()
            }
        }
        
        func hide() {
            if self.reactor.shortsMode == .preview,let shortsModel = self.shortsCollectionView?.getCurrentShortsModel() {
                ShopLiveShortform.BridgeInterface.previewHidden(shorts: shortsModel)
            }
            shortsCollectionView?.close()
            reactor.resetProperties()
            self.shortsCollectionView = nil
            self.shortformWindow.isHidden = true
            shortformDelegate?.onDidDisAppear?()
//            ShopLiveShortform.Delegate.receiveHandler.delegate?.onDidDisAppear?()
        }
        
        private func clearPreviewItem() {
            rootViewController.view.subviews.compactMap { $0 as? ShopLiveWindowItemView }.forEach { $0.removeFromSuperview() }
        }
        
        func setItem(_ item: ShortsCollectionBaseView, completion: @escaping ()->Void) {
            // preview에 보여지고 있는 itemView 전체 제거
            clearPreviewItem()
            shortsCollectionView = item
            rootViewController.view.addSubview(item.itemView)
            item.itemView.fit_SL()
            rootViewController.view.bringSubviewToFront(item.itemView)
            item.itemView.translatesAutoresizingMaskIntoConstraints = false
            completion()
        }
        
        private var customerWindow : UIWindow?
        
        private lazy var shortformWindow: SLWindow = {
            let window = SLWindow()
            if #available(iOS 13.0, *) {
                window.windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
            }
            window.backgroundColor = .clear
            window.windowLevel = .statusBar - 1
            window.layer.masksToBounds = true
            window.frame = UIScreen.main.bounds
            window.center = self.previewPosition().center_SL
            window.rootViewController = rootViewController
            window.isHidden = true
            return window
        }()
        
        func getCurrentWindow() -> UIWindow {
            return self.shortformWindow
        }
        
        private func alignPreviewView() {
            guard let mainWindow = UIApplication.topWindow_SL else { return }
            let currentCenter = shortformWindow.center
            let center = mainWindow.center
            let isKeyboardShow = self.reactor.isKeyboardShow
            let keyboardHeight = self.reactor.keyboardHeight
            let _keyboardHeight: CGFloat = isKeyboardShow ? keyboardHeight : 0
            let rate = (mainWindow.frame.height - _keyboardHeight) / mainWindow.frame.height
            let isPositiveDiffX = center.x - currentCenter.x > 0
            let isPositiveDiffY = (center.y * rate) - currentCenter.y > 0
            let position: ShopLiveShortform.PreviewPosition = {
                switch (isPositiveDiffX, isPositiveDiffY) {
                case (true, true):
                    return .topLeft
                case (true, false):
                    return .bottomLeft
                case (false, true):
                    return .topRight
                case (false, false):
                    return .bottomRight
                }
            }()

            self.reactor.previewPosition = position
            self.handleKeyboardNoti()
        }
        
        private func alignPreviewPosition(previewCenter: CGPoint) -> ShopLiveShortform.PreviewPosition {
            guard let mainWindow = UIApplication.topWindow_SL else { return .bottomRight }
            let center = mainWindow.center
            let isKeyboardShow = self.reactor.isKeyboardShow
            let keyboardHeight = self.reactor.keyboardHeight
            let _keyboardHeight: CGFloat = isKeyboardShow ? keyboardHeight : 0
            let rate = (mainWindow.frame.height - _keyboardHeight) / mainWindow.frame.height
            let isPositiveDiffX = center.x - previewCenter.x > 0
            let isPositiveDiffY = (center.y * rate) - previewCenter.y > 0
            let position: ShopLiveShortform.PreviewPosition = {
                switch (isPositiveDiffX, isPositiveDiffY) {
                case (true, true):
                    return .topLeft
                case (true, false):
                    return .bottomLeft
                case (false, true):
                    return .topRight
                case (false, false):
                    return .bottomRight
                }
            }()
            
            
            return position
        }
        
        private func previewPosition(with scale: CGFloat = ShortFormConfigurationInfosManager.shared.shortsConfiguration.previewScale,
                                     position: ShopLiveShortform.PreviewPosition = ShortFormConfigurationInfosManager.shared.shortsConfiguration.previewPosition) -> CGRect {
            guard let mainWindow = UIApplication.topWindow_SL else { return .zero }
            var previewPosition: CGRect = .zero
            var origin = CGPoint.zero
            let isKeyboardShow = self.reactor.isKeyboardShow
            let safeAreaInsets = mainWindow.safeAreaInsets
            let previewSize = self.previewSize(with: scale)
            let previewFloatingOffset = self.reactor.previewFloatingOffset
            let previewEdgeInsets = self.reactor.previewEdgeInsets
            let previewFloatingOffsetBottom: CGFloat = previewFloatingOffset.bottom
            let keyboardHeight: CGFloat = isKeyboardShow ? self.reactor.keyboardHeight : 0
            
            let standardSize: CGSize = UIScreen.main.bounds.size
            
            switch position {
            case .bottomRight, .default:
                origin.x = standardSize.width - safeAreaInsets.right - previewEdgeInsets.right - previewSize.width - previewFloatingOffset.right
                origin.y = standardSize.height - safeAreaInsets.bottom - previewEdgeInsets.bottom - previewSize.height - keyboardHeight - previewFloatingOffsetBottom
            case .bottomLeft:
                origin.x = safeAreaInsets.left + previewEdgeInsets.left + previewFloatingOffset.left
                origin.y = standardSize.height - safeAreaInsets.bottom - previewEdgeInsets.bottom - previewSize.height - keyboardHeight - previewFloatingOffsetBottom
            case .topRight:
                origin.x = standardSize.width - safeAreaInsets.right - previewEdgeInsets.right - previewSize.width - previewFloatingOffset.right
                
                let isOutOfScreen = (standardSize.height - keyboardHeight - (safeAreaInsets.top + previewEdgeInsets.top + previewFloatingOffset.top)) < previewSize.height
                origin.y = isOutOfScreen ? standardSize.height - safeAreaInsets.bottom - previewEdgeInsets.bottom - previewSize.height - keyboardHeight - previewFloatingOffsetBottom : safeAreaInsets.top + previewEdgeInsets.top + previewFloatingOffset.top
            case .topLeft:
                origin.x = safeAreaInsets.left + previewEdgeInsets.left + previewFloatingOffset.left
                
                let isOutOfScreen = (standardSize.height - keyboardHeight - (safeAreaInsets.top + previewEdgeInsets.top + previewFloatingOffset.top)) < previewSize.height
                origin.y = isOutOfScreen ? standardSize.height - safeAreaInsets.bottom - previewEdgeInsets.bottom - previewSize.height - keyboardHeight - previewFloatingOffsetBottom : safeAreaInsets.top + previewEdgeInsets.top + previewFloatingOffset.top
            }

            previewPosition = CGRect(origin: origin, size: previewSize)

            return previewPosition
        }
        
        private func previewSize(with scale: CGFloat) -> CGSize {
            let width =  (UIScreen.isLandscape_SL ? UIScreen.main.bounds.height : UIScreen.main.bounds.width) * scale
            let height = (16 / 9) * width
            return CGSize(width: width, height: height)
        }
    }
}
extension ShopLiveShortform.SLShortFormWindow : ShortFormDetailRootViewControllerDelegate {
    func onStartRotation(to size : CGSize) {
        guard let collectionView = self.shortsCollectionView else { return }
        if collectionView.getCurrentShortsMode() == .detail {
            collectionView.onStartRotation(to: size)
        }
    }
    
    func onChangingRotation(to size : CGSize) {
        guard let collectionView = self.shortsCollectionView else { return }
        if collectionView.getCurrentShortsMode() == .preview {
            self.alignPreviewView()
        }
        else {
            collectionView.onChangingRotation(to: size)
        }
    }
    
    func onFinishedRotation(on size : CGSize) {
        guard let collectionView = self.shortsCollectionView else { return }
        if collectionView.getCurrentShortsMode() == .preview {
            collectionView.redrawPreviewDimLayer()
        }
        else {
            collectionView.onFinishedRotation(on: size)
        }
    }
}
extension ShopLiveShortform.SLShortFormWindow {
    func setPreviewDTO(dto : ShortformPreviewOptionDTO?) {
        reactor.setPreviewOptionDTO(dto: dto)
    }
}
extension ShopLiveShortform {
    class SLWindow: UIWindow, UIGestureRecognizerDelegate {
        func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
            return !(touch.view is UIButton)
        }
    }
}

