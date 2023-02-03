//
//  Photos.swift
//  PhotoCrop
//
//  Created by ByungHoon Ann on 2023/01/30.
//

import Photos
import RxDataSources

struct Photos {
    public var albums: [PHAsset]
}

extension Photos: SectionModelType {
    init(original: Photos, items: [PHAsset]) {
        self = original
        albums = items
    }
    
    var items: [PHAsset] {
        return albums
    }
}

struct AlbumItem {
    var fetchResult: PHFetchResult<PHAsset>
}
