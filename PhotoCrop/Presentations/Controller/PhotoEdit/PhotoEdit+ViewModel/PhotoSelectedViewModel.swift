//
//  PhotoSelectedViewModel.swift
//  PhotoCrop
//
//  Created by ByungHoon Ann on 2023/02/03.
//

import Photos
import UIKit
import RxSwift
import RxCocoa


final class PhotoSelectedViewModel {
    struct Input {
        let editSelected: Observable<(PhotoCropType, PHImage)>
    }
    
    struct Output {
        let selectedReflect: Observable<PhotoEdit>
    }
    
    init() {
        
    }
    
    func transform(input: Input) -> Output {
        let edit = input.editSelected
            .map {
                PhotoEdit(true, $0.0, $0.1)
            }
        return Output(selectedReflect: edit)
    }
}
