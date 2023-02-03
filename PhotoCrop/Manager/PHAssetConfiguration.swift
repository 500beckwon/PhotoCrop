//
//  PHAssetConfiguration.swift
//  PhotoCrop
//
//  Created by ByungHoon Ann on 2023/02/01.
//

import Photos

final class PHAssetConfiguration: NSObject {
    private static var single = PHAssetConfiguration()
    
    @objc  class func `default`() -> PHAssetConfiguration {
        return PHAssetConfiguration.single
    }
    
    ///Default is 300x300
    var targetSize = PHAssetConstants.shared.targetSize
    
    var phFetchOptions: PHFetchOptions = PHAssetConstants.shared.phFetchOptions
    
    var imageRequestOptions: PHImageRequestOptions = PHAssetConstants.shared.imageRequestOptions
    
    var imageRequestMiniOptions: PHImageRequestOptions = PHAssetConstants.shared.imageRequestMiniOption
    
    var livePhotoRequestOptions: PHLivePhotoRequestOptions = PHAssetConstants.shared.livePhotoRequestOptions
    
    var videoRequestOptions: PHVideoRequestOptions = PHAssetConstants.shared.videoRequestOptions
    
    lazy var albumType = AlbumVarieties().albumList
    
    ///Constants
    private class PHAssetConstants {
        static let shared = PHAssetConstants()
        
        let targetSize = CGSize(width: 300, height: 300)
        
        var phFetchOptions: PHFetchOptions {
            let options = PHFetchOptions()
            let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: false)
            options.sortDescriptors = [sortDescriptor]
            return options
        }
        
        var imageRequestMiniOption: PHImageRequestOptions {
            let options = PHImageRequestOptions()
            options.isNetworkAccessAllowed = true
            options.resizeMode = .fast
            options.deliveryMode = .fastFormat
            options.isSynchronous = true
            return options
        }
        
        var imageRequestOptions: PHImageRequestOptions {
            let options = PHImageRequestOptions()
            options.isNetworkAccessAllowed = true
            options.resizeMode = .exact
            options.deliveryMode = .highQualityFormat
            options.isSynchronous = true
            return options
        }
        
        var livePhotoRequestOptions: PHLivePhotoRequestOptions {
            let options = PHLivePhotoRequestOptions()
            options.deliveryMode = .highQualityFormat
            options.isNetworkAccessAllowed = true
            return options
        }
        
        var videoRequestOptions:  PHVideoRequestOptions {
            let options = PHVideoRequestOptions()
            options.isNetworkAccessAllowed = true
            return options
        }
    }
}

