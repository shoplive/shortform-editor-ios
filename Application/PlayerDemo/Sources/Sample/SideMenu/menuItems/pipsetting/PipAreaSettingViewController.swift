//
//  PipAreaSettingViewController.swift
//  ShopLiveSDK
//
//  Created by ShopLive on 2022/03/22.
//

import UIKit

final class PipAreaSettingViewController: UIViewController {

    private lazy var resetButton: UIButton = {
        let view = UIButton()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setTitle("초기화", for: .normal)
        view.addTarget(self, action: #selector(resetPipArea), for: .touchUpInside)
        view.backgroundColor = .lightGray
        return view
    }()
    
    private lazy var paddingTitle: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.numberOfLines = 1
        view.font = .systemFont(ofSize: 15, weight: .bold)
        view.textColor = .black
        view.text = "Padding"
        return view
    }()
    
    private lazy var marginTitle: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.numberOfLines = 1
        view.font = .systemFont(ofSize: 15, weight: .bold)
        view.textColor = .black
        view.text = "FloatingOffset"
        return view
    }()
    
    private lazy var paddingTopInput: UITextField = {
        let view = UITextField()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.textColor = .black
        view.placeholder = "top"
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.lightGray.cgColor
        view.layer.cornerRadius = 6
        view.textColor = .black
        view.setPlaceholderColor(.darkGray)
        view.leftViewMode = .always
        let paddingView = UIView(frame: .init(origin: .zero, size: .init(width: 10, height: view.frame.height)))
        view.leftView = paddingView
        return view
    }()
    
    private lazy var paddingLeftInput: UITextField = {
        let view = UITextField()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.textColor = .black
        view.placeholder = "left"
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.lightGray.cgColor
        view.layer.cornerRadius = 6
        view.setPlaceholderColor(.darkGray)
        view.leftViewMode = .always
        let paddingView = UIView(frame: .init(origin: .zero, size: .init(width: 10, height: view.frame.height)))
        view.leftView = paddingView
        return view
    }()
    
    private lazy var paddingRightInput: UITextField = {
        let view = UITextField()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.textColor = .black
        view.placeholder = "right"
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.lightGray.cgColor
        view.layer.cornerRadius = 6
        view.setPlaceholderColor(.darkGray)
        view.leftViewMode = .always
        let paddingView = UIView(frame: .init(origin: .zero, size: .init(width: 10, height: view.frame.height)))
        view.leftView = paddingView
        return view
    }()
    
    private lazy var paddingBottomInput: UITextField = {
        let view = UITextField()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.textColor = .black
        view.placeholder = "bottom"
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.lightGray.cgColor
        view.layer.cornerRadius = 6
        view.setPlaceholderColor(.darkGray)
        view.leftViewMode = .always
        let paddingView = UIView(frame: .init(origin: .zero, size: .init(width: 10, height: view.frame.height)))
        view.leftView = paddingView
        return view
    }()
    
    private lazy var marginTopInput: UITextField = {
        let view = UITextField()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.textColor = .black
        view.placeholder = "top"
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.lightGray.cgColor
        view.layer.cornerRadius = 6
        view.setPlaceholderColor(.darkGray)
        view.leftViewMode = .always
        let paddingView = UIView(frame: .init(origin: .zero, size: .init(width: 10, height: view.frame.height)))
        view.leftView = paddingView
        return view
    }()
    
    private lazy var marginBottomInput: UITextField = {
        let view = UITextField()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.textColor = .black
        view.placeholder = "bottom"
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.lightGray.cgColor
        view.layer.cornerRadius = 6
        view.setPlaceholderColor(.darkGray)
        view.leftViewMode = .always
        let paddingView = UIView(frame: .init(origin: .zero, size: .init(width: 10, height: view.frame.height)))
        view.leftView = paddingView
        return view
    }()
    
    private lazy var marginLeftInput: UITextField = {
        let view = UITextField()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.textColor = .black
        view.placeholder = "left"
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.lightGray.cgColor
        view.layer.cornerRadius = 6
        view.setPlaceholderColor(.darkGray)
        view.leftViewMode = .always
        let paddingView = UIView(frame: .init(origin: .zero, size: .init(width: 10, height: view.frame.height)))
        view.leftView = paddingView
        return view
    }()
    
    private lazy var marginRightInput: UITextField = {
        let view = UITextField()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.textColor = .black
        view.placeholder = "right"
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.lightGray.cgColor
        view.layer.cornerRadius = 6
        view.setPlaceholderColor(.darkGray)
        view.leftViewMode = .always
        let paddingView = UIView(frame: .init(origin: .zero, size: .init(width: 10, height: view.frame.height)))
        view.leftView = paddingView
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupNaviItems()
        setupViews()
        loadSetting()
        setupEdgeGesture()
    }
    
    @objc private func handleEdgeGesture(_ gesture: UIScreenEdgePanGestureRecognizer) {
        guard gesture.state == .recognized else {
            return
        }
        shopliveHideKeyboard_SL()
        self.navigationController?.popViewController(animated: true)
    }

    private func setupEdgeGesture() {
        let edgePanGesture = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(handleEdgeGesture(_:)))
        edgePanGesture.edges = .left
        self.view.addGestureRecognizer(edgePanGesture)
    }
    
    func setupBackButton() {
        let backButton = UIBarButtonItem(image: ShopLivePlayerDemoAsset.back.image, style: .plain, target: self, action: #selector(handleNaviBack)
        )
        backButton.tintColor = .white
        self.navigationItem.leftBarButtonItem = backButton

        self.navigationController?.navigationBar.topItem?.backBarButtonItem = nil
    }

    @objc func handleNaviBack() {
        shopliveHideKeyboard_SL()
        self.navigationController?.popViewController(animated: true)
    }

    func setupNaviItems() {
        self.title = "sdkoption.pipFloatingOffset.page.title".localized()
        let save = UIBarButtonItem(title: "sdk.user.save".localized(from: "shoplive"), style: .plain, target: self, action: #selector(saveAct))
        save.tintColor = .white
        self.navigationItem.rightBarButtonItem = save
        
        setupBackButton()
    }

    @objc func saveAct() {
        let padding = UIEdgeInsets(top: paddingTopInput.text?.CGFloatValue() ?? 20, left: paddingLeftInput.text?.CGFloatValue() ?? 20, bottom: paddingBottomInput.text?.CGFloatValue() ?? 20, right: paddingRightInput.text?.CGFloatValue() ?? 20)
        
        DemoConfiguration.shared.pipPadding = padding

        let floatingOffset = UIEdgeInsets(top: marginTopInput.text?.CGFloatValue() ?? 0, left: marginLeftInput.text?.CGFloatValue() ?? 0, bottom: marginBottomInput.text?.CGFloatValue() ?? 0, right: marginRightInput.text?.CGFloatValue() ?? 0)
        
        DemoConfiguration.shared.pipFloatingOffset = floatingOffset

        handleNaviBack()
    }
    
    func setupViews() {
        self.view.backgroundColor = .white
        
        self.view.addSubviews(paddingTitle, paddingTopInput, paddingLeftInput, paddingRightInput, paddingBottomInput,
                              marginTitle, marginTopInput, marginBottomInput, marginLeftInput, marginRightInput,
                              resetButton)
        
        NSLayoutConstraint.activate([
            paddingTitle.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 20),
            paddingTitle.leadingAnchor.constraint(equalTo: self.view.leadingAnchor,constant: 20),
            paddingTitle.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20),
            paddingTitle.heightAnchor.constraint(equalToConstant: 20),
            
            paddingTopInput.topAnchor.constraint(equalTo: paddingTitle.bottomAnchor,constant: 20),
            paddingTopInput.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            paddingTopInput.widthAnchor.constraint(equalToConstant: 120),
            paddingTopInput.heightAnchor.constraint(equalToConstant: 30),
            
            paddingLeftInput.topAnchor.constraint(equalTo: paddingTopInput.bottomAnchor,constant: 20),
            paddingLeftInput.leadingAnchor.constraint(equalTo: self.view.leadingAnchor,constant: 20),
            paddingLeftInput.widthAnchor.constraint(equalToConstant: 120),
            paddingLeftInput.heightAnchor.constraint(equalToConstant: 30),
            
            paddingRightInput.topAnchor.constraint(equalTo: paddingTopInput.bottomAnchor,constant: 20),
            paddingRightInput.trailingAnchor.constraint(equalTo: self.view.trailingAnchor,constant: -20),
            paddingRightInput.widthAnchor.constraint(equalToConstant: 120),
            paddingRightInput.heightAnchor.constraint(equalToConstant: 30),
            
            paddingBottomInput.topAnchor.constraint(equalTo: paddingLeftInput.bottomAnchor, constant: 20),
            paddingBottomInput.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            paddingBottomInput.widthAnchor.constraint(equalToConstant: 120),
            paddingBottomInput.heightAnchor.constraint(equalToConstant: 30),
            
            marginTitle.topAnchor.constraint(equalTo: paddingBottomInput.bottomAnchor, constant: 20),
            marginTitle.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20),
            marginTitle.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20),
            marginTitle.heightAnchor.constraint(equalToConstant: 20),
            
            marginTopInput.topAnchor.constraint(equalTo: marginTitle.bottomAnchor,constant: 20),
            marginTopInput.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            marginTopInput.widthAnchor.constraint(equalToConstant: 120),
            marginTopInput.heightAnchor.constraint(equalToConstant: 30),
            
            marginLeftInput.topAnchor.constraint(equalTo: marginTopInput.bottomAnchor,constant: 20),
            marginLeftInput.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20),
            marginLeftInput.widthAnchor.constraint(equalToConstant: 120),
            marginLeftInput.heightAnchor.constraint(equalToConstant: 30),
            
            marginRightInput.topAnchor.constraint(equalTo: marginTopInput.bottomAnchor,constant: 20),
            marginRightInput.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20),
            marginRightInput.widthAnchor.constraint(equalToConstant: 120),
            marginRightInput.heightAnchor.constraint(equalToConstant: 30),
            
            marginBottomInput.topAnchor.constraint(equalTo: marginRightInput.bottomAnchor, constant: 20),
            marginBottomInput.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            marginBottomInput.widthAnchor.constraint(equalToConstant: 120),
            marginBottomInput.heightAnchor.constraint(equalToConstant: 30),
            
            resetButton.topAnchor.constraint(equalTo: marginBottomInput.bottomAnchor, constant: 20),
            resetButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            resetButton.widthAnchor.constraint(equalToConstant: 120),
            resetButton.heightAnchor.constraint(equalToConstant: 34)
        ])
    }
    
    func loadSetting() {
        let padding = DemoConfiguration.shared.pipPadding
        paddingTopInput.text = "\(Int(padding.top))"
        paddingBottomInput.text = "\(Int(padding.bottom))"
        paddingLeftInput.text = "\(Int(padding.left))"
        paddingRightInput.text = "\(Int(padding.right))"
        
        let floatingOffset = DemoConfiguration.shared.pipFloatingOffset
        marginTopInput.text = "\(Int(floatingOffset.top))"
        marginBottomInput.text = "\(Int(floatingOffset.bottom))"
        marginLeftInput.text = "\(Int(floatingOffset.left))"
        marginRightInput.text = "\(Int(floatingOffset.right))"
    }
    
    @objc func resetPipArea() {
        paddingTopInput.text = "20"
        paddingBottomInput.text = "20"
        paddingLeftInput.text = "20"
        paddingRightInput.text = "20"
        
        marginTopInput.text = "0"
        marginBottomInput.text = "0"
        marginLeftInput.text = "0"
        marginRightInput.text = "0"
    }

}
