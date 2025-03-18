//
//  SLFFmpegTestCreateYTVersionViewController.swift
//  ShopLiveShortformEditorSDK
//
//  Created by sangmin han on 1/29/24.
//

import Foundation
import UIKit
import ShopliveSDKCommon




class SLFFmpegTestCreateYTVersionViewController : UIViewController {
    
    private var topBar : UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        
        return view
    }()
    
    private var confirmBtn : SLButton = {
        let btn = SLButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setTitle("완료", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.setFont(font: .init(size: 15, weight: .regular))
        return btn
    }()
    
    private var textView : UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.backgroundColor = .clear
        textView.textContainer.lineFragmentPadding = .zero
        textView.textContainerInset = .zero
        textView.textColor = .white
        textView.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        textView.isScrollEnabled = false
        textView.backgroundColor = .clear
        textView.textAlignment = .center
        return textView
    }()
    
    private lazy var textViewCentYAnc : NSLayoutConstraint = {
        return textView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor)
    }()
    
    private var fontSizeSlider : SLFFmpegTextSizeVerticalSlider = {
        let view = SLFFmpegTextSizeVerticalSlider()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var colorCv : UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.backgroundColor = .clear
        reactor.action( .registerCv(cv) )
        return cv
    }()
    
    private lazy var colorCvBottomAnc : NSLayoutConstraint = {
        return colorCv.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -10)
    }()
    
    private let reactor = SLFFmpegTextViewYTVersionReactor()

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .init(white: 0, alpha: 0.5)
        setLayout()
        
        bindReactor()
        
        confirmBtn.addTarget(self, action: #selector(confirmBtnTapped(sender: )), for: .touchUpInside)
    }
    
    
    override func  viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        textView.becomeFirstResponder()
    }
    
    @objc func confirmBtnTapped(sender : UIButton) {
        if let nav = self.navigationController {
            nav.popViewController(animated: true)
        }
        else {
            self.dismiss(animated: true)
        }
    }
    
}
extension SLFFmpegTestCreateYTVersionViewController {
    
    
    
    private func bindReactor() {
        
        reactor.resultHandler = { [weak self] result in
            guard let self = self else { return }
            
        }
        
        reactor.onMainQueueResultHandler = { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .handleKeyBoard(let keyBoardRect):
                    self.handleKeyBoard(keyBoardRect: keyBoardRect)
                }
            }
        }
        
    }
    
    private func handleKeyBoard(keyBoardRect : CGRect) {
        UIView.animate(withDuration: 0.3) {
            self.colorCvBottomAnc.constant = -keyBoardRect.height
            self.textViewCentYAnc.constant = -(keyBoardRect.height / 2)
            self.view.layoutIfNeeded()
        }
    }
    
}
extension SLFFmpegTestCreateYTVersionViewController {
    private func setLayout() {
        self.view.addSubview(topBar)
        self.view.addSubview(confirmBtn)
        self.view.addSubview(textView)
        self.view.addSubview(fontSizeSlider)
        self.view.addSubview(colorCv)
        
        
        NSLayoutConstraint.activate([
            topBar.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            topBar.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            topBar.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            topBar.heightAnchor.constraint(equalToConstant: 60),
            
            
            confirmBtn.centerYAnchor.constraint(equalTo: topBar.centerYAnchor),
            confirmBtn.trailingAnchor.constraint(equalTo: topBar.trailingAnchor,constant: -20),
            confirmBtn.widthAnchor.constraint(equalToConstant: 40),
            confirmBtn.heightAnchor.constraint(equalToConstant: 40),
            
            textViewCentYAnc,
            textView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            textView.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 1),
            textView.heightAnchor.constraint(lessThanOrEqualToConstant: 300),
            
            fontSizeSlider.topAnchor.constraint(equalTo: topBar.bottomAnchor),
            fontSizeSlider.trailingAnchor.constraint(equalTo: self.view.trailingAnchor,constant: -10),
            fontSizeSlider.widthAnchor.constraint(equalToConstant: 20),
            fontSizeSlider.bottomAnchor.constraint(equalTo: colorCv.topAnchor,constant: -10),
            
            colorCvBottomAnc,
            colorCv.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            colorCv.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            colorCv.heightAnchor.constraint(equalToConstant: 60),
        ])
    }
}
