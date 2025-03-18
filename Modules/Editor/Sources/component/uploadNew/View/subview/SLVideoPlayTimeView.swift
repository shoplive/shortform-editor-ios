//
//  SLVideoPlayTimeView.swift
//  matrix-shortform-ios
//
//  Created by 김우현 on 4/23/23.
//

import UIKit
import ShopliveSDKCommon

class SLVideoPlayTimeView: UIView {

    private var totalTime: CGFloat = 0
    private var currentTime: CGFloat = 0
    
    private lazy var timeLabel: SLLabel = {
        let view = SLLabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.textAlignment = .right
        view.textColor = .white
        view.setFont(font: .init(size: 10, weight: .medium))
        view.numberOfLines = 1
        return view
    }()
    
    init() {
        super.init(frame: .zero)
        layout()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func layout() {
        self.addSubview(timeLabel)
        let timeLabelConstraint = [
            timeLabel.rightAnchor.constraint(equalTo: self.rightAnchor, constant: 0),
            timeLabel.heightAnchor.constraint(equalToConstant: 14),
            timeLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ]
        
        NSLayoutConstraint.activate(timeLabelConstraint)
        
        updateLabel()
    }
    
    private func updateLabel() {
        self.timeLabel.text = "\(secondsToMinutesSeconds(Int(self.currentTime))) / \(secondsToMinutesSeconds(Int(self.totalTime)))"
    }
    
    private func secondsToMinutesSeconds(_ seconds: Int) -> String {
        let minutes = String(format: "%02d", (seconds % 3600) / 60)
        let seconds = String(format: "%02d", (seconds % 3600) % 60)
        
        return "\(minutes):\(seconds)"
    }
    
    func setTotalTime(_ time: CGFloat) {
        
        guard !time.isInfinite else { return }
        self.totalTime = time
        
        guard !self.totalTime.isInfinite && !self.currentTime.isInfinite else { return }
        
        updateLabel()
    }
    
    func setCurrentTime(_ time: CGFloat) {
        guard !time.isInfinite else {
            return
        }
        self.currentTime = time
        
        guard !self.totalTime.isInfinite && !self.currentTime.isInfinite else {
            return
        }
        
        updateLabel()
    }

}
