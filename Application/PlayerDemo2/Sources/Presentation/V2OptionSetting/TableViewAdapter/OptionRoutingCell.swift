//
//  V2OptionButtonCell.swift
//  PlayerDemo2
//
//  Created by sangmin han on 1/29/25.
//  Copyright © 2025 com.app. All rights reserved.
//

import Foundation
import UIKit

final class OptionRoutingCell : UITableViewCell {
    
    static let cellId = "v2optionbuttoncellId"
    
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
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .gray
        setLayout()
        contentView.backgroundColor = .white
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(title : String, description : String) {
        self.optionTitleLabel.text = title
        self.optionDescriptionLabel.text = description
    }
}
extension OptionRoutingCell {
    func setLayout() {
        contentView.addSubview(optionTitleLabel)
        contentView.addSubview(optionDescriptionLabel)
        
        NSLayoutConstraint.activate([
            optionTitleLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
            optionTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor,constant: 15),
            optionTitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor,constant: -10),
            optionTitleLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 20),
            
            optionDescriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor,constant: 15),
            optionDescriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor,constant: -10),
            optionDescriptionLabel.topAnchor.constraint(equalTo: optionTitleLabel.bottomAnchor,constant: 4),
            optionDescriptionLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 20),
            
            contentView.bottomAnchor.constraint(equalTo: optionDescriptionLabel.bottomAnchor)
        ])
    }
}
