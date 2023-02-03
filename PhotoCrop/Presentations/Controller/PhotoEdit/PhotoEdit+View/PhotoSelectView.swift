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
import Photos

/// 사진 목록에서 사진을 선택하면 크롭 타입에 맞게 보여주는 뷰

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
    
    let showImage = PublishRelay<PHImage>()
    
    private var type = PhotoCropType.square
    
    private var image: UIImage? {
        return imageView.image
    }
    
    private var scrollBounds: CGRect {
        return scrollView.bounds
    }
    
    private var imageViewFrame: CGRect {
        return imageView.frame
    }
    
    private var zoomScale: CGFloat {
        return scrollView.zoomScale
    }
    
    private var contentSize: CGSize {
        return scrollView.contentSize
    }
    
    let viewModel: PhotoSelectedViewModel
    let editSelect = PublishRelay<(PhotoCropType, PHImage)>()
    
    init(viewModel: PhotoSelectedViewModel = PhotoSelectedViewModel()) {
        self.viewModel = viewModel
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
    
    func makeCropInfo() -> CropInformation {
        guard let image = image else { return CropInfo() }
        let name = ""
        return CropInfo(imageName: name,
                        selectedImage: image,
                        cropType: type,
                        startPoint: scrollBounds.origin,
                        contentSize: contentSize,
                        zoomScale: zoomScale)
    }
}

private extension PhotoSelectView {
    func makeInput() -> PhotoSelectedViewModel.Input {
        let selectedEdit = editSelect.asObservable()
        return PhotoSelectedViewModel.Input(editSelected: selectedEdit)
    }
        
    func bindUI() {
        let didSelectCropType = cropTypeSelectButton
            .didSelectedCrop
            .map { EqualSelected(true, $0) }
            .scan(EqualSelected(true, .vertical), accumulator: { preValue, newValue in
                return (preValue.type != newValue.type, newValue.type)
            })
            .filter { $0.equal }
            .map { $0.1 }
        
        Observable
            .combineLatest(didSelectCropType, showImage)
            .bind(to: editSelect)
            .disposed(by: disposeBag)
        
        viewModel
            .transform(input: makeInput())
            .selectedReflect
            .subscribe(onNext: {
                let selectedAsset = $0.phImage.asset
                var size = CGSize(width: selectedAsset.pixelWidth, height: selectedAsset.pixelHeight)
                if size == .zero {
                    size = $0.phImage.image.size
                    self.imageView.image = $0.phImage.image
                } else {
                    if $0.changeImage {
                        self.imageView.fetchImage(asset: $0.phImage.asset)
                    }
                }
                self.resizingImageScrollView(imageSize: size, type: $0.cropType)
            }).disposed(by: disposeBag)
    }
    
    func resizingImageScrollView(imageSize: CGSize, type: PhotoCropType) {
        self.type = type
        scrollView.setZoomScale(1.0, animated: true)
        curtainLayout(type: type)
        
        let contentInset = type.contentInset
        let contentSize = type.scrollContentSize(imageSize: imageSize)
        let imageViewWidth = contentSize.width
        let imageViewHeight = contentSize.height
        
        scrollView.contentSize = contentSize
        scrollView.contentInset = contentInset
        self.imageViewWidth?.update(offset: imageViewWidth)
        self.imageViewHeight?.update(offset: imageViewHeight)
        scrollView.scrollCentering(inset: contentInset)
    }
    
    func rotateImage() {
        guard let image = image else { return }
        let rotateImage = image.rotate(radians: .pi/2)
        imageView.image = rotateImage
        resizingImageScrollView(imageSize: rotateImage.size, type: type)
    }
    
    @objc func rotateImageButtonTapped(_ sender: UIButton) {
        rotateImage()
    }
}
                   
extension PhotoSelectView: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        guard scrollView.zoomScale < 1 else { return }
    }
}

private extension PhotoSelectView {
    func curtainLayout(type: PhotoCropType) {
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
        rotateButton.addTarget(self, action: #selector(rotateImageButtonTapped), for: .touchUpInside)
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
