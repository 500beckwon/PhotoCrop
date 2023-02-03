//
//  CropInformation.swift
//  PhotoCrop
//
//  Created by ByungHoon Ann on 2023/02/03.
//

import UIKit

protocol CropInformation {
    var imageName: String { get }
    var selectedImage: UIImage { get }
    var cropType: PhotoCropType { get }
    var startPoint: CGPoint { get }
    var contentSize: CGSize { get }
    var zoomScale: CGFloat { get }
}

struct CropInfo: CropInformation {
    let imageName: String
    let selectedImage: UIImage
    let cropType: PhotoCropType
    let startPoint: CGPoint
    let contentSize: CGSize
    let zoomScale: CGFloat
    
    init(imageName: String = "",
         selectedImage: UIImage = UIImage(),
         cropType: PhotoCropType = .square,
         startPoint: CGPoint = .zero,
         contentSize: CGSize = CGSize(width: screenWidth, height: screenWidth),
         zoomScale: CGFloat = 1) {
        self.imageName = imageName
        self.selectedImage = selectedImage
        self.cropType = cropType
        self.startPoint = startPoint
        self.contentSize = contentSize
        self.zoomScale = zoomScale
    }
}
