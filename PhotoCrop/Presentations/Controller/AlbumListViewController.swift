//
//  AlbumListViewController.swift
//  PhotoCrop
//
//  Created by ByungHoon Ann on 2023/02/02.
//

import UIKit
import Photos
import RxSwift
import RxCocoa

final class AlbumListViewController: UIViewController, BasicViewDrawRule {
    private var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.itemSize = CGSize(width: screenWidth, height: 75)
        layout.minimumLineSpacing = 0
        layout.minimumLineSpacing = 0
        layout.sectionInset = .zero
        let cView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        return cView
    }()
    
    private let disposeBag = DisposeBag()
    
    let assetList = PublishRelay<[AssetAlbum]>()
    
    init() {
        super.init(nibName: nil, bundle: nil)
        
        assetList
            .bind(to: collectionView.rx.items(cellIdentifier: "TestAlbumCollectionCell",
                                              cellType: TestAlbumCollectionCell.self)) { index, item, cell in
                
                cell.configureCell(item: item)
            }.disposed(by: disposeBag)
        
        collectionView.rx
            .modelSelected(AssetAlbum.self)
            .subscribe(onNext: { _ in
                self.dismiss(animated: true)
            }).disposed(by: disposeBag)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        insertUI()
        basicSetUI()
        anchorUI()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        PHAssetManager.shared
            .getPHAssetAlbumList()
            .bind(to: assetList)
            .disposed(by: disposeBag)
    }
    
    func insertUI() {
        view.addSubview(collectionView)
    }
    
    func basicSetUI() {
        viewBasicSet()
        collectionViewBasicSet()
    }
    
    func anchorUI() {
        collectionViewAnchor()
    }
    
    func viewBasicSet() {
        view.backgroundColor = .white
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
