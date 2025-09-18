//
//  ShopLiveChattingWriteView.swift
//  CustomChatInputView
//
//  Created by ShopLive on 2022/03/30.
//


import UIKit
import ShopliveSDKCommon


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
        ShopLiveLogger.tempLog("ShopLiveChattingWriteView deallocated")
    }
    private var chatHeight: NSLayoutConstraint!
    
    private func setupChattingWriteView() {
        self.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
        self.addSubview(chatView)
        self.addSubview(topShadow)
        self.addSubview(sendButton)
        self.addSubview(chatInputViewTopBorder)
        
       
        chatHeight = chatView.heightAnchor.constraint(equalToConstant: ShopLiveChattingWriteView.minimumHeightChatView)
        NSLayoutConstraint.activate([
            sendButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -5),
            sendButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -5),
            sendButton.widthAnchor.constraint(equalToConstant: 60),
            sendButton.heightAnchor.constraint(equalToConstant: 36),
            
            chatView.topAnchor.constraint(equalTo: topAnchor),
            chatView.bottomAnchor.constraint(equalTo: bottomAnchor),
            chatView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            chatView.trailingAnchor.constraint(equalTo: sendButton.leadingAnchor),
            
            chatInputViewTopBorder.topAnchor.constraint(equalTo: topAnchor),
            chatInputViewTopBorder.leadingAnchor.constraint(equalTo: leadingAnchor, constant: -4),
            chatInputViewTopBorder.trailingAnchor.constraint(equalTo: trailingAnchor),
            chatInputViewTopBorder.heightAnchor.constraint(equalToConstant: 1),
            
            topShadow.topAnchor.constraint(equalTo: topAnchor),
            topShadow.leadingAnchor.constraint(equalTo: leadingAnchor),
            topShadow.trailingAnchor.constraint(equalTo: sendButton.leadingAnchor),
            topShadow.heightAnchor.constraint(equalToConstant: 9),
            
            chatHeight
        ])
    }
    
    private func teardownChattingWriteView() {
        
    }

    func updateChattingWriteView() {
        sendButton.setAttributedTitle(viewModel.sendButtonNormalTitle, for: .normal)
        sendButton.setAttributedTitle(viewModel.sendButtonDisableTitle, for: .disabled)
        chatView.updateShopLiveChatView()
    }
    
    func focus() {
        throttle { [ weak self] in
            guard let self = self else { return }
            guard self.isFocus == false else { return }
            self.isFocus = true
            self.chatInputViewTopBorder.isHidden = !(!UIScreen.isLandscape && ShopLiveController.shared.videoOrientation == .landscape)
            ShopLiveLogger.tempLog("chat border ishidden : \(!UIScreen.isLandscape && ShopLiveController.shared.videoOrientation == .landscape)")
            
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
