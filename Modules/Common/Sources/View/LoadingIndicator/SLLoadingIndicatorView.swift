//
//  IndicatorView.swift
//  ShopliveCommon
//
//  Created by James Kim on 12/16/22.
//

import Foundation
import UIKit

struct SLIndicatingStatus {
    private var indicatingName = [String: Int]()
    
    var count: Int {
        indicatingName.reduce(0) { $0 + $1.value }
    }
    
    mutating func increase(key: String) {
        let oldCount = indicatingName[key] ?? 0
        indicatingName[key] = oldCount + 1
    }
    
    mutating func decrease(key: String) {
        let oldCount = indicatingName[key] ?? 0
        indicatingName[key] = max(oldCount - 1, 0)
    }
}

public final class SLLoadingIndicatorView: UIView {
    static let shared = SLLoadingIndicatorView()

    private var backgroundView: UIView!
    private let indicatorView = UIActivityIndicatorView(style: .whiteLarge)
    private var indicatingStatus = SLIndicatingStatus()

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setView()
    }

    init() {
        super.init(frame: UIScreen.main.bounds)
        setView()
    }

    private func setView() {
        self.backgroundColor = UIColor.clear
        
        backgroundView = UIView(frame: self.bounds)
        backgroundView.backgroundColor = UIColor.black
        backgroundView.alpha = 0.0
        self.addSubview(backgroundView)
        backgroundView.fitToParent_SL()
        
        addSubview(indicatorView)
        indicatorView.center = self.center
        indicatorView.startAnimating()
    }
    
    static var targetView: UIWindow? {
        return UIApplication.shared.windows.filter {$0.isKeyWindow}.first
    }
    
    public static func show(isDimmed: Bool = true, key: String = "general", delay: TimeInterval = 0) {
        DispatchQueue.main.async(flags: .barrier) {
            UIAccessibility.post(notification: .screenChanged, argument: shared.indicatorView)
            
            shared.indicatingStatus.increase(key: key)
            if shared.indicatingStatus.count == 1, let t = targetView, !t.contains(shared) {
                targetView?.addSubview(shared)
                UIView.animate(withDuration: 0.3, delay: delay, animations: {
                    if isDimmed {
                        shared.backgroundView.alpha = 0.5
                    } else {
                        shared.backgroundView.alpha = 0.0
                    }
                    shared.alpha = 1.0
                })
            }

            if targetView?.subviews.contains(shared) == true {
                targetView?.bringSubviewToFront(shared)
            }
        }
    }

    public static func hide(key: String = "general") {
        DispatchQueue.main.async {
            shared.indicatingStatus.decrease(key: key)
            if shared.indicatingStatus.count == 0 {
                UIView.animate(withDuration: 0.3, animations: {
                    guard shared.backgroundView.alpha != 0 else { return }
                    shared.alpha = 0.0
                    shared.backgroundView.alpha = 0.0
                    shared.layer.removeAllAnimations()
                }, completion: { _ in
                    shared.removeFromSuperview()
                })

//                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
        }
    }
}
