//
//  Extension+PhotoEditViewController.swift
//  PhotoCrop
//
//  Created by ByungHoon Ann on 2023/01/30.
//

import UIKit
import RxSwift

extension PhotoEditViewController {
    func insertUI() {
        view.addSubview(editingScrollView)
        view.addSubview(topView)
        editingScrollView.addSubview(scrllImageView)
        view.addSubview(leftView)
        view.addSubview(rightView)
        view.addSubview(photoListView)
        view.addSubview(bottomView)
        view.addSubview(cropPostButton)
        view.addSubview(rotateButton)
        view.addSubview(photoAlbumListView)
    }
    
    func basicSetUI() {
        photoListView.delegate = self
        popButtonBasicSet()
        editScrollViewBasicSet()
        cropPostButtonBasicSet()
        wallViewBasicSet()
        cutPhotoBasicSet()
        photoAlbumListViewBasicSet()
        rotateButtonBasicSet()
        centerNavigationBarButtonBasicSet()
    }
    
    func anchorUI() {
        editScrollViewAnchor()
        imageViewAnchor()
        rightWallAnchor()
        leftWallAnchor()
        topWallAnchor()
        photoListViewAnchor()
        bottomViewAnchor()
        cropPostButtonAnchor()
        rotateButtonAnchor()
        photoAlbumListViewAnchor()
    }
    
    func rightWallAnchor() {
        rightView.snp.makeConstraints { make in
            make.top.right.equalTo(view.safeAreaLayoutGuide)
            make.height.equalTo(screenWidth)
            make.width.equalTo(0)
        }
    }
    
    func topWallAnchor() {
        topView.snp.makeConstraints { make in
            make.top.equalTo(view.snp.topMargin)
            make.left.trailing.equalTo(view)
            make.height.equalTo(0)
        }
    }
    
    func bottomViewAnchor() {
        bottomView.snp.makeConstraints { make in
            make.left.right.equalTo(view)
            make.bottom.equalTo(photoListView.snp.top)
            make.height.equalTo(0)
        }
    }
    
    func leftWallAnchor() {
        leftView.snp.makeConstraints { make in
            make.top.left.equalTo(view.safeAreaLayoutGuide)
            make.height.equalTo(screenWidth)
            make.width.equalTo(0)
        }
    }
    
