//
//  GuideTitleButton.swift
//  ShopLiveDemo
//
//  Created by ShopLive on 2021/12/14.
//

import UIKit

protocol GuideTitleButtonDelegate: AnyObject {
    func didTouchGuideTitleButton(_ sender: GuideTitleButton)
}

class GuideTitleButton: UIView {

    weak var delegate: GuideTitleButtonDelegate?

    lazy var campaignTitleLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.numberOfLines = 0
        view.font = .systemFont(ofSize: 16, weight: .medium)
        view.textColor = .black
        return view
    }()

    lazy var chooseButton: UIButton = {
        let view = UIButton()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .red
        view.layer.cornerRadius = 6
        view.contentEdgeInsets = .init(top: 7, left: 9, bottom: 7, right: 9)
        view.titleLabel?.font = .systemFont(ofSize: 15, weight: .medium)
        view.addTarget(self, action: #selector(didTouchButton), for: .touchUpInside)
        return view
    }()

    var defaultGuide: String = ""

    init(guide: String, buttonTitle: String) {
        super.init(frame: .zero)
        defaultGuide = guide
        campaignTitleLabel.text = guide
        chooseButton.setTitle(buttonTitle, for: .normal)
        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func clearGuide() {
        self.campaignTitleLabel.text = defaultGuide
    }

    func updateGuide(guide: String?) {
        guard let guideTitle = guide, !guideTitle.isEmpty else {
            return
        }
        self.campaignTitleLabel.text = guideTitle
    }

    func updateButtonTitle(_ title: String) {
        chooseButton.setTitle(title, for: .normal)
    }

    func setupViews() {
        self.backgroundColor = .white
        self.addSubview(campaignTitleLabel)
        self.addSubview(chooseButton)
        campaignTitleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(10)
            $0.bottom.lessThanOrEqualToSuperview().offset(-10)
            $0.leading.equalToSuperview().offset(15)
            $0.trailing.lessThanOrEqualTo(chooseButton.snp.leading).offset(-10)
            $0.height.greaterThanOrEqualTo(30)
        }

        chooseButton.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.trailing.equalToSuperview().offset(-15)
            $0.width.greaterThanOrEqualTo(90)
            $0.height.greaterThanOrEqualTo(35)
        }
    }

    @objc private func didTouchButton() {
        delegate?.didTouchGuideTitleButton(self)
    }
}

