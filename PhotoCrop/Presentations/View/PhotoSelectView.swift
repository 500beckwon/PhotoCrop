//
//  PhotoSelectView.swift
//  PhotoCrop
//
//  Created by ByungHoon Ann on 2023/01/31.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class PhotoSelectView: UIView {
    
    private let curtainWidth = screenWidth * 0.25
    
    private lazy var leadingView = UIView()
    private lazy var topView = UIView()
    private lazy var trailingView = UIView()
    private lazy var bottomView = UIView()
    
    private lazy var imageView = UIImageView()
    private lazy var scrollView = UIScrollView()
    
    private lazy var rotateButton = UIButton()
    private lazy var cropTypeSelectButton = PhotoCropTypeButton()
    
    private var imageViewWidth: Constraint?
    private var imageViewHeight: Constraint?
    
    private let disposeBag = DisposeBag()
    
    let testSize = CGSize(width: 1000, height: 3200)
    
    let showImage = PublishRelay<PHImage>()
    var type = PhotoCropType.square
    var image: UIImage? {
        return imageView.image
    }
    
    var scrollBounds: CGRect {
        return scrollView.bounds
    }
    
    var imageViewFrame: CGRect {
        return imageView.frame
    }
    
    var zoomScale: CGFloat {
        return scrollView.zoomScale
    }
    
    init() {
        super.init(frame: CGRect(x: 0, y: 0, width: screenWidth, height: screenWidth))
        insertUI()
        basicSetUI()
        anchorUI()
        bindUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    func bindUI() {
        Observable
            .combineLatest(cropTypeSelectButton.didSelectedCrop, showImage)
            .subscribe(onNext: { type, phImage in
                PHAssetManager.shared.getImage(asset: phImage.asset)
                    .do(onNext: {
                        guard let image = $0 else { return }
                        print(image.size)
                        self.resizingImageScrollView(image: image, type: type)
                        
                    }).bind(to: self.imageView.rx.image)
                        .disposed(by: self.disposeBag)

            }).disposed(by: disposeBag)
    }
    
    func resizingImageScrollView(image: UIImage, type: PhotoCropType) {
        self.type = type
        curtainLayout(type: type)
        let contentInset = type.contentInset
        let contentSize = type.scrollContentSize(image: image)
        let imageViewWidth = contentSize.width
        let imageViewHeight = contentSize.height

        scrollView.contentSize = contentSize
        scrollView.contentInset = contentInset
        self.imageViewWidth?.update(offset: imageViewWidth)
        self.imageViewHeight?.update(offset: imageViewHeight)
        //self.imageView.image = image
    }
}

extension PhotoSelectView: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        guard scrollView.zoomScale < 1 else { return }
        print(scrollView.contentSize)
//        let contentSize = scrollView.contentSize
//        let side = (screenWidth - cuttonSize - contentSize.width)
//        let side2 = (screenWidth - cuttonSize - contentSize.height)
//        scrollView.contentInset.left = cuttonSize/2 + side/2
//        scrollView.contentInset.top = cuttonSize/2 + side2/2
//
//        let leftInset = screenWidth * 0.75
//        let topInset  =
    }
}

private extension PhotoSelectView {
    func curtainLayout(type: PhotoCropType) {
        print(type.curtainVerticalWidth, type.curtainHorizontalWidth)
        leadingView.snp.updateConstraints {
            $0.width.equalTo(type.curtainHorizontalWidth)
        }
        
        trailingView.snp.updateConstraints {
            $0.width.equalTo(type.curtainHorizontalWidth)
        }
        
        topView.snp.updateConstraints {
            $0.height.equalTo(type.curtainVerticalWidth)
        }
        
        bottomView.snp.updateConstraints {
            $0.height.equalTo(type.curtainVerticalWidth)
        }
        
        UIView.animate(withDuration: 0.15, delay: 0) {
            self.layoutIfNeeded()
        }
    }
}

private extension PhotoSelectView {
    
    func insertUI() {
        [
            scrollView,
            topView,
            leadingView,
            trailingView,
            bottomView,
            rotateButton,
            cropTypeSelectButton
        ]
            .forEach {
                addSubview($0)
            }
    
        scrollView.addSubview(imageView)
    }
    
    func basicSetUI() {
        viewBasicSet()
        scrollViewBasicSet()
        imageViewBasicSet()
        curtainViewBasicSet()
        rotateButtonBasicSet()
    }
    
    func anchorUI() {
        scrollViewAnchor()
        imageViewAnchor()
        curtainViewAnchor()
        rotateButtonAnchor()
        cropTypeSelectButtonAnchor()
    }
}

private extension PhotoSelectView {
    func viewBasicSet() {
        backgroundColor = .clear
        clipsToBounds = true
    }
    
    func scrollViewBasicSet() {
        scrollView.backgroundColor = .black
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 3.0
        scrollView.bounces = true
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.delegate = self
    }
    
    func imageViewBasicSet() {
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = .blue
    }
    
    func curtainViewBasicSet() {
        topView.backgroundColor = .lightGray
        leadingView.backgroundColor = .lightGray
        trailingView.backgroundColor = .lightGray
        bottomView.backgroundColor = .lightGray
    }

    func rotateButtonBasicSet() {
        rotateButton.setImage(UIImage(named: "rotate-cw"), for: .normal)
        rotateButton.setTitle("회전", for: .normal)
        rotateButton.clipsToBounds = true
        rotateButton.backgroundColor = .black
        rotateButton.layer.cornerRadius = 18
        rotateButton.alpha = 0.5
    }
}

private extension PhotoSelectView {
    func scrollViewAnchor() {
        scrollView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    func imageViewAnchor() {
        imageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            imageViewWidth = $0.width.equalTo(screenWidth).constraint
            imageViewHeight = $0.height.equalTo(screenWidth).constraint
        }
    }
    
    func curtainViewAnchor() {
        topView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(0)
        }
        
        leadingView.snp.makeConstraints {
            $0.top.leading.bottom.equalToSuperview()
            $0.width.equalTo(0)
        }
        
        trailingView.snp.makeConstraints {
            $0.top.trailing.bottom.equalToSuperview()
            $0.width.equalTo(0)
        }
        
        bottomView.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(0)
        }
    }
    
    func rotateButtonAnchor() {
        rotateButton.snp.makeConstraints {
            $0.leading.equalTo(18)
            $0.bottom.equalTo(-25)
            $0.width.height.equalTo(36)
        }
    }
    
    func cropTypeSelectButtonAnchor() {
        cropTypeSelectButton.snp.makeConstraints {
            $0.trailing.equalTo(-16)
            $0.bottom.equalTo(-16)
            $0.width.equalTo(140)
            $0.height.equalTo(36)
        }
    }
}
