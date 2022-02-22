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
        view.setImage(UIImage(named: "sns_icon_1"), for: .normal)
        return view
    }()
    
    private lazy var snsIconButton_facebook: UIButton = {
        let view = UIButton()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setImage(UIImage(named: "sns_icon_2"), for: .normal)
        return view
    }()
    
    private lazy var snsIconButton_instagram: UIButton = {
        let view = UIButton()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setImage(UIImage(named: "sns_icon_3"), for: .normal)
        return view
    }()
    
    private lazy var snsIconButton_twitter: UIButton = {
        let view = UIButton()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setImage(UIImage(named: "sns_icon_4"), for: .normal)
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
        
        bgView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        snsButtons.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.leading.greaterThanOrEqualToSuperview().offset(20)
            $0.trailing.lessThanOrEqualToSuperview().offset(-20)
            $0.height.equalTo(50)
        }
        
        snsIconButton_twitter.snp.makeConstraints {
            $0.width.height.equalTo(50)
        }
        
        snsIconButton_kakaotalk.snp.makeConstraints {
            $0.width.height.equalTo(50)
        }
        
        snsIconButton_instagram.snp.makeConstraints {
            $0.width.height.equalTo(50)
        }
        
        snsIconButton_facebook.snp.makeConstraints {
            $0.width.height.equalTo(50)
        }
    }
    

}
