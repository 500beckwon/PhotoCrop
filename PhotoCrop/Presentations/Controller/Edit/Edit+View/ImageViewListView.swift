//
//  ImageViewListView.swift
//  PhotoCrop
//
//  Created by ByungHoon Ann on 2023/02/01.
//

import UIKit
import RxSwift
import RxCocoa

final class ImageViewListView: UIView {
    private var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 0.5
        layout.minimumInteritemSpacing = 0.5
        let itemWidth = screenWidth/4 - 1
        layout.itemSize = CGSize(width: itemWidth, height: itemWidth)
        let cView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        return cView
    }()
    
    private let disposeBag = DisposeBag()
    private let cellID = ImageListCollectionCell.reuseIdentifier
    
    let assetList = PublishRelay<[PHImage]>()
    let itemSelected = PublishRelay<PHImage>()
    let showFirstItem = PublishRelay<PHImage>()

    init() {
        super.init(frame: .zero)
        insertUI()
        basicSetUI()
        anchorUI()
        bindUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension ImageViewListView {
    func bindUI() {
        
        assetList
            .do(onNext: { [weak self] in
                guard let firstItem = $0.first else { return }
                
                self?.showFirstItem.accept(firstItem)
            })
            .bind(to: collectionView.rx
                .items(cellIdentifier: cellID,
                       cellType: ImageListCollectionCell.self)) { index, item, cell in
                cell.configureCell(phImage: item)
            }.disposed(by: disposeBag)
        
        collectionView.rx
            .modelSelected(PHImage.self)
            .bind(to: itemSelected)
            .disposed(by: disposeBag)
    }
}

extension ImageViewListView {
    func insertUI() {
        addSubview(collectionView)
    }
    
    func basicSetUI() {
        collectionViewBasicSet()
    }
    
    func anchorUI() {
        collectionViewAnchor()
    }
    
    func collectionViewAnchor() {
        collectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    func collectionViewBasicSet() {
        collectionView.registerCell(ImageListCollectionCell.self)
    }
}
