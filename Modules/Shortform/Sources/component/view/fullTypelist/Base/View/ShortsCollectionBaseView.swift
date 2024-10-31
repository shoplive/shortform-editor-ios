//
//  ShortsCollectionBaseView.swift
//  ShopLiveShortformSDK
//
//  Created by sangmin han on 8/29/23.
//

import Foundation
import UIKit
import ShopliveSDKCommon
import AVKit

class ShortsCollectionBaseView : ShopLiveWindowItemView, SLShortsWindowItemViewable {
    typealias ShortsMode = ShopLiveShortform.ShortsMode
    
    var itemView: ShopLiveWindowItemView {
        return self
    }
    
    var viewModel : ShortsCollectionBaseViewModel
    weak var shortformDelegate : ShopLiveShortformReceiveHandlerDelegate?
    
    
    lazy var feedListLayout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.itemSize = UIScreen.main.bounds.size
        return layout
    }()
    
    lazy var shortsListView: SLCollectionView = {
        let view = SLCollectionView(frame: self.frame, collectionViewLayout: feedListLayout)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentInsetAdjustmentBehavior = .never
        view.register(ShortsCell.self, forCellWithReuseIdentifier: ShortsCell.cellId)
        view.isPagingEnabled = true
        view.decelerationRate = UIScrollView.DecelerationRate.fast
        view.dataSource = self
        view.delegate = self
        view.prefetchDataSource = self
        view.backgroundColor = .black
        view.scrollsToTop = false
        view.showsVerticalScrollIndicator = false
        view.showsHorizontalScrollIndicator = false
        view.isPrefetchingEnabled = true
        return view
    }()
    
    var snapShotViewBackgroundView : UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .black
        view.isHidden = true
        return view
    }()
    
    var snapShotView: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        view.image = nil
        view.contentMode = .scaleAspectFill
        view.isHidden = true
        return view
    }()
    
    var snapShotViewWidthAnc : NSLayoutConstraint?

    var snapShotViewHeightAnc : NSLayoutConstraint?
    
    lazy var inAppPreviewView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        view.isHidden = true
        return view
    }()
    
    lazy var previewDimLayer: CAGradientLayer = {
        let layer0 = CAGradientLayer()
        layer0.colors = [
            UIColor(red: 0, green: 0, blue: 0, alpha: 0.4).cgColor,
            UIColor(red: 0, green: 0, blue: 0, alpha: 0).cgColor
        ]
        layer0.locations = [0, 1]
        layer0.startPoint = CGPoint(x: 0.25, y: 0.5)
        layer0.endPoint = CGPoint(x: 0.75, y: 0.5)
        layer0.transform = CATransform3DMakeAffineTransform(CGAffineTransform(a: 0, b: 1, c: -1, d: 0, tx: 1, ty: 0))
        layer0.name = "gradationLayer"
        return layer0
    }()
    
    lazy var previewDim: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.addSublayer(previewDimLayer)
        view.layer.cornerRadius = 10
        return view
    }()
    
    lazy var closeButton: UIButton = {
        let view = UIButton()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setImage(ShopLiveShortformSDKAsset.slClosebutton.image, for: .normal)
        view.addTarget(self, action: #selector(didTouchCloseButton), for: .touchUpInside)
        return view
    }()
    
    var closeButtonTopConstraint: NSLayoutConstraint?
    var closeButtonLeadingConstraint: NSLayoutConstraint?
    var minimumPreviewViewWidth: CGFloat = 60
    
    var lastAttachedShortsModel : ShopLiveShortform.ShortsModel?
    var lastDetachedShortsModel : ShopLiveShortform.ShortsModel?
    var lastContentOffsetY : CGFloat = 0
    
    init(viewmodel : ShortsCollectionBaseViewModel,shortformDelegate : ShopLiveShortformReceiveHandlerDelegate?) {
        self.viewModel = viewmodel
        self.shortformDelegate = shortformDelegate
        super.init(frame: .zero)
        viewmodel.delegate = self
        layout()
        setupObserver()
        bindData()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        if viewModel.shortsMode == .detail {
            ShortformNativeOnEventsManager.sendNativeOnEvents(delegate : shortformDelegate  ,command: .detail_on_player_dismiss, payload: nil, shortsId: nil, shortsDetail: nil)
            ShortformEventTraceManager.processDetailOnPlayerDismiss(shortsCollectionSrn: self.getCurrentShortsSrn(), shopliveSessionId: self.getCurrentShopliveSessionId())
        }
        self.shortformDelegate = nil
        teardownObserver()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if inAppPreviewView.frame.width != .zero {
            setCloseButtonVisible(viewModel.shortsMode == .preview && viewModel.getPreviewUseCloseBtn() )
        }
        
        if let selfSize = viewModel.superviewSize, selfSize == self.frame.size, !viewModel.isViewAppeared {
            viewModel.isViewAppeared = true
        }
        
        updateCloseButtonDim()
    }
    
    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        if let superView = newSuperview {
            self.setSuperviewSize(size: superView.frame.size)
        }
    }
    
    override func removeFromSuperview() {
        super.removeFromSuperview()
        let visibleIndexPath = self.shortsListView.indexPathsForVisibleItems
        viewModel.sendCellDetachedEventOnRemoveFromSuperView(indexPaths: visibleIndexPath)
    }
    
    func setSuperviewSize(size : CGSize){
        if size == .zero { return }
        viewModel.verticalCollectionBounds = size
        viewModel.horizontalCollectionBounds = size.transpolate_SL
        viewModel.superviewSize = size
    }
    
    
    func bindData() {}
    
    @objc func didTouchCloseButton() {
        guard viewModel.getPreviewUseCloseBtn() else { return }
        if viewModel.currentApiType == .related && viewModel.isFullNative {
            let previewEventTraceSrn = self.getPreviewEventTraceSrn()
            ShortformEventTraceManager.processPreviewShownHidden(shortsCollectionSrn: previewEventTraceSrn ,isShown: false, isClick: true, shopliveSessionId: nil )
            ShortformEventTraceManager.processPreviewShownHidden(shortsCollectionSrn: previewEventTraceSrn, isShown: false, isClick: false, shopliveSessionId: nil)
            
            ShortformNativeOnEventsManager.sendNativeOnEvents(delegate: shortformDelegate, command: .preview_click_close, payload: nil, shortsId: viewModel.currentShortsId, shortsDetail: viewModel.currentShorts?.shortsDetail)
            ShortformNativeOnEventsManager.sendNativeOnEvents(delegate: shortformDelegate, command: .preview_hidden, payload: nil, shortsId: viewModel.currentShortsId, shortsDetail: viewModel.currentShorts?.shortsDetail)
        }
        ShopLiveShortform.close()
    }
    
    func setSnapShotViewHidden(animate : Bool, isHidden : Bool) {
        snapShotViewBackgroundView.isHidden = isHidden
        if animate {
            UIView.animate(withDuration: 0.1, delay: 0) { [ weak self] in
                guard let self = self else { return }
                self.snapShotView.alpha = isHidden ? 0 : 1
            } completion: { [weak self] _ in
                guard let self = self else { return }
                self.snapShotView.isHidden = isHidden
            }
        }
        else {
            self.snapShotView.alpha = isHidden ? 0 : 1
            snapShotView.isHidden = isHidden
        }
    }
    
    func updateItemSize(_ size: CGSize) {
        if UIScreen.isLandscape_SL {
            self.viewModel.horizontalCollectionBounds = size
        }
        else {
            self.viewModel.verticalCollectionBounds = size
        }
        self.feedListLayout.itemSize = size
    }
    
    func setCurrentCellVideoLayerGravity() {
        (shortsListView.visibleCells as? [ShortsCell])?.compactMap({ $0 }).forEach({ cell in
            cell.setVideoLayerGravityFromParentView()
        })
    }
    
    func close() {
        viewModel.postStopVideoNotification()
    }
    
    func takeSnapShot() {
        viewModel.postTakeSnapShotForWindowNotification()
    }
    
    func modeChange(mode: ShortsMode) {
        viewModel.shortsMode = mode
        viewModel.postModeChangeNotification()
    }
    
    /**
     override needed
     */
    func viewTappedInPreviewMode(reset: Bool, shortsId: String?, srn: String?, completion : (() -> ())? = nil) {
        
    }
    
    /**
     override needed
     */
    func setPreviewToDetailMaintainTimeInfo() {
        
    }
    
    func setShopLiveSessionId(sessionId : String?) {
        viewModel.setShopLiveSessionId(sessionId: sessionId)
    }
    
    func cleanUpMemoryLeak() {
        (self.shortsListView.visibleCells as? [ShortsCell])?.forEach({ cell in
            cell.cleanUpMemory()
        })
    }
    
    func requestSnapShotForWindow() {
        guard let cell = self.shortsListView.visibleCells.first as? ShortsCell else { return }
        cell.takeSnapShotForWindow(srn: viewModel.currentShortsSrn)
    }
    
    func playeCurrentCell() {
        self.playCurrentItem()
    }
    
    func pauseCells() {
        guard let cells = self.shortsListView.visibleCells as? [ShortsCell] else { return }
        for cell in cells {
            cell.pause()
        }
    }
}
extension ShortsCollectionBaseView {
    func getPreviewEventTraceSrn() -> String? {
        return viewModel.getPreviewEventTraceSrn()
    }
    
