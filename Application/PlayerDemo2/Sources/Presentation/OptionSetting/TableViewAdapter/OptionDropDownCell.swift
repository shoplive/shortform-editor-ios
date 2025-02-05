//
//  DropDownOptionCell.swift
//  PlayerDemo2
//
//  Created by sangmin han on 1/28/25.
//  Copyright © 2025 com.app. All rights reserved.
//

import Foundation
import UIKit

final class OptionDropDownCell : UITableViewCell {
    
    static let cellId = "optiondropdowncellId"
   
    private lazy var optionTitleLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.numberOfLines = 0
        view.textColor = .black
        view.font = .systemFont(ofSize: 15, weight: .regular)
        return view
    }()
    
    private lazy var optionDescriptionLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.numberOfLines = 0
        view.textColor = .lightGray
        view.font = .systemFont(ofSize: 14, weight: .regular)
        return view
    }()
    
    private lazy var optionValueLabel : UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.numberOfLines = 0
        view.textColor = .black
        view.font = .systemFont(ofSize: 14, weight: .regular)
        return view
    }()
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.setLayout()
        contentView.backgroundColor = .white
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func configureCell(title : String, description : String, value : String) {
        optionTitleLabel.text = title
        optionDescriptionLabel.text = description
        optionValueLabel.text = value
    }
    
}
extension OptionDropDownCell {
    func setLayout() {
        contentView.backgroundColor = .white
        contentView.addSubview(optionTitleLabel)
        contentView.addSubview(optionDescriptionLabel)
        contentView.addSubview(optionValueLabel)
        
        
        optionTitleLabel.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview().offset(15)
            $0.trailing.equalToSuperview().offset(-10)
            $0.height.equalTo(20)
        }
        
        optionDescriptionLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(15)
            $0.trailing.equalToSuperview().offset(-10)
            $0.top.equalTo(optionTitleLabel.snp.bottom).offset(4)
            $0.height.greaterThanOrEqualTo(20)
        }
        
        optionValueLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(15)
            $0.trailing.equalToSuperview().offset(10)
            $0.top.equalTo(optionDescriptionLabel.snp.bottom).offset(4)
            $0.bottom.equalToSuperview().offset(-10)
        }
    }
}
