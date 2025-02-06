//
//  V2OptionSwitchCell.swift
//  PlayerDemo2
//
//  Created by sangmin han on 1/29/25.
//  Copyright © 2025 com.app. All rights reserved.
//

import Foundation
import UIKit
import SnapKit


protocol OptionSwitchCellDelegate : NSObjectProtocol {
    func optionSwitchCellDidChangeValue(at indexPath : IndexPath, isOn: Bool)
}

class OptionSwitchCell : UITableViewCell {
    static let cellId = "v2optionswitchcellId"
    
    
    private lazy var optionTitleLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.lineBreakMode = .byWordWrapping
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
extension OptionSwitchCell {
    func setLayout() {
        contentView.backgroundColor = .white
        contentView.addSubview(optionTitleLabel)
        contentView.addSubview(optionDescriptionLabel)
        contentView.addSubview(optionSwitch)
        
        optionTitleLabel.snp.makeConstraints {
            $0.top.equalTo(contentView.snp.top).offset(10)
            $0.leading.equalTo(contentView.snp.leading).offset(15)
            $0.trailing.equalTo(optionSwitch.snp.leading).offset(-10)
            $0.height.greaterThanOrEqualTo(20)
        }
        
        optionDescriptionLabel.snp.makeConstraints {
            $0.top.equalTo(optionTitleLabel.snp.bottom).offset(4)
            $0.leading.equalTo(contentView.snp.leading).offset(15)
            $0.trailing.equalTo(optionSwitch.snp.leading).offset(-10)
            $0.height.greaterThanOrEqualTo(20)
            $0.bottom.equalTo(contentView.snp.bottom).offset(-10)
        }
        
        optionSwitch.snp.makeConstraints {
            $0.width.equalTo(optionSwitch.frame.size.width)
            $0.trailing.equalTo(contentView.snp.trailing).offset(-20)
            $0.centerY.equalTo(contentView.snp.centerY)
        }
    
    }
}
