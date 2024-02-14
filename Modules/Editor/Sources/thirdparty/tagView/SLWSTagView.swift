//
//  SLWSTagView.swift
//  Whitesmith
//
//  Created by Ricardo Pereira on 12/05/16.
//  Copyright © 2016 Whitesmith. All rights reserved.
//

import UIKit

open class SLWSTagView: UIView, UITextInputTraits {

    fileprivate let textLabel = UILabel()
    
    private lazy var closeButton: UIButton = {
        let view = UIButton()
//        let bundle = Bundle(for: type(of: self))
//        let closebuttonImage = UIImage(named: "sl_closebutton", in: bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
        view.setImage(ShopLiveShortformEditorSDKAsset.slClosebutton.image.withRenderingMode(.alwaysTemplate), for: .normal)
        view.tintColor = .black
        return view
    }()

    open var displayText: String = "" {
        didSet {
            updateLabelText()
            setNeedsDisplay()
        }
    }

    open var displayDelimiter: String = "" {
        didSet {
            updateLabelText()
            setNeedsDisplay()
        }
    }

    open var font: UIFont? {
        didSet {
            textLabel.font = font
            setNeedsDisplay()
        }
    }

    open var cornerRadius: CGFloat = 3.0 {
        didSet {
            self.layer.cornerRadius = cornerRadius
            setNeedsDisplay()
        }
    }

    open var borderWidth: CGFloat = 0.0 {
        didSet {
            self.layer.borderWidth = borderWidth
            setNeedsDisplay()
        }
    }

    open var borderColor: UIColor? {
        didSet {
            if let borderColor = borderColor {
                self.layer.borderColor = borderColor.cgColor
                setNeedsDisplay()
            }
        }
    }

    open override var tintColor: UIColor! {
        didSet { updateContent(animated: false) }
    }

    /// Background color to be used for selected state.
    open var selectedColor: UIColor? {
        didSet { updateContent(animated: false) }
    }

    open var textColor: UIColor? {
        didSet { updateContent(animated: false) }
    }

    open var selectedTextColor: UIColor? {
        didSet { updateContent(animated: false) }
    }

    internal var onDidRequestDelete: ((_ tagView: SLWSTagView, _ replacementText: String?) -> Void)?
    internal var onDidRequestSelection: ((_ tagView: SLWSTagView) -> Void)?
    internal var onDidInputText: ((_ tagView: SLWSTagView, _ text: String) -> Void)?

    open var selected: Bool = false {
        didSet {
            if selected && !isFirstResponder {
                _ = becomeFirstResponder()
            }
            else if !selected && isFirstResponder {
                _ = resignFirstResponder()
            }
            updateContent(animated: true)
        }
    }

    // MARK: - UITextInputTraits

    public var autocapitalizationType: UITextAutocapitalizationType = .none
    public var autocorrectionType: UITextAutocorrectionType  = .no
    public var spellCheckingType: UITextSpellCheckingType  = .no
    public var keyboardType: UIKeyboardType = .default
    public var keyboardAppearance: UIKeyboardAppearance = .default
    public var returnKeyType: UIReturnKeyType = .next
    public var enablesReturnKeyAutomatically: Bool = false
    public var isSecureTextEntry: Bool = false

