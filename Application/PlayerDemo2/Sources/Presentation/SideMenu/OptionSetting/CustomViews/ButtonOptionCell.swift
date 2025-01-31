//
//  ButtonOptionCell.swift
//  PlayerDemo2
//
//  Created by Tabber on 1/20/25.
//  Copyright © 2025 com.app. All rights reserved.
//

import UIKit
import ShopLiveSDK

final class ButtonOptionCell: UITableViewCell {

    var item: SDKOptionItem?
    lazy var optionTitleLabel: UILabel = {
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
    
    private lazy var optionValueWhenDropdownLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.numberOfLines = 0
        view.textColor = .black
        view.font = .systemFont(ofSize: 14, weight: .regular)
        view.isHidden = true
        return view
    }()

    private lazy var labelBoxView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(optionTitleLabel)
        view.addSubview(optionDescriptionLabel)
        view.addSubview(optionValueWhenDropdownLabel)
        
        NSLayoutConstraint.activate([
            optionTitleLabel.topAnchor.constraint(equalTo: view.topAnchor),
            optionTitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            optionTitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            optionTitleLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 20),
            
            optionDescriptionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            optionDescriptionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            optionDescriptionLabel.topAnchor.constraint(equalTo: optionTitleLabel.bottomAnchor,constant: 4),
            
            optionValueWhenDropdownLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            optionValueWhenDropdownLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            optionValueWhenDropdownLabel.topAnchor.constraint(equalTo: optionDescriptionLabel.bottomAnchor, constant: 4),
            optionValueWhenDropdownLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        return view
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .gray
        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    private func setupViews() {
        self.contentView.backgroundColor = .white
        self.contentView.addSubview(labelBoxView)
        
        NSLayoutConstraint.activate([
            labelBoxView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            labelBoxView.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -10),
            labelBoxView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            labelBoxView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
    }
    
    private func setupDefault() {
        optionValueWhenDropdownLabel.isHidden = true
        
        guard let superview = optionDescriptionLabel.superview else { return }
        NSLayoutConstraint.activate([
            optionDescriptionLabel.leadingAnchor.constraint(equalTo: superview.leadingAnchor, constant: 0),
            optionDescriptionLabel.trailingAnchor.constraint(equalTo: superview.trailingAnchor, constant: 0),
            optionDescriptionLabel.topAnchor.constraint(equalTo: optionTitleLabel.bottomAnchor, constant: 4),
            
            optionValueWhenDropdownLabel.leadingAnchor.constraint(equalTo: superview.leadingAnchor),
            optionValueWhenDropdownLabel.trailingAnchor.constraint(equalTo: superview.trailingAnchor),
            optionValueWhenDropdownLabel.topAnchor.constraint(equalTo: optionDescriptionLabel.bottomAnchor, constant: 4),
            optionValueWhenDropdownLabel.bottomAnchor.constraint(equalTo: superview.bottomAnchor)
        ])
    }
    
    private func setupDropdown() {
        optionValueWhenDropdownLabel.isHidden = false
        
        guard let superview = optionDescriptionLabel.superview else { return }
        
        NSLayoutConstraint.activate([
            optionDescriptionLabel.leadingAnchor.constraint(equalTo: superview.leadingAnchor),
            optionDescriptionLabel.trailingAnchor.constraint(equalTo: superview.trailingAnchor),
            optionDescriptionLabel.topAnchor.constraint(equalTo: optionTitleLabel.bottomAnchor, constant: 4),
            optionDescriptionLabel.bottomAnchor.constraint(equalTo: optionValueWhenDropdownLabel.topAnchor, constant: -4),
            
            optionValueWhenDropdownLabel.leadingAnchor.constraint(equalTo: superview.leadingAnchor),
            optionValueWhenDropdownLabel.trailingAnchor.constraint(equalTo: superview.trailingAnchor),
            optionValueWhenDropdownLabel.topAnchor.constraint(equalTo: optionDescriptionLabel.bottomAnchor,constant: 4),
            optionValueWhenDropdownLabel.bottomAnchor.constraint(equalTo: super.bottomAnchor)
        ])
    }

    func configure(item: SDKOptionItem) {
        if item.optionType.settingType == .dropdown {
            setupDropdown()
        } else {
            setupDefault()
        }
        
        optionTitleLabel.text = item.name
        updateDatas(item: item)
    }
    
    func updateDatas(item: SDKOptionItem) {
        var descriptionTitle: String = ""
        
        switch item.optionType.settingType {
        case .dropdown:
            optionDescriptionLabel.text = item.optionDescription
            switch item.optionType {
            case .pipPosition:
                let pipPosition = DemoConfiguration.shared.pipPosition
                descriptionTitle = pipPosition.name
                break
            case .nextActionOnHandleNavigation:
                let nextActionOnHandleNavigation: ActionType = DemoConfiguration.shared.nextActionTypeOnHandleNavigation
                descriptionTitle = nextActionOnHandleNavigation.localizedName
                break
            default:
                break
            }
            optionValueWhenDropdownLabel.text = descriptionTitle
            break
        case .routeTo:
            switch item.optionType {
            case .pipFloatingOffset:
                descriptionTitle = item.optionDescription
                break
            default:
                descriptionTitle = item.optionDescription
                break
            }
            break
        default:
            switch item.optionType {
            case .shareScheme:
                if let shareScheme = DemoConfiguration.shared.shareScheme, !shareScheme.isEmpty {
                    descriptionTitle = shareScheme
                } else {
                    descriptionTitle = item.optionDescription
                }
                break
            case .progressColor:
                if let progressColor = DemoConfiguration.shared.progressColor, !progressColor.isEmpty {
                    descriptionTitle = progressColor
                } else {
                    descriptionTitle = item.optionDescription
                }
                break
            case .pipScale:
                if let pipScale = DemoConfiguration.shared.pipScale {
                    if pipScale > 0.0, pipScale <= 1.0 {
                        descriptionTitle = String(format: "%.1f",  pipScale)
                    } else if pipScale > 1.0, pipScale <= 100 {
                        descriptionTitle = String(format: "%.0f",  pipScale)
                    } else {
                        descriptionTitle = item.optionDescription
                    }
                } else {
                    descriptionTitle = item.optionDescription
                }
                break
            case .maxPipSize:
                if let maxPipSize = DemoConfiguration.shared.maxPipSize, maxPipSize > 0.0 {
                    descriptionTitle = String(format: "%.0f",  maxPipSize)
                } else {
                    descriptionTitle = item.optionDescription
                }
                break
            default:
                descriptionTitle = item.optionDescription
                break
            }

            optionDescriptionLabel.text = descriptionTitle
            break
        }
        
        
    }

}

