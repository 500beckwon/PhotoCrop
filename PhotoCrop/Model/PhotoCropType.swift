//
//  InsetType.swift
//  PhotoCrop
//
//  Created by ByungHoon Ann on 2023/01/30.
//

import Foundation

enum PhotoCropType: Int, CaseIterable {
    case square = 0
    case horizontal
    case vertical
}

extension PhotoCropType {
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
}