    func getCurrentShowType() -> ShortsCollectionBaseViewModel.ShortsApiType {
        return self.viewModel.currentApiType
    }
    
    func getIsFullNative() -> Bool {
        return self.viewModel.isFullNative
    }
    
    func getCurrentShortsMode() -> ShopLiveShortform.ShortsMode {
        return viewModel.shortsMode
    }
    
    func getCurrentShortsId() -> String? {
        return viewModel.currentShortsId
    }
    
    func getCurrentShortsSrn() -> String? {
        return viewModel.currentShortsSrn
    }
    
    func getCurrentShortsModel() -> ShopLiveShortform.ShortsModel? {
        return viewModel.currentShorts
    }
    
    func getCurrentShortsDetail() -> ShortsDetail? {
        return viewModel.currentShorts?.shortsDetail
    }
    
    func getCurrentShopliveSessionId() -> String? {
        return viewModel.getCurrentShopliveSessionId()
    }
    
}
//MARK: - layout
extension ShortsCollectionBaseView {
    func setCloseButtonVisible(_ visible: Bool) {
        let inAppPreviewViewWidth = inAppPreviewView.frame.width
        if inAppPreviewViewWidth < minimumPreviewViewWidth {
            inAppPreviewView.isHidden = true
        } else {
            let constraintGap = (inAppPreviewViewWidth - minimumPreviewViewWidth) / 25
            let gap = 4 + (constraintGap > 4 ? 4 : constraintGap)
            closeButtonTopConstraint?.constant = gap
            closeButtonLeadingConstraint?.constant = gap
            self.bringSubviewToFront(inAppPreviewView)
            inAppPreviewView.isHidden = !visible
            updateCloseButtonDim()
        }
    }
    
