//
//  FontOptionBox.swift
//  ShortformDemo
//
//  Created by Tabber on 2/14/25.
//  Copyright © 2025 com.app. All rights reserved.
//

import UIKit
import SnapKit
import ShopliveSDKCommon


class FontOptionBox: UIView {
    
    enum FontType: Int {
        case 시스템기본 = 0
        case 나눔스퀘어_Bold = 1
        case 나눔스퀘어_Light = 2
        case 쿠키런 = 3
        case 온글잎밑미 = 4
        case 조선굵은명조 = 5
        case G마켓산스 = 6
        
        var fontStringValue: String {
            switch self {
            case .나눔스퀘어_Bold:
                return "NanumSquareOTFB"
            case .나눔스퀘어_Light:
                return "NanumSquareOTFL"
            case .쿠키런:
                return "CookieRunOTF-Regular"
            case .온글잎밑미:
                return "Ownglyph_meetme-Rg"
            case .조선굵은명조:
                return "ChosunKm"
            case .G마켓산스:
                return "GmarketSansTTFMedium"
            default:
                return ""
            }
        }
        
        var fontKor: String {
            switch self {
            case .나눔스퀘어_Bold:
                return "나눔스퀘어 B"
            case .나눔스퀘어_Light:
                return "나눔스퀘어 L"
            case .쿠키런:
                return "쿠키런"
            case .온글잎밑미:
                return "온글잎 밑미"
            case .조선굵은명조:
                return "조선굵은명조"
            case .G마켓산스:
                return "G마켓 Sans"
            default:
                return "시스템 기본"
            }
        }
        
        static func convert(_ font: String) -> FontType {
            switch font {
            case "NanumSquareOTFB": .나눔스퀘어_Bold
            case "NanumSquareOTFL": .나눔스퀘어_Light
            case "CookieRunOTF-Regular": .쿠키런
            case "Ownglyph_meetme-Rg": .온글잎밑미
            case "ChosunKm": .조선굵은명조
            case "GmarketSansTTFMedium": .G마켓산스
            default: .시스템기본
            }
        }
    }
    
    private var titleLabel : UILabel = {
        let label = UILabel()
        label.text = "Font 옵션"
        label.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        label.textColor = .black
        label.backgroundColor = .white
        return label
    }()
    
    private var selectFont: String = ""
    
    private let buttonArray: [FontType] = [
        .시스템기본,
        .나눔스퀘어_Light,
        .나눔스퀘어_Bold,
        .쿠키런,
        .온글잎밑미,
        .조선굵은명조,
        .G마켓산스
    ]
    
    private var buttons: [UIButton] = []
    
    private var scrollView: UIScrollView = UIScrollView()
    private var scrollContentView: UIView = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setLayout() {
        
        self.addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(self.snp.top)
            $0.leading.equalTo(self.snp.leading).offset(15)
        }
        
        
        let stackView: UIStackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 5
        
        buttonArray.forEach { font in
            let btn = UIButton()
            btn.translatesAutoresizingMaskIntoConstraints = false
            btn.setTitle(font.fontKor, for: .normal)
            btn.titleLabel?.font = .init(name: font.fontStringValue, size: 13)
            
            if font.fontStringValue == "" {
                btn.titleLabel?.font = UIFont.systemFont(ofSize: 13, weight: .regular)
            }
            
            btn.setTitleColor(UIColor(red: 51/255, green: 51/255, blue: 51/255, alpha: 1.0), for: .normal)
            btn.setTitleColor(.white, for: .selected)
            btn.titleLabel?.minimumScaleFactor = 0.5
            btn.backgroundColor = .white
            btn.layer.cornerRadius = 10
            btn.layer.borderColor = UIColor(red: 51/255, green: 51/255, blue: 51/255, alpha: 1.0).cgColor
            btn.layer.borderWidth = 1
            btn.addTarget(self, action: #selector(buttonSelect), for: .touchUpInside)
            btn.tag = font.rawValue
            
            btn.titleLabel?.lineBreakMode = .byTruncatingTail
            btn.titleLabel?.numberOfLines = 0
            btn.titleEdgeInsets = .init(top: 0, left: 5, bottom: 0, right: 5)
            btn.setContentHuggingPriority(.required, for: .horizontal)
            btn.setContentCompressionResistancePriority(.required, for: .horizontal)
            
            self.buttons.append(btn)
            
            stackView.addArrangedSubview(btn)
            
            btn.snp.makeConstraints {
                $0.width.equalTo(90)
            }
            
        }
        stackView.isLayoutMarginsRelativeArrangement = true
        
        self.addSubview(scrollView)
        self.scrollView.addSubview(scrollContentView)
        self.scrollContentView.addSubview(stackView)
        
        scrollView.snp.makeConstraints {
            $0.top.equalTo(self.titleLabel.snp.bottom).offset(15)
            $0.leading.equalTo(self.snp.leading)
            $0.trailing.equalTo(self.snp.trailing)
            $0.bottom.equalTo(self.snp.bottom)
            $0.height.equalTo(100)
        }
        
        scrollContentView.snp.makeConstraints {
            $0.top.equalTo(self.scrollView.snp.top)
            $0.leading.equalTo(self.scrollView.snp.leading)
            $0.trailing.equalTo(self.scrollView.snp.trailing)
            $0.bottom.equalTo(self.scrollView.snp.bottom)
        }
        
        stackView.snp.makeConstraints {
            $0.top.equalTo(self.scrollContentView.snp.top)
            $0.leading.equalTo(self.scrollContentView.snp.leading)
            $0.trailing.equalTo(self.scrollContentView.snp.trailing)
            $0.bottom.equalTo(self.scrollContentView.snp.bottom)
        }
        
    }
    
    func setFont(font: String) {
        self.selectFont = font
        
        let convertFont = FontType.convert(font)
        
        let targetButton = buttons[convertFont.rawValue]
        
        
        self.buttons.forEach {
            if $0.tag == convertFont.rawValue {
                $0.isSelected = true
                $0.backgroundColor = UIColor(red: 51/255, green: 51/255, blue: 51/255, alpha: 1.0)
            } else {
                $0.backgroundColor = .white
                $0.isSelected = false
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            let targetOffset = CGPoint(x: targetButton.frame.origin.x / 2, y: 0)
            self.scrollView.setContentOffset(targetOffset, animated: true)
        }
    }
    
    func applyFontOption() {
        OptionSettingModel.font = selectFont
        ShopLiveCommon.setFontFamily(font: selectFont)
    }
    
    @objc func buttonSelect(sender: UIButton) {
        if let type = FontType(rawValue: sender.tag) {
            self.selectFont = type.fontStringValue
            self.buttons.forEach {
                if $0.tag == type.rawValue {
                    $0.backgroundColor = UIColor(red: 51/255, green: 51/255, blue: 51/255, alpha: 1.0)
                    $0.isSelected = true
                } else {
                    $0.backgroundColor = .white
                    $0.isSelected = false
                }
            }
            
            let targetOffset = CGPoint(x: sender.frame.origin.x / 2, y: 0)
            self.scrollView.setContentOffset(targetOffset, animated: true)
        }
    }
}
