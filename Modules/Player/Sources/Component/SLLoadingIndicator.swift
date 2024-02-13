//
//  SLLoadingIndicator.swift
//  ShopLiveSDK
//
//  Created by ShopLive on 2021/10/29.
//

import UIKit

final class SLLoadingIndicator: SLView {
    private var loadingImages: [UIImage] = []

    var isAnimating: Bool {
        return indicatorImageView.isAnimating
    }

    private lazy var indicatorImageView: SLImageView = {
        let view = SLImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        view.isUserInteractionEnabled = false
        return view
    }()

    func startAnimating() {
        self.isHidden = false
        indicatorImageView.startAnimating()
    }

    func stopAnimating() {
        self.isHidden = true
        indicatorImageView.stopAnimating()
    }

    init() {
        super.init(frame: .zero)
        setupViews()
    }

    init(images: UIImage...) {
        super.init(frame: .zero)
        setupViews()
        configure(images: images)
    }

    init(images: [UIImage]) {
        super.init(frame: .zero)
        setupViews()
        configure(images: images)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = .clear
        self.isHidden = true
        self.isUserInteractionEnabled = false
        self.addSubviews(indicatorImageView)
        indicatorImageView.fitToSuperView()
    }

    func configure(images: [UIImage]) {
        guard images.count > 0 else { return }

        loadingImages.removeAll()
        loadingImages.append(contentsOf: images)
        reloadImages()
    }

    func configure(images: UIImage...) {
        loadingImages.removeAll()
        loadingImages.append(contentsOf: images)
        reloadImages()
    }

    func reloadImages() {
        indicatorImageView.animationImages = loadingImages
        indicatorImageView.animationDuration = 3
        indicatorImageView.animationRepeatCount = 0
    }
}

