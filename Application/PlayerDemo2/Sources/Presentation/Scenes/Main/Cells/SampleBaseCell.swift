//
//  SampleBaseCell.swift
//  PlayerDemo2
//
//  Created by Tabber on 1/17/25.
//  Copyright © 2025 com.app. All rights reserved.
//

import UIKit

protocol SampleBaseCellDelegate: AnyObject {
    func updateDatas()
    func showUserInfoView()
}

class SampleBaseCell: UITableViewCell {

    weak var baseDelegate: SampleBaseCellDelegate?
    var parent: UIViewController?

    let sectionTitleLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.numberOfLines = 1
        view.lineBreakMode = .byTruncatingTail
        view.font = .systemFont(ofSize: 18, weight: .bold)
        view.textColor = .black
        return view
    }()

    let titleMenuView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        return view
    }()

    let itemView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
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
        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupViews() {
        self.contentView.backgroundColor = .white
        self.contentView.addSubview(sectionTitleLabel)
        self.contentView.addSubview(titleMenuView)
        self.contentView.addSubview(itemView)
        
        NSLayoutConstraint.activate([
            sectionTitleLabel.topAnchor.constraint(equalTo: contentView.topAnchor,constant: 15),
            sectionTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            sectionTitleLabel.heightAnchor.constraint(equalToConstant: 22),
            
            titleMenuView.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -15),
            titleMenuView.leadingAnchor.constraint(equalTo: self.sectionTitleLabel.trailingAnchor, constant: 15),
            titleMenuView.centerYAnchor.constraint(equalTo: self.sectionTitleLabel.centerYAnchor),
            titleMenuView.heightAnchor.constraint(equalToConstant: 30),
            
            itemView.topAnchor.constraint(equalTo: titleMenuView.bottomAnchor),
            itemView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            itemView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            itemView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])

    }

    func setSectionTitle(title: String) {
        sectionTitleLabel.text = "[\(title)]"
    }

    func configure(parent: UIViewController) {
        self.parent = parent
    }

}
