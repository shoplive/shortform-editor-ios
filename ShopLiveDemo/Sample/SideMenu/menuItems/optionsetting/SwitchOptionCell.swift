//
//  SwitchOptionCell.swift
//  ShopLiveDemo
//
//  Created by ShopLive on 2021/12/16.
//

import UIKit

protocol SwitchOptionCellDelegate: AnyObject {
    func didChangeSwitch(isOn: Bool, item: SDKOptionItem?)
}

class SwitchOptionCell: UITableViewCell {

    var item: SDKOptionItem?
    weak var delegate: SwitchOptionCellDelegate?

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

    lazy var touchArea: UIButton = {
        let view = UIButton()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        view.addTarget(self, action: #selector(didTapSwitch), for: .touchUpInside)
        return view
    }()

    private lazy var optionSwitch: UISwitch = {
        let view = UISwitch()
        view.translatesAutoresizingMaskIntoConstraints = false
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
        self.contentView.addSubview(optionTitleLabel)
        self.contentView.addSubview(optionDescriptionLabel)
        self.contentView.addSubview(optionSwitch)
        self.contentView.addSubview(touchArea)

        touchArea.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        optionSwitch.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-20)
            $0.width.equalTo(50)
            $0.centerY.equalToSuperview()
        }
        
        optionTitleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(20)
            $0.leading.equalToSuperview().offset(15)
            $0.trailing.equalTo(optionSwitch.snp.leading).offset(-10)
            $0.height.greaterThanOrEqualTo(20)
        }
        
        optionDescriptionLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(15)
            $0.trailing.equalTo(optionSwitch.snp.leading).offset(-10)
            $0.top.equalTo(optionTitleLabel.snp.bottom).offset(4)
            $0.bottom.equalToSuperview().offset(-20)
        }

    }

    func configure(item: SDKOptionItem) {
        self.item = item
        optionTitleLabel.text = item.name
        optionDescriptionLabel.text = item.optionDescription
        loadConfiguration()
    }

    @objc func didTapSwitch() {
        optionSwitch.isOn = !optionSwitch.isOn

        updateConfiguration()
    }

    private func loadConfiguration() {
        var useOption = false
        guard let item = self.item else { return }

        switch item.optionType {
        case .headphoneOption1:
            useOption = DemoConfiguration.shared.useHeadPhoneOption1
            break
        case .callOption:
            useOption = DemoConfiguration.shared.useCallOption
            break
        case .customShare:
            useOption = DemoConfiguration.shared.useCustomShare
            break
        case .customProgress:
            useOption = DemoConfiguration.shared.useCustomProgress
            break
        case .chatInputCustomFont:
            useOption = DemoConfiguration.shared.useChatInputCustomFont
            break
        case .chatSendButtonCustomFont:
            useOption = DemoConfiguration.shared.useChatSendButtonCustomFont
            break
        case .playWhenPreviewTapped:
            useOption = DemoConfiguration.shared.usePlayWhenPreviewTapped
            break
        case .mute:
            useOption = DemoConfiguration.shared.isMuted
            break
        default:
            break
        }
        optionSwitch.isOn = useOption
    }

    private func updateConfiguration() {
        guard let item = self.item else { return }

        let useOption  = optionSwitch.isOn
        switch item.optionType {
        case .headphoneOption1:
            DemoConfiguration.shared.useHeadPhoneOption1 = useOption
            break
        case .callOption:
            DemoConfiguration.shared.useCallOption = useOption
            break
        case .customShare:
            DemoConfiguration.shared.useCustomShare = useOption
            break
        case .customProgress:
            DemoConfiguration.shared.useCustomProgress = useOption
            break
        case .chatInputCustomFont:
            DemoConfiguration.shared.useChatInputCustomFont = useOption
            break
        case .chatSendButtonCustomFont:
            DemoConfiguration.shared.useChatSendButtonCustomFont = useOption
            break
        case .playWhenPreviewTapped:
            DemoConfiguration.shared.usePlayWhenPreviewTapped = useOption
            break
        case .mute:
            DemoConfiguration.shared.isMuted = useOption
            break
        default:
            break
        }
    }

    func saveOption() {

    }
}
