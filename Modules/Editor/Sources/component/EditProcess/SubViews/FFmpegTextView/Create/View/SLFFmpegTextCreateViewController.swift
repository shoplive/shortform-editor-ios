//
//  SLFFmpegTextCreateView.swift
//  ShopLiveShortformEditorSDK
//
//  Created by sangmin han on 12/27/23.
//

import Foundation
import ShopliveSDKCommon
import UIKit


protocol SLFFMpegTextViewControllerDelegate : NSObjectProtocol {
    func onSLFFMpgetTextViewComplete(textInfo : SLFFmpegTextCreateViewReactor.TextInfo )
}

class SLFFmpegTextCreateViewController : UIViewController {
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
        btn.imageView?.tintColor = .white
        return btn
    }()
    
    lazy private var pageTitleLabel : SLLabel = {
        let label = SLLabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.setFont(font: .init(size: 16, weight: .medium))
        label.textAlignment = .center
        label.text = "TextCreate"
        return label
    }()
    
    
    lazy private var textView : UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.backgroundColor = .white
        textView.textColor = .black
        textView.font = UIFont.systemFont(ofSize: 15)
        textView.textContainer.lineFragmentPadding = 0
        textView.textContainerInset = UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)
        textView.layer.cornerRadius = 15
        textView.clipsToBounds = true
        textView.delegate = self
        return textView
    }()
    
    
    private var fontSizeTitleLabel : SLLabel = {
        let label = SLLabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.setFont(font: .init(size: 15, weight: .medium))
        label.text = "Fontsize"
        return label
    }()
    
    private var fontSizeValueLabel : SLLabel = {
        let label = SLLabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.setFont(font: .init(size: 15, weight: .medium))
        label.text = "15"
        return label
    }()
    
    private var fontSizeStepper : UIStepper = {
        let stepper = UIStepper()
        stepper.translatesAutoresizingMaskIntoConstraints = false
        stepper.stepValue = 1
        stepper.value = 15
        return stepper
    }()
    
    private var fontColorTitleLabel : SLLabel = {
        let label = SLLabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.setFont(font: .init(size: 15, weight: .medium))
        label.text = "Fontcolor"
        return label
    }()
    
    
    private var fontColorBox : UIButton = {
        let view = UIButton()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.white.cgColor
        view.backgroundColor = .black
        return view
    }()
    
    private var fontColorValueLabel : SLLabel = {
        let textField = SLLabel()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.backgroundColor = .black
        textField.setFont(font: .init(size: 15, weight: .medium))
        textField.textColor = .white
        textField.textAlignment = .right
        textField.text = "#000000"
        return textField
    }()
    
    lazy private var fontColorPicker : SLColorPickerView = {
        let view = SLColorPickerView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.delegate = self
        view.isHidden = true
        return view
    }()
    
    private var textBackgroundColorTitlelabel : SLLabel = {
        let label = SLLabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.setFont(font: .init(size: 15, weight: .medium))
        label.text = "Backgroundcolor"
        return label
    }()
    
    private var backgroundColorBox : UIButton = {
        let view = UIButton()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.white.cgColor
        view.backgroundColor = .black
        return view
    }()
    
    private var textBackgroundColorValueLabel : SLLabel = {
        let textField = SLLabel()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.backgroundColor = .black
        textField.setFont(font: .init(size: 15, weight: .medium))
        textField.textColor = .white
        textField.textAlignment = .right
        textField.text = "#000000"
        return textField
    }()
    
    lazy private var backgroundColorPicker : SLColorPickerView = {
        let view = SLColorPickerView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.delegate = self
        view.isHidden = true
        return view
    }()
    
    private var timeRangeTitlelabel : SLLabel = {
        let label = SLLabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.setFont(font: .init(size: 15, weight: .medium))
        label.text = "TimeRange"
        return label
    }()
    
    private var startTimeRangeTextField : UITextField = {
        let textField = UITextField()
        textField.backgroundColor = .white
        textField.font = UIFont.systemFont(ofSize: 15,weight: .regular)
        textField.textAlignment = .center
        textField.textColor = .black
        textField.keyboardType = .decimalPad
        return textField
    }()
    
    private var endTimeRangeTextField : UITextField = {
        let textField = UITextField()
        textField.backgroundColor = .white
        textField.font = UIFont.systemFont(ofSize: 15,weight: .regular)
        textField.textAlignment = .center
        textField.textColor = .black
        textField.keyboardType = .decimalPad
        return textField
    }()
    
    
    
    private var scrollView : UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private var scrollStackView : UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.distribution = .fill
        return stackView
    }()
    
    
    
    private var confirmBtn : SLButton = {
        let btn = SLButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.backgroundColor = .white
        btn.setTitle("confirm", for: .normal)
        btn.setFont(font: .init(size: 10, weight: .medium))
        btn.setTitleColor(.black, for: .normal)
        btn.layer.cornerRadius = 15
        return btn
    }()
    
    
    
    private let reactor = SLFFmpegTextCreateViewReactor()
    
    weak var delegate : SLFFMpegTextViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .black
        self.setLayout()
        self.setKeyboardToolbar()
        self.bindReactor()
        self.addObserver()
        
        backBtn.addTarget(self, action: #selector(backBtnTapped(sender: )), for: .touchUpInside)
        fontSizeStepper.addTarget(self, action: #selector(fontStepperTapped(sender: )), for: .valueChanged)
        fontColorBox.addTarget(self, action: #selector(fontColorBoxTapped(sender: )), for: .touchUpInside)
        backgroundColorBox.addTarget(self, action: #selector(backgroundColorBoxTapped(sender: )), for: .touchUpInside)
        startTimeRangeTextField.addTarget(self, action: #selector(textFieldDidChange(textField: )), for: .editingChanged)
        endTimeRangeTextField.addTarget(self, action: #selector(textFieldDidChange(textField: )), for: .editingChanged)
        confirmBtn.addTarget(self, action: #selector(confirmBtnTapped(sender: )), for: .touchUpInside)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.removeObserver()
    }
    
    
    @objc func backBtnTapped(sender : UIButton) {
        reactor.action( .requestPopView )
    }
    
    @objc func fontStepperTapped(sender : UIStepper) {
        reactor.action( .requestFontSizeChange(Int(sender.value)) )
    }
    
    @objc func fontColorBoxTapped(sender : UIButton) {
        fontColorPicker.isHidden = !fontColorPicker.isHidden
    }
    
    @objc func backgroundColorBoxTapped(sender : UIButton) {
        backgroundColorPicker.isHidden = !backgroundColorPicker.isHidden
    }
    
    
    @objc func textFieldDidChange(textField : UITextField) {
        guard let time = Double(textField.text ?? "") else { return }
        if textField === startTimeRangeTextField {
            reactor.action( .setStartTime(time) )
        }
        else {
            reactor.action( .setEndTime(time) )
        }
    }
    
    
    @objc func confirmBtnTapped(sender : UIButton) {
        reactor.action( .requestConfirm )
    }
    
    
    private func bindReactor() {
        
        reactor.resultHandler = { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .setTextCreateCompletion(let textInfo):
                self.onSetTextCreateCompletion(textInfo: textInfo)
            default:
                break
            }
            
        }
        reactor.mainQueueResultHandler = { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .requestPopView:
                    self.onRequestPopView()
                case .setFontSize(let size):
                    self.onSetFontSize(size: size)
                default:
                    break
                    
                }
            }
        }
    }
    
    
    private func onRequestPopView() {
        self.dismiss(animated: true)
    }
    
    private func onSetFontSize(size : Int) {
        self.textView.font = UIFont.systemFont(ofSize: CGFloat(size), weight: .regular)
        self.fontSizeValueLabel.text = "\(size)"
    }
    
    private func onSetTextCreateCompletion(textInfo : SLFFmpegTextCreateViewReactor.TextInfo) {
        delegate?.onSLFFMpgetTextViewComplete(textInfo: textInfo)
    }
    
}
extension SLFFmpegTextCreateViewController : UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        reactor.action( .setText(textView.text) )
    }
    
    
}
extension SLFFmpegTextCreateViewController : SLColorPickerDelegate {
    func slColorPicker(_ view : SLColorPickerView, didSelect color: UIColor, rgb: [CGFloat]) {
        if view === fontColorPicker {
            self.fontColorBox.backgroundColor = color
            self.textView.textColor = color
            let hexString = CGEParserUtil.makeRGB2HexString(r: Float(rgb[0]), g: Float(rgb[1]), b: Float(rgb[2]), a: 1)
            self.fontColorValueLabel.text = hexString
            reactor.action( .setTextColor(hexString) )
        }
        else {
            self.textView.backgroundColor = color
            self.backgroundColorBox.backgroundColor = color
            let hexString = CGEParserUtil.makeRGB2HexString(r: Float(rgb[0]), g: Float(rgb[1]), b: Float(rgb[2]), a: 1)
            self.textBackgroundColorValueLabel.text = hexString
            reactor.action( .setTextBackgroundColor(hexString) )
        }
    }
}
//MARK: - keyBoardHandling
extension SLFFmpegTextCreateViewController {
    func addObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleNotification(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleNotification(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func removeObserver() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func handleNotification(_ notification : Notification) {
        
        var keyboardRect : CGRect = .zero
        if let keyboardFrameEndUserInfo = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            keyboardRect = keyboardFrameEndUserInfo.cgRectValue
        }
        
        switch notification.name {
        case UIResponder.keyboardWillShowNotification:
            self.handleKeyboard(keyBoardRect: keyboardRect)
            break
        case UIResponder.keyboardWillHideNotification:
            self.handleKeyboard(keyBoardRect: .zero)
            break
        default:
            break
        }
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
        let activeFields : UITextView? = findSubViewsRecursively(startView: self.view).first { ($0.isFirstResponder) }
        
        
        if var activeField = activeFields {
            let converted = activeField.convert(activeField.frame.origin, to: self.scrollView)
            if vcRect.contains(converted) == false {
                let scrollPoint = CGPoint(x: 0, y: converted.y - keyBoardRect.height)
                scrollView.setContentOffset(scrollPoint, animated: true)
            }
        }
    }
    
    private func findSubViewsRecursively(startView : UIView) -> [UITextView] {
        var subViews : [UITextView] = []
        for subView in startView.subviews {
            subViews.append(contentsOf: findSubViewsRecursively(startView: subView))
        }
        
        if startView is UITextView {
            subViews.append(startView as! UITextView)
        }
        
        return subViews
    }
    
    private func setKeyboardToolbar(){
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(doneButtonTapped))
        
        toolbar.setItems([flexibleSpace,doneButton], animated: false)
        
        textView.inputAccessoryView = toolbar
        startTimeRangeTextField.inputAccessoryView = toolbar
        endTimeRangeTextField.inputAccessoryView = toolbar
    }
    
