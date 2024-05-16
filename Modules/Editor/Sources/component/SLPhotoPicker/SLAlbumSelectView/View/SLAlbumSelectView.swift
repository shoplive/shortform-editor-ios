//
//  File.swift
//  CustomImagePicker
//
//  Created by sangmin han on 5/3/24.
//

import Foundation
import UIKit
import ShopliveSDKCommon


class SLAlbumSelectView : UIView, SLReactor {
    
    
    enum Action {
        case reloadData
        case reloadRow(([IndexPath], UITableView.RowAnimation))
        case show(Bool)
        case setPhotoLibrary(SLPhotoLibrary)
        case setAssetsCollection([SLAssetsCollection])
    }
    
    enum Result {
        case setFocusedCollection(SLAssetsCollection)
    }
    
    private var backgroundView : UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.backgroundColor = .init(white: 0, alpha: 0.2)
        return btn
    }()
    
    private var thumbView : UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .init(red: 84, green: 84, blue: 84, aa: 1)
        view.layer.cornerRadius = 2
        return view
    }()
    
    private var albumTb : UITableView = {
        let tb = UITableView(frame: .zero, style: .plain)
        tb.translatesAutoresizingMaskIntoConstraints = false
        tb.backgroundColor = .clear
        tb.delaysContentTouches = true
        tb.separatorColor = .none
        tb.separatorInset = .zero
        tb.separatorStyle = .none
        return tb
    }()
    
    
    private var bottomSheetContainerView : UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .init(red: 31, green: 31, blue: 31,aa: 1)
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.layer.cornerRadius = 20
//        view.roundCorners_SL(corners: [.topRight, .topLeft], radius: 20)
        return view
    }()
    
    lazy private var bottomSheetContainerViewBottomAnc : NSLayoutConstraint = {
        return bottomSheetContainerView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 300)
    }()
    
    lazy private var bottomShettContainerViewTopAnc : NSLayoutConstraint = {
        return bottomSheetContainerView.topAnchor.constraint(equalTo: self.bottomAnchor, constant: 0)
    }()
    
    var resultHandler: ((Result) -> ())?
    private var baseBottomSheetHeight : CGFloat = 0
    private var maxBottomSheetHeight : CGFloat = 0
    
    
    private let reactor = SLAlbumSelectReactor()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .clear
        setLayout()
        bindReactor()
        
        reactor.action( .registerTablView(albumTb) )
        backgroundView.addTarget(self, action: #selector(backgroundTapped(sender: )), for: .touchUpInside)
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panGestureRecognizer(sender: )))
        thumbView.addGestureRecognizer(panGesture)
    }
    
    required init?(coder : NSCoder) {
        fatalError()
    }
    
    
    
    @objc func backgroundTapped(sender : UIButton) {
        self.reactor.action( .setShow(false) )
    }
    
    override open func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if self.isHidden || self.alpha == 0 {
            return super.hitTest(point, with: event)
        }
        let thumbViewOriginPoint = bottomSheetContainerView.convert(thumbView.frame.origin, to: self)
        let thumbViewRect = CGRect(x: thumbViewOriginPoint.x, y: thumbViewOriginPoint.y - 25, width: 100, height: 50)
        
        if thumbViewRect.contains(point) {
            return thumbView
        }
        
        return super.hitTest(point, with: event)
    }
    
}
//MARK: - panGesture
extension SLAlbumSelectView {
    @objc func panGestureRecognizer(sender : UIPanGestureRecognizer){
        switch sender.state {
        case .changed:
            let translation = sender.translation(in: self)
            let numerOfTotalItem : CGFloat = CGFloat(albumTb.numberOfRows(inSection: 0))
            let maxTableViewContentHeight = numerOfTotalItem * reactor.getCellHeight()
            maxBottomSheetHeight = min(maxTableViewContentHeight + 30 ,UIScreen.main.bounds.height * 0.8)
            let expectedHeight = -(bottomShettContainerViewTopAnc.constant + translation.y )
            let midHeight = floor(UIScreen.main.bounds.height / 2)
            let isDragginUp : Bool = sender.velocity(in: self).y < 0 ? true : false
            
            sender.setTranslation(.zero, in: self)
            
            if maxBottomSheetHeight < midHeight {
                if expectedHeight > maxBottomSheetHeight && isDragginUp {
                    self.bottomShettContainerViewTopAnc.constant = -min(expectedHeight,midHeight)
                }
                else {
                    bottomShettContainerViewTopAnc.constant += translation.y
                }
            }
            else {
                if expectedHeight > maxBottomSheetHeight {
                    self.bottomShettContainerViewTopAnc.constant = -min(expectedHeight,self.maxBottomSheetHeight)
                }
                else {
                    bottomShettContainerViewTopAnc.constant += translation.y
                }
            }
        case .ended:
            let midHeight = floor(UIScreen.main.bounds.height / 2)
            let bottomSheetHeight = -bottomShettContainerViewTopAnc.constant
            let toMaxDiff : (CGFloat, CGFloat) = (abs(bottomSheetHeight - maxBottomSheetHeight),maxBottomSheetHeight)
            let toBaseDiff : (CGFloat, CGFloat) = (abs(bottomSheetHeight - baseBottomSheetHeight),baseBottomSheetHeight)
            let toMidDiff : (CGFloat,CGFloat) = (abs(bottomSheetHeight - midHeight),midHeight)
            let toBottomDiff : (CGFloat, CGFloat) = (abs(bottomSheetHeight),0)
            var targetHeight : CGFloat = 0
            if let least = [toMaxDiff,toBaseDiff,toBottomDiff,toMidDiff].sorted(by: { $0.0 < $1.0 }).first {
                targetHeight = least.1
            }
            else {
                targetHeight = baseBottomSheetHeight
            }
            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0) {
                self.bottomShettContainerViewTopAnc.constant = -targetHeight
                self.layoutIfNeeded()
            } completion: { _ in
                if targetHeight == 0 {
                    self.reactor.action( .setShow(false) )
                }
            }
        default:
            break
        }
    }
}
//MARK: - view action
extension SLAlbumSelectView {
    func action(_ action: Action) {
        switch action {
        case .reloadData:
            self.onReloadData()
        case .reloadRow((let indexPaths, let animation)):
            self.onReloadRow(indexPaths: indexPaths, rowAnimation: animation)
        case .show(let show):
            self.onShow(show: show)
        case .setPhotoLibrary(let pl):
            self.onSetPhotoLibrary(pl: pl)
        case .setAssetsCollection(let collections):
            self.onSetAssetsCollection(collection: collections)
        }
    }
    
    
    private func onReloadData() {
        self.albumTb.reloadData()
    }
    
