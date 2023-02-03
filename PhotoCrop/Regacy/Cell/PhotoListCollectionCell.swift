//
//  PhotoListCollectionCell.swift
//  PhotoCrop
//
//  Created by ByungHoon Ann on 2023/01/30.
//

import UIKit
import Photos
// import Gifu

class PhotoListCollectionCell: UICollectionViewCell {
    var phAsset: PHAsset?
    var preViewMode = false
    var id: String?
    var photo: String? {
        didSet {
            if let _urlString = photo {
                cachingImage(_urlString, id: id)
            }
        }
    }
    
    var selectedView = UIView()
    var imageView = UIImageView()
    var pictureVersionLabel = UILabel()
    var selectButton = UIButton(type: .system)
    var pictureRatioImageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .white
        insertUI()
        anchorUI()
        basicSetUI()
    }

    func insertUI() {
        contentView.addSubview(imageView)
        contentView.addSubview(selectedView)
        contentView.addSubview(selectButton)
        contentView.addSubview(pictureVersionLabel)
        contentView.addSubview(pictureRatioImageView)
    }
    
    func anchorUI() {
        imageViewAnchor()
        selectedViewAnchor()
        selectedButtonAnchor()
        pictureVersionLabelAnchor()
        pictureRatioImageViewAnchor()
    }
    
    func basicSetUI() {
        selectedButtonBasicSet()
        imageViewBasicSet()
        pictureVersionLabelBasicSet()
        pictureRatioImageViewBasicSet()
    }
    
    func imageViewBasicSet() {
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
    }
    
    func selectedViewBasicSet() {
        selectedView.alpha = 0.6
        selectedView.isHidden = true
        selectedView.backgroundColor = .clear
    }
    
    func selectedButtonBasicSet() {
        selectButton.isHidden = SelectedIndex.shared.isHidden
        selectButton.setTitleColor(.white, for: .selected)
        selectButton.clipsToBounds = true
        selectButton.titleLabel?.backgroundColor = .blue
        selectButton.tintColor = .blue
        selectButton.backgroundColor = .lightGray
        selectButton.alpha = 0.7
    }
    
    func pictureRatioImageViewBasicSet() {
        // pictureRatioImageView.backgroundColor = .tutorialBlack
        pictureRatioImageView.layer.cornerRadius = 4.5
        pictureRatioImageView.clipsToBounds = true
        pictureRatioImageView.contentMode = .scaleAspectFill
        pictureRatioImageView.backgroundColor = .clear
    }
    
    func pictureVersionLabelAnchor() {
        pictureVersionLabel.snp.makeConstraints { make in
            make.top.left.equalTo(contentView)
            make.height.equalTo(18)
        }
    }
    
    func pictureVersionLabelBasicSet() {
        pictureVersionLabel.textColor = .white
        pictureVersionLabel.backgroundColor = .black
        pictureVersionLabel.font = .boldSystemFont(ofSize: 9)
    }
    
    func imageViewAnchor() {
        imageView.snp.makeConstraints { make in
            make.top.left.right.bottom.equalTo(contentView)
        }
    }
    
    func selectedViewAnchor() {
        selectedView.snp.makeConstraints { make in
            make.top.left.right.bottom.equalTo(contentView)
        }
    }
    
    func selectedButtonAnchor() {
        selectButton.snp.makeConstraints { make in
            make.top.equalTo(contentView).offset(2)
            make.right.equalTo(contentView).offset(-1)
            make.width.height.equalTo(18)
        }
    }
    
    func pictureRatioImageViewAnchor() {
        pictureRatioImageView.snp.makeConstraints { make in
            make.top.equalTo(contentView).offset(2)
            make.right.equalTo(contentView).offset(-1)
            make.width.height.equalTo(18)
        }
    }
    
    override var isHighlighted: Bool {
        didSet {
            selectedView.isHidden = !isHighlighted
            selectButton.isHighlighted = isHighlighted
        }
    }

    override var isSelected: Bool {
        didSet {
            if isSelected == true {
                imageView.alpha = 0.6
            } else {
                imageView.alpha = 1.0
            }
            selectButton.isSelected = isSelected
            if selectButton.isSelected == true {
                selectButton.backgroundColor = .blue
            } else {
                selectButton.backgroundColor = .lightGray
            }
        }
    }

    func setupImageView() {
        contentView.addSubview(imageView)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        phAsset = nil
       // pictureVersionLabel.text = nil
    }
    
    func setDatas(asset: PHAsset, cachingImageManager: PHCachingImageManager) {
        let _screenWidth = CGSize(width: screenWidth/3 - 1, height: screenWidth/3 - 1)
        let options = PHImageRequestOptions()
        options.isSynchronous = true
        options.isNetworkAccessAllowed = false
        cachingImageManager.requestImage(for: asset,
                                         targetSize: _screenWidth,
                                         contentMode: .aspectFill,
                                         options: options) { image, _ in
            guard let _image = image else { return }
            if _image.size.width > _image.size.height {
              //  let ratio =  _image.size.height/_image.size.width
             //   let round = round(ratio * 100) / 100
                // self.pictureVersionLabel.text = "가로형사진 = \(round)"
               // ["SquareSegemnt", "SquareShot", "squareLong"]
                self.pictureRatioImageView.image = UIImage(named: "SquareShot")
            } else if _image.size.width < _image.size.height {
               // let ratio = _image.size.width/_image.size.height
               // let round = round(ratio * 100) / 100
                // self.pictureVersionLabel.text = "세로형사진 = \(round)"
                self.pictureRatioImageView.image = UIImage(named: "squareLong")
            } else if _image.size.width == _image.size.height {
                // self.pictureVersionLabel.text = "정방형사진"
                self.pictureRatioImageView.image = UIImage(named: "SquareSegemnt")
            }
            self.imageView.image = image
        }
    }

    func cachingImage(_ imageName: String, id: String?) {
       // let _id = id ?? ""
        if preViewMode == false {
                
        }
    }
}
