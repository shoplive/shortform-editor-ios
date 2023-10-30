//
//  ShopLiveChatView.swift
//  CustomChatInputView
//
//  Created by ShopLive on 2022/03/30.
//

import Foundation
import UIKit

protocol ShopLiveChatViewDelegate: AnyObject {
    func numberOfLinesChanged(lines: Int)
    func textViewDidChange(textView: UITextView)
    func didTouchSendButton()
}

final class ShopLiveChatView: SLScrollView, UITextViewDelegate {
    
    class ViewModel {
        let chatInputMaxLines: Int = 3
        
        var chatInputPlaceholderColor: UIColor {
            UIColor(red: 0.686, green: 0.686, blue: 0.686, alpha: 1)
        }
        
        var lastNumberOfLines: Int = 1
        
        private var chatInputColor: UIColor {
            UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)
        }
        
        var topPadding: CGFloat {
            lastNumberOfLines == 1 ? 12 : 8
        }
        
        var bottomPadding: CGFloat {
            lastNumberOfLines == 1 ? 12 : 4
        }
        
        private var chatInputFont: UIFont {
            guard let chatFont = ShopLiveConfiguration.UI.inputBoxFont else {
                return .systemFont(ofSize: 14, weight: .regular)
            }
            
            return chatFont.findAvailableFont()
        }
        
        private var chatInputLineHeightMultiple: CGFloat {
            chatInputFont.lineHeightMultiple()
        }
        
        var chatInputAttributes: [NSAttributedString.Key : Any] {
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineHeightMultiple = chatInputLineHeightMultiple
            
            return [
                .kern: -0.14,
                .paragraphStyle: paragraphStyle,
                .font: chatInputFont,
                .foregroundColor: chatInputColor
            ]
        }
        
        var chatPlaceholderAttributes: [NSAttributedString.Key : Any] {
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineHeightMultiple = chatInputLineHeightMultiple
            return [
                .kern: -0.14,
                .paragraphStyle: paragraphStyle,
                .font: chatInputFont,
                .foregroundColor: chatInputPlaceholderColor
            ]
        }
        
        var chatInputPlaceholderText: NSAttributedString {
            NSAttributedString(string: ShopLiveConfiguration.UI.chatInputPlaceholderString, attributes: chatPlaceholderAttributes)
        }
        
        var chatViewHeight: CGFloat {
            lastNumberOfLines == 1 ? ShopLiveChattingWriteView.minimumHeightChatView : ShopLiveChattingWriteView.maximumHeightChatView
        }
        
