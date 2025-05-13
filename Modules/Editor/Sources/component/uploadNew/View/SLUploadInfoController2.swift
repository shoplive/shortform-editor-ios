//
//  SLUploadInfoController2.swift
//  ShopLiveShortformEditorSDK
//
//  Created by sangmin han on 11/6/23.
//

import Foundation
import UIKit
import ShopliveSDKCommon

protocol SLUploadInfoControllerDelegate: AnyObject {
    func temporaryUploadInfo(uploadInfo: SLUploadAttachmentInfo)
}

class SLUploadInfoController2 : UIViewController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13.0, *) {
            return .darkContent
        } else {
            return .default
        }
    }
    
    private var bundle : Bundle {
        return Bundle(for: type(of: self))
    }
    
    private var naviBar : UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        return view
    }()
    
    lazy private var backBtn : UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setImage(ShopLiveShortformEditorSDKAsset.slBackArrow.image.withRenderingMode(.alwaysTemplate), for: .normal)
        btn.imageView?.tintColor = .black
        return btn
    }()
    
    lazy private var pageTitleLabel : SLLabel = {
        let label = SLLabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .baseLabelColor
        label.setFont(font: .init(size: 16, weight: .medium))
        label.textAlignment = .center
        label.text = "uploadinfo.page.title".localizedString(bundle: bundle)
        return label
    }()
    
    private var scrollView : UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        return scrollView
    }()
    
    private var stackView : UIStackView = {
        let stack = UIStackView(arrangedSubviews: [ ])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.distribution = .fill
        return stack
    }()
    
    private var playerContainerView : UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        return view
    }()
    
    private var videoThumnailImageBtn : VideoThumbnailBtn = {
        let btn = VideoThumbnailBtn()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.cornerRadiusV_SL = 12
        btn.imageView?.contentMode = .scaleAspectFill
        return btn
    }()
    
    lazy private var titleLabel : SLLabel = {
        let label = SLLabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor(red: 51/255, green: 51/255, blue: 51/255, alpha: 1.0)
        label.setFont(font: .init(size: 16, weight: .medium))
        label.text = "uploadinfo.title.title".localizedString(bundle: bundle)
        return label
    }()
    
    lazy private var titleTextView : SLPasteInterceptTextView = {
        let textView = SLPasteInterceptTextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.maxCharacterCount = 50
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.backgroundColor = UIColor(red: 246, green: 246, blue: 246)
        textView.textContainer.lineFragmentPadding = 0
        textView.textContainerInset = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 12)
        textView.isScrollEnabled = false
        textView.cornerRadiusV_SL = 10
        textView.clipsToBounds = true
        textView.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        textView.delegate = self
        textView.showsVerticalScrollIndicator = false
        textView.autocorrectionType = .no
        textView.spellCheckingType = .no
        return textView
    }()
    
    lazy private var descriptionLabel : UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor(red: 51/255, green: 51/255, blue: 51/255, alpha: 1.0)
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.text = "uploadinfo.description.title".localizedString(bundle: bundle)
        return label
    }()
    
    private lazy var descriptionTextField : SLPasteInterceptTextView = {
        let view = SLPasteInterceptTextView()
        view.maxCharacterCount = 100
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(red: 246, green: 246, blue: 246)
        view.textContainerInset = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 12)
        view.textContainer.lineFragmentPadding = .zero
        view.isScrollEnabled = false
        view.cornerRadiusV_SL = 10
        view.clipsToBounds = true
        view.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        view.delegate = self
        view.showsVerticalScrollIndicator = false
        view.autocorrectionType = .no
        view.spellCheckingType = .no
        return view
    }()
    
    lazy private var tagLabel: SLLabel = {
        let view = SLLabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.textColor = UIColor(red: 51/255, green: 51/255, blue: 51/255, alpha: 1.0)
        view.setFont(font: .init(size: 16, weight: .medium))
        view.text =  "uploadinfo.tag.title".localizedString(bundle: bundle)
        return view
    }()
    
    private var tagView : UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.cornerRadiusV_SL = 10
        return view
    }()
    
    private lazy var tagField: SLWSTagsField = {
        let view = SLWSTagsField(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.tintColor = UIColor(red: 0.886, green: 0.886, blue: 0.886, alpha: 1.0)
        view.textColor = .black
        view.textField.textColor = .black
        view.textField.tintColor = .systemBlue
        view.cornerRadius = 3.0
        view.spaceBetweenLines = 10
        view.spaceBetweenTags = 10
        view.placeholderAlwaysVisible = false
        view.textDelegate = self
        view.layoutMargins = UIEdgeInsets(top: 2, left: 6, bottom: 2, right: 6)
        view.contentInset = UIEdgeInsets(top: 10, left: 16, bottom: 10, right: 12) //old padding
        let bundle = Bundle(for: type(of: self))
        view.placeholder = "uploadinfo.tag.placeholder".localizedString(bundle: bundle)
        view.placeholderColor = UIColor(red: 143/255, green: 143/255, blue: 143/255, alpha: 1.0)
        view.textField.returnKeyType = .continue
        view.backgroundColor = UIColor(red: 246/255, green: 246/255, blue: 246/255, alpha: 1.0)
        view.useCloseButton = true
        view.textField.autocorrectionType = .no
        view.textField.spellCheckingType = .no
        return view
    }()
    
    
    private lazy var uploadButton: UIButton = {
        let view = UIButton(type: .custom)
        view.translatesAutoresizingMaskIntoConstraints = false
        let bundle = Bundle(for: type(of: self))
        let uploadText = "uploadinfo.upload.title".localizedString(bundle: bundle)
        view.setTitle(uploadText, for: .normal)
        view.setTitleColor(.white, for: .normal)
        view.setBackgroundColor_SL(UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0), for: .selected)
        view.setBackgroundColor_SL(UIColor(red: 246/255, green: 246/255, blue: 246/255, alpha: 1.0), for: .normal)
        view.cornerRadiusV_SL = 10
        view.isSelected = false
        return view
    }()
    
    private lazy var loadingProgress: SLLoadingAlertController = {
        let vc = SLLoadingAlertController()
        vc.view.translatesAutoresizingMaskIntoConstraints = false
        vc.view.isHidden = true
        let bundle = Bundle(for: type(of: self))
        vc.setLoadingText("loading.inprocessing.title".localizedString(bundle: bundle))
        return vc
    }()
    
    
    weak var delegate : SLUploadInfoControllerDelegate?
    weak var shortformEditorDelegate : ShopLiveShortformEditorDelegate?
    weak var videoEditorDelegate : ShopLiveVideoEditorDelegate?
    
    private var reactor : SLUploadInfoReactor
    
    init(uploadInfo : SLUploadAttachmentInfo){
        reactor = SLUploadInfoReactor(uploadInfo: uploadInfo)
        super.init(nibName: nil, bundle: nil)
    }
    
    init(videoUrl : String,localAbsoluteUrl : URL, localRelativeUrl : URL){
        reactor = SLUploadInfoReactor(localAbsoluteUrl: localAbsoluteUrl, localRelativeUrl: localRelativeUrl)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        bindReactor()
        bindTagField()
        setLayout()
        reactor.action(.viewDidLoad)
        
        
        backBtn.addTarget(self, action: #selector(backBtnTapped(sender: )), for: .touchUpInside)
        videoThumnailImageBtn.addTarget(self, action: #selector(videoThumbnailTapped(sender: )), for: .touchUpInside)
        uploadButton.addTarget(self, action: #selector(uploadBtnTapped(sender: )), for: .touchUpInside)
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        reactor.action( .setShortformEditorDelegate(self.shortformEditorDelegate) )
        reactor.action( .setVideoEditorDelegate(self.videoEditorDelegate) )
    }
    
    deinit {
        ShopLiveLogger.tempLog("[ShopliveShortformEditor] SLUploadInfoController2 deinited")
    }
    
    @objc func backBtnTapped(sender : UIButton){
        reactor.action( .requestPopView )
    }
    
    @objc func videoThumbnailTapped(sender : UIButton){
        reactor.action( .requestShowUploadPreview )
    }
    
    @objc func uploadBtnTapped(sender : UIButton) {
        if uploadButton.isSelected == false {
            titleTextView.becomeFirstResponder()
            return
        }
        reactor.action( .requestUploadProcess )
    }
    
    private func bindTagField(){
        tagField.onDidAddTag = { [weak self] _, _ in
            guard let self = self else { return }
            reactor.action( .setTags(self.tagField.tags.compactMap({ $0.text })) )
        }
        
        tagField.onDidRemoveTag = { [weak self] _, _ in
            guard let self = self else { return }
            reactor.action( .setTags(self.tagField.tags.compactMap({ $0.text })) )
        }
        
        tagField.onDidChangeText =  {[weak self] field, tag in
            guard let self = self else { return }
            guard tagField.tags.count < 5 else {
                tagField.text = ""
                return
            }
            
            guard var tagText = field.text else {
                if field.tags.isNotEmpty_SL {
                    field.text = "#"
                }
                return
            }
            
            tagText = tagText.replacingOccurrences(of: " ", with: "_")
            tagText = tagText.replacingOccurrences(of: "\\n", with: "_")
            
            while tagText.contains("__") {
                tagText = tagText.replacingOccurrences(of: "__", with: "_")
            }
            
            if tagText.isNotEmpty_SL {
                let prefix = tagText.first == "#" ? "#" : ""
                tagField.text = prefix + tagText.filter({$0 != "#"})
            }
        }
    }
    
    private func bindReactor(){
        
        reactor.resultHandler = { _ in
        }
        
        
        reactor.onMainQueueResultHandler = { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .setVideoThumbnail(let image):
                    self.videoThumnailImageBtn.setImage(image, for: .normal)
                    
                case .setTitle(let title):
                    self.titleTextView.text = title
                case .setTitleTextColor(let color):
                    self.titleTextView.textColor = color

                case .setDescription(let desc):
                    self.descriptionTextField.text = desc
                case .setDescriptionTextColor(let color):
                    self.descriptionTextField.textColor = color
                    
                case .setTags(let tags):
                    self.tagField.addTags( tags ?? [] )
                
                case .setLoadingVisible(let isVisible):
                    self.processLoadingView(isVisible: isVisible)
                
                case .setIsUploadIsAvailable(let isAvailable):
                    self.setIsUploadAvailable(isAvailable: isAvailable)
                
                case .showToast(let message):
                    self.showToast(message: message)
                    
                case .showUploadPreview(let attachInfo):
                    self.showUploadPreviewController(attachInfo: attachInfo)
                    
                case .popView(let attachInfo):
                    self.popView(attachInfo: attachInfo)
                    
                case .setDescriptionsFieldsVisibility(let isVisible):
                    self.setDescriptionFieldsVisible(isVisible: isVisible)
                
                case .setTagsFieldVisibility(let isVisible):
                    self.setTagsFieldsVisible(isVisible: isVisible)
                    
                case .handleKeyboard(let keyBoardRect):
                    self.handleKeyboard(keyBoardRect: keyBoardRect)
                
                case .setKeyBoardDoneAccesoryView:
                    self.setKeyBoardDoneAccessoryView()
                default:
                    break
                }
            }
        }
    }
    
    private func setKeyBoardDoneAccessoryView(){
        let doneToolBar : UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 40))
        doneToolBar.barStyle = UIBarStyle.blackTranslucent
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        let doneBtn = UIBarButtonItem(title: "done", style: .done, target: self, action: #selector(keyBoardDoneTapped(sender: )))
        var items : [UIBarButtonItem] = [flexSpace,doneBtn]
        doneToolBar.items = items
        doneToolBar.sizeToFit()
        titleTextView.inputAccessoryView = doneToolBar
        descriptionTextField.inputAccessoryView = doneToolBar
        tagField.inputFieldAccessoryView = doneToolBar
    }
    
    @objc private func keyBoardDoneTapped(sender : UIBarButtonItem){
        self.view.endEditing(true)
    }
    
    private func processLoadingView(isVisible : Bool){
        self.loadingProgress.view.isHidden = !isVisible
        self.uploadButton.isSelected = !isVisible
    }
    
    private func setIsUploadAvailable(isAvailable : Bool) {
        uploadButton.isSelected = isAvailable
    }
    
    private func showUploadPreviewController(attachInfo : SLUploadAttachmentInfo) {
        self.wrapTagWhenKeyboardHides(textField: tagField.textField) { [weak self] in
            guard let self = self else { return }
            let preview = ShopLiveShortformUploaderPreviewController(url: attachInfo.videoUrl)
            preview.modalPresentationStyle = .overFullScreen
            preview.modalPresentationCapturesStatusBarAppearance = true
            self.navigationController?.present(preview, animated: true)
        }
    }
    
    private func popView(attachInfo : SLUploadAttachmentInfo){
        delegate?.temporaryUploadInfo(uploadInfo: attachInfo)
        if let nav = self.navigationController {
            nav.popViewController(animated: true)
        }
        else {
            self.dismiss(animated: true)
        }
    }
    
    private func setDescriptionFieldsVisible(isVisible : Bool) {
        self.descriptionLabel.isHidden = !isVisible
        self.descriptionTextField.isHidden = !isVisible
    }
    
    private func setTagsFieldsVisible(isVisible : Bool) {
        self.tagLabel.isHidden = !isVisible
        self.tagView.isHidden = !isVisible
    }
    
    private func handleKeyboard(keyBoardRect : CGRect){
        if keyBoardRect == .zero {
            scrollView.contentInset = .zero
            scrollView.scrollIndicatorInsets = .zero
            return
        }
        let insets = UIEdgeInsets(top: 0, left: 0, bottom: keyBoardRect.height, right: 0)
        scrollView.contentInset = insets
        scrollView.scrollIndicatorInsets = insets
        
        var vcRect = self.view.frame
        vcRect.size.height -= keyBoardRect.height
        
        let activeFields : UIView? = [titleTextView, descriptionTextField, tagField].first{ $0.isFirstResponder }
        
        if var activeField = activeFields {
            let converted = activeField.convert(activeField.bounds.origin, to: self.view)
            if vcRect.contains(converted) == false {
                let scrollPoint = CGPoint(x: 0, y: converted.y - keyBoardRect.height)
                scrollView.setContentOffset(scrollPoint, animated: true)
            }
        }
    }
    
}
extension SLUploadInfoController2 {
    private func wrapTagWhenKeyboardHides(textField : UITextField,completion : (() -> ())? = nil) {
        if textField !== tagField.textField { return }
        if textField.text == "" || textField.text == "#" {
            DispatchQueue.main.async {
                completion?()
            }
            return
        }
        var text : String = ""
        if (textField.text?.hasPrefix("#") ?? false) == false {
            text = "#" + (textField.text ?? "")
        }
        else {
            text = (textField.text ?? "")
        }
        DispatchQueue.main.async(){ [weak self] in
            self?.tagField.addTag(text)
            completion?()
        }
    }
    
}
extension SLUploadInfoController2 {
    private func setLayout() {
        self.view.addSubview(naviBar)
        self.view.addSubview(backBtn)
        self.view.addSubview(pageTitleLabel)
        self.view.addSubview(scrollView)
        scrollView.addSubview(stackView)
    
        stackView.addArrangedSubview(playerContainerView)
        playerContainerView.addSubview(videoThumnailImageBtn)
        
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(titleTextView)
        stackView.addArrangedSubview(descriptionLabel)
        stackView.addArrangedSubview(descriptionTextField)
        stackView.addArrangedSubview(tagLabel)
        stackView.addArrangedSubview(tagView)
        tagView.addSubview(tagField)
        
        self.view.addSubview(uploadButton)
        self.view.addSubview(loadingProgress.view)
        
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        stackView.setCustomSpacing(25, after: playerContainerView)
        stackView.setCustomSpacing(4, after: titleLabel)
        stackView.setCustomSpacing(15, after: titleTextView)
        stackView.setCustomSpacing(4, after: descriptionLabel)
        stackView.setCustomSpacing(15, after: descriptionTextField)
        stackView.setCustomSpacing(4, after: tagLabel)
        
        NSLayoutConstraint.activate([
            naviBar.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            naviBar.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            naviBar.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            naviBar.heightAnchor.constraint(equalToConstant: 44),
            
            backBtn.centerYAnchor.constraint(equalTo: naviBar.centerYAnchor),
            backBtn.leadingAnchor.constraint(equalTo: self.view.leadingAnchor,constant: 20),
            backBtn.widthAnchor.constraint(equalToConstant: 30),
            backBtn.heightAnchor.constraint(equalToConstant: 30),
            
            pageTitleLabel.centerYAnchor.constraint(equalTo: naviBar.centerYAnchor),
            pageTitleLabel.centerXAnchor.constraint(equalTo: naviBar.centerXAnchor),
            pageTitleLabel.widthAnchor.constraint(lessThanOrEqualToConstant: 200),
            pageTitleLabel.heightAnchor.constraint(equalToConstant: 18),
            
            scrollView.topAnchor.constraint(equalTo: naviBar.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: uploadButton.topAnchor,constant: -10),
            
            playerContainerView.heightAnchor.constraint(equalToConstant: 160),
            
            videoThumnailImageBtn.topAnchor.constraint(equalTo: playerContainerView.topAnchor),
            videoThumnailImageBtn.bottomAnchor.constraint(equalTo: playerContainerView.bottomAnchor),
            videoThumnailImageBtn.widthAnchor.constraint(equalToConstant: 107),
            videoThumnailImageBtn.centerXAnchor.constraint(equalTo: playerContainerView.centerXAnchor),
            
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            
            titleLabel.heightAnchor.constraint(equalToConstant: 20),
            titleTextView.heightAnchor.constraint(greaterThanOrEqualToConstant: 44),
            
            descriptionLabel.heightAnchor.constraint(equalToConstant: 20),
            descriptionTextField.heightAnchor.constraint(greaterThanOrEqualToConstant: 44),
            
            tagField.topAnchor.constraint(equalTo: tagView.topAnchor),
            tagField.leadingAnchor.constraint(equalTo: tagView.leadingAnchor),
            tagField.trailingAnchor.constraint(equalTo: tagView.trailingAnchor),
            tagField.bottomAnchor.constraint(equalTo: tagView.bottomAnchor),
            
            
            uploadButton.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor,constant: -20),
            uploadButton.leadingAnchor.constraint(equalTo: self.view.leadingAnchor,constant: 20),
            uploadButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor,constant: -20),
            uploadButton.heightAnchor.constraint(equalToConstant: 44),
            
            
            loadingProgress.view.topAnchor.constraint(equalTo: self.view.topAnchor),
            loadingProgress.view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            loadingProgress.view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            loadingProgress.view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])
        
        
    }
}
extension SLUploadInfoController2 : UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if textView === titleTextView {
            let currentString = (textView.text ?? "") as NSString
            let newString = currentString.replacingCharacters(in: range, with: text)
            if range.location == 0 && (text.prefix(1) == "\n" || text.prefix(1) == " ") {
                return false
            }
            
