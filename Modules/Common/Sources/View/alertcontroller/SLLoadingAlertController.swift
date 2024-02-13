//
//  LoadingAlertController.swift
//  matrix-shortform-ios
//
//  Created by 김우현 on 5/1/23.
//

import UIKit

@objc public protocol SLLoadingAlertControllerDelegate: AnyObject {
    
    func didCancelLoading()
    func didFinishLoading()
}

public class SLLoadingAlertController: UIViewController, UIGestureRecognizerDelegate {

    public weak var delegate: SLLoadingAlertControllerDelegate?
    
    public var cancelLoading: Bool = false
    
    private lazy var loadingView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.6)
        view.cornerRadiusV_SL = 16
        return view
    }()
    
    private lazy var indicatorView: SLSLNVActivityIndicatorView = {
        let view = SLSLNVActivityIndicatorView(frame: .zero, type: .circleStrokeSpin)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var progressView: SLCircularProgressView = {
        let view = SLCircularProgressView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.trackColor = .clear
        view.progressColor = .white
        view.isHidden = true
        return view
    }()
    
    private lazy var indicatorLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.textColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
        view.font = .systemFont(ofSize: 15, weight: .semibold)
        view.textColor = .white
        view.textAlignment = .center
        return view
    }()
    
    public func setLoadingText(_ text: String) {
        indicatorLabel.text = text
    }
    
    public var useProgress: Bool = false
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    public func resetProgress() {
        progressView.setProgress(0)
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture))
        self.view.addGestureRecognizer(tapGesture)
        tapGesture.delegate = self
        tapGesture.isEnabled = true
        
        self.view.addSubview(loadingView)
        loadingView.addSubview(indicatorView)
        loadingView.addSubview(progressView)
        loadingView.addSubview(indicatorLabel)
        
        loadingView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        loadingView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
        loadingView.heightAnchor.constraint(equalToConstant: 92).isActive = true
        loadingView.widthAnchor.constraint(equalToConstant: 146).isActive = true
        
        NSLayoutConstraint.activate([
            progressView.centerXAnchor.constraint(equalTo: loadingView.centerXAnchor),
            progressView.topAnchor.constraint(equalTo: loadingView.topAnchor, constant: 20),
            progressView.widthAnchor.constraint(equalToConstant: 32),
            progressView.heightAnchor.constraint(equalToConstant: 32)
        ])
        
        indicatorView.centerXAnchor.constraint(equalTo: loadingView.centerXAnchor).isActive = true
        indicatorView.topAnchor.constraint(equalTo: loadingView.topAnchor, constant: 20).isActive = true
        indicatorView.heightAnchor.constraint(equalToConstant: 24).isActive = true
        indicatorView.widthAnchor.constraint(equalToConstant: 24).isActive = true
        
        indicatorLabel.leftAnchor.constraint(equalTo: loadingView.leftAnchor, constant: 10).isActive = true
        indicatorLabel.rightAnchor.constraint(equalTo: loadingView.rightAnchor, constant: -10).isActive = true
        indicatorLabel.topAnchor.constraint(equalTo: indicatorView.bottomAnchor, constant: 20).isActive = true
        indicatorLabel.heightAnchor.constraint(equalToConstant: 16).isActive = true
        
        indicatorView.isHidden = useProgress
        progressView.isHidden = !useProgress
        
        if !useProgress {
            indicatorView.startAnimating()
        } else {
            
            loadingView.bringSubviewToFront(progressView)
        }
    }
    
    public func setProgress(_ progress: CGFloat) {
        guard useProgress else { return }
        progressView.setProgress(progress)
    }
    
    public func finishLoading() {
        guard !cancelLoading else { return }
        self.dismiss(animated: false) {
            self.delegate?.didFinishLoading()
        }
    }
    
    public func finishLoadingWithOutDelegateEvent() {
        self.view.isHidden = true
        indicatorView.stopAnimating()
        self.dismiss(animated: true)
    }
    
    
    public func cancal() {
        cancelLoading = true
        self.dismiss(animated: false) {
            self.delegate?.didCancelLoading()
        }
    }
    
    @objc private func handleTapGesture(_ recognizer: UITapGestureRecognizer) {
        cancelLoading = true
        self.dismiss(animated: false) {
            self.delegate?.didCancelLoading()
        }
    }

}
