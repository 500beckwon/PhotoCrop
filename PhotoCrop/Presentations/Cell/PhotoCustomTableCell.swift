//
//  PhotoCustomTableCell.swift
//  PhotoCrop
//
//  Created by ByungHoon Ann on 2023/01/30.
//

import UIKit
import Photos

final class PhotoCustomTableCell: UITableViewCell {
    private let imageManager = PHCachingImageManager()
    
    var albumList: AlbumList? {
        didSet {
            guard let album = albumList else { return }
            cachingPhasset(asset: album)
        }
    }
    
    var recentImageView = UIImageView()
    var albumTitleLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        insertUI()
        basicSetUI()
        anchorUI()
        selectionStyle = .none
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension PhotoCustomTableCell {
    func insertUI() {
        contentView.addSubview(recentImageView)
        contentView.addSubview(albumTitleLabel)
    }
    
    func basicSetUI() {
        recentImageViewBasicSet()
        albumTitleLabelBasicSet()
    }
    
    func anchorUI() {
        recentImageViewAnchor()
        albumTitleLabelAnchor()
    }
    
    func recentImageViewAnchor() {
        recentImageView.snp.makeConstraints { make in
            make.centerY.equalTo(contentView)
            make.left.equalTo(30)
            make.width.height.equalTo(60)
        }
    }
    
    func albumTitleLabelAnchor() {
        albumTitleLabel.snp.makeConstraints { make in
            make.centerY.equalTo(recentImageView)
            make.left.equalTo(recentImageView.snp.right).offset(30)
            make.height.equalTo(25)
        }
    }
    
    func recentImageViewBasicSet() {
        recentImageView.layer.cornerRadius = 22
        recentImageView.backgroundColor = .clear
        recentImageView.clipsToBounds = true
        recentImageView.contentMode = .scaleAspectFill
        recentImageView.isUserInteractionEnabled = false
    }
    
    func albumTitleLabelBasicSet() {
        albumTitleLabel.textColor = .black
        albumTitleLabel.textAlignment = .left
        albumTitleLabel.backgroundColor = .clear
        albumTitleLabel.font = .boldSystemFont(ofSize: 14)
    }
    
    func cachingPhasset(asset: AlbumList) {
        albumTitleLabel.text = "\(albumList?.title ?? "")(\(asset.count))"
        if asset.album.isEmpty == false {
            setDatas(asset: asset.album[0])
        }
    }
    
    func setDatas(asset: PHAsset) {
        let options = PHImageRequestOptions()
        let imageManager = PHImageManager.default()
        options.isSynchronous = true
        options.resizeMode = .none
        let _screenWidth = CGSize(width: 60, height: 60)
        imageManager.requestImage(for: asset,
                                  targetSize: _screenWidth,
                                  contentMode: .aspectFill,
                                  options: nil) { [weak self] image, _ in
            self?.recentImageView.image = image
        }
    }
}
