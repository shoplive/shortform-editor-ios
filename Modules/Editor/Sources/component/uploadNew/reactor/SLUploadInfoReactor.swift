//
//  SLUploadInfoReactor.swift
//  ShopLiveShortformEditorSDK
//
//  Created by sangmin han on 11/6/23.
//

import Foundation
import UIKit
import ShopliveSDKCommon


class SLUploadInfoReactor : NSObject, SLReactor {
    typealias globalConfig = ShopLiveEditorConfigurationManager
    
    enum Action {
        case requestVideoThumbnail
        case viewDidLoad
        case setTitle(String)
        case setDesc(String)
        case setTags([String])
        case requestUploadProcess
        case requestIfUploadIsAvailable
        case requestShowUploadPreview
        case titleDidBeginEditing(UITextView)
        case titleDidEndEditing(UITextView)
        case titleDidChange(UITextView)
        case descriptoinDidBeginEditing(UITextView)
        case descriptoinDidEndEditing(UITextView)
        case descriptionDidChange(UITextView)
        case requestPopView
        case setShortformEditorDelegate(ShopLiveShortformEditorDelegate?)
        case setVideoEditorDelegate(ShopLiveVideoEditorDelegate?)
    }
    
    enum Result {
        case setVideoThumbnail(UIImage?)
        case setTitle(String?)
        case setTitleTextColor(UIColor)
        case setDescription(String?)
        case setDescriptionTextColor(UIColor)
        case setTags([String]?)
        case setLoadingVisible(Bool)
        case setIsUploadIsAvailable(Bool)
        case setViewEndEditing(Bool)
        case showToast(String)
        case showUploadPreview(SLUploadAttachmentInfo)
        case popView(SLUploadAttachmentInfo)
        
        case setDescriptionsFieldsVisibility(Bool)
        case setTagsFieldVisibility(Bool)
        case handleKeyboard(CGRect)
        case setKeyBoardDoneAccesoryView
    }
    
    //view properties
    lazy private var bundle : Bundle = {
        return Bundle(for: type(of: self))
    }()
    
    private var textColor: UIColor {
        return UIColor(red: 51/255, green: 51/255, blue: 51/255, alpha: 1.0)
    }
    
    private var textFieldTextColor: UIColor {
        return UIColor(red: 51/255, green: 51/255, blue: 51/255, alpha: 1.0)
    }
    
    private var textFieldPlaceHolderColor : UIColor {
        return UIColor(red: 143/255, green: 143/255, blue: 143/255, alpha: 1.0)
    }
    
    private var titleTextFieldPlaceHolderText : String {
        return "uploadinfo.title.placeholder".localizedString(bundle: bundle)
    }
    
    private var descriptionTextFieldPlaceHolderText : String {
        return "uploadinfo.description.placeholder".localizedString(bundle: bundle)
    }
    
    private var isKeyboardShow : Bool = false
    private var iqKeyboardManagerIsInstalled : Bool = false
    
    
    private var thumbnailPath : String {
        FileManager.default.temporaryDirectory.appendingPathComponent("shortform-thumbnail.jpg").absoluteString
    }
    private var temporaryUploadInfo: SLUploadAttachmentInfo?
    private var videoUrl : String?
    private var videoData : ShortsVideo?
    private var videoDuration : Int {
        if let duration = videoData?.getVideoDuration() {
            return Int(ceil(duration * 1000))
        }
        return 0
    }
    
    //upload infos
    private var uploadTitle : String = ""
    private var uploadDescription : String = ""
    private var uploadTags : [String] = []
    
    private weak var shortformEditorDelegate : ShopLiveShortformEditorDelegate?
    private weak var videoEditorDelegate : ShopLiveVideoEditorDelegate?
    
    var onMainQueueResultHandler : ((Result) -> ())?
    var resultHandler: ((Result) -> ())?
    
    init(uploadInfo : SLUploadAttachmentInfo) {
        if let videoUrl = URL(string: uploadInfo.videoUrl) {
            videoData = ShortsVideo(videoUrl: videoUrl)
        }
        self.temporaryUploadInfo = uploadInfo
        self.videoUrl = uploadInfo.videoUrl
    }
    
    init(videoUrl : String) {
        self.videoUrl = videoUrl
        if let videoUrl = URL(string: videoUrl) {
            videoData = ShortsVideo(videoUrl: videoUrl)
        }
    }
    
