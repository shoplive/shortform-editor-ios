//
//  OptionAlertCell.swift
//  PlayerDemo2
//
//  Created by sangmin han on 1/29/25.
//  Copyright © 2025 com.app. All rights reserved.
//

import Foundation
import UIKit

final class OptionAlertCell : UITableViewCell {
    
    static let cellId = "optionalertcellId"
   
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
extension OptionAlertCell {
    func setLayout() {
        contentView.backgroundColor = .white
        contentView.addSubview(optionTitleLabel)
        contentView.addSubview(optionDescriptionLabel)
        contentView.addSubview(optionValueLabel)
        
        NSLayoutConstraint.activate([
            optionTitleLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
            optionTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor,constant: 15),
            optionTitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor,constant: -10),
            optionTitleLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 20),
            
            optionDescriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor,constant: 15),
            optionDescriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor,constant: -10),
            optionDescriptionLabel.topAnchor.constraint(equalTo: optionTitleLabel.bottomAnchor,constant: 4),
            optionDescriptionLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 20),
            
            optionValueLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            optionValueLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            optionValueLabel.topAnchor.constraint(equalTo: optionDescriptionLabel.bottomAnchor, constant: 4),
            optionValueLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor,constant: -10),
        ])
    }
}