    func updateCloseButtonDim() {
        previewDimLayer.bounds = inAppPreviewView.bounds.insetBy(dx: -0.5*inAppPreviewView.bounds.size.width, dy: -0.5*inAppPreviewView.bounds.size.height)
        previewDimLayer.position = inAppPreviewView.center
    }
    
    @objc func layout() {
        self.addSubview(shortsListView)
        shortsListView.isScrollEnabled = viewModel.isSwipable
        self.addSubview(snapShotViewBackgroundView)
        self.addSubview(snapShotView)
        self.bringSubviewToFront(snapShotViewBackgroundView)
        self.bringSubviewToFront(snapShotView)
        
        setupCloseButton()
        
        NSLayoutConstraint.activate([
            shortsListView.topAnchor.constraint(equalTo: self.topAnchor),
            shortsListView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            shortsListView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            shortsListView.bottomAnchor.constraint(equalTo: self.bottomAnchor),

            snapShotViewBackgroundView.topAnchor.constraint(equalTo: self.topAnchor),
            snapShotViewBackgroundView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            snapShotViewBackgroundView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            snapShotViewBackgroundView.bottomAnchor.constraint(equalTo: self.bottomAnchor),


            snapShotView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            snapShotView.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ])

        if UIDevice.current.userInterfaceIdiom == .pad {
            setSnapShotLayoutForIpad()
        } else {
            setSnapShotLayoutForIphoneCenterCrop()
        }
    }
    
    func setSnapShotLayoutForIpad() {
        self.removeOldSnapShotWidthAndHeightConstraint()
        self.snapShotViewHeightAnc = snapShotView.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 1.0)
        self.snapShotViewHeightAnc?.isActive = true