    func editScrollViewAnchor() {
        editingScrollView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.left.right.equalTo(view)
            scrollViewHeight = make.height.equalTo(screenWidth).constraint
        }
    }
    
    func imageViewAnchor() {
        scrllImageView.snp.makeConstraints { make in
            make.top.left.right.bottom.equalTo(editingScrollView)
            imageViewWidth = make.width.equalTo(screenWidth).constraint
            imageViewHeight = make.height.equalTo(screenWidth).constraint
        }
    }
    
    func photoListViewAnchor() {
        photoListView.snp.makeConstraints { make in
            make.top.equalTo(editingScrollView.snp.bottom)
            make.left.right.bottom.equalTo(view)
        }
    }
    
    func cropPostButtonAnchor() {
        cropPostButton.snp.makeConstraints { make in
            make.right.equalTo(view).offset(-18)
            make.bottom.equalTo(photoListView.snp.top).offset(-25)
            make.width.equalTo(140)
            make.height.equalTo(36)
        }
    }
    
    func rotateButtonAnchor() {
        rotateButton.snp.makeConstraints { make in
            make.left.equalTo(view).offset(18)
            make.bottom.equalTo(photoListView.snp.top).offset(-25)
            make.width.equalTo(36)
            make.height.equalTo(36)
        }
    }
    
    func photoAlbumListViewAnchor() {
        photoAlbumListView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.left.right.equalTo(view)
            albumListConstraint = make.height.equalTo(0).constraint
        }
    }
    
    func cropPostButtonBasicSet() {
        cropPostButton.delegate = self
    }
    
    func photoAlbumListViewBasicSet() {
        photoAlbumListView.isHidden = true
        photoAlbumListView.delegate = self
    }
    
    func centerNavigationBarButtonBasicSet() {
        let titleView = UIView(frame: CGRect(x: 0, y: 0, width: 120, height: 40))
        comboImageView.frame = CGRect(x: 85, y: 10, width: 20, height: 20)
        comboImageView.image = UIImage(named: "Combo")
        comboImageView.contentMode = .scaleAspectFill
       
        titleButton.frame = CGRect(x: 10, y: 0, width: 100, height: 40)
        titleButton.backgroundColor = .clear
        titleButton.tintColor = .clear
        
        titleButton.setTitle("갤러리", for: .normal)
        titleButton.setTitle("앨범선택", for: .selected)
        titleButton.titleLabel?.font = .boldSystemFont(ofSize: 14)
        titleButton.setTitleColor(.black, for: .normal)
        titleButton.setTitleColor(.black, for: .selected)
        titleButton.layer.cornerRadius = 10
        titleButton.clipsToBounds = true
        titleButton.addTarget(self, action: #selector(showAlbum), for: .touchUpInside)
        titleView.addSubview(titleButton)
        titleView.addSubview(comboImageView)
        navigationItem.titleView = titleView
        comboImageView.transform = CGAffineTransform(rotationAngle: .pi)
    }
    
    @objc func showAlbum(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        var piRoatate: CGFloat = 0
        var height: CGFloat = 0
        switch sender.isSelected {
        case true:
            if photoAlbumListView.albums.isEmpty == true {
                photoAlbumListView.getAlbumList()
            }
            height = CGFloat(photoAlbumListView.albums.count * 75)
            if height > screenHeight - 75 {
                let barHeight = navigationController?.navigationBar.frame.height ?? 44
                height = screenHeight - barHeight
            }
            photoAlbumListView.isHidden = false
            piRoatate = (.pi * 2)
        case false:
            piRoatate = .pi
        }
        albumListConstraint?.update(offset: height)
        UIView.animate(withDuration: 0.3) { [weak self] in
            guard let self = self else { return }
            self.comboImageView.transform = CGAffineTransform(rotationAngle: piRoatate)
            self.view.layoutIfNeeded()
        }
    }
     
    func popButtonBasicSet() {
        backButton.setImage(UIImage(named: "chevron-left"), for: .normal)
        backButton.frame = CGRect(x: 18, y: 0, width: 36, height: 36)
        backButton.backgroundColor = .clear
        backButton.addTarget(self, action: #selector(touchPopButtonEvent), for: .touchUpInside)
        let barButton = UIBarButtonItem(customView: backButton)
        navigationItem.leftBarButtonItem = barButton
    }
    
    @objc func touchPopButtonEvent() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func rotateImage() {
        guard let originalImage = scrllImageView.image else { return }
        let rotateImage = originalImage.rotate(radians: .pi/2)
        scrllImageView.image = rotateImage
        resizeDidSelected(imageSize: rotateImage.size, scrollCenter: true)
    }
    
    func scrollImageViewBasicSet() {
        scrllImageView.contentMode = .scaleAspectFill
        scrllImageView.clipsToBounds = true
    }
    
    func editScrollViewBasicSet() {
        editingScrollView.backgroundColor = .lightGray
        editingScrollView.minimumZoomScale = 1.0
        editingScrollView.maximumZoomScale = 3.0
        editingScrollView.delegate = self
        editingScrollView.bounces = true
        editingScrollView.showsVerticalScrollIndicator = false
        editingScrollView.showsHorizontalScrollIndicator = false
    }
    
    func wallViewBasicSet() {
        topView.backgroundColor = .lightGray
        leftView.backgroundColor = .lightGray
        rightView.backgroundColor = .lightGray
        bottomView.backgroundColor = .lightGray
    }
    
    func cutPhotoBasicSet() {
        cutPhotoButton.setImage(UIImage(named: "ic-Check"), for: .normal)
        cutPhotoButton.setTitle("자르기", for: .normal)
        cutPhotoButton.frame.size = CGSize(width: 36, height: 36)
        cutPhotoButton.addTarget(self, action: #selector(cutPhotoEvent), for: .touchUpInside)
        let barButtonItem = UIBarButtonItem(customView: cutPhotoButton)
        navigationItem.rightBarButtonItem = barButtonItem
    }
    
    func rotateButtonBasicSet() {
        rotateButton.setImage(UIImage(named: "rotate-cw"), for: .normal)
        rotateButton.clipsToBounds = true
        rotateButton.backgroundColor = .black
        rotateButton.layer.cornerRadius = 18
        rotateButton.addTarget(self, action: #selector(rotateImage), for: .touchUpInside)
        rotateButton.alpha = 0.5
    }
    
    // MARK: - 사진 유니티 전송
    
    @objc func cutPhotoEvent(_ sender: UIButton) {
        guard let image = scrllImageView.image else { return }
     
        let photoRatio = getRatio(selectedIndex)
        let now = "Time"
        if aleadyImage != "", aleadyNumber != nil {
            let number = aleadyNumber ?? 0
            CropImageManager.shared.images.remove(at: number)
            CropImageManager.shared.ratios.remove(at: number)
            CropImageManager.shared.imageNames.remove(at: number)
        }
        
        CropImageManager.shared.ratios.append(photoRatio)
        CropImageManager.shared.imageNames.append("\(now)")
        CropImageManager
            .shared
            .sendResizeImage(s3Upload: false,
                             image: image,
                            
                             time: now,
                             segment: selectedIndex,
                             scroll: editingScrollView.bounds,
                             contentViewFrame: scrllImageView.frame,
                             zoomScale: editingScrollView.zoomScale) { image in
                let vc = CutResultViewController(image: image)
                self.navigationController?.pushViewController(vc, animated: true)
            }
    }
    
    // MARK: - 비율 String 반환
    
    func getRatio(_ segmnetCount: Int) -> String {
        switch segmnetCount {
        case 0  : return "square"
        case 1  : return "horizontal"
        case 2  : return "vertical"
        default : return "square"
        }
    }
}

extension PhotoEditViewController: PhotoCustomAlbumViewDelegate {
    func didSelectedAlbum(album: AlbumList) {
        let photo = Photos(albums: album.album)
        photoListView.photos = [photo]
        photoListView.subject.accept([photo])
        albumListConstraint?.update(inset: 0)
        titleButton.isSelected = false
        titleButton.backgroundColor = .white
        comboImageView.transform = CGAffineTransform(rotationAngle: .pi)
        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()
        }
    }
}
