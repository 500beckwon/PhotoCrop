//
//  InsetType.swift
//  PhotoCrop
//
//  Created by ByungHoon Ann on 2023/01/30.
//

import UIKit

enum PhotoCropType: Int, CaseIterable {
    case square = 0
    case horizontal
    case vertical
}

extension PhotoCropType {
    var curtainWidth: CGFloat {
        return screenWidth * 0.125
    }
    
    var image: UIImage? {
        switch self {
        case .square:
            return UIImage(named: "SquareSegemnt")
        case .horizontal:
            return UIImage(named: "SquareShot")
        case .vertical:
            return UIImage(named: "squareLong")
        }
    }
    var title: String {
        switch self {
        case .square:
            return "정"
        case .horizontal:
            return "가"
        case .vertical:
            return "세"
        }
    }
    
    var curtainHorizontalWidth: CGFloat {
        switch self {
        case .square, .horizontal:
            return 0
        case .vertical:
            return screenWidth * 0.125
        }
    }
    
    var curtainVerticalWidth: CGFloat {
        switch self {
        case .square, .vertical:
            return 0
        case .horizontal:
            return screenWidth * 0.125
        }
    }
    
    var convertCGImageSize: CGSize {
        switch self {
        case .square:
            return CGSize(width: 1080, height: 1080)
        case .horizontal:
            return CGSize(width: 1080, height: 810)
        case .vertical:
            return CGSize(width: 1080, height: 1440)
        }
    }
    
    var contentInset: UIEdgeInsets {
        let edge: UIEdgeInsets
        switch self {
        case .square:
            edge = .zero
        case .horizontal:
            edge = UIEdgeInsets(top: curtainWidth, left: 0, bottom: curtainWidth, right: 0)
        case .vertical:
            edge = UIEdgeInsets(top: 0, left: curtainWidth, bottom: 0, right: curtainWidth)
        }
        return edge
    }
    
    func scrollContentSize(imageSize: CGSize) -> CGSize {
        var size = CGSize(width: screenWidth, height: screenWidth)

        switch self {
        case .square:
            if imageSize.width > imageSize.height {
                size.width = screenWidth / (imageSize.height / imageSize.width)
            } else if imageSize.width < imageSize.height {
                size.height = screenWidth / (imageSize.width / imageSize.height)
            }
        case .horizontal:
            if imageSize.width > imageSize.height {
                size = CGSize(width: (screenWidth * 0.75) / (imageSize.height / imageSize.width),
                              height: (screenWidth * 0.75))
            } else if imageSize.width < imageSize.height {
                size.height = screenWidth / (imageSize.width / imageSize.height)
            }
        case .vertical:
            if imageSize.width > imageSize.height {
                size.width = screenWidth / (imageSize.height / imageSize.width)
            } else if imageSize.width < imageSize.height {
                size = CGSize(width: screenWidth * 0.75,
                              height:  (screenWidth * 0.75) / (imageSize.width / imageSize.height))
            }
        }
        return size
    }
    
    func cropScrollOrigin(imageSize: CGSize,
                          startPoint: CGPoint,
                          contentSize: CGSize
                         ) -> CGPoint {
        let xPadding = self == .vertical ? curtainWidth : 0
        let yPadding = self == .horizontal ? curtainWidth : 0
        
        let ratioX = (startPoint.x + xPadding)/contentSize.width
        let ratioY = (startPoint.y + yPadding)/contentSize.height
        
        let minX = ratioX * imageSize.width
        let minY = ratioY * imageSize.height
        
        return CGPoint(x: minX, y: minY)
    }
    
    func cropImageSize(imageSize: CGSize,
                       contentSize: CGSize,
                       zoomScale: CGFloat) -> CGSize {
        var sizeRatio: CGFloat = 1
        var width =  imageSize.width/zoomScale
        var height = imageSize.width/zoomScale
        switch self {
        case .square:
            if imageSize.width > imageSize.height {
                width = imageSize.height/zoomScale
                height = imageSize.height/zoomScale
            }
        case .horizontal:
            sizeRatio = screenWidth / (contentSize.width / zoomScale)
            
            if imageSize.width > imageSize.height {
                width = (imageSize.width * sizeRatio) / zoomScale
                height = (imageSize.height) / zoomScale
            } else {
                width =  imageSize.width/zoomScale
                height = (imageSize.width - imageSize.width/4)/zoomScale
            }
        case .vertical:
            sizeRatio = screenWidth / (contentSize.height / zoomScale)
            
            if imageSize.height > imageSize.width {
                height = imageSize.height * sizeRatio / zoomScale
                width =  (imageSize.width) / zoomScale
            } else {
                width =  (imageSize.height * 0.75) / zoomScale
                height = (imageSize.height) / zoomScale
            }
        }

        return CGSize(width: width, height: height)
    }

    func cropConvertRect(cropInfo: CropInformation) -> CGRect {
        var imageSize = cropInfo.selectedImage.size
        if imageSize.height > 2000 || imageSize.width > 2000 {
            imageSize.width /= 3
            imageSize.height /= 3
        }
        
        let point = cropScrollOrigin(imageSize: imageSize,
                                     startPoint: cropInfo.startPoint,
                                     contentSize: cropInfo.contentSize)
        
        let size = cropImageSize(imageSize: imageSize,
                                 contentSize: cropInfo.contentSize,
                                 zoomScale: cropInfo.zoomScale)

        return CGRect(origin: point, size: size)
    }
    
    func imageViewWidth() {
        
    }
}