        let resolution = ShortFormConfigurationInfosManager.shared.shortsConfiguration.resolution
        self.snapShotViewWidthAnc = snapShotView.widthAnchor.constraint(equalTo: self.heightAnchor, multiplier: resolution.width/resolution.height)
        self.snapShotViewWidthAnc?.isActive = true
    }

    func setSnapShotLayoutForIphoneCenterCrop() {
        self.removeOldSnapShotWidthAndHeightConstraint()
        self.snapShotViewHeightAnc = snapShotView.heightAnchor.constraint(equalTo: self.heightAnchor)
        self.snapShotViewHeightAnc?.isActive = true

        self.snapShotViewWidthAnc = snapShotView.widthAnchor.constraint(equalTo: self.widthAnchor)
        self.snapShotViewWidthAnc?.isActive = true
    }

    func setSnapShotLayoutWithRatioSize(ratioSize : CGSize) {
        self.removeOldSnapShotWidthAndHeightConstraint()
        let mainWidth = UIScreen.main.bounds.width
        let mainHeight = UIScreen.main.bounds.height

        if ratioSize.width > ratioSize.height {
            self.snapShotViewWidthAnc = snapShotView.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 1)
            self.snapShotViewWidthAnc?.isActive = true

            let resolution = ratioSize.height / ratioSize.width
            self.snapShotViewHeightAnc = snapShotView.heightAnchor.constraint(equalTo: self.widthAnchor, multiplier: resolution)
            self.snapShotViewHeightAnc?.isActive = true
        }
        else {
            self.snapShotViewHeightAnc = snapShotView.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 1)
            self.snapShotViewHeightAnc?.isActive = true

            let resolution = ratioSize.width / ratioSize.height
            self.snapShotViewWidthAnc = snapShotView.widthAnchor.constraint(equalTo: self.heightAnchor, multiplier: resolution)
            self.snapShotViewWidthAnc?.isActive = true
        }
    }

    func removeOldSnapShotWidthAndHeightConstraint() {
        self.snapShotViewHeightAnc?.isActive = false
        self.snapShotViewHeightAnc = nil
        self.snapShotViewWidthAnc?.isActive = false
        self.snapShotViewWidthAnc = nil
    }
    
    func setupCloseButton() {
        self.addSubview(inAppPreviewView)
        inAppPreviewView.fitToSuperView_SL()
        inAppPreviewView.addSubview(previewDim)
        previewDim.heightAnchor.constraint(equalToConstant: 60).isActive = true
        previewDim.leadingAnchor.constraint(equalTo: inAppPreviewView.leadingAnchor, constant: 0).isActive = true
        previewDim.trailingAnchor.constraint(equalTo: inAppPreviewView.trailingAnchor, constant: 0).isActive = true
        previewDim.topAnchor.constraint(equalTo: inAppPreviewView.topAnchor, constant: 0).isActive = true
        
        inAppPreviewView.addSubview(closeButton)
        closeButtonLeadingConstraint = closeButton.leadingAnchor.constraint(equalTo: inAppPreviewView.leadingAnchor, constant: 8)
        closeButtonLeadingConstraint?.isActive = true
        closeButtonTopConstraint = closeButton.topAnchor.constraint(equalTo: inAppPreviewView.topAnchor, constant: 8)
        closeButtonTopConstraint?.isActive = true
        closeButton.widthAnchor.constraint(equalToConstant: 24).isActive = true
        closeButton.heightAnchor.constraint(equalToConstant: 24).isActive = true
        self.bringSubviewToFront(inAppPreviewView)
    }
    
    
    
}
extension ShortsCollectionBaseView : UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.shortsListData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        //세로에서 가로모드로 회전할 경우 현재 보고 있는 셀도 다시 생성되어서 seekbar가 처음으로 되돌아감 따라서 이전에 저장해 두었던 셀을 고대로 다시 가져다주면 됨
        viewModel.loadWebViewsFor(indexPath: [indexPath])
        
        if self.viewModel.isOnRotation, let latestCell = self.viewModel.latestCell.latestCell,
           self.viewModel.latestActivePageIndex == indexPath.row {
            latestCell.handleDeviceRotation(isLandscape: UIScreen.isLandscape_SL)
            latestCell.reloadWebView()
            return latestCell
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ShortsCell.cellId, for: indexPath) as! ShortsCell
        
        if let data = viewModel.shortsListData[safe : indexPath.row] {
            var seekToOnPreviewToFullScreen : ShortformCurrentTimeDTO? = nil
            if viewModel.getVideoShortsIdTimeWhenPreviewTapped() ?? "1" == data.shortsId ?? "2" &&
                viewModel.getShortsMode() != .preview &&
                viewModel.getCanUseShortformCurrentTimeDTO() == true {
                seekToOnPreviewToFullScreen = viewModel.getVideoCurrentTimeWhenPreviewTapped()
                viewModel.setVideoCurrentTimeWhenPreviewTapped(time: nil)
                viewModel.setCanUseShortformCurrentTimeDTO(canUse: false)
            }
            
            cell.configureCell(webView: viewModel.getWebview(for: data.shortsId ?? "",indexPath: indexPath),
                               youtubeWebView: viewModel.getYoutubePlayerView(for: data.shortsId ?? "", indexPath: indexPath),
                               model: data,
                               delegate: self,
                               shortformDelegate: shortformDelegate,
                               indexPath: indexPath,
                               viewProvideype: viewModel.viewProvideType,
                               shopliveSessionId: viewModel.getCurrentShopliveSessionId(),
                               shortsMode: viewModel.shortsMode,
                               isLandScape: UIScreen.isLandscape_SL,
                               isMute: viewModel.getMuted(),
                               seekToOnInitial: seekToOnPreviewToFullScreen,
                               setShortsSingleDetailViewPayload: self.viewModel.getSetShortsSingleDetailViewPayload(at: indexPath, shortsModel: data, isYoutube: viewModel.checkIsYoutubePlayer(indexPath: indexPath)),
                               preferredForwardBufferDuration: viewModel.getPreferredForwardBufferDuration())
        }
        
        if viewModel.didAnimatePreviewToFullScreen && indexPath.row == 0 {
            viewModel.didAnimatePreviewToFullScreen = false
            cell.play(skipIfPaused: false)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if self.viewModel.isOnRotation { return }
        if let latestCell = viewModel.latestCell.latestCell {
            latestCell.setMute(viewModel.getMuted())
        }
        
        if let toPlayPage = viewModel.scrollToPage , toPlayPage == indexPath.row, let playCell = cell as? ShortsCell {
            viewModel.latestCell.setLatest(latestCell: playCell, indexPath: indexPath)
        }
        if let cell = cell as? ShortsCell {
            if self.viewModel.shortsMode != .preview && cell.isWebViewExist() == false {
                cell.reloadWebView()
            }
            cell.setMute(viewModel.getMuted())
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        didEndDisplaying cell: UICollectionViewCell,
                        forItemAt indexPath: IndexPath) {
        viewModel.deleteWebViewsWhenCellDidEndDisplaying(indexPath: indexPath)
        guard let playCell = cell as? ShortsCell else {
            return
        }
        
        playCell.stop()
    }
    
    /**
     override needed
     */
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        indexPaths.map{ $0.row }.forEach { index in
            viewModel.preDownlaodPosterImage(index: index)
            viewModel.preDownloadYoutubePosterImage(index: index)
        }
        viewModel.loadWebViewsFor(indexPath: indexPaths)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if viewModel.blockScrollViewDidScrollForRotation == false {
            self.playCurrentItem()
        }
        if let shortsCell = self.shortsListView.visibleCells as? [ShortsCell] {
            shortsCell.forEach { cell in
                cell.checkAttachedAndDetached(scrollView: shortsListView, coordinateView: self)
            }
        }
    }
    
    /**
     v1 overrided
     */
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            guard let index = self.getCenterItemIndexPath()?.row, let srn = self.viewModel.shortsListData[safe: index]?.srn, let latestCell = self.viewModel.latestCell.latestCell else { return }
            
            latestCell.play(skipIfPaused: true)
            if self.viewModel.latestActivePageIndex != index {
                self.viewModel.latestActivePageIndex = index
                self.viewModel.postActivePageNotification(srn: srn, index: index)
            }
        }
    }
    
    
}

