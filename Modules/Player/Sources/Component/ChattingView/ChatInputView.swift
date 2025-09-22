//
//  ChatInputView.swift
//  CustomChatInputView
//
//  Created by ShopLive on 2022/03/30.
//

import Foundation
import UIKit
import ShopliveSDKCommon

protocol ChatInputViewDelegate: AnyObject {
    func numberOfLinesChanged(lines: Int)
    func textViewDidChange(textView: UITextView)
    func didTouchSendButton()
}
//인풋 필드
final class ChatInputView: SLScrollView {
    
    // 기존 스타일 보존 (변경 최소화)
    final class ChatInputStyle {
        let maxLines: Int = 3
        let placeholderColor = UIColor(red: 0.686, green: 0.686, blue: 0.686, alpha: 1)
        let foregroundColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)
        var lastNumberOfLines: Int = 1
        
        var topPadding: CGFloat { lastNumberOfLines == 1 ? 12 : 8 }
        var bottomPadding: CGFloat { lastNumberOfLines == 1 ? 12 : 4 }
        
        private var inputTextFont: UIFont {
            guard let chatFont = ShopLiveConfiguration.UI.inputBoxFont else {
                return .systemFont(ofSize: 14, weight: .regular)
            }
            return chatFont.findAvailableFont()
        }
        
        private var lineHeightMultiple: CGFloat { inputTextFont.lineHeightMultiple() }
        
        var inputTextAttribute: [NSAttributedString.Key: Any] {
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineHeightMultiple = lineHeightMultiple
            return [
                .kern: -0.14,
                .paragraphStyle: paragraphStyle,
                .font: inputTextFont,
                .foregroundColor: foregroundColor
            ]
        }
        
        var placeholderAttributes: [NSAttributedString.Key: Any] {
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineHeightMultiple = lineHeightMultiple
            return [
                .kern: -0.14,
                .paragraphStyle: paragraphStyle,
                .font: inputTextFont,
                .foregroundColor: placeholderColor
            ]
        }
        
        var placeholderText: NSAttributedString {
            NSAttributedString(
                string: ShopLiveConfiguration.UI.chatInputPlaceholderString,
                attributes: placeholderAttributes
            )
        }
        
        var chatViewHeight: CGFloat {
            lastNumberOfLines == 1
            ? ShopLiveChattingView.minimumHeightChatView
            : ShopLiveChattingView.maximumHeightChatView
        }
        
