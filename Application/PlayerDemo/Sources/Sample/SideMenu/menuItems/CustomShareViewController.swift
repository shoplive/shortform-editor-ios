//
//  CustomShareViewController.swift
//  ShopLiveSwiftSample
//
//  Created by ShopLive on 2022/02/17.
//

import UIKit

class CustomShareViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(tapBackground))

        view.addGestureRecognizer(tap)
        
    }
    
    @objc func tapBackground() {
        self.dismiss(animated: false, completion: nil)
    }
    
    private lazy var snsButtons: UIStackView = {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .horizontal
        view.distribution = .fillEqually
        view.alignment = .fill
        view.spacing = 8
        return view
    }()
    
    private lazy var snsIconButton_kakaotalk: UIButton = {
        let view = UIButton()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        view.setImage(PlayerDemoAsset.snsIcon1.image, for: .normal)
        view.imageView?.contentMode = .scaleAspectFit
        return view
    }()
    
    private lazy var snsIconButton_facebook: UIButton = {
        let view = UIButton()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setImage(PlayerDemoAsset.snsIcon2.image, for: .normal)
        view.imageView?.contentMode = .scaleAspectFit
        return view
    }()
    
    private lazy var snsIconButton_instagram: UIButton = {
        let view = UIButton()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setImage(PlayerDemoAsset.snsIcon3.image, for: .normal)
        view.imageView?.contentMode = .scaleAspectFit
        return view
    }()
    
    private lazy var snsIconButton_twitter: UIButton = {
        let view = UIButton()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setImage(PlayerDemoAsset.snsIcon4.image, for: .normal)
        view.imageView?.contentMode = .scaleAspectFit
        return view
    }()
    
    func setupViews() {
        
        let bgView = UIView()
        bgView.backgroundColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.4)
        snsButtons.addArrangedSubview(snsIconButton_kakaotalk)
        snsButtons.addArrangedSubview(snsIconButton_facebook)
        snsButtons.addArrangedSubview(snsIconButton_instagram)
        snsButtons.addArrangedSubview(snsIconButton_twitter)
        
        self.view.backgroundColor = .clear
        
        self.view.addSubviews(bgView, snsButtons)
        
        NSLayoutConstraint.activate([
            bgView.topAnchor.constraint(equalTo: self.view.topAnchor),
            bgView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            bgView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            bgView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            
            snsButtons.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
            snsButtons.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            snsButtons.leadingAnchor.constraint(greaterThanOrEqualTo: self.view.leadingAnchor, constant: 20),
            snsButtons.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20),
            snsButtons.heightAnchor.constraint(equalToConstant: 50),
            
            snsIconButton_twitter.widthAnchor.constraint(equalToConstant: 50),
            snsIconButton_twitter.heightAnchor.constraint(equalToConstant: 50),
            
            snsIconButton_kakaotalk.widthAnchor.constraint(equalToConstant: 50),
            snsIconButton_kakaotalk.heightAnchor.constraint(equalToConstant: 50),
            
            snsIconButton_instagram.widthAnchor.constraint(equalToConstant: 50),
            snsIconButton_instagram.heightAnchor.constraint(equalToConstant: 50),
            
            snsIconButton_facebook.widthAnchor.constraint(equalToConstant: 50),
            snsIconButton_facebook.heightAnchor.constraint(equalToConstant: 50),
            
            
            
        ])
        
//        bgView.snp.makeConstraints {
//            $0.edges.equalToSuperview()
//        }
//        
//        snsButtons.snp.makeConstraints {
//            $0.center.equalToSuperview()
//            $0.leading.greaterThanOrEqualToSuperview().offset(20)
//            $0.trailing.lessThanOrEqualToSuperview().offset(-20)
//            $0.height.equalTo(50)
//        }
//        
//        snsIconButton_twitter.snp.makeConstraints {
//            $0.width.height.equalTo(50)
//        }
//        
//        snsIconButton_kakaotalk.snp.makeConstraints {
//            $0.width.height.equalTo(50)
//        }
//        
//        snsIconButton_instagram.snp.makeConstraints {
//            $0.width.height.equalTo(50)
//        }
//        
//        snsIconButton_facebook.snp.makeConstraints {
//            $0.width.height.equalTo(50)
//        }
    }
    

}