    deinit {
        ShopLiveLogger.debugLog("[ShopliveShortformEditor] SLUploadInfoReactor deinited")
        removeObserver()
    }
    
    func action(_ action: Action) {
        switch action {
        case .setShortformEditorDelegate(let delegate):
            self.shortformEditorDelegate = delegate
        case .setVideoEditorDelegate(let delegate):
                    self.videoEditorDelegate = delegate
            
        case .requestVideoThumbnail:
            self.makeVideoThumbnail()
        case .viewDidLoad:
            self.onViewDidLoad()
            
        case .setTitle(let title):
            self.uploadTitle = title
        case .setDesc(let desc):
            self.uploadDescription = desc
        case .setTags(let tags):
            self.uploadTags = tags
        
        case .titleDidBeginEditing(let tv):
            self.onTitleDidBeginEditing(textView: tv)
        case .titleDidEndEditing(let tv):
            self.onTitleDidEndEditing(textView: tv)
        case .titleDidChange(let tv):
            self.onTitleDidChange(textView: tv)
        
        case .descriptoinDidBeginEditing(let tv):
            self.onDescriptionDidBeginEditing(textView: tv)
        case .descriptoinDidEndEditing(let tv):
            self.onDescriptionDidEndEditing(textView: tv)
        case .descriptionDidChange(let tv):
            self.onDescriptionDidChange(textView: tv)
            
        case .requestIfUploadIsAvailable:
            self.checkUploadInfoValidate()
        case .requestUploadProcess:
            self.processIsInfoUploadable()
            
        case .requestShowUploadPreview:
            self.showUploadPreview()
        case .requestPopView:
            self.popView()
        }
        
    }
    
    
    private func makeVideoThumbnail() {
        guard let videoUrl = URL(string: self.videoUrl ?? "") else { return }
        onMainQueueResultHandler?(
            .setVideoThumbnail(SLThumbnailManager(videoUrl: videoUrl).imageFromVideo(at: 0))
        )
    }
    
    private func onViewDidLoad() {
        if let title = self.temporaryUploadInfo?.title, title.isEmpty == false {
            self.uploadTitle = title
            onMainQueueResultHandler?( .setTitle(title) )
            onMainQueueResultHandler?( .setTitleTextColor(title == titleTextFieldPlaceHolderText ? textFieldPlaceHolderColor : textFieldTextColor) )
        }
        else {
            onMainQueueResultHandler?( .setTitle(titleTextFieldPlaceHolderText))
            onMainQueueResultHandler?( .setTitleTextColor(textFieldPlaceHolderColor) )
        }
        
        if let desc = self.temporaryUploadInfo?.description, desc.isEmpty == false {
            self.uploadDescription = desc
            onMainQueueResultHandler?( .setDescription(desc) )
            onMainQueueResultHandler?( .setDescriptionTextColor(desc == descriptionTextFieldPlaceHolderText ? textFieldPlaceHolderColor : textFieldTextColor) )
        }
        else {
            onMainQueueResultHandler?( .setDescription(descriptionTextFieldPlaceHolderText))
            onMainQueueResultHandler?( .setDescriptionTextColor(textFieldPlaceHolderColor) )
        }
        
        if let tags = self.temporaryUploadInfo?.tags {
            self.uploadTags = tags
            onMainQueueResultHandler?( .setTags(tags) )
        }
        
        onMainQueueResultHandler?( .setDescriptionsFieldsVisibility(globalConfig.shared.visibleContents.isDescriptionVisible) )
        onMainQueueResultHandler?( .setTagsFieldVisibility(globalConfig.shared.visibleContents.isTagsVisible) )
        
        makeVideoThumbnail()
        
        #if(canImport(IQKeyboardManagerSwift))
        self.iqKeyboardManagerIsInstalled = true
        #endif
        
        if self.iqKeyboardManagerIsInstalled == false {
            addObserver()
            onMainQueueResultHandler?( .setKeyBoardDoneAccesoryView )
        }
    }
    
    private func onTitleDidBeginEditing(textView : UITextView) {
        guard textView.text == self.titleTextFieldPlaceHolderText else { return }
        onMainQueueResultHandler?( .setTitle(nil) )
        onMainQueueResultHandler?( .setTitleTextColor(textFieldTextColor) )
    }
    