        var textContentHeight: CGFloat {
            CGFloat(lastNumberOfLines * 20)
        }
    }
    
    private lazy var itemContentView: SLView = {
        let view = SLView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        return view
    }()
    
    lazy var chatTextView: ShopLiveChattingView = {
        let view = ShopLiveChattingView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.delegate = self
        view.contentInset = .zero
        view.textContainerInset = .zero
        view.textContainer.lineFragmentPadding = .zero
        view.backgroundColor = .white
        view.enablesReturnKeyAutomatically = true
        view.returnKeyType = .send
        view.isScrollEnabled = false
        view.typingAttributes = viewModel.chatInputAttributes
        view.placeholderAttributedText = viewModel.chatInputPlaceholderText
        view.textContainer.maximumNumberOfLines = 0
        return view
    }()
    
    let viewModel = ViewModel()
    
    weak var chatViewDelegate: ShopLiveChatViewDelegate?
    
    init() {
        super.init(frame: .zero)
        self.initProperties()
        self.setupShopLiveChatView()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initProperties()
        self.setupShopLiveChatView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.initProperties()
        self.setupShopLiveChatView()
    }
    
    deinit {
        ShopLiveLogger.debugLog("ShopLiveChatView deallocated")
    }
    
    private func initProperties() {
        self.contentInset = .init(top: 0, left: 0, bottom: 0, right: 0)
        self.backgroundColor = .white
        self.isScrollEnabled = true
        self.showsVerticalScrollIndicator = true
        self.flashScrollIndicators()
    }
    
    private var topChatTextView: NSLayoutConstraint!
    private var bottomChatTextView: NSLayoutConstraint!
    private var contentViewHeight: NSLayoutConstraint!
    private var leftChatTextView: NSLayoutConstraint!
    private var rightChatTextView: NSLayoutConstraint!
    private func setupShopLiveChatView() {
        addSubview(itemContentView)
        itemContentView.addSubview(chatTextView)
        
        leftChatTextView = NSLayoutConstraint(item: chatTextView, attribute: .left, relatedBy: .equal, toItem: itemContentView, attribute: .left, multiplier: 1.0, constant: 0)
        rightChatTextView = NSLayoutConstraint(item: chatTextView, attribute: .right, relatedBy: .equal, toItem: itemContentView, attribute: .right, multiplier: 1.0, constant: 0)
        topChatTextView = NSLayoutConstraint(item: chatTextView, attribute: .top, relatedBy: .equal, toItem: itemContentView, attribute: .top, multiplier: 1.0, constant: viewModel.topPadding)
        bottomChatTextView = NSLayoutConstraint(item: chatTextView, attribute: .bottom, relatedBy: .equal, toItem: itemContentView, attribute: .bottom, multiplier: 1.0, constant: viewModel.bottomPadding)
        
        itemContentView.addConstraints([leftChatTextView, rightChatTextView, topChatTextView, bottomChatTextView])
        
        let contentViewWidth = NSLayoutConstraint(item: itemContentView, attribute: .width, relatedBy: .equal, toItem: self, attribute: .width, multiplier: 1.0, constant: 0)
        contentViewHeight = NSLayoutConstraint(item: itemContentView, attribute: .height, relatedBy: .equal, toItem: self, attribute: .height, multiplier: 1.0, constant: ShopLiveChattingWriteView.minimumHeightChatView)
        
        self.addConstraints([contentViewWidth, contentViewHeight])
        
        self.contentSize = CGSize(width: self.frame.width, height: viewModel.textContentHeight + topChatTextView.constant.magnitude + bottomChatTextView.constant.magnitude)
    }
    
    private func teardownShopLiveChatView() {
        
    }

    func updateShopLiveChatView() {
        chatTextView.typingAttributes = viewModel.chatInputAttributes
        chatTextView.placeholderAttributedText = viewModel.chatInputPlaceholderText
    }
    
    func updateShopLiveChatViewConstraint() {
        if ShopLiveController.shared.isPreview {
            leftChatTextView.constant = 0
            rightChatTextView.constant = 0
        } else {
            rightChatTextView.constant = 0
            leftChatTextView.constant = 15
        }
    }
    
    var isExpanded: Bool {
        self.chatTextView.numberOfLines() > 1
    }
    
    var hasText: Bool {
        let inputString = self.chatTextView.attributedText.string.filter { !$0.isWhitespace }
        return inputString.count > 0
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        
    }
    
    func textViewDidChange(_ textView: UITextView) {
        let numberOfLines: Int = textView.numberOfLines()
        
        if let shopliveChatView = textView as? ShopLiveChattingView {
            shopliveChatView.updatePlaceholder()
        }
        
        if viewModel.lastNumberOfLines != numberOfLines {
            viewModel.lastNumberOfLines = numberOfLines
            self.isScrollEnabled = true
//            contentViewHeight.constant = viewModel.chatViewHeight

            self.contentSize = CGSize(width: self.frame.width, height: viewModel.textContentHeight + topChatTextView.constant.magnitude + bottomChatTextView.constant.magnitude)
            contentViewHeight.constant = self.contentSize.height
            if numberOfLines >= viewModel.chatInputMaxLines {
                self.contentOffset = .init(x: self.contentOffset.x, y: self.contentSize.height - self.frame.height)
            } else {
                self.contentOffset = .init(x: self.contentOffset.x, y: 2)
            }
            
            setNeedsDisplay()
            
            chatViewDelegate?.numberOfLinesChanged(lines: numberOfLines)
        }
        
        chatViewDelegate?.textViewDidChange(textView: textView)
    }
    
    func clearChatView() {
        let numberOfLines: Int = 1
        viewModel.lastNumberOfLines = numberOfLines
        
        chatTextView.updatePlaceholder()
        
        self.isScrollEnabled = !(numberOfLines < viewModel.chatInputMaxLines)
        contentViewHeight.constant = viewModel.chatViewHeight

        self.contentSize = CGSize(width: self.frame.width, height: viewModel.textContentHeight + topChatTextView.constant.magnitude + bottomChatTextView.constant.magnitude)
        
        if numberOfLines >= viewModel.chatInputMaxLines {
            self.contentOffset = .init(x: self.contentOffset.x, y: self.contentSize.height - self.frame.height)
        } else {
            self.contentOffset = .init(x: self.contentOffset.x, y: 2)
        }
        
        setNeedsDisplay()
        
        chatViewDelegate?.numberOfLinesChanged(lines: numberOfLines)
        
        chatViewDelegate?.textViewDidChange(textView: chatTextView)
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let originText = textView.attributedText.string
        let carrigeReturn = "\n"
        let newLength = originText.count + (text == carrigeReturn ? 0 : text.count) - range.length

        guard newLength <= ShopLiveConfiguration.UI.chatInputMaxLength else {
            return false
        }

        if text == carrigeReturn {
            chatViewDelegate?.didTouchSendButton()
            return false
        } else{
            return true
        }
    }
}

final class ShopLiveChattingView: SLTextView {
    lazy var placeholderLabel: SLLabel = {
        let view = SLLabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.numberOfLines = 1
        view.adjustsFontSizeToFitWidth = true
        view.minimumScaleFactor = 0.4
        return view
    }()
    
    init() {
        super.init(frame: .zero, textContainer: nil)
        setupShopLiveChattingView()
    }
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        setupShopLiveChattingView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        ShopLiveLogger.debugLog("ShopLiveChattingView deallocated")
        teardownShopLiveChattingView()
    }
    
    private func setupShopLiveChattingView() {
        addSubview(placeholderLabel)
        self.placeholderLabel.fitToSuperView()
    }
    
    private func teardownShopLiveChattingView() {
        
    }
    
    var placeholderAttributedText: NSAttributedString? {
      get {
          placeholderLabel.attributedText
      }
      set {
          placeholderLabel.attributedText = newValue
        setNeedsLayout()
      }
    }
    
    override var hasText: Bool {
        let inputString = self.attributedText.string.filter { !$0.isWhitespace }
        return inputString.count > 0
    }
    
    override func layoutSubviews() {
      super.layoutSubviews()
      
      placeholderLabel.frame.origin = CGPoint(x: 5 + textContainerInset.left, y: textContainerInset.top)
      placeholderLabel.sizeToFit()
    }
    
    func updatePlaceholder() {
        placeholderLabel.isHidden = !attributedText.string.isEmpty
    }
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        
      if action == #selector(UIResponderStandardEditActions.paste(_:)) || action == #selector(UIResponderStandardEditActions.copy(_:)) {
        return true
      }

      return super.canPerformAction(action, withSender: sender)
    }
}
