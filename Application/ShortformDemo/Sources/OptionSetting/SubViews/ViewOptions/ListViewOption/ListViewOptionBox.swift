//
//  ListViewOptionBox.swift
//  shortform-examples
//
//  Created by sangmin han on 2023/07/28.
//

import Foundation
import UIKit
import ShopLiveShortformSDK

class ListViewOptionBox : UIView {
    
    private let shuffleBox = OptionSetSwitchBox(title: "셔플 여부",type: .shuffle)
    private let viewCountVisibleBox = OptionSetSwitchBox(title: "조회수 보이기",type: .viewCount)
    private let titleVisibleBox = OptionSetSwitchBox(title: "제목 보이기",type: .title)
    private let descriptionVisibleBox = OptionSetSwitchBox(title: "description 보이기",type: .description)
    private let productCountVisibleBox = OptionSetSwitchBox(title: "상품 갯수 보이기",type: .productCount)
    private let brandVisibleBox = OptionSetSwitchBox(title: "브랜드 보이기",type: .brand)
    private let snapBox = OptionSetSwitchBox(title: "개별 컨텐츠 강조", type: .snap)
    private let wifiBox = OptionSetSwitchBox(title: "wifi에서만 재생", type: .playOnlyOnWifi)
    private let cardTypeBox = ListViewCardTypeOptionBox()
    
    
    private let cellSpacingBox = OptionTextViewInputBox(title: "셀 간격")
    private let cellCornerRadiusBox = OptionTextViewInputBox(title: "셀 cornerRadius")
    private let tagBox = OptionTextViewInputBox(title: "Tags")
    private var tagSearchOperatorLabel : UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        label.text = "태그 연산자"
        return label
    }()
    
    private var orBtn : UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setTitle("OR", for: .normal)
        btn.setTitleColor(UIColor(red: 51/255, green: 51/255, blue: 51/255, alpha: 1.0), for: .normal)
        btn.setTitleColor(.white, for: .selected)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        btn.backgroundColor = UIColor(red: 51/255, green: 51/255, blue: 51/255, alpha: 1.0)
        btn.layer.cornerRadius = 10
        btn.layer.borderColor = UIColor(red: 51/255, green: 51/255, blue: 51/255, alpha: 1.0).cgColor
        btn.layer.borderWidth = 1
        btn.tag = 0
        btn.isSelected = true
        return btn
    }()
    
    private var andBtn : UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setTitle("AND", for: .normal)
        btn.setTitleColor(UIColor(red: 51/255, green: 51/255, blue: 51/255, alpha: 1.0), for: .normal)
        btn.setTitleColor(.white, for: .selected)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        btn.backgroundColor = .white
        btn.layer.cornerRadius = 10
        btn.layer.borderColor = UIColor(red: 51/255, green: 51/255, blue: 51/255, alpha: 1.0).cgColor
        btn.layer.borderWidth = 1
        btn.tag = 1
        return btn
    }()
    
    private let brandBox = OptionTextViewInputBox(title: "Brands")
    private let skusBox = OptionTextViewInputBox(title: "Skus")
    
    
    
    private let normalBtnbackgroundColor : UIColor = .white
    private let selectedBtnbackgroundColor : UIColor = UIColor(red: 51/255, green: 51/255, blue: 51/255, alpha: 1.0)
    private var model : OptionSettingModel?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.setLayout()
        
        brandVisibleBox.delegate = self
        productCountVisibleBox.delegate = self
        descriptionVisibleBox.delegate = self
        titleVisibleBox.delegate = self
        shuffleBox.delegate = self
        viewCountVisibleBox.delegate = self
        brandVisibleBox.delegate = self
        snapBox.delegate = self
        wifiBox.delegate = self
        cardTypeBox.delegate = self
        
        cellSpacingBox.setKeyboardType(type: .decimalPad)
        cellCornerRadiusBox.setKeyboardType(type: .decimalPad)
        orBtn.addTarget(self, action: #selector(tagSearchOperatorTapped(sender: )), for: .touchUpInside)
        andBtn.addTarget(self, action: #selector(tagSearchOperatorTapped(sender: )), for: .touchUpInside)
      
        bindTextViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func setOptionModel(model : OptionSettingModel) {
        self.model = model
        shuffleBox.setSwitchIsOn(isOn: model.shuffle)
        viewCountVisibleBox.setSwitchIsOn(isOn: model.viewCountVisible)
        titleVisibleBox.setSwitchIsOn(isOn: model.titleVisible)
        descriptionVisibleBox.setSwitchIsOn(isOn: model.descriptionVisible)
        productCountVisibleBox.setSwitchIsOn(isOn: model.productCountVisible)
        brandVisibleBox.setSwitchIsOn(isOn: model.brandVisible)
        tagBox.setValue(value: model.tags.joined(separator: ","))
        brandBox.setValue(value: model.brands.joined(separator: ","))
        cellSpacingBox.setValue(value: "\(model.cellSpacing)")
        cellCornerRadiusBox.setValue(value: "\(model.cellCornerRadius)")
        orBtn.isSelected = model.tagSearchOperate == .OR
        andBtn.isSelected = model.tagSearchOperate == .AND
        snapBox.setSwitchIsOn(isOn: model.snapEnabled)
        wifiBox.setSwitchIsOn(isOn: model.playOnlyWifi)
        cardTypeBox.setCardTypeOnInit(type: model.cardType)
    }
    
    
    @objc func tagSearchOperatorTapped(sender : UIButton){
        orBtn.isSelected = sender.tag == 0
        andBtn.isSelected = sender.tag == 1
        
        orBtn.backgroundColor = sender.tag == 0 ? selectedBtnbackgroundColor : normalBtnbackgroundColor
        andBtn.backgroundColor = sender.tag == 1 ? selectedBtnbackgroundColor : normalBtnbackgroundColor
        
        model?.tagSearchOperate = orBtn.isSelected ? .OR : .AND
    }
    
    func bindTextViews(){
        tagBox.textViewValueTracker = { [weak self] text in
            let trimmed = text.trimWhiteSpacing_SL
            let parsed = trimmed.components(separatedBy: ",")
            self?.model?.tags = parsed
        }
        
        brandBox.textViewValueTracker = { [weak self] text  in
            let trimmed = text.trimWhiteSpacing_SL
            let parsed = trimmed.components(separatedBy: ",")
            self?.model?.brands = parsed
        }
        
        skusBox.textViewValueTracker = { [weak self] text in
            let trimmed = text.trimWhiteSpacing_SL
            let parsed = trimmed.components(separatedBy: ",")
            self?.model?.skus = parsed
        }
        
        cellSpacingBox.textViewValueTracker = { [weak self] text in
            if let n = NumberFormatter().number(from: text) {
                self?.model?.cellSpacing = CGFloat(truncating: n)
            }
            else {
                self?.model?.cellSpacing = 20
            }
        }
        
        cellCornerRadiusBox.textViewValueTracker = { [weak self] text in
            if let n = NumberFormatter().number(from: text) {
                self?.model?.cellCornerRadius = CGFloat(truncating: n)
            }
            else {
                self?.model?.cellCornerRadius = 6
            }
        }
    }
    
    
}
extension ListViewOptionBox {
    private func setLayout(){
        let tagSearchOperatorBtnStack = UIStackView(arrangedSubviews: [orBtn,andBtn])
        tagSearchOperatorBtnStack.translatesAutoresizingMaskIntoConstraints = false
        tagSearchOperatorBtnStack.axis = .horizontal
        tagSearchOperatorBtnStack.spacing = 10
        tagSearchOperatorBtnStack.distribution = .fillEqually
        
        
        let tagSearchOperatorStack = UIStackView(arrangedSubviews: [ tagSearchOperatorLabel ,tagSearchOperatorBtnStack])
        tagSearchOperatorStack.translatesAutoresizingMaskIntoConstraints = false
        tagSearchOperatorStack.axis = .horizontal
        tagSearchOperatorStack.distribution = .equalSpacing
        
        
        let stack = UIStackView(arrangedSubviews:[titleVisibleBox,
                                                  descriptionVisibleBox,
                                                  productCountVisibleBox,
                                                  brandVisibleBox,
                                                  viewCountVisibleBox,
                                                  shuffleBox,
                                                  snapBox,
                                                  wifiBox,
                                                  cardTypeBox,
                                                  cellSpacingBox,
                                                  cellCornerRadiusBox,
                                                  tagBox,
                                                  tagSearchOperatorStack,
                                                  brandBox,
                                                  skusBox])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 10
        stack.isLayoutMarginsRelativeArrangement = true
        stack.layoutMargins = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        self.addSubview(stack)
        
        NSLayoutConstraint.activate([
            tagSearchOperatorBtnStack.widthAnchor.constraint(equalToConstant: 110),
            tagSearchOperatorStack.heightAnchor.constraint(equalToConstant: 40),
            
            
            stack.topAnchor.constraint(equalTo: self.topAnchor),
            stack.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            stack.heightAnchor.constraint(lessThanOrEqualToConstant: 5000),
            
            self.bottomAnchor.constraint(equalTo: stack.bottomAnchor)
        ])
        
    }
}
extension ListViewOptionBox : OptionSetSwitchBoxDelegate {
    func optionChange(type: OptionSetSwitchBox.OptionType, value: Bool) {
        guard let model = model else { return }
        switch type {
        case .shuffle:
            model.shuffle = value
        case .viewCount:
            model.viewCountVisible = value
        case .title:
            model.titleVisible = value
        case .description:
            model.descriptionVisible = value
        case .productCount:
            model.productCountVisible = value
        case .brand:
            model.brandVisible = value
        case .snap:
            model.snapEnabled = value
        case .playOnlyOnWifi:
            model.playOnlyWifi = value
        default:
            break
        }
    }
}
extension ListViewOptionBox : ListViewCardTypeOptionBoxDelegate {
    func listCardViewTypeSelected(type: ShopLiveShortform.CardViewType) {
        model?.cardType = type
    }
}