        var textContentHeight: CGFloat {
            CGFloat(lastNumberOfLines * 20)
        }
    }
    
    // MARK: - UI
    private lazy var containerView: SLView = {
        let view = SLView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        return view
    }()
    
    private(set) lazy var chatTextView: SLTextView = {
        let view = SLTextView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.delegate = self
        view.textContainerInset = .zero
        view.textContainer.lineFragmentPadding = .zero
        view.backgroundColor = .white
        view.enablesReturnKeyAutomatically = true
        view.returnKeyType = .send
        view.isScrollEnabled = false
        view.typingAttributes = styleConfig.inputTextAttribute
        view.inputAccessoryView = nil
        return view
    }()
    
    private lazy var placeholderLabel: SLLabel = {
        let view = SLLabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.adjustsFontSizeToFitWidth = true
        view.minimumScaleFactor = 0.4
        view.attributedText = styleConfig.placeholderText
        return view
    }()
    
    var isExpanded: Bool {
        chatTextView.numberOfLines() > 1
    }
    
    var hasText: Bool {
        let inputString = chatTextView.attributedText.string.filter { !$0.isWhitespace }
        return inputString.count > 0
    }
    
    private(set) var styleConfig = ChatInputStyle()
    weak var chatInputViewDelegate: ChatInputViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        render()
        updatePlaceholderVisibility()
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Layout
    private var containerViewHeightConstraint: NSLayoutConstraint!
    private var topChatTextViewConstraint: NSLayoutConstraint!
    private var bottomChatTextViewConstraint: NSLayoutConstraint!
    private var leftChatTextViewConstraint: NSLayoutConstraint!
    private var rightChatTextViewConstraint: NSLayoutConstraint!
    
    private func render() {
        backgroundColor = .white
        
        addSubview(containerView)
        containerView.addSubview(chatTextView)
        chatTextView.addSubview(placeholderLabel)
        
        // TextView constraints
        leftChatTextViewConstraint = NSLayoutConstraint(
            item: chatTextView,
            attribute: .left,
            relatedBy: .equal,
            toItem: containerView,
            attribute: .left,
            multiplier: 1.0,
            constant: 0
        )
        rightChatTextViewConstraint = NSLayoutConstraint(
            item: chatTextView,
            attribute: .right,
            relatedBy: .equal,
            toItem: containerView,
            attribute: .right,
            multiplier: 1.0,
            constant: 0
        )
        topChatTextViewConstraint = NSLayoutConstraint(
            item: chatTextView,
            attribute: .top,
            relatedBy: .equal,
            toItem: containerView,
            attribute: .top,
            multiplier: 1.0,
            constant: styleConfig.topPadding
        )
        bottomChatTextViewConstraint = NSLayoutConstraint(
            item: chatTextView,
            attribute: .bottom,
            relatedBy: .equal,
            toItem: containerView,
            attribute: .bottom,
            multiplier: 1.0,
            constant: styleConfig.bottomPadding
        )
        containerView.addConstraints([leftChatTextViewConstraint, rightChatTextViewConstraint, topChatTextViewConstraint, bottomChatTextViewConstraint])
        
        // ContentView sizing
        let contentViewWidth = NSLayoutConstraint(
            item: containerView, attribute: .width,
            relatedBy: .equal, toItem: self, attribute: .width,
            multiplier: 1.0, constant: 0
        )
        containerViewHeightConstraint = NSLayoutConstraint(
            item: containerView, attribute: .height,
            relatedBy: .equal, toItem: self, attribute: .height,
            multiplier: 1.0, constant: ShopLiveChattingView.minimumHeightChatView
        )
        addConstraints([contentViewWidth, containerViewHeightConstraint])
        
        // Placeholder label constraints (텍스트 인셋과 맞춤)
        NSLayoutConstraint.activate([
            placeholderLabel.leadingAnchor.constraint(equalTo: chatTextView.leadingAnchor, constant: 5 + chatTextView.textContainerInset.left),
            placeholderLabel.topAnchor.constraint(equalTo: chatTextView.topAnchor, constant: chatTextView.textContainerInset.top)
        ])
        
        contentSize = CGSize(
            width: frame.width,
            height: styleConfig.textContentHeight
            + topChatTextViewConstraint.constant.magnitude
            + bottomChatTextViewConstraint.constant.magnitude
        )
    }
    
    // MARK: - Public
    func updateChatViewConstraint() {
        let isPreview = ShopLiveController.shared.isPreview
        leftChatTextViewConstraint.constant = isPreview ?  0 : 15
    }
    
    func clearChatView() {
        let numberOfLines: Int = 1
        styleConfig.lastNumberOfLines = numberOfLines
        
        updatePlaceholderVisibility()
        
        isScrollEnabled = !(numberOfLines < styleConfig.maxLines)
        containerViewHeightConstraint.constant = styleConfig.chatViewHeight
        
        contentSize = CGSize(
            width: frame.width,
            height: styleConfig.textContentHeight
            + topChatTextViewConstraint.constant.magnitude
            + bottomChatTextViewConstraint.constant.magnitude
        )
        
        if numberOfLines >= styleConfig.maxLines {
            contentOffset = .init(x: contentOffset.x, y: contentSize.height - frame.height)
        } else {
            contentOffset = .init(x: contentOffset.x, y: 2)
        }
        
        setNeedsDisplay()
        
        chatInputViewDelegate?.numberOfLinesChanged(lines: numberOfLines)
        chatInputViewDelegate?.textViewDidChange(textView: chatTextView)
    }

    // MARK: - Placeholder
    
    func updatePlaceholderVisibility() {
        placeholderLabel.isHidden = !chatTextView.attributedText.string.isEmpty
    }
}

extension ChatInputView: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        let numberOfLines: Int = textView.numberOfLines()
        
        updatePlaceholderVisibility()
        
        if styleConfig.lastNumberOfLines != numberOfLines {
            styleConfig.lastNumberOfLines = numberOfLines
            isScrollEnabled = true
            
            contentSize = CGSize(
                width: frame.width,
                height: styleConfig.textContentHeight
                + topChatTextViewConstraint.constant.magnitude
                + bottomChatTextViewConstraint.constant.magnitude
            )
            containerViewHeightConstraint.constant = contentSize.height
            
            if numberOfLines >= styleConfig.maxLines {
                contentOffset = .init(x: contentOffset.x, y: contentSize.height - frame.height)
            } else {
                contentOffset = .init(x: contentOffset.x, y: 2)
            }
            
            setNeedsDisplay()
            chatInputViewDelegate?.numberOfLinesChanged(lines: numberOfLines)
        }
        chatInputViewDelegate?.textViewDidChange(textView: textView)
    }
    
    func textView(
        _ textView: UITextView,
        shouldChangeTextIn range: NSRange,
        replacementText text: String
    ) -> Bool {
        let originText = textView.attributedText.string
        let returnKey = "\n"
        let newLength = originText.count + (text == returnKey ? 0 : text.count) - range.length
        
        guard newLength <= ShopLiveConfiguration.UI.chatInputMaxLength else {
            return false
        }
        
        if text == returnKey {
            chatInputViewDelegate?.didTouchSendButton()
            return false
        }
        return true
    }
}
