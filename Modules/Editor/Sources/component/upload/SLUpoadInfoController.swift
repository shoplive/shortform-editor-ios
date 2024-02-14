//
//  UpoadInfoController.swift
//  ShortformUpload
//
//  Created by 김우현 on 4/30/23.
//

import UIKit
import ShopliveSDKCommon

protocol SLUploadInfoControllerDelegate: AnyObject {
    func temporaryUploadInfo(uploadInfo: SLUploadAttachmentInfo)
}

class SLUploadInfoController: UIViewController, UIGestureRecognizerDelegate, UITextFieldDelegate {
    
    enum UploadAction {
        case none
        case uploadable
        case upload(sessionSecret: String, apiEndpoint: String)
        case register(videoId: Int)
        case onError(error: Error)
    }
    
    lazy private var bundle : Bundle = {
        return Bundle(for: type(of: self))
    }()
    
    private var uploadAct: Bindable<UploadAction> = .init(.none)
    
    private var thumbnailManager: SLThumbnailManager?
    
    weak var delegate: SLUploadInfoControllerDelegate?
    
    private var temporaryUploadInfo: SLUploadAttachmentInfo?
    
    private var shortformVideo: ShortsVideo?
    
    private var thumbnailPath: String { FileManager.default.temporaryDirectory.appendingPathComponent("shortform-thumbnail.jpg").absoluteString }
    
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
    
    private var apiEndpoint: String = ""
    
