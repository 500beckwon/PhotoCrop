//
//  ImageAlbumListView.swift
//  PhotoCrop
//
//  Created by ByungHoon Ann on 2023/02/02.
//

import UIKit
import Photos
import RxSwift
import RxCocoa

final class ImageAlbumListView: BasicView {
    
    var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.itemSize = CGSize(width: screenWidth, height: 75)
        layout.minimumLineSpacing = 0
        layout.minimumLineSpacing = 0
        layout.sectionInset = .zero
        let cView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        return cView
    }()
    
    let disposeBag = DisposeBag()
    let assetList = PublishRelay<[AssetAlbum]>()
    
    init() {
        super.init(frame: .zero)
        
        assetList
            .bind(to: collectionView.rx.items(cellIdentifier: "TestAlbumCollectionCell",
                                              cellType: TestAlbumCollectionCell.self)) { index, item, cell in
                
                cell.configureCell(item: item)
            }.disposed(by: disposeBag)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        PHAssetManager.shared
            .getPHAssetAlbumList()
            .bind(to: assetList)
            .disposed(by: disposeBag)
    }
    
    override func insertUI() {
        addSubview(collectionView)
    }
    
    override func basicSetUI() {
        collectionViewBasicSet()
    }
    
    override func anchorUI() {
        collectionViewAnchor()
    }
    
    func collectionViewBasicSet() {
        
        collectionView.backgroundColor = .clear
        collectionView.registerCell(TestAlbumCollectionCell.self)
    }
    
    func collectionViewAnchor() {
        collectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}


final class TestAlbumCollectionCell: UICollectionViewCell, BasicViewDrawRule {
    
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

private extension TestAlbumCollectionCell {
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
