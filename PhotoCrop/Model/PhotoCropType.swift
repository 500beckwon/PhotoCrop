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
    
    func scrollContentSize(image: UIImage) -> CGSize {
        var size = CGSize(width: screenWidth, height: screenWidth)
        let imageSize = image.size
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
    
    func imageViewWidth() {
        
    }
}
