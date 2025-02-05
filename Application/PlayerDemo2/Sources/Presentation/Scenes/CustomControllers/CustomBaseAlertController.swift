//
//  CustomBaseAlertController.swift
//  PlayerDemo2
//
//  Created by Tabber on 1/20/25.
//  Copyright © 2025 com.app. All rights reserved.
//

import UIKit

class CustomBaseAlertController: UIViewController {

    lazy var alertItemView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        view.layer.cornerRadius = 6
        return view
    }()

    private let dimView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .black
        view.alpha = 0.5
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .clear
        setupViews()
        dimView.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(handleTapGesture)))
    }
 
    @objc private func handleTapGesture() {
        self.dismiss(animated: false, completion: nil)
    }

    func setupViews() {
        self.view.addSubview(dimView)
        
        NSLayoutConstraint.activate([
            dimView.topAnchor.constraint(equalTo: self.view.topAnchor),
            dimView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            dimView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            dimView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])
//        dimView.snp.makeConstraints {
//            $0.edges.equalToSuperview()
//        }
    }

}
