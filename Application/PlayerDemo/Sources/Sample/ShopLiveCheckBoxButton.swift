//
//  ShopLiveCheckBoxButton.swift
//  ShopLiveDemo
//
//  Created by ShopLive on 2021/12/16.
//

import UIKit

protocol ShopLiveCheckBoxButtonDelegate: AnyObject {
    func didChecked(_ sender: ShopLiveCheckBoxButton)
}

final class ShopLiveCheckBoxButton: UIView {

    weak var delegate: ShopLiveCheckBoxButtonDelegate?

    var identifier: String = ""

    var isChecked: Bool {
        return checkButton.isSelected
    }

    lazy var checkButton: UIButton = {
        let view = UIButton(type: .custom)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setImage(PlayerDemoAsset.checkNotSelected.image, for: .normal)
        view.setImage(PlayerDemoAsset.checkSelected.image, for: .selected)
        return view
    }()

    lazy var descriptionLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.numberOfLines = 1
        view.lineBreakMode = .byTruncatingTail
        view.textColor = .black
        return view
    }()

    lazy var touchArea: UIButton = {
        let view = UIButton()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        view.addTarget(self, action: #selector(didTouchCheckbox), for: .touchUpInside)
        return view
    }()

    var isSelected: Bool {
        set {
            checkButton.isSelected = newValue
        }
        get {
            return checkButton.isSelected
        }
    }

    init() {
        super.init(frame: .zero)
        setupViews()
    }
    override init(frame: CGRect) {
        super.init(frame: .zero)
        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(descriptionLabel)
        self.addSubview(checkButton)
        self.addSubview(touchArea)
        
        NSLayoutConstraint.activate([
            checkButton.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            checkButton.topAnchor.constraint(equalTo: self.topAnchor),
            checkButton.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            checkButton.heightAnchor.constraint(equalToConstant: 20),
            
            descriptionLabel.topAnchor.constraint(equalTo: self.topAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            descriptionLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            descriptionLabel.leadingAnchor.constraint(equalTo: checkButton.trailingAnchor, constant: 5),
            
            touchArea.topAnchor.constraint(equalTo: self.topAnchor),
            touchArea.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            touchArea.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            touchArea.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])

//        checkButton.snp.makeConstraints {
//            $0.leading.top.bottom.equalToSuperview()
//            $0.height.equalTo(20)
//        }
//
//        descriptionLabel.snp.makeConstraints {
//            $0.top.bottom.trailing.equalToSuperview()
//            $0.leading.equalTo(checkButton.snp.trailing).offset(5)
//        }
//
//        touchArea.snp.makeConstraints {
//            $0.edges.equalToSuperview()
//        }
    }

    func configure(identifier: String, description: String) {
        self.identifier = identifier
        self.descriptionLabel.text = description
    }

    @objc func didTouchCheckbox() {
        checkButton.isSelected = !checkButton.isSelected
        delegate?.didChecked(self)
    }
}