extension ShortsCollectionBaseView {
    
    func playWhenReconnect() {
        self.shortsListView.reloadDataWithCompletion(items: []) {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                guard let currentIndexPath = self.shortsListView.indexPathsForVisibleItems.first else { return }
                guard let srn = self.viewModel.shortsListData[currentIndexPath.row].srn else { return }
                guard let cell = self.shortsListView.cellForItem(at: currentIndexPath) as? ShortsCell else { return }
                self.viewModel.updateWebViewPoolForReconnection(currentIndex: currentIndexPath)
                self.viewModel.postActivePageNotification(srn: srn, index: currentIndexPath.row)
                self.viewModel.latestCell.setLatest(latestCell: cell,indexPath: currentIndexPath)
                cell.play(skipIfPaused: false)
            }
        }
    }
    
    func getCenterItemIndexPath() -> IndexPath? {
        guard let centerItem = getCenterItem() else { return nil }
        return shortsListView.indexPath(for: centerItem)
    }
    
    func getCenterItem() -> ShortsCell? {
        let listCenter = self.shortsListView.contentOffset.y + self.shortsListView.frame.center_SL.y
        return shortsListView.visibleCells.sorted { e1, e2 in
            return abs(listCenter - e1.convert(e1.bounds, to: self.shortsListView).center_SL.y) < abs(listCenter - e2.convert(e2.bounds, to: self.shortsListView).center_SL.y)
        }.first as? ShortsCell
    }
    
    func playCurrentItem() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            guard let centerItem = self.getCenterItem() else {
                return
            }
            
            guard let latestCell = self.viewModel.latestCell.latestCell, latestCell != centerItem else {
                return
            }
            latestCell.pause()
            self.viewModel.latestCell.setLatest(latestCell: centerItem, indexPath: self.shortsListView.indexPath(for: centerItem))
            centerItem.setMute(self.viewModel.getMuted())
            centerItem.play(skipIfPaused: false)
        }
    }
}

