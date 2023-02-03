//
//  PhotoEditViewModel.swift
//  PhotoCrop
//
//  Created by ByungHoon Ann on 2023/02/03.
//

import Photos
import UIKit
import RxCocoa
import RxSwift

final class PhotoEditViewModel {
    struct Input {
        let photoSelected: Observable<PHImage>
        let albumSelected: Observable<AssetAlbum>
        let cropRequest: Observable<CropInformation>
    }
    
    struct Output {
        let photoSelected: Observable<PHImage>
        let albumSelected: Observable<[PHImage]>
        let cropResult: Observable<UIImage>
    }
    
    let selectedViewModel: PhotoSelectedViewModel
    let useCase: PhotoEditUseCase
    
    init(
        selectedViewModel: PhotoSelectedViewModel = PhotoSelectedViewModel(),
        useCase: PhotoEditUseCase = PhotoEditUseCaseImpl()
    ) {
        self.selectedViewModel = selectedViewModel
        self.useCase = useCase
    }
    
    func transform(input: Input) -> Output {
        let photoSelected = input.photoSelected
        let albumSelected = input.albumSelected.flatMap { [weak self] assetAlbum -> Observable<[PHImage]> in
            guard let self = self else { return .never() }
            return self.useCase.selectedAlbumConvert(album: assetAlbum.phAssetCollection)
        }
        
        let cropResult = input.cropRequest.flatMap { [weak self] cropInfo -> Observable<UIImage> in
            guard let self = self else { return .never() }
            return self.useCase.cropRequest(cropInfo: cropInfo).map { $0 ?? UIImage() }
        }
        
        return Output(photoSelected: photoSelected,
                      albumSelected: albumSelected,
                      cropResult: cropResult)
    }
}
 
