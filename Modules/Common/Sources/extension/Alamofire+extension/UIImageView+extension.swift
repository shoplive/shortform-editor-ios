//
//  UIImageView+extension.swift
//  ShopliveCommonLibrary
//
//  Created by James Kim on 11/27/22.
//

import UIKit

public extension UIImageView {
    
    public func loadImage_SL(from url: URL?, placeHolderImage: UIImage? = nil, completion: ((UIImage?) -> ())? = nil) {
        guard let url = url else { return }
        ImageDownLoaderManager.shared.download(imageUrl: url) { result  in
            switch result {
            case .success(let imageData):
                if let image = UIImage(data: imageData) {
                    DispatchQueue.main.async {
                        self.image = image
                        completion?(image)
                    }
                }
                else {
                    completion?(nil)
                }
            case .failure(let error):
                completion?(nil)
            }
        }
    }
}


