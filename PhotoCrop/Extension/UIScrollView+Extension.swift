//
//  UIScrollView+Extension.swift
//  PhotoCrop
//
//  Created by ByungHoon Ann on 2023/02/03.
//

import UIKit

extension UIScrollView {
    func scrollCentering(inset: UIEdgeInsets) {
        let centerOffsetX = (contentSize.width - frame.size.width) / 2
        let centerOffsetY = (contentSize.height - frame.size.height) / 2
        let centerPoint = CGPoint(x: centerOffsetX, y: centerOffsetY)
        setContentOffset(centerPoint, animated: false)
    }
}
