//
//  SideMenuCell.swift
//  SwiftSample
//
//  Created by ShopLive on 2021/12/10.
//

import UIKit

final class SideMenuCell: UITableViewCell {

    var item: SideMenu?

    private let menuItemLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.numberOfLines = 1
        view.lineBreakMode = .byTruncatingTail
        view.textColor = .black
        view.font = .systemFont(ofSize: 13, weight: .medium)
        view.textAlignment = .left
        return view
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
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
        self.contentView.addSubview(menuItemLabel)
        NSLayoutConstraint.activate([
            menuItemLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 15),
            menuItemLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor,constant: 15),
            menuItemLabel.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -15),
            menuItemLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -15)
        ])
//        menuItemLabel.snp.makeConstraints {
//            $0.top.leading.equalToSuperview().offset(15)
//            $0.bottom.trailing.lessThanOrEqualToSuperview().offset(-15)
//        }
    }

    func configure(item: SideMenu) {
        self.item = item
        self.menuItemLabel.text = item.stringKey.localized()
    }

}