    @objc private func doneButtonTapped() {
        self.view.endEditing(true)
    }
    
}
extension SLFFmpegTextCreateViewController {
    private func setLayout() {
        self.view.addSubview(naviBar)
        self.view.addSubview(backBtn)
        self.view.addSubview(pageTitleLabel)
        self.view.addSubview(scrollView)
        self.view.addSubview(confirmBtn)
        scrollView.addSubview(scrollStackView)
        
        
        
        //font size
        let fontSizeInnerRightStack = UIStackView(arrangedSubviews: [fontSizeValueLabel,fontSizeStepper])
        fontSizeInnerRightStack.axis = .horizontal
        fontSizeInnerRightStack.spacing = 10
        let fontSizeStack = UIStackView(arrangedSubviews: [fontSizeTitleLabel, fontSizeInnerRightStack])
        fontSizeStack.axis = .horizontal
        fontSizeStack.distribution = .equalSpacing
        
        //fontColor
        let fontColorInnertRightStack = UIStackView(arrangedSubviews: [fontColorBox,fontColorValueLabel])
        fontColorInnertRightStack.axis = .horizontal
        fontColorInnertRightStack.spacing = 10
        let fontColorStack = UIStackView(arrangedSubviews: [fontColorTitleLabel, fontColorInnertRightStack])
        fontColorStack.axis = .horizontal
        fontColorStack.distribution = .equalSpacing
        
        
        
        //background
        let backgroundColorInnertRightStack = UIStackView(arrangedSubviews: [backgroundColorBox,textBackgroundColorValueLabel])
        backgroundColorInnertRightStack.axis = .horizontal
        backgroundColorInnertRightStack.spacing = 10
        
        let backgroundColorStack = UIStackView(arrangedSubviews: [textBackgroundColorTitlelabel, backgroundColorInnertRightStack])
        backgroundColorStack.axis = .horizontal
        backgroundColorStack.distribution = .equalSpacing
        
        let timeRangeInnerRightStack = UIStackView(arrangedSubviews: [startTimeRangeTextField, endTimeRangeTextField])
        timeRangeInnerRightStack.axis = .horizontal
        timeRangeInnerRightStack.spacing = 10
        let timeRangeStack = UIStackView(arrangedSubviews: [ timeRangeTitlelabel, timeRangeInnerRightStack ])
        timeRangeStack.axis = .horizontal
        timeRangeStack.distribution = .equalSpacing
        
        
        scrollStackView.addArrangedSubview(textView)
        scrollStackView.addArrangedSubview(fontSizeStack)
        scrollStackView.addArrangedSubview(fontColorStack)
        scrollStackView.addArrangedSubview(fontColorPicker)
        scrollStackView.addArrangedSubview(backgroundColorStack)
        scrollStackView.addArrangedSubview(backgroundColorPicker)
        scrollStackView.addArrangedSubview(timeRangeStack)
        scrollStackView.isLayoutMarginsRelativeArrangement = true
        scrollStackView.layoutMargins = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        scrollStackView.setCustomSpacing(20, after: textView)
        scrollStackView.spacing = 10
        
        
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
            scrollView.bottomAnchor.constraint(equalTo: confirmBtn.bottomAnchor,constant: -10 ),
            
            scrollStackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            scrollStackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            scrollStackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            scrollStackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            
            textView.heightAnchor.constraint(equalToConstant: 150),
            
            fontColorBox.widthAnchor.constraint(equalToConstant: 60),
            fontColorPicker.heightAnchor.constraint(equalToConstant: 40),
            
            backgroundColorBox.widthAnchor.constraint(equalToConstant: 60),
            backgroundColorPicker.heightAnchor.constraint(equalToConstant: 40),
            
            timeRangeStack.heightAnchor.constraint(equalToConstant: 40),
            
            startTimeRangeTextField.widthAnchor.constraint(equalToConstant: 50),
            endTimeRangeTextField.widthAnchor.constraint(equalToConstant: 50),
            
            confirmBtn.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -12),
            confirmBtn.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor,constant: 20),
            confirmBtn.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            confirmBtn.heightAnchor.constraint(equalToConstant: 44)
        ])
        
    }
    
   
    
}