extension ShortsCollectionBaseView : ShortsCollectionBaseViewModelDelegate {
    
    func setAudioSessionManager() {
        let audioSessionManager = AudioSessionManager.shared
        audioSessionManager.setCategory(category: .playback, options: audioSessionManager.currentCategoryOptions)
        if self.viewModel.shortsMode == .preview {
            audioSessionManager.setCategory(category: .playback, options: .mixWithOthers)
        }
        else {
            
            if viewModel.getMuted() == true { //ShortFormConfigurationInfosManager.shared.shortsConfiguration.mutedWhenStart
                viewModel.setIsMuted(isMuted: true)
                audioSessionManager.setCategory(category: .playback, options: [])
            }
            else {
                viewModel.setIsMuted(isMuted: false)
                if ShortFormConfigurationInfosManager.shared.shortsConfiguration.mixWithOthers == true {
                    audioSessionManager.setCategory(category: .playback, options: .mixWithOthers)
                }
                else {
                    audioSessionManager.setCategory(category: .playback, options: [])
                }
            }
        }
    }
    
    func playWhenNetworkReconnected() {
        self.playWhenReconnect()
    }
    
    func reloadData(completion: (() -> ())?) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.shortsListView.reloadDataWithCompletion(items: self.viewModel.getUpdatingIndexPaths()) {
                completion?()
            }
        }
    }
    
    func insertItemsWithOutAnimation(updateIndexPaths: [IndexPath]) {
        UIView.performWithoutAnimation { [weak self] in
            guard let self = self else { return }
            self.shortsListView.insertItems(at: self.viewModel.getUpdatingIndexPaths())
        }
    }
    
    func setScrollEnabled(isEnabled: Bool) {
        self.shortsListView.isScrollEnabled = isEnabled
    }
    
    func onViewAppeared() {
        if let pageTo = self.viewModel.scrollToPage {
            self.playPage(pageTo)
        }
    }
    
    func playToPage(index: Int) {
        self.playPageTo(index)
    }
    
    func setCloseBtnVisible(isVisible: Bool) {
        self.setCloseButtonVisible(isVisible)
    }
    
    func getLoadedCells(from : Int, to : Int) -> [ShortsCell]? {
        return (from...to).map{ IndexPath(row: $0, section: 0) }.compactMap { indexPath -> ShortsCell? in
            return self.shortsListView.cellForItem(at: indexPath) as? ShortsCell
        }
    }
    
    func getCurrentIndexPath() -> IndexPath? {
        let contentOffsety = shortsListView.contentOffset.y
        let contentHeight = shortsListView.frame.size.height
        guard contentHeight > 0 else {
            return nil
        }
        let index = Int(contentOffsety / contentHeight)
        return IndexPath(row: index, section: 0)
    }
    
    func getIndexPathsForVisibleItems() -> [IndexPath] {
        return self.shortsListView.indexPathsForVisibleItems
    }
    
    func getCellForAt(indexPath: IndexPath) -> UICollectionViewCell? {
        return shortsListView.cellForItem(at: indexPath)
    }
    
    func openOsShareSheet(url: String) {
        guard let parent = self.parentViewController_SL else { return }
        parent.showShareSheet_SL(url: url)
    }
}

