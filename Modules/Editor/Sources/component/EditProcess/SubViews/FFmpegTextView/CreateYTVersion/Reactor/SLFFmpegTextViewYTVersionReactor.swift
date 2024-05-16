//
//  SLFFmpegTextViewYTVersionReactor.swift
//  ShopLiveShortformEditorSDK
//
//  Created by sangmin han on 1/29/24.
//

import Foundation
import UIKit
import ShopliveSDKCommon


class SLFFmpegTextViewYTVersionReactor : NSObject, SLReactor {
    
    enum Action {
        case registerCv(UICollectionView)
    }
    
    enum Result {
        case handleKeyBoard(CGRect)
        
    }
    
    private var colorList : [UIColor] = [.white, .black, .red , .orange, .yellow, .green , .blue , .purple , .cyan , .brown ]
    
    var resultHandler: ((Result) -> ())?
    
    var onMainQueueResultHandler : ((Result) -> ())?
    
    
    override init() {
        super.init()
        addObserver()
    }
    
    deinit {
        removeObserver()
    }
    
    
    func action(_ action: Action) {
        switch action {
        case .registerCv(let cv):
            self.registerCv(cv: cv)
        }
        
    }
    
    private func registerCv(cv : UICollectionView) {
        cv.delegate = self
        cv.dataSource = self
        cv.register(SLFFmpegTextBackgroundColorCell.self, forCellWithReuseIdentifier: SLFFmpegTextBackgroundColorCell.cellId)
    }
    
    
}
extension SLFFmpegTextViewYTVersionReactor {
    private func addObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleNotification(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleNotification(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
    }
    
    private func removeObserver() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        
    }
    
    @objc func handleNotification(_ notification : Notification) {
        
        switch notification.name {
        case UIResponder.keyboardWillShowNotification, UIResponder.keyboardWillHideNotification:
            self.handleKeyBoardNotification(notification: notification)
        default:
            break
        }
        
        
    }
    
    
    private func handleKeyBoardNotification( notification : Notification) {
        var keyboardHeight : CGFloat = 0
        var bottomPadding : CGFloat = 0
        var keyBoardRect : CGRect = .zero
        
        if let keyboardFrameEndUserInfo = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            keyBoardRect = keyboardFrameEndUserInfo.cgRectValue
            bottomPadding = UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0
            keyboardHeight = keyBoardRect.height - bottomPadding
        }
        if notification.name == UIResponder.keyboardWillShowNotification {
            onMainQueueResultHandler?( .handleKeyBoard(keyBoardRect) )
        }
        else {
            onMainQueueResultHandler?( .handleKeyBoard(.zero) )
        }
        
    }
    
}
extension SLFFmpegTextViewYTVersionReactor : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return colorList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SLFFmpegTextBackgroundColorCell.cellId, for: indexPath) as! SLFFmpegTextBackgroundColorCell
        cell.setColor(color: colorList[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return .init(width: 40, height: 40)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
}


