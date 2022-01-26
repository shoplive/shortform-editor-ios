//
//  ChattingWriteView.swift
//  ShopLiveSDK
//
//  Created by ShopLive on 2021/06/17.
//

import UIKit
import Foundation

protocol ChattingWriteDelegate: AnyObject {
    func didTouchSendButton()
    func updateHeight()
}

internal final class ChattingWriteView: UIView {

    class ViewModel {
        var chatInputPlaceholderText: String = NSLocalizedString("chat.placeholder", comment: "메시지를 입력하세요")
        var chatInputSendText: String = NSLocalizedString("chat.send.title", comment: "보내기")
        var chatInputMaxLength: Int = 50

        init(placeholder: String, sendText: String, maxLength: Int) {
            chatInputPlaceholderText = placeholder
            chatInputSendText = sendText
            chatInputMaxLength = maxLength
        }
    }

    weak var delegate: ChattingWriteDelegate?
    private var viewModel: ViewModel?
    private var inputFrame: CGRect = .zero

    var chatText: String {
        get {
            return chatTextView.textView.text
        }
    }
    private var isFocus: Bool = false
    init() {
        super.init(frame: .zero)
        setupViews()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }

    func configure(viewModel: ViewModel) {
        self.viewModel = viewModel

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 1.19

        let isCustomFont = ShopLiveController.shared.inputBoxFont != nil
        chatTextView.placeholderAttributedText = NSMutableAttributedString(string: viewModel.chatInputPlaceholderText, attributes: [NSAttributedString.Key.kern: -0.14, NSAttributedString.Key.paragraphStyle: paragraphStyle, .font: isCustomFont ? ShopLiveController.shared.inputBoxFont ?? UIFont.systemFont(ofSize: 14, weight: .regular) : UIFont.systemFont(ofSize: 14, weight: .regular), .foregroundColor: UIColor(red: 0.686, green: 0.686, blue: 0.686, alpha: 1)])


        setSendButtonTitle(title: viewModel.chatInputSendText)
    }

    func focus() {
        guard isFocus == false else { return }
        isFocus = true
        chatTextView.becomeFirstResponder()
    }

    func focusOut() {
        isFocus = false
    }

    func isFocused() -> Bool {
        return chatTextView.textView.isFirstResponder
    }

    func clear() {
        chatTextView.textView.text.removeAll()
    }

    private var topShadow: UIView = {
        var view = UIView()
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
        return view
    }()

