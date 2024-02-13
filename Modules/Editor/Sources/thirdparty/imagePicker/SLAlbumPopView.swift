//
//  SLAlbumPopView.swift
//  SLPhotosPicker
//
//  Created by wade.hawk on 2017. 4. 19..
//  Copyright © 2017년 wade.hawk. All rights reserved.
//

import UIKit

protocol PopupViewProtocol: AnyObject {
    var bgView: UIView! { get set }
    var popupView: UIView! { get set }
    var originalFrame: CGRect { get set }
    var show: Bool { get set }
    
    func setupPopupFrame()
    
    
    var bottomSheetContainerView : UIView { get set }
    var bottomSheetContainerViewBottomAnc : NSLayoutConstraint { get set }
    var bottomShettContainerViewTopAnc : NSLayoutConstraint { get set }
    var baseBottomSheetHeight : CGFloat { get set }
    var maxBottomSheetHeight : CGFloat { get set }
    var tableView : UITableView { get set }
    
}

extension PopupViewProtocol where Self: UIView {
    fileprivate func getFrame(scale: CGFloat) -> CGRect {
        var frame = self.originalFrame
        frame.size.width = frame.size.width * scale
        frame.size.height = frame.size.height * scale
        frame.origin.x = self.frame.width/2 - frame.width/2
        return frame
    }
    func setupPopupFrame() {
        if self.originalFrame == CGRect.zero {
            self.originalFrame = self.popupView.frame
        }else {
            self.originalFrame.size.height = self.popupView.frame.height
        }
    }
    func show(_ show: Bool, duration: TimeInterval = 0.3) {
        guard self.show != show else { return }
        self.layer.removeAllAnimations()
        self.isHidden = false
        self.bgView.alpha = show ? 0 : 1
        if show {
            let totalNumberOfItem : CGFloat = CGFloat(tableView.numberOfRows(inSection: 0))
            let cellHeight : CGFloat = 54 + 14
            baseBottomSheetHeight = min(totalNumberOfItem * cellHeight, UIScreen.main.bounds.height / 2) + 30
            bottomShettContainerViewTopAnc.constant = -baseBottomSheetHeight
        }
        else {
            bottomShettContainerViewTopAnc.constant = 0
        }
        
        UIView.animate(withDuration: duration, animations: {
            self.bgView.alpha = show ? 1 : 0
            if show {
                self.bottomSheetContainerViewBottomAnc.constant = 0
            }
            else {
                self.bottomSheetContainerViewBottomAnc.constant = 300
            }
            self.layoutIfNeeded()
        }) { _ in
            self.isHidden = show ? false : true
            self.show = show
        }
    }
}

open class SLAlbumPopView: UIView, PopupViewProtocol {
    @IBOutlet open var bgView: UIView!
    @IBOutlet open var popupView: UIView!
    @IBOutlet var popupViewHeight: NSLayoutConstraint!
    @objc var originalFrame = CGRect.zero
    @objc var show = false
    
    var originBottomSheetCenty : CGFloat = 0
    var baseBottomSheetHeight: CGFloat = 0
    var maxBottomSheetHeight: CGFloat = 0
    private let cellHeight : CGFloat = 54 + 14
    
    open lazy var tableView : UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delaysContentTouches = true
        tableView.rowHeight = cellHeight
        tableView.separatorColor = UIColor.init("#EEEEEE")
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 23, bottom: 0, right: 23)
        let backgroundView = UIView()
        backgroundView.backgroundColor = .white
        tableView.backgroundView = backgroundView
        return tableView
    }()
    
    private var thumbView : UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .init("#CBCBCB")
        view.layer.cornerRadius = 2
        return view
    }()
    
    var bottomSheetContainerView : UIView = {
        let view  = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        view.roundCorners_SL(corners: [.topRight, .topLeft], radius: 20)
        return view
    }()
    
    lazy var bottomSheetContainerViewBottomAnc : NSLayoutConstraint = {
        return bottomSheetContainerView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 300)
    }()
    
    lazy var bottomShettContainerViewTopAnc : NSLayoutConstraint = {
        return bottomSheetContainerView.topAnchor.constraint(equalTo: self.bottomAnchor, constant: 0)
    }()
    
    override open func awakeFromNib() {
        super.awakeFromNib()
        self.popupView.layer.cornerRadius = 5.0
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapBgView))
        self.bgView.addGestureRecognizer(tapGesture)
        self.tableView.register(UINib(nibName: "SLCollectionTableViewCell", bundle: Bundle(for: type(of: self))), forCellReuseIdentifier: "SLCollectionTableViewCell")
        if #available(iOS 13.0, *) {
            self.popupView.backgroundColor = .white
        }
        self.popupView.isHidden = true
        self.setLayout()
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panGestureRecognizer(sender: )))
        thumbView.addGestureRecognizer(panGesture)
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
    
    @objc func tapBgView() {
        self.show(false)
    }
    
    @objc func panGestureRecognizer(sender : UIPanGestureRecognizer){
        switch sender.state {
        case .changed:
            let translation = sender.translation(in: self)
            let numerOfTotalItem : CGFloat = CGFloat(tableView.numberOfRows(inSection: 0))
            let maxTableViewContentHeight = numerOfTotalItem * cellHeight
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
                    self.show(false)
                }
            }
        default:
            break
        }
    }
    
}
extension SLAlbumPopView {
    private func setLayout(){
        self.addSubviews_SL(bottomSheetContainerView)
        bottomSheetContainerView.addSubview(thumbView)
        bottomSheetContainerView.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            bottomSheetContainerViewBottomAnc,
            bottomSheetContainerView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            bottomSheetContainerView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            bottomShettContainerViewTopAnc,
            
            thumbView.topAnchor.constraint(equalTo: bottomSheetContainerView.topAnchor, constant: 6),
            thumbView.centerXAnchor.constraint(equalTo: bottomSheetContainerView.centerXAnchor),
            thumbView.widthAnchor.constraint(equalToConstant: 60),
            thumbView.heightAnchor.constraint(equalToConstant: 4),
            
            tableView.topAnchor.constraint(equalTo: bottomSheetContainerView.topAnchor, constant: 30),
            tableView.leadingAnchor.constraint(equalTo: bottomSheetContainerView.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: bottomSheetContainerView.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: bottomSheetContainerView.bottomAnchor)
        ])
    }
}
/*
 let storyboard = UIStoryboard(name: "myStoryboardName", bundle: nil)
 let vc = storyboard.instantiateViewController(withIdentifier: "myVCID")
 self.present(vc, animated: true)
 */
