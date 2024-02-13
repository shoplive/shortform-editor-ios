//
//  ShopLiveChattingWriteView.swift
//  CustomChatInputView
//
//  Created by ShopLive on 2022/03/30.
//


import UIKit
import ShopLiveSDKCommon


protocol ShopLiveChattingWriteDelegate: AnyObject {
    func didTouchSendButton()
    func updateHeight()
}

final class ShopLiveChattingWriteView: SLView {

    static let minimumHeightChatView: CGFloat = 44
    static let maximumHeightChatView: CGFloat = 62
    
    class ViewModel {
        var indicatorColor: UIColor {
            UIColor(red: 0.886, green: 0.886, blue: 0.886, alpha: 1)
        }
        
        var sendButtonNormalTitle: NSAttributedString {
            let paragraphStyle = NSMutableParagraphStyle()
            let font = ShopLiveConfiguration.UI.sendButtonFont ?? UIFont.systemFont(ofSize: 14, weight: .medium).findAvailableFont()
            
            paragraphStyle.lineHeightMultiple = font.lineHeightMultiple()
            return NSAttributedString(string: ShopLiveConfiguration.UI.chatInputSendString, attributes: [NSAttributedString.Key.kern: -0.28, NSAttributedString.Key.paragraphStyle: paragraphStyle, .foregroundColor: UIColor(red: 0, green: 0.471, blue: 1, alpha: 1), .font: font])
        }
        
        var sendButtonDisableTitle: NSAttributedString {
            let paragraphStyle = NSMutableParagraphStyle()
            let font = ShopLiveConfiguration.UI.sendButtonFont ?? UIFont.systemFont(ofSize: 14, weight: .medium).findAvailableFont()
            
            paragraphStyle.lineHeightMultiple = font.lineHeightMultiple()
            return NSAttributedString(string: ShopLiveConfiguration.UI.chatInputSendString, attributes: [NSAttributedString.Key.kern: -0.28, NSAttributedString.Key.paragraphStyle: paragraphStyle, .foregroundColor: UIColor(red: 0.886, green: 0.886, blue: 0.886, alpha: 1), .font: font])
        }
    }
    