    private var baseRect: CGRect = .zero
    private lazy var chatTextView: SLNextGrowingTextView = {
        let chatView = SLNextGrowingTextView()
        chatView.translatesAutoresizingMaskIntoConstraints = false
        chatView.maxNumberOfLines = 2
        chatView.backgroundColor = .clear
        chatView.delegate = self
        chatView.textView.delegate = self
        chatView.textView.enablesReturnKeyAutomatically = true
        let isCustomFont = ShopLiveController.shared.inputBoxFont != nil
        chatView.textView.returnKeyType = .send
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 1.19
        chatView.textView.typingAttributes = [NSAttributedString.Key.kern: -0.14, NSAttributedString.Key.paragraphStyle: paragraphStyle, .font: isCustomFont ? ShopLiveController.shared.inputBoxFont ?? UIFont.systemFont(ofSize: 14, weight: .regular) : UIFont.systemFont(ofSize: 14, weight: .regular), .foregroundColor: UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)]
        chatView.placeholderAttributedText = NSMutableAttributedString(string: NSLocalizedString("chat.placeholder", comment: "메시지를 입력하세요"), attributes: [NSAttributedString.Key.kern: -0.14, NSAttributedString.Key.paragraphStyle: paragraphStyle, .font: isCustomFont ? ShopLiveController.shared.inputBoxFont ?? UIFont.systemFont(ofSize: 14, weight: .regular) : UIFont.systemFont(ofSize: 14, weight: .regular), .foregroundColor: UIColor(red: 0.686, green: 0.686, blue: 0.686, alpha: 1)])
        return chatView
    }()

    private func setSendButtonTitle(title: String) {

        let isCustomFont = ShopLiveController.shared.sendButtonFont != nil
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 1.19
        sendButton.setAttributedTitle(NSMutableAttributedString(string: title, attributes: [NSAttributedString.Key.kern: -0.13, NSAttributedString.Key.paragraphStyle: paragraphStyle, .foregroundColor: UIColor(red: 0, green: 0.471, blue: 1, alpha: 1), .font: isCustomFont ? ShopLiveController.shared.sendButtonFont ?? UIFont.systemFont(ofSize: 14, weight: .medium) : UIFont.systemFont(ofSize: 14, weight: .medium)]), for: .normal)
        sendButton.setAttributedTitle(NSMutableAttributedString(string: title, attributes: [NSAttributedString.Key.kern: -0.13, NSAttributedString.Key.paragraphStyle: paragraphStyle, .foregroundColor:  UIColor(red: 0.796, green: 0.796, blue: 0.796, alpha: 1), .font: isCustomFont ? ShopLiveController.shared.sendButtonFont ?? UIFont.systemFont(ofSize: 14, weight: .medium) : UIFont.systemFont(ofSize: 14, weight: .medium)]), for: .disabled)
    }

    private func isChatEnable() -> Bool {
        return chatTextView.textView.text.count > 0
    }

    private lazy var sendButton: UIButton = {
        let send = UIButton()
        send.translatesAutoresizingMaskIntoConstraints = false
        send.layer.masksToBounds = true
        send.backgroundColor = .white
        send.layer.cornerRadius = 4
        send.isEnabled = false

        var paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 0.9
        send.titleLabel?.textAlignment = .center
        send.setAttributedTitle(NSMutableAttributedString(string: NSLocalizedString("chat.send.title", comment: "보내기"), attributes: [NSAttributedString.Key.kern: -0.13, NSAttributedString.Key.paragraphStyle: paragraphStyle, .foregroundColor: UIColor(red: 0.937, green: 0.204, blue: 0.204, alpha: 1), .font: UIFont.systemFont(ofSize: 14, weight: .medium)]), for: .normal)
        send.setAttributedTitle(NSMutableAttributedString(string: NSLocalizedString("chat.send.title", comment: "보내기"), attributes: [NSAttributedString.Key.kern: -0.13, NSAttributedString.Key.paragraphStyle: paragraphStyle, .foregroundColor: UIColor(red: 0.796, green: 0.796, blue: 0.796, alpha: 1), .font: UIFont.systemFont(ofSize: 14, weight: .medium)]), for: .disabled)

        send.addTarget(self, action: #selector(didTouchSendButton), for: .touchUpInside)
        return send
    }()

    @objc
    func didTouchSendButton() {
        sendButton.isEnabled = false
        delegate?.didTouchSendButton()
    }

    private var chatTopEqual: NSLayoutConstraint!
    private var chatTopMin: NSLayoutConstraint!

    private func setupViews() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = .white
        self.addSubview(chatTextView)
        self.addSubview(sendButton)
        self.addSubview(topShadow)

        let topShadowTop = NSLayoutConstraint.init(item: topShadow, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 0)
        let topShadowLeading = NSLayoutConstraint.init(item: topShadow, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1.0, constant: 12)
        let topShadowTrailing = NSLayoutConstraint.init(item: topShadow, attribute: .trailing, relatedBy: .equal, toItem: sendButton, attribute: .leading, multiplier: 1.0, constant: -8)
        let topShadowHeight = NSLayoutConstraint.init(item: topShadow, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 9)
        topShadow.addConstraint(topShadowHeight)

        chatTopEqual = NSLayoutConstraint.init(item: chatTextView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 0)
        chatTopMin = NSLayoutConstraint.init(item: chatTextView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 6)

        let chatBottom = NSLayoutConstraint.init(item: chatTextView, attribute: .bottom, relatedBy: .lessThanOrEqual, toItem: self, attribute: .bottom, multiplier: 1.0, constant: -8)
        let chatLeading = NSLayoutConstraint.init(item: chatTextView, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1.0, constant: 12)
        let chatTrailing = NSLayoutConstraint.init(item: chatTextView, attribute: .trailing, relatedBy: .equal, toItem: sendButton, attribute: .leading, multiplier: 1.0, constant: -8)

        let sendBottom = NSLayoutConstraint.init(item: sendButton, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: -8)
        let sendTrailing = NSLayoutConstraint.init(item: sendButton, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1.0, constant: -4)
        let sendWidth = NSLayoutConstraint.init(item: sendButton, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 68)
        let sendHeight = NSLayoutConstraint.init(item: sendButton, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 36)
        
        sendButton.addConstraints([sendWidth, sendHeight])
        self.addConstraints([
            topShadowTop, topShadowLeading, topShadowTrailing,
            chatTopEqual, chatTopEqual, chatBottom, chatLeading, chatTrailing,//, chatCenterY,
            sendBottom, sendTrailing
        ])
        chatTopEqual.isActive = false
        chatTopMin.isActive = true

        self.inputFrame = self.baseRect
        chatTextView.delegates.didChangeHeight = { [weak self] height in
          guard let `self` = self else { return }
            if height == self.baseRect.height {
                self.chatTopEqual.isActive = false
                self.chatTopMin.isActive = true
            } else {
                self.chatTopMin.isActive = false
                self.chatTopEqual.isActive = true

            }

            DispatchQueue.main.async {
                if !self.isHidden && self.inputFrame.height != height {
                    self.inputFrame.size = .init(width: self.inputFrame.width, height: height)
                    debugPrint("heightLog self.inputFrame.height: \(self.inputFrame.height)")
                    self.delegate?.updateHeight()
                }
            }
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        if baseRect == .zero {
            baseRect = chatTextView.textView.frame
        }
    }
}

extension ChattingWriteView: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView){
        if #available(iOS 13, *) {
            let verSubView: UIView = scrollView.subviews[(scrollView.subviews.count - 1)]
            if let verticalIndicator = verSubView.subviews.first {
                verticalIndicator.backgroundColor = UIColor(red: 0.886, green: 0.886, blue: 0.886, alpha: 1)
            }

        } else {
            if let verticalIndicator: UIImageView = (scrollView.subviews[(scrollView.subviews.count - 1)] as? UIImageView) {
                verticalIndicator.backgroundColor = UIColor(red: 0.886, green: 0.886, blue: 0.886, alpha: 1)
            }
        }
    }
}

extension ChattingWriteView: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        sendButton.isEnabled = textView.hasText
    }

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        guard let originText = textView.text else { return true }


        let newLength = originText.count + text.count - range.length

        guard newLength <= (viewModel?.chatInputMaxLength ?? 50) else {
            return false
        }

        if text == "\n" {
            self.didTouchSendButton()
            return false
        } else{
            return true
        }
    }
}
/*
 let range = NSMakeRange(0, to.range.location + to.range.length + 1)
 guard (group as NSString).length - range.length > 0 else {
     continue
 }
 let text = (group as NSString).replacingCharacters(in: range, with: "")
 */
