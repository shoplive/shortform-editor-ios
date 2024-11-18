//
//  SLCropableUIimageView.swift
//  ShopLiveShortformEditorSDK
//
//  Created by sangmin han on 11/4/24.
//  Copyright © 2024 com.app. All rights reserved.
//

import Foundation
import UIKit
import ShopliveSDKCommon

class SLCropableUIImageView : UIView, SLReactor {
    
    enum Action {
        case setImage(UIImage?)
        case setCornerRadius(CGFloat)
        case setClipsToBound(Bool)
        case setImageViewContentMode(ContentMode)
        case setCropViewSize(CGSize)
        case requestCroppedImageResult
        case requestNormalImageResult
        case setCropViewIsAvailable(Bool)
        
    }
    
    enum Result {
        case croppedImageResult(UIImage?)
        case normalImageResult(UIImage?)
    }
    
    private let imageView : UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private lazy var cropView : SLVideoEditorPlayerCropView = {
        let view = SLVideoEditorPlayerCropView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        view.setIsCropAvailable(isAvailable: true)
        return view
    }()
   
    var resultHandler: ((Result) -> ())?
    
    override init(frame : CGRect) {
        super.init(frame: .zero)
        setLayout()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func action(_ action: Action) {
        switch action {
        case .setImage(let image):
            self.onSetImage(image : image)
        case .setClipsToBound(let isClip):
            self.onSetClipsToBound(isClip: isClip)
        case .setCornerRadius(let cornerRadius):
            self.onSetCornerRadius(radius: cornerRadius)
        case .setImageViewContentMode(let contentMode):
            self.onSetImageViewContentMode(contentMode: contentMode)
        case .setCropViewSize(let size):
            self.onSetCropViewSize(size: size)
        case .requestCroppedImageResult:
            self.onRequestCroppedImageResult()
        case .requestNormalImageResult:
            self.onRequestNormalImageResult()
        case .setCropViewIsAvailable(let isAvailable):
            self.onSetCropViewIsAvailable(isAvailable : isAvailable)
        }
    }
    
    private func onSetImage(image : UIImage?) {
        self.imageView.image = image
    }
    
    private func onSetClipsToBound(isClip : Bool) {
        self.imageView.clipsToBounds = isClip
    }
    
    private func onSetCornerRadius(radius : CGFloat) {
        self.imageView.layer.cornerRadius = radius
    }
    
    private func onSetImageViewContentMode(contentMode : ContentMode) {
        self.imageView.contentMode = contentMode
    }
    
    private func onSetCropViewSize(size : CGSize) {
        self.cropView.videoResolution = size
        self.cropView.setInitialCropRect(rect: .init(origin: .zero, size: size))
        self.cropView.updateCropArea()
        self.cropView.setIsCropAvailable(isAvailable: true)
    }
    
    private func onRequestCroppedImageResult() {
        resultHandler?( .croppedImageResult(getCroppedImage()) )
    }
    
    private func onRequestNormalImageResult() {
        resultHandler?( .normalImageResult(self.imageView.image) ) 
    }
    
    private func onSetCropViewIsAvailable(isAvailable : Bool) {
        self.cropView.isHidden = isAvailable ? false : true
    }
}
extension SLCropableUIImageView {
    private func getCroppedImage() -> UIImage? {
        guard let convertedRect = self.convertCropRectToActualImageSize(cropRect: cropView.getCropViewRect()) else {
            return imageView.image
        }
        return self.cropped(to: convertedRect)
    }
}
extension SLCropableUIImageView {
    private func cropped(to rect: CGRect) -> UIImage? {
        guard let cgImage = self.imageView.image?.cgImage?.cropping(to: rect) else {
            return nil
        }
        return UIImage(cgImage: cgImage)
    }
    
    private func convertCropRectToActualImageSize(cropRect : CGRect) -> CGRect? {
        guard let imageSize = imageView.image?.size else {
            return nil
        }
        
        let widthRatio = imageSize.width / self.bounds.width
        let heightRatio = imageSize.height / self.bounds.height
        
        let convertedRect = CGRect(
            x: cropRect.origin.x * widthRatio,
            y: cropRect.origin.y * heightRatio,
            width: cropRect.width * widthRatio,
            height: cropRect.height * heightRatio
        )
        
        return convertedRect
    }
}
extension SLCropableUIImageView {
    private func setLayout() {
        self.addSubview(imageView)
        self.addSubview(cropView)
        
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: self.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            
            cropView.topAnchor.constraint(equalTo: self.topAnchor),
            cropView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            cropView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            cropView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
    }
}
