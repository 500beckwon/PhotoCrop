//
//  PhotoListViewController.swift
//  PhotoCrop
//
//  Created by ByungHoon Ann on 2023/02/01.
//

import UIKit
import RxSwift
import Photos
import SnapKit

final class PhotoListViewController: UIViewController {
    var photoView = PhotoSelectView()
    var photoListView = ImageViewListView()
    var albumListView = ImageAlbumListView()
    var editButton = UIButton(type: .system)
    var albumButton = UIButton(type: .system)
    
    private let disposeBag = DisposeBag()
    
    var albumListViewHeight: Constraint?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        insertUI()
        basicSetUI()
        anchorUI()
        
        photoListView.itemSelected
            .bind(to: photoView.showImage)
            .disposed(by: disposeBag)
    }
}

extension PhotoListViewController: BasicViewDrawRule {
    func insertUI() {
        [
            photoView,
            photoListView
          //  albumListView
        ]
            .forEach {
                view.addSubview($0)
            }
    }
    
    func basicSetUI() {
        viewBasicSet()
        editButtonBasicSet()
        albumButtonBasicSet()
        photoViewBasicSet()
        photoListViewBasicSet()
        albumListViewBasicSet()
    }
    
    func anchorUI() {
        photoViewAnchor()
        photoListViewAnchor()
    }
}

private extension PhotoListViewController {
    @objc func albumButtonTapped(_ sender: UIButton) {
       let vc = AlbumListViewController()
        vc.modalPresentationStyle = .overFullScreen
        present(vc, animated: true)
    }
    
    @objc func editButtonTapped(_ sender: UIButton) {
        let time = ""
        
        guard let image = self.photoView.image else { return }
        CropImageManager
            .shared
            .sendResizeImage(s3Upload: false,
                             image: image,
                             
                             time: time,
                             segment: photoView.type.rawValue,
                             scroll: photoView.scrollBounds,
                             contentViewFrame: photoView.imageViewFrame,
                             zoomScale: photoView.zoomScale ) { image in
                let vc = CutResultViewController(image: image)
                self.navigationController?.pushViewController(vc, animated: true)
            }
    }
}

private extension PhotoListViewController {
    func viewBasicSet() {
        view.backgroundColor = .white
    }
    
    func editButtonBasicSet() {
        editButton.setTitle("자르기", for: .normal)
        editButton.addTarget(self, action: #selector(editButtonTapped), for: .touchUpInside)
        let barButton = UIBarButtonItem(customView: editButton)
        navigationItem.rightBarButtonItem = barButton
    }
    
    func albumButtonBasicSet() {
        albumButton.setTitle("앨범선택", for: .normal)
        albumButton.setTitle("어쩌구", for: .selected)
        albumButton.tintColor = .clear
        albumButton.setTitleColor(.black, for: .normal)
        albumButton.addTarget(self, action: #selector(albumButtonTapped), for: .touchUpInside)
        navigationItem.titleView = albumButton
    }
    
    func photoViewBasicSet() {
        
    }
    
    func photoListViewBasicSet() {
        
    }
    
    func albumListViewBasicSet() {
       // albumListView.isHidden = true
    }
    
    func photoViewAnchor() {
        photoView.snp.makeConstraints {
            $0.leading.top.trailing.equalTo(view.safeAreaLayoutGuide)
            $0.height.equalTo(screenWidth)
        }
    }
    
    func photoListViewAnchor() {
        photoListView.snp.makeConstraints {
            $0.top.equalTo(photoView.snp.bottom)
            $0.leading.trailing.equalTo(view.safeAreaInsets)
            $0.bottom.equalTo(view)
        }
    }
    
    func albumListViewAnchor() {
        albumListView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.leading.trailing.equalTo(view)
            albumListViewHeight = $0.height.equalTo(0).constraint
        }
    }
}