    private func onReloadRow(indexPaths : [IndexPath], rowAnimation : UITableView.RowAnimation) {
        self.albumTb.reloadRows(at: indexPaths, with: rowAnimation)
    }
    
    private func onShow(show : Bool) {
        reactor.action( .setShow(show) )
    }
    
    private func onSetPhotoLibrary(pl : SLPhotoLibrary) {
        reactor.action( .setPhotoLibrary(pl) )
    }
    
    private func onSetAssetsCollection(collection : [SLAssetsCollection]) {
        reactor.action( .setAssetsCollections(collection) )
    }
}

//MARK: - reactor bind
extension SLAlbumSelectView {
    private func bindReactor() {
        reactor.resultHandler = { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .show(let show):
                self.onReactorShow(show: show)
            case .setFocusedCollection(let collection):
                self.onReactorSetFocusedCollection(collection : collection)
            }
        }
    }
    
    private func onReactorShow(show : Bool) {
        self.layer.removeAllAnimations()
        self.isHidden = false
        self.backgroundView.alpha = show ? 0 : 1
        if show {
            let totalNumberOfItem : CGFloat = CGFloat(albumTb.numberOfRows(inSection: 0))
            let cellHeight : CGFloat = 54 + 14
            baseBottomSheetHeight = min(totalNumberOfItem * cellHeight, UIScreen.main.bounds.height / 2) + 30
            bottomShettContainerViewTopAnc.constant = -baseBottomSheetHeight
        }
        else {
            bottomShettContainerViewTopAnc.constant = 0
        }
        UIView.animate(withDuration: 0.3, animations: {
            self.backgroundView.alpha = show ? 1 : 0
            if show {
                self.bottomSheetContainerViewBottomAnc.constant = 0
            }
            else {
                self.bottomSheetContainerViewBottomAnc.constant = 300
            }
            self.layoutIfNeeded()
        }) { _ in
            self.isHidden = show ? false : true
        }
    }
    
    private func onReactorSetFocusedCollection(collection : SLAssetsCollection) {
        resultHandler?( .setFocusedCollection(collection) )
    }
}
extension SLAlbumSelectView {
    private func setLayout() {
        self.addSubview(backgroundView)
        self.addSubview(bottomSheetContainerView)
        bottomSheetContainerView.addSubview(thumbView)
        bottomSheetContainerView.addSubview(albumTb)
        
        NSLayoutConstraint.activate([
            backgroundView.topAnchor.constraint(equalTo: self.topAnchor),
            backgroundView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            
            bottomSheetContainerViewBottomAnc,
            bottomSheetContainerView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            bottomSheetContainerView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            bottomShettContainerViewTopAnc,
            
            thumbView.topAnchor.constraint(equalTo: bottomSheetContainerView.topAnchor, constant: 6),
            thumbView.centerXAnchor.constraint(equalTo: bottomSheetContainerView.centerXAnchor),
            thumbView.widthAnchor.constraint(equalToConstant: 60),
            thumbView.heightAnchor.constraint(equalToConstant: 4),
            
            albumTb.topAnchor.constraint(equalTo: bottomSheetContainerView.topAnchor, constant: 30),
            albumTb.leadingAnchor.constraint(equalTo: bottomSheetContainerView.leadingAnchor),
            albumTb.trailingAnchor.constraint(equalTo: bottomSheetContainerView.trailingAnchor),
            albumTb.bottomAnchor.constraint(equalTo: bottomSheetContainerView.bottomAnchor)
        ])
    }
}
