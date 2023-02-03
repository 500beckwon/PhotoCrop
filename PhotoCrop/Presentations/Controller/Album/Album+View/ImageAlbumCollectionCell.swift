//
//  ImageAlbumCollectionCell.swift
//  PhotoCrop
//
//  Created by ByungHoon Ann on 2023/02/03.
//

import UIKit
import RxSwift

final class ImageAlbumCollectionCell: UICollectionViewCell, BasicViewDrawRule {
    
    private var imageView = UIImageView()
    private var titleLabel   = UILabel()
    private let disposeBag = DisposeBag()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        insertUI()
        basicSetUI()
        anchorUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
    }
    
    func configureCell(item assetAlbum: AssetAlbum) {
        imageView.fetchImageAsset(assetAlbum.asset, targetSize: CGSize(width: 100, height: 100))
        titleLabel.text = "\(assetAlbum.albumTitle)(\(assetAlbum.count))"
    }
    
    func insertUI() {
        [imageView,
         titleLabel]
            .forEach {
                contentView.addSubview($0)
            }
    }
    
    func basicSetUI() {
        contentViewBasicSet()
        imageViewBasicSet()
        titleLabelBasicSet()
    }
    
    func anchorUI() {
        imageViewAnchor()
        titleLabelAnchor()
    }
}

private extension ImageAlbumCollectionCell {
    func contentViewBasicSet() {
        contentView.backgroundColor = .white
    }
    
    func imageViewBasicSet() {
        imageView.backgroundColor = .blue
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 30
    }
    func titleLabelBasicSet() {
        titleLabel.textAlignment = .left
        titleLabel.font = .boldSystemFont(ofSize: 14)
        titleLabel.backgroundColor = .clear
        titleLabel.textColor = .black
    }
    
    func imageViewAnchor() {
        imageView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalTo(30)
            $0.width.height.equalTo(60)
        }
    }
    
    func titleLabelAnchor() {
        titleLabel.snp.makeConstraints {
            $0.centerY.equalTo(imageView)
            $0.leading.equalTo(imageView.snp.trailing).offset(30)
        }
    }
}
