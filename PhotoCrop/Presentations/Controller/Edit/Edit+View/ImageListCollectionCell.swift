//
//  ImageListCollectionCell.swift
//  PhotoCrop
//
//  Created by ByungHoon Ann on 2023/02/01.
//

import UIKit

final class ImageListCollectionCell: UICollectionViewCell {
    private var imageView = UIImageView()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        insertUI()
        basicSetUI()
        anchorUI()
    }
    
    func configureCell(phImage: PHImage) {
        imageView.image = phImage.image
    }
}

extension ImageListCollectionCell: BasicViewDrawRule {
    func insertUI() {
        contentView.addSubview(imageView)
    }
    
    func basicSetUI() {
        imageView.backgroundColor = .clear
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
    }
    
    func anchorUI() {
        imageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}
