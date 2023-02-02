//
//  CropButton.swift
//  PhotoCrop
//
//  Created by ByungHoon Ann on 2023/01/31.
//

import UIKit
import RxSwift
import RxCocoa

final class CropButton: UIButton {
    var photoCropType: PhotoCropType
    
    init(_ photoCropType: PhotoCropType = .square) {
        self.photoCropType = photoCropType
        super.init(frame: CGRect(origin: .zero, size: CGSize(width: 36, height: 36)))
        basicSetUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
     //   setImage(photoCropType.image, for: .normal)
        setTitle(photoCropType.title, for: .normal)
        setTitle(photoCropType.title + "?!", for: .selected)
    }
    
    func basicSetUI() {
        backgroundColor = .black.withAlphaComponent(0.5)
        clipsToBounds = true
    }
}

extension Reactive where Base: CropButton {
    var photoCropTap: ControlProperty<PhotoCropType> {
        return base.rx.controlProperty(editingEvents: .touchUpInside) { base in
            return base.photoCropType
        } setter: { base, catchValue in
        }
    }
}
