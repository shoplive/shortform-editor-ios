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
        let view = SLVideoEditorPlayerCropView(cropGridViewColor: cropGridViewColor)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        view.setIsCropAvailable(isAvailable: true)
        return view
    }()
  
    private var cropGridViewColor : UIColor = .white
    var resultHandler: ((Result) -> ())?
    
    init(cropGridViewColor : UIColor) {
        super.init(frame: .zero)
        self.cropGridViewColor = cropGridViewColor
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
        let imageSize = getVisibleImageFrame()?.size ?? size
        self.cropView.setInitialCropRect(rect: .init(origin: .zero, size: imageSize))
        NSLayoutConstraint.activate([
            cropView.widthAnchor.constraint(equalToConstant: imageSize.width),
            cropView.heightAnchor.constraint(equalToConstant: imageSize.height)
        ])
        self.layoutIfNeeded()
        self.cropView.updateCropArea()
        self.cropView.setIsCropAvailable(isAvailable: true)
        
    }
    
    //실제 .scaleAspectFit으로 설정되어서 렌더링 되는 영역의 크기 
    private func getVisibleImageFrame() -> CGRect? {
        guard let image = imageView.image else {
            return nil
        }

        let imageSize = image.size
        let imageViewSize = imageView.bounds.size
        let widthRatio = imageViewSize.width / imageSize.width
        let heightRatio = imageViewSize.height / imageSize.height
        let scale = min(widthRatio, heightRatio)
        
        
        let visibleWidth = imageSize.width * scale
        let visibleHeight = imageSize.height * scale
        
        let x = (imageViewSize.width - visibleWidth) / 2
        let y = (imageViewSize.height - visibleHeight) / 2
        
        return CGRect(x: x, y: y, width: visibleWidth, height: visibleHeight)
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
        guard let cgImage = self.imageView.image?.fixedOrientation().cgImage?.cropping(to: rect) else {
            return nil
        }
        return UIImage(cgImage: cgImage, scale: 1.0, orientation: .up )
    }
    
    private func convertCropRectToActualImageSize(cropRect : CGRect) -> CGRect? {
        guard let imageSize = imageView.image?.size else {
            return nil
        }
       
        let widthRatio = imageSize.width / cropView.frame.width
        let heightRatio = imageSize.height / cropView.frame.height
        
        let convertedRect = CGRect(
            x: cropRect.origin.x * widthRatio,
            y: cropRect.origin.y * heightRatio ,
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
            
            cropView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            cropView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
        ])
    }
}

fileprivate extension UIImage {
    func fixedOrientation() -> UIImage {
        guard imageOrientation != .up else {
            return self
        }
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        defer { UIGraphicsEndImageContext() }
        
        draw(in: CGRect(origin: .zero, size: size))
        
        return UIGraphicsGetImageFromCurrentImageContext() ?? self
    }
}
