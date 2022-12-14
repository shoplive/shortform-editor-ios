//
//  SampleBaseCell.swift
//  ShopLiveDemo
//
//  Created by ShopLive on 2021/12/14.
//

import UIKit

protocol SampleBaseCellDelegate: AnyObject {
    func updateDatas()
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
        
        self.sectionTitleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(15)
            $0.leading.equalToSuperview().offset(15)
            $0.height.equalTo(22)
        }

        self.titleMenuView.snp.makeConstraints {
            $0.trailing.lessThanOrEqualToSuperview().offset(-15)
            $0.leading.equalTo(self.sectionTitleLabel.snp.trailing).offset(15)
            $0.centerY.equalTo(self.sectionTitleLabel)
            $0.height.equalTo(30)
        }

        self.itemView.snp.makeConstraints {
            $0.top.equalTo(self.titleMenuView.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }

    }

    func setSectionTitle(title: String) {
        sectionTitleLabel.text = "[\(title)]"
    }

    func configure(parent: UIViewController) {
        self.parent = parent
    }

}
