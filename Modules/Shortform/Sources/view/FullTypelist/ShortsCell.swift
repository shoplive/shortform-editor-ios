//
//  ShortsCell.swift
//  matrix-shortform-ios
//
//  Created by 김우현 on 2/26/23.
//

import UIKit
import ShopLiveSDKCommon

protocol ShortsCellDelegate: AnyObject {
    func didFinishdPlayingShorts(cell: ShopLiveShortform.ShortsCell, item: ShopLiveShortform.ShortsModel?)
    func shortsCommand(name: String, payload: [String: Any]?)
    func didFinishLoadingWebView()
    func getShortsListDataForV2ActivePage() -> [ShopLiveShortform.ShortsModel]?
}

extension ShopLiveShortform {
    class ShortsCell: UICollectionViewCell {
        
        class ShortsCellModel {
            var shorts: ShortsModel?
            
            func configure(shorts: ShortsModel) {
                self.shorts = shorts
            }
                        
        }
        
        private weak var shortsView: ShortsView?
        
        private(set) var shortsCellModel = ShortsCellModel()
        
        weak var delegate: ShortsCellDelegate?
        
        private var isCurrentOrientationLandscape : Bool = UIScreen.isLandscape_SL
        
        private var indexPath : IndexPath?
        
        override init(frame : CGRect){
            super.init(frame: frame)
            self.clipsToBounds = true
            
        }
        
        required init(coder : NSCoder){
            fatalError()
        }
        
        override func prepareForReuse() {
            super.prepareForReuse()
        }
        
        func configure(webView : SLWebView, shorts: ShortsModel, shortsMode: ShopLiveShortform.ShortsMode, contentIndex: IndexPath, isLandScape : Bool,indexPath : IndexPath,currentOverlayUrl : URL?, currentViewProvideType : ShortsCollectionBaseViewModel.ViewProvidedType,shopliveSessionId : String?) {
            shortsCellModel.configure(shorts: shorts)
            
            self.indexPath = indexPath
            
            if self.shortsView != nil {
                self.shortsView?.removeFromSuperview()
                self.shortsView = nil
            }
            
            let shortsView = ShortsView(webView: webView,
                                        shorts: shorts,
                                        shortsMode: shortsMode,
                                        contentIndex: contentIndex.row,
                                        currentOverlayUrl: currentOverlayUrl,
                                        currentViewProvideType: currentViewProvideType,shopliveSessionId: shopliveSessionId)
            
            self.contentView.addSubview(shortsView)
            shortsView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                shortsView.topAnchor.constraint(equalTo: self.topAnchor),
                shortsView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
                shortsView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
                shortsView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
            ])
            self.shortsView = shortsView
            self.shortsView?.delegate = self
            handleDeviceRotation(isLandScape: isLandScape)
            
        }
        
        func handleDeviceRotation(isLandScape : Bool){
            guard let shortsView = self.shortsView else { return }
            if isCurrentOrientationLandscape != isLandScape {
                isCurrentOrientationLandscape = isLandScape
                shortsView.invalidateLayout()
                shortsView.sendWebToSafeareaInfo()
            }
        }
        
        func getCellIndexPath() -> IndexPath? {
            return self.indexPath
        }
        
        func reconShortsView() {
            self.shortsView?.delegate = self
        }
        
        func replay() {
            reconShortsView()
            shortsView?.replay()
        }
        
        func play(_ skipIfPaused: Bool = false) {
            reconShortsView()
            shortsView?.play(skipIfPaused)
        }
        
        func pause() {
            shortsView?.pause()
        }
        
        func stop() {
            shortsView?.stop()
        }
        
        func setMute(_ mute: Bool) {
            shortsView?.setMute(mute)
        }
        
        func setShortsMode(_ mode: ShortsMode) {
            shortsView?.setShortsMode(mode)
        }
        
        func reloadWebview() {
            shortsView?.reloadWebview()
        }
        
        func isWebViewExist() -> Bool {
            return shortsView?.isWebViewExist() ?? false
        }
        
        func reConfigureWebView() {
            shortsView?.reloadWebview()
        }
        
    }
}

extension ShopLiveShortform.ShortsCell: ShortsViewDelegate {
    
    func shortsCommand(name: String, payload: [String : Any]?) {
        delegate?.shortsCommand(name: name, payload: payload)
    }
    
    func didFinishedPlayingShorts(item: ShopLiveShortform.ShortsModel) {
        delegate?.didFinishdPlayingShorts(cell: self, item: shortsCellModel.shorts)
    }
    
    func didFinishLoadingWebView() {
        delegate?.didFinishLoadingWebView()
    }
    
    func getShortsListDataForV2ActivePage() -> [ShopLiveShortform.ShortsModel]? {
        return delegate?.getShortsListDataForV2ActivePage()
    }
}