    // MARK: - Initializers
    var useCloseButton: Bool = true
    public init(tag: SLWSTag) {
        super.init(frame: CGRect.zero)
        self.backgroundColor = tintColor
        self.layer.cornerRadius = cornerRadius
        self.layer.masksToBounds = true

        textColor = UIColor(red: 51/255, green: 51/255, blue: 51/255, alpha: 1.0)
        selectedColor = .gray
        selectedTextColor = .black

        textLabel.frame = CGRect(x: layoutMargins.left, y: layoutMargins.top, width: 0, height: 0)
        textLabel.font = font
        textLabel.textColor = .white
        textLabel.backgroundColor = .clear
        textLabel.numberOfLines = 0
        textLabel.lineBreakMode = .byCharWrapping
        addSubview(textLabel)
        addSubview(closeButton)
        self.displayText = "#\(tag.text)"
        updateLabelText()

        
        closeButton.addTarget(self, action: #selector(closeBtnTapped(sender: )), for: .touchUpInside)
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTapGestureRecognizer))
        addGestureRecognizer(tapRecognizer)
        setNeedsLayout()
        
    }
    
    @objc func closeBtnTapped(sender : UIButton) {
        self.onDidRequestDelete?(self,nil)
    }
    private lazy var closeButtonSize: CGFloat = useCloseButton ? 8.49 : 0
    private func updateCloseButton(origin: CGPoint) {
        closeButton.isHidden = !useCloseButton
        closeButton.frame = CGRect(x: origin.x, y: origin.y, width: closeButtonSize, height: closeButtonSize)
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        assert(false, "Not implemented")
    }

    // MARK: - Styling

    fileprivate func updateColors() {
        self.backgroundColor = selected ? selectedColor : tintColor
        textLabel.textColor = selected ? selectedTextColor : textColor
    }

    internal func updateContent(animated: Bool) {
        guard animated else {
            updateColors()
            return
        }

        UIView.animate(
            withDuration: 0.2,
            animations: { [weak self] in
                self?.updateColors()
                if self?.selected ?? false {
                    self?.transform = CGAffineTransform(scaleX: 1.15, y: 1.15)
                }
            },
            completion: { [weak self] _ in
                if self?.selected ?? false {
                    UIView.animate(withDuration: 0.1) { [weak self] in
                        self?.transform = CGAffineTransform.identity
                    }
                }
            }
        )
    }

    // MARK: - Size Measurements

    open override var intrinsicContentSize: CGSize {
        let labelIntrinsicSize = textLabel.intrinsicContentSize
        return CGSize(width: labelIntrinsicSize.width + (useCloseButton ? 18 : 0) + layoutMargins.left + layoutMargins.right,
                      height: labelIntrinsicSize.height + layoutMargins.top + layoutMargins.bottom)
    }

    open override func sizeThatFits(_ size: CGSize) -> CGSize {
        let layoutMarginsHorizontal = layoutMargins.left + layoutMargins.right
        let layoutMarginsVertical = layoutMargins.top + layoutMargins.bottom
        let fittingSize = CGSize(width: size.width - layoutMarginsHorizontal,
                                 height: size.height - layoutMarginsVertical)
        let labelSize = textLabel.sizeThatFits(fittingSize)
        return CGSize(width: labelSize.width + layoutMarginsHorizontal,
                      height: labelSize.height + layoutMarginsVertical)
    }

    open func sizeToFit(_ size: CGSize) -> CGSize {
        
        let attr = NSAttributedString(string: textLabel.text ?? "" ,attributes: [.font : textLabel.font!])
        let height = attr.boundingRect(with: CGSize(width: size.width - 2, height: 1000), options: [.usesLineFragmentOrigin,.truncatesLastVisibleLine], context: nil).height +
        layoutMargins.top + layoutMargins.bottom + 3
        
        if intrinsicContentSize.width > size.width {
            return CGSize(width: size.width,
                          height: max(intrinsicContentSize.height,height))
        }
        return CGSize(width: self.intrinsicContentSize.width, height: max(intrinsicContentSize.height,height))
        //intrinsicContentSize
    }

    // MARK: - Attributed Text
    fileprivate func updateLabelText() {
        // Unselected shows "[displayText]," and selected is "[displayText]"
        textLabel.text = displayText + displayDelimiter
        // Expand Label
        let intrinsicSize = CGSize(width: self.intrinsicContentSize.width, height: self.intrinsicContentSize.height)

        frame = CGRect(x: 0, y: 0, width: intrinsicSize.width + (useCloseButton ? 18 : 0), height: intrinsicSize.height)
        
        updateCloseButton(origin: CGPoint(x: intrinsicSize.width + (useCloseButton ? 12 : 0), y: (self.frame.height - closeButtonSize) / 2))
    }

    // MARK: - Laying out
    open override func layoutSubviews() {
        super.layoutSubviews()
        let textLabelFrame = bounds.inset(by: layoutMargins)
        textLabel.frame = CGRect(origin: textLabelFrame.origin, size: CGSize(width: textLabelFrame.width - (useCloseButton ? 18 : 0), height: textLabelFrame.height))
        if frame.width == 0 || frame.height == 0 {
            let intrinsicSize = CGSize(width: self.intrinsicContentSize.width + (useCloseButton ? 18 : 0), height: self.intrinsicContentSize.height)
            frame.size = intrinsicSize
        }
        updateCloseButton(origin: CGPoint(x: self.textLabel.frame.width + (useCloseButton ? 12 : 0), y: (frame.height - closeButtonSize) / 2))
        
        // print("ypos \((frame.height - closeButtonSize) / 2)")
    }

    // MARK: - First Responder (needed to capture keyboard)
    open override var canBecomeFirstResponder: Bool {
        return true
    }

    open override func becomeFirstResponder() -> Bool {
        let didBecomeFirstResponder = super.becomeFirstResponder()
        selected = true
        return didBecomeFirstResponder
    }

    open override func resignFirstResponder() -> Bool {
        let didResignFirstResponder = super.resignFirstResponder()
        selected = false
        return didResignFirstResponder
    }

    // MARK: - Gesture Recognizers
    @objc func handleTapGestureRecognizer(_ sender: UITapGestureRecognizer) {
        if selected {
            return
        }
        onDidRequestSelection?(self)
    }
    
    override open func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let closeBtnRect = closeButton.frame.insetBy(dx: -10, dy: -3)
        if closeBtnRect.contains(point) {
            return closeButton
        }
        
        return super.hitTest(point, with: event)
    }
    
}

extension SLWSTagView: UIKeyInput {

    public var hasText: Bool {
        return true
    }

    public func insertText(_ text: String) {
        onDidInputText?(self, text)
    }

    public func deleteBackward() {
        onDidRequestDelete?(self, nil)
    }

}