    private func onTitleDidEndEditing(textView : UITextView) {
        guard textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        onMainQueueResultHandler?( .setTitle(titleTextFieldPlaceHolderText) )
        onMainQueueResultHandler?( .setTitleTextColor(textFieldPlaceHolderColor) )
    }
    
    private func onTitleDidChange(textView : UITextView) {
        self.uploadTitle = textView.text
        if textView.text == titleTextFieldPlaceHolderText {
            onMainQueueResultHandler?( .setIsUploadIsAvailable(false) )
        }
        else {
            self.checkUploadInfoValidate()
        }
    }
    
    private func onDescriptionDidBeginEditing(textView : UITextView) {
        guard textView.text == self.descriptionTextFieldPlaceHolderText else { return }
        onMainQueueResultHandler?( .setDescription(nil) )
        onMainQueueResultHandler?( .setDescriptionTextColor(textFieldTextColor) )
    }
    
    private func onDescriptionDidEndEditing(textView : UITextView) {
        guard textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        onMainQueueResultHandler?( .setDescription(descriptionTextFieldPlaceHolderText) )
        onMainQueueResultHandler?( .setDescriptionTextColor(textFieldPlaceHolderColor) )
    }
    
    private func onDescriptionDidChange(textView : UITextView) {
        self.uploadDescription = textView.text
    }
    
    private func checkUploadInfoValidate() {
        if self.uploadTitle.count > 0 {
            self.onMainQueueResultHandler?(.setIsUploadIsAvailable(true))
        }
        else {
            self.onMainQueueResultHandler?(.setIsUploadIsAvailable(false))
        }
    }
    
    private func showUploadPreview() {
        guard let uploadInfo = self.makeUploadInfo() else { return }
        onMainQueueResultHandler?( .showUploadPreview(uploadInfo))
    }
    
    private func popView(){
        guard let info = self.makeUploadInfo() else { return }
        onMainQueueResultHandler?( .popView(info) )
    }
    
    private func makeUploadInfo() -> SLUploadAttachmentInfo? {
        guard let videoUrl = self.videoUrl else { return nil }
        return SLUploadAttachmentInfo(title: self.uploadTitle, description: self.uploadDescription, tags: self.uploadTags , videoUrl: videoUrl)
    }
    
}
extension SLUploadInfoReactor {
    func addObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleNotification(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleNotification(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func removeObserver() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func handleNotification(_ notification : Notification) {
        var keyboardHeight: CGFloat = 0
        var bottomPadding: CGFloat = 0
        var keyboardRect : CGRect = .zero
        if let keyboardFrameEndUserInfo = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            keyboardRect = keyboardFrameEndUserInfo.cgRectValue
            bottomPadding = UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0
        
            keyboardHeight = keyboardRect.height - bottomPadding
        }
        
        switch notification.name {
        case UIResponder.keyboardWillShowNotification:
            if iqKeyboardManagerIsInstalled == false {
                onMainQueueResultHandler?( .handleKeyboard(keyboardRect) )
            }
            if !isKeyboardShow {
//                self.uploadBottomConstraint.constant = -12 - keyboardHeight
//                UIView.animate(withDuration: 0.3) { [weak self] in
//                    self?.view.layoutIfNeeded()
//                }
            }
            isKeyboardShow = true
            break
        case UIResponder.keyboardWillHideNotification:
            if iqKeyboardManagerIsInstalled == false {
                onMainQueueResultHandler?( .handleKeyboard(.zero) )
            }
            if isKeyboardShow {
//                self.uploadBottomConstraint.constant = -12
//                UIView.animate(withDuration: 0.3) { [weak self] in
//                    self?.view.layoutIfNeeded()
//                }
            }
            isKeyboardShow = false
            break
        default:
            break
        }
    }
}
extension SLUploadInfoReactor {
    
    private func processIsInfoUploadable() {
        if self.uploadTitle.trimWhiteSpacing_SL.isEmpty {
            onMainQueueResultHandler?(.setViewEndEditing(true))
            let bundle = Bundle(for: type(of: self))
            onMainQueueResultHandler?(.showToast("toast.uploadinfo.empty_video_title".localizedString(bundle: bundle)))
        }
        else {
            onMainQueueResultHandler?(.setLoadingVisible(true))
            DispatchQueue.global(qos: .background).async { [weak self] in
                guard let self = self else { return }
                self.processUploadCheckAPI()
            }
        }
    }

