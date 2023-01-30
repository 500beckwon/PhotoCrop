//
//  UIView+Extension.swift
//  PhotoCrop
//
//  Created by ByungHoon Ann on 2023/01/30.
//

import UIKit

extension UIView {
    func getTargetSize(currentWidth: Int, currentHeight: Int) -> CGSize {
        var width = currentWidth
        var height = currentHeight
        if width > height {
            width = Int(CGFloat(1080))
            height = Int(CGFloat(810))
        } else if width < height {
            width = Int(CGFloat(1080))
            height = Int(CGFloat(1440))
        } else {
            width = Int(CGFloat(1080))
            height = Int(CGFloat(1080))
        }
        return CGSize(width: width, height: height)
    }
    
}
