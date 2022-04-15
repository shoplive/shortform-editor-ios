//
//  OptionSectionHeader.swift
//  ShopLiveDemo
//
//  Created by ShopLive on 2021/12/16.
//

import UIKit

class OptionSectionHeader: UITableViewHeaderFooterView {

    private lazy var sectionTitleLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.numberOfLines = 0
        view.textColor = .black
        view.font = .systemFont(ofSize: 17, weight: .bold)
        return view
    }()

    private lazy var topLine: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .lightGray
        view.isHidden = true
        return view
    }()

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        setupViews()

    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        self.contentView.addSubview(sectionTitleLabel)
        self.contentView.addSubview(topLine)
        self.contentView.backgroundColor = .white
        sectionTitleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(15)
            $0.top.equalToSuperview().offset(25)
            $0.bottom.equalToSuperview()
            $0.trailing.lessThanOrEqualToSuperview().offset(-15)
        }

        topLine.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(1)
        }
    }

    func configure(headerTitle: String, section: Int) {
        self.sectionTitleLabel.text = headerTitle
        self.topLine.isHidden = (section == 0)
    }

}
