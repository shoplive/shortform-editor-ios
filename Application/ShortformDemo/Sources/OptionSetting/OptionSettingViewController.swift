//
//  OptionSettingViewController.swift
//  shortform-examples
//
//  Created by sangmin han on 2023/07/28.
//

import Foundation
import UIKit
import ShopliveSDKCommon
import ShopLiveShortformSDK


class OptionSettingViewController : UIViewController {
    
    enum ViewType {
        case card
        case vertical
        case horizontal
        case web
    }
    
    private var landingBox = LandingSelectBox()
    private var commonUserSetupBox = CommonUserSetUpBox()
    private var cacheBox = CacheOptionBox()
    private var listViewOptionBox = ListViewOptionBox()
    private var detailWebViewOptionsBox = DetailWebViewOptionBox()
    private var detailViewOptionBox = DetailViewOptionBox()
    private var editorOptionBox = EditorViewOptionBox()
    private var previewOptionBox = PreviewOptionBox()
    
    private var confirmBtn : UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setTitle("CONFIRM", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.backgroundColor = UIColor(red: 51/255, green: 51/255, blue: 51/255, alpha: 1.0)
        return btn
    }()
    
    
    private var scrollView = UIScrollView()
    private var stack = UIStackView()
    
    private var viewType : ViewType = .card
    private var cardModel : OptionSettingModel = OptionSettingModel()
    private var verticalModel : OptionSettingModel = OptionSettingModel()
    private var horizontalModel : OptionSettingModel = OptionSettingModel()
    
    var resultCallBack : ((_ type : ViewType, _ options : OptionSettingModel,_ accessKey : String?) -> ())?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        setLayout()
        confirmBtn.addTarget(self, action: #selector(confirmBtnTapped(_: )), for: .touchUpInside)
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        addObserver()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        removeObserver()
    }
    
    func setViewType(type : ViewType){
        editorOptionBox.setOptions()
        previewOptionBox.setOptions()
        cacheBox.reloadCacheSize()
        self.viewType = type
        switch type {
        case .card:
            listViewOptionBox.setOptionModel(model: cardModel)
            listViewOptionBox.isHidden = false
        case .horizontal:
            listViewOptionBox.setOptionModel(model: horizontalModel)
            listViewOptionBox.isHidden = false
        case .vertical:
            listViewOptionBox.setOptionModel(model: verticalModel)
            listViewOptionBox.isHidden = false
        case .web:
            listViewOptionBox.isHidden = true
        }
    }
    
    @objc func confirmBtnTapped(_ : UIButton){
        switch viewType {
        case .card:
            self.resultCallBack?(viewType,cardModel,landingBox.getValue())
        case .horizontal:
            self.resultCallBack?(viewType,horizontalModel,landingBox.getValue())
        case.vertical:
            self.resultCallBack?(viewType,verticalModel,landingBox.getValue())
        default:
            self.resultCallBack?(viewType,cardModel,landingBox.getValue())
            break
        }
        detailWebViewOptionsBox.applyOption()
        self.dismiss(animated: true)
    }
    
}
extension OptionSettingViewController {
    private func setLayout(){
        self.view.addSubview(scrollView)
        scrollView.keyboardDismissMode = .onDrag
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(stack)
        
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.addArrangedSubview(landingBox)
        stack.addArrangedSubview(commonUserSetupBox)
        stack.addArrangedSubview(cacheBox)
        stack.addArrangedSubview(listViewOptionBox)
        stack.addArrangedSubview(detailWebViewOptionsBox)
        stack.addArrangedSubview(detailViewOptionBox)
        stack.addArrangedSubview(editorOptionBox)
        stack.addArrangedSubview(previewOptionBox)
        stack.addArrangedSubview(confirmBtn)
        
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            
            confirmBtn.heightAnchor.constraint(equalToConstant: 50),
            
            stack.topAnchor.constraint(equalTo: scrollView.topAnchor),
            stack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            stack.widthAnchor.constraint(equalTo: scrollView.widthAnchor, multiplier: 1),
            stack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor)
        ])
    }
}
extension OptionSettingViewController {
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
    
}