    private func processUploadCheckAPI() {
        SLShortformUploadableAPI().request { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let uploadable):
                guard let sessionSecret = uploadable.sessionSecret,
                      let uploadAPIEndpoint = uploadable.uploadApiEndpoint else {
                    let commonError = ShopLiveCommonErrorGenerator.generateError(errorCase: .UnexpectedError, error: nil, message: "[ShortformEditor] sessionSecrete or updateApiEndPoint missing" )
                    self.shortformEditorDelegate?.onShopLiveShortformEditorError?(error: commonError )
                    self.videoEditorDelegate?.onShopLiveVideoEditorError?(error: commonError )
                    self.onMainQueueResultHandler?(.setLoadingVisible(false))
                    return
                }
                self.processUploadAPI(sessionSecret: sessionSecret, apiEndPoint: uploadAPIEndpoint)
                
            case .failure(let error):
                onMainQueueResultHandler?(.setLoadingVisible(false))
                self.passNetworkErrorsToShortformDelegate(error: error)
                break
            }
        }
    }
    
    
    private func processUploadAPI(sessionSecret : String, apiEndPoint : String) {
        guard let videoUrl = self.videoUrl else { return }
        SLShortformVideoAPI(apiEndpoint: apiEndPoint, image: self.thumbnailPath, video: videoUrl, sessionSecret: sessionSecret).upload { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let response):
                self.processRegisterAPI(videoId: response.videoId ?? -1)
            case .failure(let error):
                onMainQueueResultHandler?(.setLoadingVisible(false))
                self.passNetworkErrorsToShortformDelegate(error: error)
                break
            }
        }
    }
    
    private func processRegisterAPI(videoId : Int){
        SLShortformRegisterAPI(parameters: self.makeShortsJson(videoId: videoId)).request { [weak self] result  in
            guard let self = self else { return }
            switch result {
            case .success(_):
                self.shortformEditorDelegate?.onShopLiveShortformEditorUploadSuccess?()
                self.onMainQueueResultHandler?(.setLoadingVisible(false))
                self.removeVideoFile()
                ShopLiveShortformEditor().close()
                break
            case .failure(let error):
                onMainQueueResultHandler?(.setLoadingVisible(false))
                self.passNetworkErrorsToShortformDelegate(error: error)
                break
            }
        }
    }
    
    private func passNetworkErrorsToShortformDelegate(error : Error) {
        if let error = error as? ShopLiveCommonError {
            self.shortformEditorDelegate?.onShopLiveShortformEditorError?(error: error)
            self.videoEditorDelegate?.onShopLiveVideoEditorError?(error: error)
        }
        else {
            let commonError = ShopLiveCommonErrorGenerator.generateError(errorCase: .UnexpectedError, error: error, message: nil)
            self.shortformEditorDelegate?.onShopLiveShortformEditorError?(error: commonError )
            self.videoEditorDelegate?.onShopLiveVideoEditorError?(error: commonError )
        }
    }
    
    private func makeShortsJson(videoId : Int) -> [String : Any] {
        var shortsDict : [String : Any] = [:]
        
        var cardsDict : [String : Any] = [:]
        cardsDict["cardType"] = "VIDEO"
        cardsDict["clips"] = [["from" : 0, "to" : self.videoDuration ]]
        cardsDict["source"] = "media"
        cardsDict["videoId"] = videoId
        
        var shortsDetailDict : [String : Any] = [:]
        shortsDetailDict["description"] = self.uploadDescription
        shortsDetailDict["tags"] = self.uploadTags
        shortsDetailDict["title"] = self.uploadTitle
        
        
        shortsDict["cards"] = [cardsDict]
        shortsDict["shortsDetail"] = shortsDetailDict
        shortsDict["shortsType"] = "CARD"
        
        return ["shorts" : shortsDict]
    }
    
    private func removeVideoFile(){
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let self = self, let videoUrl = self.videoUrl else { return }
            try? FileManager.default.removeItem(atPath: videoUrl)
        }
    }
    
    private func removeThumbnail() {
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let self = self else { return }
            try? FileManager.default.removeItem(atPath: self.thumbnailPath)
        }
    }
}
