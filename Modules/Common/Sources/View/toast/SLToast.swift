//
//  SLToast.swift
//  matrix-shortform-ios
//
//  Created by 김우현 on 5/2/23.
//

import Foundation
import UIKit

public enum SLToastDuration {
    case short
    case middle
    case long
    
    var duration: TimeInterval {
        switch self {
        case .long:
            return 1.0
        case .middle:
            return 0.5
        case .short:
            return 0.3
        }
    }
}

class SLToastView: UIView {
    
    private var toastMessage: String = ""
    private var toastDuration: SLToastDuration = .middle
    
    private lazy var toastLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.textColor = .white
        view.numberOfLines = 0
        return view
    }()
    
    init(message: String, duration: SLToastDuration = .middle) {
        super.init(frame: .zero)
        self.toastMessage = message
        self.toastDuration = duration
        
        layout()
        setupToast()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func layout() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = .clear
        let bgcolor = UIView()
        bgcolor.translatesAutoresizingMaskIntoConstraints = false
        bgcolor.backgroundColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.8)
        bgcolor.cornerRadiusV_SL = 10
        bgcolor.clipsToBounds = false
        //UIColor(red: 151/255, green: 151/255, blue: 151/255, alpha: 0.5)
        self.addSubview(bgcolor)
        bgcolor.fit_SL()
        
        self.addSubview(toastLabel)
        
        let toastLabelConstraint = [
            toastLabel.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 10),
            toastLabel.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -10),
            toastLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 8),
            toastLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -8),
        ]
        
        NSLayoutConstraint.activate(toastLabelConstraint)
        
        bgcolor.isUserInteractionEnabled = false
        toastLabel.isUserInteractionEnabled = false
        self.isUserInteractionEnabled = false
        self.alpha = 0
        self.cornerRadiusV_SL = 10
        self.clipsToBounds = false
    }
    
    private func setupToast() {
        self.toastLabel.text = self.toastMessage
    }
    
    func showToast() {
        UIView.animate(withDuration: 0.2) { [weak self] in
            self?.alpha = 1.0
        } completion: { [weak self] isFinished in
            self?.hideToast()
        }
    }
    
    private func hideToast() {
        DispatchQueue.main.asyncAfter(deadline: .now() + toastDuration.duration) {
            UIView.animate(withDuration: 0.2) { [weak self] in
                self?.alpha = 0.0
            } completion: { [weak self] isFinished in
                self?.removeFromSuperview()
            }
        }
    }
    
}

class SLToast: UIViewController {
    
    private lazy var toastView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        let bgcolor = UIView()
        bgcolor.translatesAutoresizingMaskIntoConstraints = false
        bgcolor.backgroundColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.8)
        bgcolor.cornerRadiusV_SL = 10
        bgcolor.clipsToBounds = false
        view.addSubview(bgcolor)
        bgcolor.fit_SL()
        
        view.addSubview(toastLabel)
        
        let toastLabelConstraint = [
            toastLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
            toastLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20),
            toastLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 8),
            toastLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -8),
        ]
        
        NSLayoutConstraint.activate(toastLabelConstraint)
        
        bgcolor.isUserInteractionEnabled = false
        toastLabel.isUserInteractionEnabled = false
        view.isUserInteractionEnabled = false
        view.alpha = 0
        view.cornerRadiusV_SL = 10
        view.clipsToBounds = false
        return view
    }()
    
    private lazy var toastLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.textColor = .white
        return view
    }()
    
    private var toastMessage: String = ""
    private var toastDuration: SLToastDuration = .middle
    
    init(message: String, duration: SLToastDuration = .middle) {
        super.init(nibName: nil, bundle: nil)
        self.toastMessage = message
        self.toastDuration = duration
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setToastMessage(message: String) {
        self.toastMessage = message
    }
    
    func setToastDuration(duration: SLToastDuration) {
        self.toastDuration = duration
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addSubview(toastView)
        
        let toastViewConstraint = [
            toastView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor, constant: 0),
            toastView.leftAnchor.constraint(greaterThanOrEqualTo: self.view.leftAnchor),
            toastView.rightAnchor.constraint(lessThanOrEqualTo: self.view.rightAnchor),
            toastView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
        ]
        
        NSLayoutConstraint.activate(toastViewConstraint)
        
        self.view.isUserInteractionEnabled = false
        self.view.cornerRadiusV_SL = 10
        self.view.clipsToBounds = false
        setupToast()
        showToast()
    }
 
    private func setupToast() {
        self.toastLabel.text = self.toastMessage
    }
    
    private func showToast() {
        UIView.animate(withDuration: 0.2) { [weak self] in
            self?.toastView.alpha = 1.0
        } completion: { [weak self] isFinished in
            self?.hideToast()
        }
    }
    
    private func hideToast() {
        DispatchQueue.main.asyncAfter(deadline: .now() + toastDuration.duration) {
            UIView.animate(withDuration: 0.2) { [weak self] in
                self?.toastView.alpha = 0.0
            } completion: { [weak self] isFinished in
                self?.dismiss(animated: false)
            }
        }
    }
    
}

extension UIViewController {
    public func showToastAlert(messgae: String) {
        let toast = SLToast(message: messgae)
        toast.modalPresentationStyle = .overFullScreen
        
        if let nav = self.navigationController {
            nav.present(toast, animated: false)
        } else {
            self.present(toast, animated: false)
        }
    }
    
    public func showToast(message: String, duration: SLToastDuration = .middle) {
        let toastView = SLToastView(message: message)
        self.view.addSubview(toastView)
        
        let toastViewConstraint = [
            toastView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor, constant: 0),
            toastView.leftAnchor.constraint(greaterThanOrEqualTo: self.view.leftAnchor, constant: 10),
            toastView.rightAnchor.constraint(lessThanOrEqualTo: self.view.rightAnchor, constant: -10),
            toastView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
        ]
        
        NSLayoutConstraint.activate(toastViewConstraint)
        self.view.bringSubviewToFront(toastView)
        
        toastView.showToast()
    }
}

extension UIWindow {
    
    public func showToast(message : String, duration : SLToastDuration = .middle){
        let toastView = SLToastView(message: message,duration: duration)
        self.addSubview(toastView)
        let toastViewConstraint = [
            toastView.centerXAnchor.constraint(equalTo: self.centerXAnchor, constant: 0),
            toastView.leftAnchor.constraint(greaterThanOrEqualTo: self.leftAnchor, constant: 10),
            toastView.rightAnchor.constraint(lessThanOrEqualTo: self.rightAnchor, constant: -10),
            toastView.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor, constant: -10),
        ]
        
        NSLayoutConstraint.activate(toastViewConstraint)
        self.bringSubviewToFront(toastView)
        
        toastView.showToast()
    }
    
}
