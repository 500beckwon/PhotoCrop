//
//  PHPhotoLibrary+Extension.swift
//  PhotoCrop
//
//  Created by ByungHoon Ann on 2023/02/01.
//

import Photos
import RxSwift

extension PHPhotoLibrary {
    static var authorize: Observable<Bool> {
        return Observable.create { observable in
            var isAuthorization = false
            if #available(iOS 14.0, *) {
                isAuthorization = authorizationStatus() == .authorized || authorizationStatus() == .limited
                
            } else {
                if authorizationStatus() == .authorized {
                    isAuthorization = true
                } else {
                    requestAuthorization { status in
                        
                        observable.onNext(status == .authorized)
                        observable.onCompleted()
                    }
                }
            }
            defer {
                observable.onNext(isAuthorization)
                observable.onCompleted()
            }
            return Disposables.create()
        }
    }
}
