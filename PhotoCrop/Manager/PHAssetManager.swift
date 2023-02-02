//
//  PHAssetManager.swift
//  PhotoCrop
//
//  Created by ByungHoon Ann on 2023/02/01.
//

import Photos
import RxSwift

final class PHAssetManager {
    static let shared = PHAssetManager()
    private var storedPHImages: [PHImage] = []
    
    var configs = PHAssetConfiguration.default()
    
    var phFetchOptions: PHFetchOptions {
        get {
            configs.phFetchOptions
        }
        set {
            configs.phFetchOptions = newValue
        }
    }
    
    var imageRequestOptions: PHImageRequestOptions {
        get {
            configs.imageRequestOptions
        }
        set {
            configs.imageRequestOptions = newValue
        }
    }
    
    var imageRequestMiniOption: PHImageRequestOptions {
        get {
            configs.imageRequestMiniOptions
        }
        set {
            configs.imageRequestMiniOptions = newValue
        }
    }
    
    var targetSize: CGSize {
        get {
            configs.targetSize
        }
        set {
            configs.targetSize = newValue
        }
    }
    
    var livePhotoRequestOptions: PHLivePhotoRequestOptions {
        get {
            return configs.livePhotoRequestOptions
        }
        set {
            configs.livePhotoRequestOptions = newValue
        }
    }
    
    var videoRequestOptions: PHVideoRequestOptions {
        get {
            return configs.videoRequestOptions
        }
        set {
            configs.videoRequestOptions = newValue
        }
    }
    
    var albumTypeList: [PHFetchResult<PHAssetCollection>] {
        return configs.albumType
    }
}

extension PHAssetManager {
    func getPHAssetAlbumList() -> Observable<[AssetAlbum]> {
        return Observable.create { observable in
            var albums = [AssetAlbum]()
            self.albumTypeList.forEach {
                var fetchResult: PHFetchResult<PHAsset>?
                $0.enumerateObjects { album, index, _ in
                    let title = album.localizedTitle ?? "제목없음"
                    var thumbnailAsset = PHAsset()
                    fetchResult = PHAsset.fetchAssets(in: album, options: nil)
                    if let albumCount = fetchResult?.count, albumCount > 0 {
                        switch album.assetCollectionType {
                        case .album : thumbnailAsset = (fetchResult?.firstObject)!
                            
                        default: thumbnailAsset = (fetchResult?.lastObject)!
                        }
                        
                        let assetAlbum = AssetAlbum(asset: thumbnailAsset,
                                                    albumTitle: title.localTitleConfirm(),
                                                    count: albumCount)
                        albums.append(assetAlbum)
                    }
                }
            }
            observable.onNext(albums)
            return Disposables.create()
        }
         
    }
    
    func getPHAssetCollection() -> [PHCollection] {
        var allAssetCollections = [PHCollection]()
        
        PHAssetCollection
            .fetchTopLevelUserCollections(with: nil)
            .enumerateObjects { assetCollection, _, _ in
                allAssetCollections.append(assetCollection)
        }
        return allAssetCollections
    }
    
    func getPHAssets(with mediaType: PHAssetMediaType) -> [PHAsset] {
        var allAssets: [PHAsset] = []
        PHAsset.fetchAssets(with: mediaType, options: phFetchOptions).enumerateObjects { asset, _, _ in
            allAssets.append(asset)
        }
        return allAssets
    }
    
    func getImage(
        asset: PHAsset,
        contentMode: PHImageContentMode = .aspectFill
    ) -> Observable<UIImage?> {
        
        return Observable.create { observable in
            let targetSize = CGSize(width: asset.pixelWidth, height: asset.pixelHeight)
            PHImageManager
                .default()
                .requestImage(for: asset,
                              targetSize: targetSize,
                              contentMode: contentMode,
                              options: self.imageRequestOptions) { image, _ in
                    observable.onNext(image)
                    observable.onCompleted()
                }
            return Disposables.create()
         }
     }
    
    func getImageList(
        assetList: [PHAsset],
        contentMode: PHImageContentMode = .aspectFit,
        targetSize: CGSize = CGSize(width: 200, height: 200)
    ) -> Observable<[PHImage]> {
        return Observable
            .from(assetList)
            .flatMap { asset -> Observable<PHImage> in
                return Observable.create { observable in
                    PHImageManager.default().requestImage(for: asset, targetSize: targetSize, contentMode: contentMode, options: self.imageRequestOptions) { image, _ in
                        guard let image = image else {
                            return
                        }
                        let phImage = PHImage(asset: asset, image: image)
                        observable.onNext(phImage)
                        observable.onCompleted()
                    }
                    return Disposables.create()
                    
                }
            }.toArray()
            .asObservable()
    }
}
