//
//  ShopLiveChattingView.swift
//  CustomChatInputView
//
//  Created by ShopLive on 2022/03/30.
//


import UIKit
import ShopliveSDKCommon


protocol ShopLiveChattingViewDelegate: AnyObject {
    func didTouchSendButton()
    func updateHeight()
}

final class ShopLiveChattingView: SLView {

    class ChattingViewConfiguration {
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
    
    static let minimumHeightChatView: CGFloat = 44
    static let maximumHeightChatView: CGFloat = 62
    
    private lazy var chatInputViewTopBorder: SLView = {
        let border = SLView()
        border.backgroundColor = UIColor(red: 0.886, green: 0.886, blue: 0.886, alpha: 1)
        border.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 1)
        border.isHidden = true
        return border
    }()
    
    private lazy var chatView: ChatInputView = {
        let view = ChatInputView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.chatInputViewDelegate = self
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
        send.setAttributedTitle(styleConfig.sendButtonNormalTitle, for: .normal)
        send.setAttributedTitle(styleConfig.sendButtonDisableTitle, for: .disabled)
        send.addTarget(self, action: #selector(didTouchSendButton), for: .touchUpInside)
        return send
    }()
    
    weak var delegate: ShopLiveChattingViewDelegate?
    private let styleConfig = ChattingViewConfiguration()
    private var isFocus = false
    private let throttle = SLThrottle(queue: .main, delay: 0.3)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        render()
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    private var chatHeight: NSLayoutConstraint!
    
    private func render() {
        self.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
        self.addSubview(chatView)
        self.addSubview(topShadow)
        self.addSubview(sendButton)
        self.addSubview(chatInputViewTopBorder)
        
       
        chatHeight = chatView.heightAnchor.constraint(equalToConstant: ShopLiveChattingView.minimumHeightChatView)
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

    func updatePlaceholderVisibility() {
        chatView.updatePlaceholderVisibility()
    }
    
    func focus() {
        throttle { [ weak self] in
            guard let self = self else { return }
            guard self.isFocus == false else { return }
            self.isFocus = true
            self.chatInputViewTopBorder.isHidden = !(!UIScreen.isLandscape_SL && ShopLiveController.shared.videoOrientation == .landscape)
            self.chatView.chatTextView.becomeFirstResponder()
        } onCancel: { }
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
    
    @discardableResult
    override func becomeFirstResponder() -> Bool {
      return chatView.chatTextView.becomeFirstResponder()
    }
    
    @discardableResult
    override func resignFirstResponder() -> Bool {
      return chatView.chatTextView.resignFirstResponder()
    }
}
 
extension ShopLiveChattingView: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView){
        if #available(iOS 13, *) {
            if let subviews = scrollView.subviews as? [SLView],
               let verticalIndicator = subviews[(scrollView.subviews.count - 1)].subviews.first {
                verticalIndicator.backgroundColor = styleConfig.indicatorColor
            }
        } else {
            if let verticalIndicator: SLImageView = (scrollView.subviews[(scrollView.subviews.count - 1)] as? SLImageView) {
                verticalIndicator.backgroundColor = styleConfig.indicatorColor
            }
        }
    }
}

extension ShopLiveChattingView: ChatInputViewDelegate {
    func textViewDidChange(textView: UITextView) {
        sendButton.isEnabled = textView.hasText
    }
    
    func numberOfLinesChanged(lines: Int) {
        chatHeight.constant = lines == 1 ? ShopLiveChattingView.minimumHeightChatView : ShopLiveChattingView.maximumHeightChatView

        topShadow.isHidden = lines < chatView.styleConfig.maxLines
        delegate?.updateHeight()
        self.setNeedsLayout()
    }
}