            if range.location >= 0 && (range.location + range.length) < currentString.length {
                let frontChar = currentString.substring(with: NSRange(location: range.location - 1, length: 1))
                if frontChar == "\n" && text.prefix(1) == "\n" {
                    return false
                }
                let behindChar = currentString.substring(with: NSRange(location: range.location + range.length, length: 1))
                if behindChar == "\n" && text.suffix(1) == "\n" {
                    return false
                }
            }
            if String(newString.suffix(2)) == "\n\n" && (textView.text ?? "").count < newString.count {
                return false
            }
            return newString.count <= 50
        }
        else if textView === descriptionTextField {
            let currentString = (textView.text ?? "") as NSString
            let newString = currentString.replacingCharacters(in: range, with: text)
            if range.location == 0 && (text.prefix(1) == "\n" || text.prefix(1) == " ") {
                return false
            }
            if range.location >= 0 && (range.location + range.length) < currentString.length {
                let frontChar = currentString.substring(with: NSRange(location: range.location - 1, length: 1))
                if frontChar == "\n" && text.prefix(1) == "\n" {
                    return false
                }
                let behindChar = currentString.substring(with: NSRange(location: range.location + range.length, length: 1))
                if behindChar == "\n" && text.suffix(1) == "\n" {
                    return false
                }
            }
            
            if String(newString.suffix(2)) == "\n\n" && (textView.text ?? "").count < newString.count {
                return false
            }
            return newString.count <= 100
        }
        return true
    }

    func textViewDidChange(_ textView: UITextView) {
        if textView == titleTextView {
            reactor.action( .titleDidChange(textView) )
        }
        else if textView == descriptionTextField {
            reactor.action( .descriptionDidChange(textView) )
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView == titleTextView {
            reactor.action( .titleDidBeginEditing(textView) )
        }
        else if textView == descriptionTextField {
            reactor.action( .descriptoinDidBeginEditing(textView) )
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView == titleTextView {
            reactor.action( .titleDidEndEditing(textView) )
        }
        else if textView == descriptionTextField {
            reactor.action( .descriptoinDidEndEditing(textView) )
        }
    }
    
    
}

extension SLUploadInfoController2 : UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case titleTextView:
            descriptionTextField.becomeFirstResponder()
            break
        case descriptionTextField:
            tagField.textField.becomeFirstResponder()
        case tagField.textField:
            if let text = textField.text, text.isEmpty {
                shopliveHideKeyboard_SL()
                return false
            }
            break
        default:
            break
        }
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        wrapTagWhenKeyboardHides(textField: textField)
        return true
    }
}

