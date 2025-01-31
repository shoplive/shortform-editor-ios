//
//  V2OptionSwitchCell.swift
//  PlayerDemo2
//
//  Created by sangmin han on 1/29/25.
//  Copyright © 2025 com.app. All rights reserved.
//

import Foundation
import UIKit


protocol OptionSwitchCellDelegate : NSObjectProtocol {
    func optionSwitchCellDidChangeValue(at indexPath : IndexPath, isOn: Bool)
}

class V2OptionSwitchCell : UITableViewCell {
    static let cellId = "v2optionswitchcellId"
    
    
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
    
    private lazy var optionSwitch: UISwitch = {
        let view = UISwitch()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
   
    weak var delegate : OptionSwitchCellDelegate?
    var indexPath : IndexPath?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.setLayout()
        contentView.backgroundColor = .white
        optionSwitch.addTarget(self, action: #selector(switchButtonValueChanged(sender: )), for: .valueChanged)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func switchButtonValueChanged(sender : UISwitch) {
        guard let indexPath = self.indexPath else { return }
        delegate?.optionSwitchCellDidChangeValue(at: indexPath , isOn: sender.isOn)
    }
    
    func configureCell(title : String, description : String, isOn : Bool, indexPath : IndexPath) {
        self.optionTitleLabel.text = title
        self.optionDescriptionLabel.text = title
        self.optionSwitch.isOn = isOn
        self.indexPath = indexPath
    }
}
extension V2OptionSwitchCell {
    func setLayout() {
        contentView.addSubview(optionTitleLabel)
        contentView.addSubview(optionDescriptionLabel)
        contentView.addSubview(optionSwitch)
        NSLayoutConstraint.activate([
            optionTitleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            optionTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            optionTitleLabel.trailingAnchor.constraint(equalTo: optionSwitch.leadingAnchor, constant: -10),
            optionTitleLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 20),
            
            optionDescriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            optionDescriptionLabel.trailingAnchor.constraint(equalTo: optionSwitch.leadingAnchor, constant: -10),
            optionDescriptionLabel.topAnchor.constraint(equalTo: optionTitleLabel.bottomAnchor, constant: 4),
            optionDescriptionLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
            
            optionSwitch.trailingAnchor.constraint(equalTo: contentView.trailingAnchor,constant: -20),
            optionSwitch.widthAnchor.constraint(equalToConstant: 50),
            optionSwitch.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
        ])
    }
}
