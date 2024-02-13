//
//  UIImage+extension.swift
//  ShopliveCommon
//
//  Created by James Kim on 11/23/22.
//

import UIKit

public extension UIImage {
    func resizeWithWidth_SL(width: CGFloat) -> UIImage? {
        let imageView = UIImageView(frame: CGRect(origin: .zero, size: CGSize(width: width, height: CGFloat(ceil(width/size.width * size.height)))))
        imageView.contentMode = .scaleAspectFit
        imageView.image = self
        UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, false, scale)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        imageView.layer.render(in: context)
        guard let result = UIGraphicsGetImageFromCurrentImageContext() else { return nil }
        UIGraphicsEndImageContext()
        return result
    }
    
    func imageWithTint_SL(_ color: UIColor, alpha: CGFloat = 1.0) -> UIImage {
        guard let cgImage = cgImage else { return self }

        UIGraphicsBeginImageContextWithOptions(self.size, false, UIScreen.main.scale)

        let context = UIGraphicsGetCurrentContext()

        color.setFill()

        context?.translateBy(x: 0, y: self.size.height)
        context?.scaleBy(x: 1.0, y: -1.0)

        context?.setBlendMode(CGBlendMode.colorBurn)
        let rect = CGRect(x: 0.0, y: 0.0, width: self.size.width, height: self.size.height)
        context?.draw(cgImage, in: rect)

        context?.setBlendMode(CGBlendMode.sourceIn)
        context?.addRect(rect)
        context?.drawPath(using: CGPathDrawingMode.fill)

        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        guard let image = img else { return self }
        return image
    }
    
    func resizeImageTo_SL(size: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        self.draw(in: CGRect(origin: CGPoint.zero, size: size))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return resizedImage
    }
    
    func scalePreservingAspectRatio_SL(targetSize: CGSize) -> UIImage {
        // Determine the scale factor that preserves aspect ratio
        let widthRatio = targetSize.width / size.width
        let heightRatio = targetSize.height / size.height
        
        let scaleFactor = min(widthRatio, heightRatio)
        
        // Compute the new image size that preserves aspect ratio
        let scaledImageSize = CGSize(
            width: size.width * scaleFactor,
            height: size.height * scaleFactor
        )

        // Draw and return the resized UIImage
        let renderer = UIGraphicsImageRenderer(
            size: scaledImageSize
        )

        let scaledImage = renderer.image { _ in
            self.draw(in: CGRect(
                origin: .zero,
                size: scaledImageSize
            ))
        }
        
        return scaledImage
    }
    
    func changeScale_SL(to: CGFloat) -> UIImage? {
        let toSize: CGSize = .init(width: self.size.width * to, height: self.size.height * to)
        UIGraphicsBeginImageContextWithOptions(toSize, false, 0.0)
        self.draw(in: CGRect(origin: CGPoint.zero, size: toSize))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return resizedImage
    }

    func resizeWith_SL(width: CGFloat) -> UIImage? {
        let height = CGFloat(ceil(width/self.size.width * self.size.height))
        let size = CGSize(width: width, height: height)
        let imageView = UIImageView(frame: CGRect(origin: .zero, size: size))
        imageView.contentMode = .scaleAspectFit
        imageView.image = self

        UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, false, scale)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        imageView.layer.render(in: context)
        guard let result = UIGraphicsGetImageFromCurrentImageContext() else { return nil }
        UIGraphicsEndImageContext()

        return result
    }

    func toBlackAndWhite_SL() -> UIImage? {
        guard let ciImage = CIImage(image: self) else {
            return nil
        }
        guard let grayImage = CIFilter(name: "CIPhotoEffectNoir", parameters: [kCIInputImageKey: ciImage])?.outputImage else {
            return nil
        }
        let bAndWParams: [String: Any] = [kCIInputImageKey: grayImage,
                                          kCIInputContrastKey: 50.0,
                                          kCIInputBrightnessKey: 10.0]
        guard let bAndWImage = CIFilter(name: "CIColorControls", parameters: bAndWParams)?.outputImage else {
            return nil
        }
        guard let cgImage = CIContext(options: nil).createCGImage(bAndWImage, from: bAndWImage.extent) else {
            return nil
        }
        return UIImage(cgImage: cgImage)
    }

    enum Quality {
        case uncompressed
        case highest
        case high
        case medium
        case low
        case lowest
    }

    var uncompressedPNGData_SL: Data? { return self.pngData()        }
    var highestQualityJPEGNSData_SL: Data? { return self.jpegData(compressionQuality: 1.0)  }
    var highQualityJPEGNSData_SL: Data? { return self.jpegData(compressionQuality: 0.75) }
    var mediumQualityJPEGNSData_SL: Data? { return self.jpegData(compressionQuality: 0.5)  }
    var lowQualityJPEGNSData_SL: Data? { return self.jpegData(compressionQuality: 0.25) }
    var lowestQualityJPEGNSData_SL: Data? { return self.jpegData(compressionQuality: 0.0)  }
    
    func toNSTextAttachment_SL(_ width: CGFloat? = nil, _ height: CGFloat? = nil, _ yPos: CGFloat = -8) -> NSTextAttachment {
        let imageAttachment = NSTextAttachment()
        imageAttachment.bounds = CGRect(x: 0, y: yPos, width: width ?? self.size.width, height: height ?? self.size.height)
        imageAttachment.image = self
        return imageAttachment
    }

    func toNSTextAttachment_SL(yPos: CGFloat = -8) -> NSTextAttachment {
        let imageAttachment = NSTextAttachment()
        imageAttachment.bounds = CGRect(x: 0, y: yPos, width:  self.size.width, height: self.size.height)
        imageAttachment.image = self
        return imageAttachment
    }
    
    convenience init?(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) {
      let rect = CGRect(origin: .zero, size: size)
      UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
      color.setFill()
      UIRectFill(rect)
      let image = UIGraphicsGetImageFromCurrentImageContext()
      UIGraphicsEndImageContext()
      
      guard let cgImage = image?.cgImage else { return nil }
      self.init(cgImage: cgImage)
    }
    
    func saveThumbnail_SL() {
        if let jpgData = self.jpegData(compressionQuality: 0.5) {
            let path = FileManager.default.temporaryDirectory.appendingPathComponent("shortform-thumbnail.jpg")
            try? jpgData.write(to: path)
        }
    }
}
