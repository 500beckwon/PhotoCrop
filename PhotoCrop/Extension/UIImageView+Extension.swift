//
//  UIImageView+Extension.swift
//  PhotoCrop
//
//  Created by ByungHoon Ann on 2023/02/02.
//

import UIKit
import Photos
import RxCocoa

extension UIImageView {
    func fetchImageAsset(_ asset: PHAsset?,
                         targetSize size: CGSize,
                         contentMode: PHImageContentMode = .aspectFill,
                         options: PHImageRequestOptions? = nil,
                         completionHandler: ((Bool) -> Void)? = nil) {
        guard let asset = asset else {
            completionHandler?(false)
            return
        }
        
        let resultHandler: (UIImage?, [AnyHashable: Any]?) -> Void = { image, info in
            self.image = image
            completionHandler?(true)
        }

        PHImageManager.default().requestImage(
            for: asset,
            targetSize: size,
            contentMode: contentMode,
            options: options,
            resultHandler: resultHandler)
    }
    
    func fetchImage(asset: PHAsset) {
        PHAssetManager.shared.getImage(asset: asset) { [weak self] image in
            guard let self = self else { return }
            self.image = image
        }
    }
}
