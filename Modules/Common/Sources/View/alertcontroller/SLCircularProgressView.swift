//
//  CircularProgressView.swift
//  matrix-shortform-ios
//
//  Created by 김우현 on 5/1/23.
//

import UIKit

class SLCircularProgressView: UIView {

    private let progressLayer = CAShapeLayer()
    private let trackLayer = CAShapeLayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCircularPath()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupCircularPath()
    }

    var progressColor: UIColor = .white {
        didSet {
            progressLayer.strokeColor = progressColor.cgColor
        }
    }

    var trackColor: UIColor = .white {
        didSet {
            trackLayer.strokeColor = trackColor.cgColor
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        updateCircularPath()
    }

    private func setupCircularPath() {
        backgroundColor = .clear
        layer.cornerRadius = bounds.width / 2

        trackLayer.fillColor = UIColor.clear.cgColor
        trackLayer.lineWidth = 2.0
        trackLayer.strokeEnd = 1.0
        layer.addSublayer(trackLayer)

        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.lineWidth = 2.0
        progressLayer.strokeEnd = 0.0
        layer.addSublayer(progressLayer)
    }

    private func updateCircularPath() {
        let circlePath = UIBezierPath(
            arcCenter: CGPoint(x: bounds.width / 2, y: bounds.height / 2),
            radius: (bounds.width - 1.5) / 2,
            startAngle: CGFloat(-0.5 * .pi),
            endAngle: CGFloat(1.5 * .pi),
            clockwise: true
        )

        trackLayer.path = circlePath.cgPath
        trackLayer.strokeColor = trackColor.cgColor

        progressLayer.path = circlePath.cgPath
        progressLayer.strokeColor = progressColor.cgColor
    }

    func setProgress(_ value: CGFloat) {
        progressLayer.strokeEnd = value
    }

}

