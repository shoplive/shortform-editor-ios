//
//  CampaignInfoCell.swift
//  ShopLiveDemo
//
//  Created by ShopLive on 2021/12/14.
//

import UIKit

protocol CampaignInfoCellDelegate: AnyObject{
    func keysetFieldSelected()
    func updateKeySet(_ keyset: ShopLiveKeySet)
}

final class CampaignInfoCell: SampleBaseCell {

    weak var delegate: CampaignInfoCellDelegate?
    
    private lazy var guideTitleInputField: UITextField = {
        let view = UITextField()
        view.delegate = self
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isUserInteractionEnabled = true
        view.placeholder = "base.section.campaignInfo.campaign.none.title".localized()
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.lightGray.cgColor
        view.layer.cornerRadius = 6
        view.textColor = .black
        view.leftViewMode = .always
        let paddingView = UIView(frame: .init(origin: .zero, size: .init(width: 10, height: view.frame.height)))
        view.leftView = paddingView
        view.setPlaceholderColor(.darkGray)
        return view
    }()

    private lazy var chooseButton: UIButton = {
        let view = UIButton()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .red
        view.layer.cornerRadius = 6
        view.contentEdgeInsets = .init(top: 7, left: 9, bottom: 7, right: 9)
        view.titleLabel?.font = .systemFont(ofSize: 15, weight: .medium)
        view.addTarget(self, action: #selector(didTouchButton), for: .touchUpInside)
        view.setTitle("base.section.campaignInof.button.chooseCampaign.title".localized(), for: .normal)
        return view
    }()

    private lazy var accessKeyInputField: UITextField = {
        let view = UITextField()
        view.delegate = self
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isUserInteractionEnabled = true
        view.placeholder = "accessKey"
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.lightGray.cgColor
        view.layer.cornerRadius = 6
        view.textColor = .black
        view.leftViewMode = .always
        let paddingView = UIView(frame: .init(origin: .zero, size: .init(width: 10, height: view.frame.height)))
        view.leftView = paddingView
        view.setPlaceholderColor(.darkGray)
        return view
    }()

    lazy var campaignKeyInputField: UITextField = {
        let view = UITextField()
        view.delegate = self
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isUserInteractionEnabled = true
        view.placeholder = "campaignKey"
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.lightGray.cgColor
        view.layer.cornerRadius = 6
        view.textColor = .black
        view.leftViewMode = .always
        let paddingView = UIView(frame: .init(origin: .zero, size: .init(width: 10, height: view.frame.height)))
        view.leftView = paddingView
        view.setPlaceholderColor(.darkGray)
        return view
    }()

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        currentKeyUpdated()
        ShopLiveDemoKeyTools.shared.addKeysetObserver(observer: self)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
    }

    override func setupViews() {
        super.setupViews()
        self.itemView.addSubview(guideTitleInputField)
        self.itemView.addSubview(chooseButton)
        self.itemView.addSubview(accessKeyInputField)
        self.itemView.addSubview(campaignKeyInputField)
        guideTitleInputField.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(15)
            $0.top.equalToSuperview().offset(15)
            $0.trailing.equalTo(chooseButton.snp.leading).offset(-15)
            $0.height.equalTo(30)
        }

        chooseButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-15)
            $0.top.equalToSuperview().offset(5)
            $0.height.equalTo(35)
            $0.width.equalTo(80)
        }

        accessKeyInputField.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(15)
            $0.trailing.equalToSuperview().offset(-15)
            $0.top.equalTo(guideTitleInputField.snp.bottom).offset(10)
            $0.height.equalTo(30)
        }

        campaignKeyInputField.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(15)
            $0.trailing.equalToSuperview().offset(-15)
            $0.top.equalTo(accessKeyInputField.snp.bottom).offset(10)
            $0.bottom.equalToSuperview()
            $0.height.equalTo(30)
        }

        self.setSectionTitle(title: "base.section.campaignInfo.title".localized())
    }

    @objc private func didTouchButton() {
        let page = CampaignsViewController()
        page.selectKeySet = true
        self.parent?.navigationController?.pushViewController(page, animated: true)
    }
}

extension CampaignInfoCell: KeySetObserver {
    var identifier: String {
        return "CampaignInfoCell"
    }

    func keysetUpdated() {

    }

    func currentKeyUpdated() {
        if let currentKey = ShopLiveDemoKeyTools.shared.currentKey() {
            guideTitleInputField.text = currentKey.alias
            campaignKeyInputField.text = currentKey.campaignKey
            accessKeyInputField.text = currentKey.accessKey
        } else {
            guideTitleInputField.text = "base.section.campaignInfo.campaign.none.title".localized()
            campaignKeyInputField.text = "campaignKey"
            accessKeyInputField.text = "accessKey"
        }
        guideTitleInputField.sizeToFit()
        
        var alias = guideTitleInputField.text ?? "base.section.campaignInfo.campaign.none.title".localized()
        var campaignKey = campaignKeyInputField.text ?? "campaignKey"
        var accessKey = accessKeyInputField.text ?? "accessKey"
        
        let keyset = ShopLiveKeySet(alias: alias.trimmingCharacters(in: .whitespacesAndNewlines),
                                    campaignKey: campaignKey.trimmingCharacters(in: .whitespacesAndNewlines),
                                    accessKey: accessKey.trimmingCharacters(in: .whitespacesAndNewlines))
        
        delegate?.updateKeySet(keyset)
    }
}

extension CampaignInfoCell: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        delegate?.keysetFieldSelected()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

        let newText = string.trimmingCharacters(in: .whitespacesAndNewlines)

        guard let text = textField.text, let predictRange = Range(range, in: text) else { return true }

        let predictedText = text.replacingCharacters(in: predictRange, with: newText)
        
        var alias = guideTitleInputField.text ?? "base.section.campaignInfo.campaign.none.title".localized()
        var campaignKey = campaignKeyInputField.text ?? "campaignKey"
        var accessKey = accessKeyInputField.text ?? "accessKey"
        
        switch textField {
        case campaignKeyInputField:
            campaignKey = predictedText
            break
        case accessKeyInputField:
            accessKey = predictedText
            break
        case guideTitleInputField:
            alias = predictedText
            break
        default:
            break
        }
        
        let keyset = ShopLiveKeySet(alias: alias.trimmingCharacters(in: .whitespacesAndNewlines),
                                    campaignKey: campaignKey.trimmingCharacters(in: .whitespacesAndNewlines),
                                    accessKey: accessKey.trimmingCharacters(in: .whitespacesAndNewlines))

        self.delegate?.updateKeySet(keyset)
        return true
    }
}
