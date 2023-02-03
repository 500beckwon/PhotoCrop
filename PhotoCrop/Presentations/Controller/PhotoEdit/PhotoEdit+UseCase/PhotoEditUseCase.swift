//
//  PhotoEditUseCase.swift
//  PhotoCrop
//
//  Created by ByungHoon Ann on 2023/02/03.
//

import Photos
import RxSwift

protocol PhotoEditUseCase: AnyObject {
    func selectedAlbumConvert(album: [PHAsset]) -> Observable<[PHImage]>
    func cropRequest(cropInfo: CropInformation) -> Observable<UIImage?>
}

final class PhotoEditUseCaseImpl: PhotoEditUseCase {
    func selectedAlbumConvert(album: [PHAsset]) -> Observable<[PHImage]> {
        guard !album.isEmpty else { return Observable.just([]) }
        return PHAssetManager.shared.getImageList(assetList: album)
    }
    
    func cropRequest(cropInfo: CropInformation) -> Observable<UIImage?> {
        return CropImageManager.shared.newCrop(cropInfo: cropInfo)
    }
}