    private lazy var navibar: UINavigationBar = {
        let view = UINavigationBar()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .baseColor
        view.tintColor = .baseColor
        if #available(iOS 13.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.backgroundColor = .baseColor
            appearance.shadowColor = .baseColor
            view.standardAppearance = appearance
            view.scrollEdgeAppearance = appearance
        }
        view.setBackgroundImage(UIImage(), for:.default)
        view.shadowImage = UIImage()
        return view
    }()
    
    private lazy var naviItem: UINavigationItem = {
        let item = UINavigationItem()
        item.titleView?.backgroundColor = .baseColor
        return item
    }()
    
    private lazy var navibarConstraint = [
        self.navibar.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
        self.navibar.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
        self.navibar.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
        self.navibar.heightAnchor.constraint(equalToConstant: 44)
    ]
    
    private lazy var titleView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .baseColor
        let titleLabel = UILabel()
        titleLabel.textColor = .baseLabelColor
        titleLabel.font = .systemFont(ofSize: 16, weight: .medium)
        var paragraphStyle = NSMutableParagraphStyle()
        titleLabel.textAlignment = .center
        let bundle = Bundle(for: type(of: self))
        titleLabel.attributedText = NSMutableAttributedString(string: "uploadinfo.page.title".localizedString(bundle: bundle), attributes: [NSAttributedString.Key.paragraphStyle: paragraphStyle])
        view.addSubview(titleLabel)
        titleLabel.fit_SL()
        return view
    }()
    
    private lazy var contentView: UIView  = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var contentScrollView: UIScrollView = {
        let view = UIScrollView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.showsVerticalScrollIndicator = false
        return view
    }()
    
    private lazy var videoThumbnail: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isUserInteractionEnabled = true
        view.cornerRadiusV_SL = 12
        return view
    }()
    
    private lazy var videoThumbnailPlayIcon: UIImageView = {
        let bundle = Bundle(for: type(of: self))
//        let playpreviewImage = UIImage(named: "sl_playpreview", in: bundle, compatibleWith: nil)?.withRenderingMode(.alwaysOriginal)
        let view = UIImageView(image: ShopLiveShortformEditorSDKAsset.slPlaypreview.image)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentMode = .scaleAspectFill
        return view
    }()
    
    private lazy var titleLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.numberOfLines = 1
        view.textAlignment = .left
        view.textColor = textColor
        view.font = .systemFont(ofSize: 16, weight: .medium)
        return view
    }()
    
    private lazy var titleTextFieldHeightAnc : NSLayoutConstraint = {
        return titleTextField.heightAnchor.constraint(equalToConstant: 44)
    }()
    
    private lazy var titleTextField : SLPasteInterceptTextView = {
        let view = SLPasteInterceptTextView()
        view.maxCharacterCount = 50
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(red: 246, green: 246, blue: 246)
        view.textContainer.lineFragmentPadding = 0
        view.textContainerInset = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 12)
        view.isScrollEnabled = false
        view.cornerRadiusV_SL = 10
        view.clipsToBounds = true
        view.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        view.delegate = self
        view.text = titleTextFieldPlaceHolderText
        view.textColor = textFieldPlaceHolderColor
        view.showsVerticalScrollIndicator = false
        view.autocorrectionType = .no
        view.spellCheckingType = .no
        return view
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.numberOfLines = 1
        view.textAlignment = .left
        view.textColor = textColor
        view.font = .systemFont(ofSize: 16, weight: .medium)
        return view
    }()
    
    private lazy var descriptionTextFieldHeightAnc : NSLayoutConstraint = {
        return descriptionTextField.heightAnchor.constraint(equalToConstant: 44)
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
        view.text = descriptionTextFieldPlaceHolderText
        view.textColor = textFieldPlaceHolderColor
        view.showsVerticalScrollIndicator = false
        view.autocorrectionType = .no
        view.spellCheckingType = .no
        return view
    }()
    
    private lazy var tagLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.numberOfLines = 1
        view.textAlignment = .left
        view.textColor = textColor
        view.font = .systemFont(ofSize: 16, weight: .medium)
        return view
    }()
    
    private lazy var tagView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.cornerRadiusV_SL = 10
        view.addSubview(tagField)
        tagField.fit_SL()
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
    
    private lazy var contentBottomSpacingView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var uploadButton: UIButton = {
        let view = UIButton(type: .custom)
        view.translatesAutoresizingMaskIntoConstraints = false
        let bundle = Bundle(for: type(of: self))
        let uploadText = "uploadinfo.upload.title".localizedString(bundle: bundle)
        view.setTitle(uploadText, for: .normal)
        view.setBackgroundColor_SL(UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0), for: .selected)
        view.setBackgroundColor_SL(UIColor(red: 246/255, green: 246/255, blue: 246/255, alpha: 1.0), for: .normal)
        view.setTitleColor(.white, for: .normal)
        view.cornerRadiusV_SL = 10
        view.addTarget(self, action: #selector(didTapUploadButton), for: .touchUpInside)
        view.isSelected = false
        return view
    }()
    
    private lazy var uploadBottomConstraint = uploadButton.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -12)
    
    private func setNavigationBar(){
        configureNavigationButton()
    }
    
    private lazy var loadingProgress: SLLoadingAlertController = {
        let vc = SLLoadingAlertController()
        vc.delegate = self
        vc.view.isHidden = true
        let bundle = Bundle(for: type(of: self))
        vc.setLoadingText("loading.inprocessing.title".localizedString(bundle: bundle))
        return vc
    }()
    
    private func configureNavigationButton(){
//        let bundle = Bundle(for: type(of: self))
//        let backImage = UIImage(named: "sl_back_arrow", in: bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)

        naviItem.titleView = titleView
        let backButton = UIBarButtonItem(image: ShopLiveShortformEditorSDKAsset.slBackArrow.image, style: .plain, target: self, action: #selector(self.back))
        
        naviItem.leftBarButtonItem = backButton
        naviItem.leftBarButtonItem?.tintColor = .baseLabelColor
        self.navibar.setItems([naviItem], animated: false)
    }
    
    @objc private func back() {
        delegate?.temporaryUploadInfo(uploadInfo: getUploadInfo())
        shortformVideo = nil
        self.navigationController?.popViewController(animated: true)
    }
    
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        updateConstraint()
    }
    
    private func updateConstraint() {
        NSLayoutConstraint.activate(navibarConstraint)
    }
    
    private var videoUrl: String
    private var videoDuration: Int {
        if let duration = shortformVideo?.getVideoDuration() {
            return Int(ceil(duration * 1000))
        } else {
            return 0
        }
    }
    
    init(uploadInfo: SLUploadAttachmentInfo) {
        if let videoURL = URL(string: uploadInfo.videoUrl) {
            shortformVideo = ShortsVideo(videoUrl: videoURL)
        }
        
        self.temporaryUploadInfo = uploadInfo
        self.videoUrl = uploadInfo.videoUrl
        
        
        super.init(nibName: nil, bundle: nil)
    }
    
    init(videoUrl: String) {
        self.videoUrl = videoUrl
        if let videoURL = URL(string: videoUrl) {
            shortformVideo = ShortsVideo(videoUrl: videoURL)
        }
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13, *) {
            return .darkContent
        } else {
            return .default
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        layout()
        attributes()
        bindView()
        bindData()
    }
    
    private func layout() {
        let backTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture))
        self.view.addGestureRecognizer(backTapGesture)
        backTapGesture.delegate = self
        backTapGesture.isEnabled = true
        
        self.view.backgroundColor = .white
        self.view.addSubview(navibar)
        self.view.addSubview(uploadButton)
        self.view.addSubview(loadingProgress.view)
        loadingProgress.view.fit_SL()
        self.view.addSubview(contentScrollView)
        contentScrollView.addSubview(contentView)

        let contentViewConstraint = [
            contentView.leadingAnchor.constraint(equalTo: contentScrollView.contentLayoutGuide.leadingAnchor, constant: 0),
            contentView.trailingAnchor.constraint(equalTo: contentScrollView.contentLayoutGuide.trailingAnchor, constant: 0),
            contentView.topAnchor.constraint(equalTo: contentScrollView.contentLayoutGuide.topAnchor, constant: 0),
            contentView.bottomAnchor.constraint(equalTo: contentScrollView.contentLayoutGuide.bottomAnchor, constant: 0),
            contentView.leadingAnchor.constraint(equalTo: contentScrollView.frameLayoutGuide.leadingAnchor, constant: 0),
            contentView.trailingAnchor.constraint(equalTo: contentScrollView.frameLayoutGuide.trailingAnchor, constant: 0),
            contentView.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 1.0),
            contentView.topAnchor.constraint(equalTo: self.contentScrollView.topAnchor, constant: 0)
        ]
        
        contentView.addSubview(videoThumbnail)
        contentView.addSubview(videoThumbnailPlayIcon)
        contentView.addSubview(titleLabel)
        contentView.addSubview(titleTextField)
        contentView.addSubview(descriptionLabel)
        contentView.addSubview(descriptionTextField)
        contentView.addSubview(tagLabel)
        contentView.addSubview(tagView)
        contentView.addSubview(contentBottomSpacingView)
        
        
        let contentScrollViewConstraint = [
            contentScrollView.topAnchor.constraint(equalTo: self.navibar.bottomAnchor, constant: 0),
            contentScrollView.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 0),
            contentScrollView.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: 0),
            contentScrollView.bottomAnchor.constraint(equalTo: self.uploadButton.topAnchor, constant: -10)
        ]
        
        let videoThumbnailConstraint = [
            videoThumbnail.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            videoThumbnail.centerXAnchor.constraint(equalTo: contentView.centerXAnchor, constant: 0),
            videoThumbnail.widthAnchor.constraint(equalToConstant: 107),
            videoThumbnail.heightAnchor.constraint(equalToConstant: 160)
        ]
        
        let videoThumbnailPlayImageConstraint = [
            videoThumbnailPlayIcon.topAnchor.constraint(equalTo: videoThumbnail.topAnchor, constant: 4),
            videoThumbnailPlayIcon.trailingAnchor.constraint(equalTo: videoThumbnail.trailingAnchor, constant: -4),
            videoThumbnailPlayIcon.widthAnchor.constraint(equalToConstant: 30),
            videoThumbnailPlayIcon.heightAnchor.constraint(equalToConstant: 30)
        ]
        
        let titleLabelConstraint = [
            titleLabel.topAnchor.constraint(equalTo: videoThumbnail.bottomAnchor, constant: 24),
            titleLabel.leftAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.leftAnchor, constant: 20),
            titleLabel.rightAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.rightAnchor, constant: 20)
        ]
        
        let titleTextFieldConstraint = [
            titleTextField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            titleTextField.leftAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.leftAnchor, constant: 20),
            titleTextField.rightAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.rightAnchor, constant: -20),
            titleTextFieldHeightAnc
        ]
        
        let descriptionLabelConstraint = [
            descriptionLabel.topAnchor.constraint(equalTo: titleTextField.bottomAnchor, constant: 16),
            descriptionLabel.leftAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.leftAnchor, constant: 20),
            descriptionLabel.rightAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.rightAnchor, constant: 20)
        ]
        
        let descriptionTextFieldConstraint = [
            descriptionTextField.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 4),
            descriptionTextField.leftAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.leftAnchor, constant: 20),
            descriptionTextField.rightAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.rightAnchor, constant: -20),
            descriptionTextFieldHeightAnc
        ]
        
        let tagFieldConstraint = [
            tagView.leftAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.leftAnchor, constant: 20),
            tagView.rightAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.rightAnchor, constant: -20),
            tagView.topAnchor.constraint(equalTo: tagLabel.bottomAnchor, constant: 4),
            tagView.heightAnchor.constraint(greaterThanOrEqualToConstant: 44),
            tagView.bottomAnchor.constraint(equalTo: contentBottomSpacingView.topAnchor, constant: -10)
        ]
        
        let bottomSpacingViewConstraint = [
            contentBottomSpacingView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 0),
            contentBottomSpacingView.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: 0),
            contentBottomSpacingView.topAnchor.constraint(equalTo: tagView.bottomAnchor, constant: 10),
            contentBottomSpacingView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10)
        ]
        
        let tagLabelConstraint = [
            tagLabel.topAnchor.constraint(equalTo: descriptionTextField.bottomAnchor, constant: 16),
            tagLabel.leftAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.leftAnchor, constant: 20),
            tagLabel.rightAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.rightAnchor, constant: 20)
        ]
        
        let uploadButtonConstraint = [
            uploadButton.leftAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leftAnchor, constant: 20),
            uploadButton.rightAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.rightAnchor, constant: -20),
            uploadButton.heightAnchor.constraint(equalToConstant: 44)
        ]
        
        NSLayoutConstraint.activate(navibarConstraint)
        NSLayoutConstraint.activate(uploadButtonConstraint)
        uploadBottomConstraint.isActive = true
        NSLayoutConstraint.activate(contentScrollViewConstraint)
        NSLayoutConstraint.activate(contentViewConstraint)
        
        NSLayoutConstraint.activate(videoThumbnailConstraint)
        NSLayoutConstraint.activate(videoThumbnailPlayImageConstraint)
        NSLayoutConstraint.activate(titleLabelConstraint)
        NSLayoutConstraint.activate(titleTextFieldConstraint)
        NSLayoutConstraint.activate(descriptionLabelConstraint)
        NSLayoutConstraint.activate(descriptionTextFieldConstraint)
        NSLayoutConstraint.activate(tagLabelConstraint)
        NSLayoutConstraint.activate(tagFieldConstraint)
        NSLayoutConstraint.activate(bottomSpacingViewConstraint)
        
        self.setNavigationBar()
        
        self.view.bringSubviewToFront(self.loadingProgress.view)
    }
    
    private func attributes() {
        if let videoUrl = URL(string: self.videoUrl) {
            thumbnailManager = SLThumbnailManager(videoUrl: videoUrl)
            
            self.videoThumbnail.image = thumbnailManager?.imageFromVideo(at: 0)
            self.videoThumbnail.image?.saveThumbnail_SL()
        }
        
        titleLabel.text = "uploadinfo.title.title".localizedString(bundle: bundle)
        if let title = temporaryUploadInfo?.title {
            titleTextField.text = title
            titleTextField.textColor = textFieldTextColor
            self.setTextViewScrollBehaviorAndHeight(textView: titleTextField, heightAnc: titleTextFieldHeightAnc)
            if title == titleTextFieldPlaceHolderText {
                titleTextField.textColor = textFieldPlaceHolderColor
            }
            else {
                titleTextField.textColor = textFieldTextColor
            }
        }

        
        descriptionLabel.text = "uploadinfo.description.title".localizedString(bundle: bundle)
        if let description = temporaryUploadInfo?.description {
            descriptionTextField.text = description
            descriptionTextField.textColor = textFieldTextColor
            self.setTextViewScrollBehaviorAndHeight(textView: descriptionTextField, heightAnc: descriptionTextFieldHeightAnc)
            if description == descriptionTextFieldPlaceHolderText {
                descriptionTextField.textColor = textFieldPlaceHolderColor
            }
            else {
                descriptionTextField.textColor = textFieldTextColor
            }
        }
        
        tagLabel.text = "uploadinfo.tag.title".localizedString(bundle: bundle)
        
        if let tags = temporaryUploadInfo?.tags {
            self.tagField.addTags(tags)
        }
        
        if titleTextField.text == titleTextFieldPlaceHolderText {
            uploadButton.isSelected = false
        }
        else {
            uploadButton.isSelected = checkUploadInfoValidate()
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleNotification(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleNotification(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    deinit {
        shortformVideo = nil
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc
    private func handleTapGesture() {
        if let tagFieldText = tagField.text, tagFieldText.count < 2 {
            if tagFieldText == "#" || tagFieldText.isEmpty {
                tagField.textField.text = ""
            }
        }
        
        shopliveHideKeyboard_SL()
    }
    
    private func bindView() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapThumbnail))
        self.videoThumbnail.addGestureRecognizer(tapGesture)
        tapGesture.delegate = self
        tapGesture.isEnabled = true
        tagField.onDidAddTag = {[weak self] field, tag in
            guard let self = self else { return }

            if self.contentScrollView.contentSize.height < self.contentScrollView.bounds.size.height { return }
            let bottomOffset = CGPoint(x: 0, y: self.contentScrollView.contentSize.height - self.contentScrollView.bounds.size.height)
            self.contentScrollView.setContentOffset(bottomOffset, animated: false)
        }

        tagField.onDidRemoveTag = {[weak self] field, tag in
            guard let self = self else { return }
            
            if self.contentScrollView.contentSize.height < self.contentScrollView.bounds.size.height { return }
            let bottomOffset = CGPoint(x: 0, y: self.contentScrollView.contentSize.height - self.contentScrollView.bounds.size.height)
            self.contentScrollView.setContentOffset(bottomOffset, animated: false)
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
    
    private func loadingProgressVisible(_ visible: Bool) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            if visible {
                self.loadingProgress.view.isHidden = false
                self.uploadButton.isSelected = false
            } else {
                self.loadingProgress.view.isHidden = true
                self.uploadButton.isSelected = true
            }
        }
    }
    
    private func bindData() {
        uploadAct.bind { [weak self] uploadAction in
            guard let self = self else { return }
            
            switch uploadAction {
            case .uploadable:
                if self.checkIfTitleIsEmpty() == false { return }
                self.loadingProgressVisible(true)
                self.checkUploadable()
                break
            case .upload(let sessionSecret, let apiEndpoint):
                self.apiEndpoint = apiEndpoint
                self.upload(sessionSecret: sessionSecret, apiEndpoint: apiEndpoint)
                break
            case .register(let videoId):
                self.register(videoId: videoId)
                break
            case .onError(_):
                self.loadingProgressVisible(false)
                break
            default:
                break
            }
        }
    }
    
    private func checkIfTitleIsEmpty() -> Bool {
        if (self.titleTextField.text ?? "").trimWhiteSpacing_SL == "" {
            self.view.endEditing(true)
            let bundle = Bundle(for: type(of: self))
            self.showToast(message: "toast.uploadinfo.empty_video_title".localizedString(bundle: bundle))
            return false
        }
        return true
    }
    
    @objc private func didTapThumbnail(_ recognizer: UITapGestureRecognizer) {
        self.wrapTagWhenKeyboardHides(textField: tagField.textField) { [weak self] in
            guard let self = self else { return }
            let preview = SLUploadVideoPreviewController.init(uploadInfo: self.getUploadInfo())
            preview.modalPresentationStyle = .overFullScreen
            preview.modalPresentationCapturesStatusBarAppearance = true
            self.navigationController?.present(preview, animated: true)
        }
    }
    
    private func getUploadInfo() ->  SLUploadAttachmentInfo {
        var title : String = self.titleTextField.text
        if title == "" {
            title = titleTextFieldPlaceHolderText
        }
        var description : String = self.descriptionTextField.text
        if description == "" {
            description = descriptionTextFieldPlaceHolderText
        }
        return SLUploadAttachmentInfo(title: title, description: description, tags: self.tagField.tags.filter{ $0.text != "" }.map { $0.text }, videoUrl: self.videoUrl)
    }
    
    private func setUploadAction(_ action: UploadAction) {
        self.uploadAct.value = action
    }
    @objc private func didTapUploadButton() {
        if uploadButton.isSelected == false {
            titleTextField.becomeFirstResponder()
            return
        }
        self.setUploadAction(.uploadable)
    }
    
    private func checkUploadable() {
        SLShortformUploadCheckAPI().request { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let uploadable):
                guard let sessionSecret = uploadable.sessionSecret,
                      let uploadApiEndpoint = uploadable.uploadApiEndpoint else { return }
                self.uploadAct.value = .upload(sessionSecret: sessionSecret, apiEndpoint: uploadApiEndpoint)
                break
            case .failure(let error):
                self.uploadAct.value = .onError(error: error)
                print(error.localizedDescription)
                break
            }
        }
    }
    
    private func upload(sessionSecret: String, apiEndpoint: String) {
        SLShortformUploadAPI(apiEndpoint: apiEndpoint, image: self.thumbnailPath, video: self.videoUrl, sessionSecret: sessionSecret).upload { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let uploadResponse):
                self.setUploadAction(.register(videoId: uploadResponse.videoId ?? -1))
                break
            case .failure(let error):
//
//                if let error = error as? ShopLiveNetworkError {
//                    print("upload ShopLiveNetworError \(error)")
//                }
//                else {
//                    print("upload Error \(error)")
//                }
//               
                self.setUploadAction(.onError(error: error))
                break
            }
        }
    }
    
    private func makeShortsJson(videoId: Int) -> [String: Any] {
        guard let shortsDictionary = "{  \"shorts\": {    \"cards\": [      {        \"cardType\": \"VIDEO\",        \"clips\": [          {            \"from\": 0,            \"to\": \(self.videoDuration)          }        ],        \"source\": \"media\",        \"videoId\": \(videoId)      }    ],    \"shortsDetail\": {      \"description\": \"\((descriptionTextField.text ?? ""))\",      \"tags\": [\(self.tagField.tags.map { "\"\($0.text)\"" }.joined(separator: ","))              ],      \"title\": \"\((titleTextField.text ?? ""))\"    },    \"shortsType\": \"CARD\"  }}".dictionary_SL as? [String: Any] else {
            return [:]
        }
        
        return shortsDictionary
    }
    
    private func register(videoId: Int) {
        SLShortformRegisterAPI(parameters: makeShortsJson(videoId: videoId)).request { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(_):
                self.loadingProgressVisible(false)
                self.removeVideoFile()
                self.dismiss(animated: true)
                break
            case .failure(let error):
                self.setUploadAction(.onError(error: error))
                break
            }
        }
    }
    
    private func removeVideoFile() {
        try? FileManager.default.removeItem(atPath: self.videoUrl)
    }
    
    private func removeThumbnail() {
        try? FileManager.default.removeItem(atPath: self.thumbnailPath)
    }
    
    private func checkUploadInfoValidate() -> Bool {
        guard let titleTextCount = titleTextField.text?.count, titleTextCount > 0 else { return false }
        
        return true
    }
    
    var isKeyboardShow: Bool = false
    @objc func handleNotification(_ notification: Notification) {
        
        var keyboardHeight: CGFloat = 0
        var bottomPadding: CGFloat = 0
        
        if let keyboardFrameEndUserInfo = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardScreenEndFrame = keyboardFrameEndUserInfo.cgRectValue
            bottomPadding = UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0
        
            keyboardHeight = keyboardScreenEndFrame.height - bottomPadding
        }
        
        switch notification.name {
        case UIResponder.keyboardWillShowNotification:
            if !isKeyboardShow {
                self.uploadBottomConstraint.constant = -12 - keyboardHeight
                
                UIView.animate(withDuration: 0.3) { [weak self] in
                    self?.view.layoutIfNeeded()
                }
            }
            isKeyboardShow = true
            break
        case UIResponder.keyboardWillHideNotification:
            if isKeyboardShow {
                self.uploadBottomConstraint.constant = -12
                
                UIView.animate(withDuration: 0.3) { [weak self] in
                    self?.view.layoutIfNeeded()
                }
            }
            isKeyboardShow = false
            break
        default:
            break
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case titleTextField:
            descriptionTextField.becomeFirstResponder()
            break
        case descriptionTextField:
            tagField.textField.becomeFirstResponder()
            if contentScrollView.contentSize.height < contentScrollView.bounds.size.height { break }
            let bottomOffset = CGPoint(x: 0, y: contentScrollView.contentSize.height - contentScrollView.bounds.size.height)
            contentScrollView.setContentOffset(bottomOffset, animated: false)
            break
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

extension SLUploadInfoController: SLLoadingAlertControllerDelegate {
    func didCancelLoading() {
        //필터 관련 브랜치 머지하면서 구체화 될 예정 그전까지는 no - op으로 설정
    }
    
    func didFinishLoading() {
        //필터 관련 브랜치 머지하면서 구체화 될 예정 그전까지는 no - op으로 설정
    }
    
    func cancelLoading() {
        
    }
    
    func finishLoading() {
        
    }
}
extension SLUploadInfoController : UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if textView === titleTextField {
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
        if textView === titleTextField {
            self.setTextViewScrollBehaviorAndHeight(textView : textView,heightAnc: titleTextFieldHeightAnc)
            if textView.text ?? "" == titleTextFieldPlaceHolderText {
                uploadButton.isSelected = false
            }
            else {
                uploadButton.isSelected = checkUploadInfoValidate()
            }
        }
        else if textView === descriptionTextField {
            self.setTextViewScrollBehaviorAndHeight(textView : textView,heightAnc: descriptionTextFieldHeightAnc)
        }
    }
    
    
    private func setTextViewScrollBehaviorAndHeight(textView : UITextView,heightAnc : NSLayoutConstraint) {
        var font : UIFont
        if let _font = textView.font {
            font = _font
        }
        else {
            font = UIFont.systemFont(ofSize: 16, weight: .regular)
        }
        let (expectedheight,lineCount) = self.heightAndLineCountForText(textView: textView, text: textView.text, font: font, width: textView.textContainer.size.width ,padding: 24)
        UIView.animate(withDuration: 0.1) { [unowned self] in
            heightAnc.constant = max(44,expectedheight)
            self.view.layoutIfNeeded()
        }
        textView.isScrollEnabled = lineCount >= 3
    }
    
    private func heightAndLineCountForText(textView : UITextView, text : String, font : UIFont, width : CGFloat,padding : CGFloat) -> (CGFloat, Int) {
        
        let singleAttr = NSAttributedString(string: "d",attributes: [.font : font])
        let singleLineHeight = singleAttr.boundingRect(with: CGSize(width: width, height: 100), options: [.usesLineFragmentOrigin] ,context: nil).height
        
        let attr = NSAttributedString(string: text,attributes: [.font : font])
        let height = attr.boundingRect(with: CGSize(width: width, height: 1000), options: [.usesLineFragmentOrigin], context: nil).height
        
        let resultHeight = min(height + padding, (singleLineHeight * 3) + 24)
        return (ceil(resultHeight),  Int(ceil(height / singleLineHeight)))
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView === titleTextField {
            if textView.text == titleTextFieldPlaceHolderText {
                textView.text = nil
                textView.textColor = textFieldTextColor
            }
        }
        else if textView === descriptionTextField {
            if textView.text == descriptionTextFieldPlaceHolderText {
                textView.text = nil
                textView.textColor = textFieldTextColor
            }
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView === titleTextField {
            if textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                textView.text = titleTextFieldPlaceHolderText
                textView.textColor = textFieldPlaceHolderColor
            }
        }
        else if textView === descriptionTextField {
            if textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                textView.text = descriptionTextFieldPlaceHolderText
                textView.textColor = textFieldPlaceHolderColor
            }
        }
        
    }
    
}