    private lazy var chatInputViewTopBorder: SLView = {
        let border = SLView()
        border.backgroundColor = UIColor(red: 0.886, green: 0.886, blue: 0.886, alpha: 1)
        border.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 1)
        border.isHidden = true
        return border
    }()
    
    private lazy var chatView: ShopLiveChatView = {
        let view = ShopLiveChatView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.chatViewDelegate = self
        view.delegate = self
        return view
    }()
    
    private var topShadow: SLView = {
        var view = SLView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        let layer0 = CAGradientLayer()
        layer0.colors = [
          UIColor(red: 1, green: 1, blue: 1, alpha: 1).cgColor,
          UIColor(red: 1, green: 1, blue: 1, alpha: 0).cgColor
        ]

        layer0.locations = [0, 1]
        layer0.startPoint = CGPoint(x: 0.25, y: 0.5)
        layer0.endPoint = CGPoint(x: 0.75, y: 0.5)
        layer0.transform = CATransform3DMakeAffineTransform(CGAffineTransform(a: 0, b: 1, c: -1, d: 0, tx: 1, ty: 0))
        layer0.bounds = view.bounds.insetBy(dx: -0.5*view.bounds.size.width, dy: -0.5*view.bounds.size.height)
        layer0.position = view.center
        view.layer.addSublayer(layer0)
        view.alpha = 0.8
        view.isHidden = true
        return view
    }()
    
    private lazy var sendButton: SLButton = {
        let send = SLButton()
        send.translatesAutoresizingMaskIntoConstraints = false
        send.layer.masksToBounds = true
        send.backgroundColor = .clear
        send.layer.cornerRadius = 4
        send.isEnabled = false

        send.titleLabel?.textAlignment = .center
        send.setAttributedTitle(viewModel.sendButtonNormalTitle, for: .normal)
        send.setAttributedTitle(viewModel.sendButtonDisableTitle, for: .disabled)
        send.addTarget(self, action: #selector(didTouchSendButton), for: .touchUpInside)
        return send
    }()
    
    weak var delegate: ShopLiveChattingWriteDelegate?
    
    private let viewModel = ViewModel()
    
    private var isFocus: Bool = false
    
    let throttle: Throttle = Throttle(queue: DispatchQueue.main, delay: 0.3)
    
    init() {
        super.init(frame: .zero)
        setupChattingWriteView()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupChattingWriteView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupChattingWriteView()
    }
    
    deinit {
        ShopLiveLogger.debugLog("ShopLiveChattingWriteView deallocated")
    }
    private var sendButtonTrailing: NSLayoutConstraint!
    private var chatViewLeading: NSLayoutConstraint!
    private var chatHeight: NSLayoutConstraint!
    private var selfHeight: NSLayoutConstraint!
    private var topShadowLeading: NSLayoutConstraint!
    private var topShadowtrailing: NSLayoutConstraint!
    private var topShadowHeight: NSLayoutConstraint!
    private var sendBottom: NSLayoutConstraint!
    private var sendWidth: NSLayoutConstraint!
    private var sendHeight: NSLayoutConstraint!
    private var chatTrailing: NSLayoutConstraint!
    private func setupChattingWriteView() {
        self.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
        self.addSubview(chatView)
        self.addSubview(topShadow)
        self.addSubview(sendButton)
        self.addSubview(chatInputViewTopBorder)
        
        let topShadowTop = NSLayoutConstraint.init(item: topShadow, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 0)
        topShadowLeading = NSLayoutConstraint.init(item: topShadow, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1.0, constant: 0)
        topShadowtrailing = NSLayoutConstraint.init(item: topShadow, attribute: .trailing, relatedBy: .equal, toItem: sendButton, attribute: .leading, multiplier: 1.0, constant: 0)
        topShadowHeight = NSLayoutConstraint.init(item: topShadow, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 0)
        topShadow.addConstraint(topShadowHeight)
        
        self.sendButtonTrailing = sendButton.trailingAnchor.constraint(equalTo: self.trailingAnchor)
        sendBottom = NSLayoutConstraint.init(item: sendButton, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: 0)
        sendWidth = NSLayoutConstraint.init(item: sendButton, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 0)
        sendHeight = NSLayoutConstraint.init(item: sendButton, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 0)
        sendButton.addConstraints([sendWidth, sendHeight])
        
        self.chatViewLeading = chatView.leadingAnchor.constraint(equalTo: self.leadingAnchor)
        let chatTop = NSLayoutConstraint.init(item: chatView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 0)
        let chatBottom = NSLayoutConstraint.init(item: chatView, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: 0)
        chatTrailing = NSLayoutConstraint.init(item: chatView, attribute: .trailing, relatedBy: .equal, toItem: sendButton, attribute: .leading, multiplier: 1.0, constant: 0)
        chatHeight = NSLayoutConstraint.init(item: chatView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1.0, constant: ShopLiveChattingWriteView.minimumHeightChatView)
        orientationChattingWritrViewConstraint()
        
        chatView.addConstraints([chatHeight])
        
        self.addConstraints([topShadowTop, topShadowLeading, topShadowtrailing,
                             chatTop, chatViewLeading, chatTrailing, chatBottom,
                             sendBottom, sendButtonTrailing])
    }
    
    private func teardownChattingWriteView() {
        
    }

    func updateChattingWriteView() {
        sendButton.setAttributedTitle(viewModel.sendButtonNormalTitle, for: .normal)
        sendButton.setAttributedTitle(viewModel.sendButtonDisableTitle, for: .disabled)
        chatView.updateShopLiveChatView()
    }
    
    func orientationChattingWritrViewConstraint() {
        if ShopLiveController.shared.isPreview {
            chatViewLeading.constant = 0
            sendButtonTrailing.constant = 0
        } else if UIScreen.currentOrientation.deviceOrientation == .landscapeRight {
            chatViewLeading.constant = UIScreen.safeArea.right == .zero ? 0 : UIScreen.safeArea.right / 3
            sendButtonTrailing.constant = -UIScreen.safeArea.right
        } else if UIScreen.currentOrientation.deviceOrientation == .landscapeLeft {
            chatViewLeading.constant = UIScreen.safeArea.left
            sendButtonTrailing.constant = UIScreen.safeArea.left == .zero ? 0 : -(UIScreen.safeArea.right / 3)
        } else {
            chatViewLeading.constant = 0
            sendButtonTrailing.constant = -4
        }
    }
    
    func updateChattingWriteViewConstraint() {
        if ShopLiveController.windowStyle == .inAppPip {
            topShadowLeading.constant = 0
            topShadowtrailing.constant = 0
            topShadowHeight.constant = 0
            sendBottom.constant = 0
            sendWidth.constant = 0
            sendHeight.constant = 0
            chatTrailing.constant = 0
        } else {
            topShadowLeading.constant = 12
            topShadowtrailing.constant = -16
            topShadowHeight.constant = 9
            sendBottom.constant = -6
            sendWidth.constant = 60
            sendHeight.constant = 36
            chatTrailing.constant = -4
        }
        chatView.updateShopLiveChatViewConstraint()
    }
    
    func focus() {
        throttle { [ weak self] in
            guard let self = self else { return }
            guard self.isFocus == false else { return }
            self.isFocus = true
            self.chatInputViewTopBorder.isHidden = !(!UIScreen.isLandscape && ShopLiveController.shared.videoOrientation == .landscape)
            ShopLiveLogger.debugLog("chat border ishidden : \(!UIScreen.isLandscape && ShopLiveController.shared.videoOrientation == .landscape)")
            
            self.chatView.chatTextView.becomeFirstResponder()
        } onCancel: {
            
        }
        
    }
    
    func focusOut() {
        isFocus = false
    }

    func isFocused() -> Bool {
        return chatView.chatTextView.isFirstResponder
    }

    func clearChatText() {
        chatView.chatTextView.attributedText = nil
        chatView.clearChatView()
    }
    
    @objc func didTouchSendButton() {
        sendButton.isEnabled = false
        delegate?.didTouchSendButton()
    }
    
    var chatText: String {
        chatView.chatTextView.attributedText.string
    }
    
    @discardableResult override func becomeFirstResponder() -> Bool {
      return chatView.chatTextView.becomeFirstResponder()
    }
    
    @discardableResult override func resignFirstResponder() -> Bool {
      return chatView.chatTextView.resignFirstResponder()
    }
}
 
extension ShopLiveChattingWriteView: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView){
        if #available(iOS 13, *) {
            if let subviews = scrollView.subviews as? [SLView],
               let verticalIndicator = subviews[(scrollView.subviews.count - 1)].subviews.first {
                verticalIndicator.backgroundColor = viewModel.indicatorColor
            }
        } else {
            if let verticalIndicator: SLImageView = (scrollView.subviews[(scrollView.subviews.count - 1)] as? SLImageView) {
                verticalIndicator.backgroundColor = viewModel.indicatorColor
            }
        }
    }
}

extension ShopLiveChattingWriteView: ShopLiveChatViewDelegate {
    func textViewDidChange(textView: UITextView) {
        sendButton.isEnabled = textView.hasText
    }
    
    func numberOfLinesChanged(lines: Int) {
        chatHeight.constant = lines == 1 ? ShopLiveChattingWriteView.minimumHeightChatView : ShopLiveChattingWriteView.maximumHeightChatView

        topShadow.isHidden = lines < chatView.viewModel.chatInputMaxLines
        delegate?.updateHeight()
        self.setNeedsLayout()
    }
}
