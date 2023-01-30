//
//  PhotoEditViewController.swift
//  PhotoCrop
//
//  Created by ByungHoon Ann on 2023/01/30.
//

import Photos
import RxSwift
import SnapKit
import UIKit



extension PhotoEditViewController: UIGestureRecognizerDelegate { }

final class PhotoEditViewController: UIViewController, PhotoStyleEditViewDelegate {
    lazy var comboImageView = UIImageView()
    lazy var titleButton = UIButton(type: .system)
    var originalImageView: UIImageView?
    
    lazy var photoListView = PhotoListView()
    
    lazy var photoAlbumListView = PhotoCustomAlbumView()
    lazy var editingScrollView = UIScrollView()
    var cuttonSize: CGFloat {
        return screenWidth * 0.25
    }
    
    var scrollViewHeight: Constraint?
    var imageViewWidth: Constraint?
    var imageViewHeight: Constraint?
    var albumListConstraint: Constraint?
    
    lazy var scrllImageView = UIImageView()
    lazy var contanierView = UIView()
    lazy var editModeButton = UIButton(type: .system)
    lazy var cutPhotoButton = UIButton(type: .system)
    lazy var backButton = UIButton(type: .system)
    lazy var rotateButton = UIButton(type: .system)
    lazy var leftView = UIView()
    lazy var rightView = UIView()
    lazy var topView = UIView()
    lazy var bottomView = UIView()
    
    lazy var cropPostButton = PhotoStyleEditView()
    
    let disposeBag = DisposeBag()
    
    var aleadyImage = ""
    var aleadyNumber: Int?
    var basicRatio = "square"
    var myRoomEnter: Bool = false
    
    
    var selectedIndex: Int = 0 {
        didSet {
            editPhotoEvent()
        }
    }
    
    override  func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        insertUI()
        basicSetUI()
        anchorUI()
        photoPermissionCheck()
    }
    
    override  func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    
    override  func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        originalImageView?.image = nil
        originalImageView = nil
    }
    
    func photoPermissionCheck() {
        if #available(iOS 14, *) {
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { [weak self] statue in
                guard let self = self else { return }
                var message = ""
                switch statue {
                case .denied: message = "거부하셨습니다"
                case .restricted: message = "제한하셨습니다"
                case .limited: message = "부분적으로 허용하셨습니다"
                    self.setPhasset()
                case .authorized: message = ""
                    self.setPhasset()
                case .notDetermined: message = "정하지 않으셨습니다"
                default: ()
                }
                DispatchQueue.main.async {
                    self.photoAccessGuideToast(message: message)
                }
            }
        } else {
            checkPhotoAccess()
            // Fallback on earlier versions
        }
    }
    
    func checkPhotoAccess() {
        var message = ""
        switch PHPhotoLibrary.authorizationStatus() {
        case .denied: message = "거부하셨습니다"
        case .restricted: message = "제한하셨습니다"
        case .limited: message = "부분적으로 허용하셨습니다"
            self.setPhasset()
        case .authorized: message = ""
            self.setPhasset()
        case .notDetermined: message = "정하지 않으셨습니다"
        default: ()
        }
        photoAccessGuideToast(message: message)
    }
    
    func setPhasset() {
        PHPhotoLibrary.shared().register(photoListView)
        
        photoAlbumListView.getAlbumList()
        photoListView.loadAllAlbums()
    }
    
    func photoAccessGuideToast(message: String) {
        
    }
}

// MARK: - 편집 버튼 Event 함수

extension PhotoEditViewController {
    @objc func cropSegmentAction(_ sender: UISegmentedControl) {
        editingScrollView.setZoomScale(1.0, animated: true)
        guard let image = scrllImageView.image else { return }
        edithorizontal(segment: sender.selectedSegmentIndex)
        
        photoListView.snp.updateConstraints { make in
            make.top.equalTo(editingScrollView.snp.bottom)
        }
        
        resizeDidSelected(imageSize: image.size, scrollCenter: true)
    }
    
    func editPhotoEvent() {
        editingScrollView.setZoomScale(1.0, animated: true)
        guard let image = scrllImageView.image else { return }
        edithorizontal(segment: selectedIndex)
        resizeDidSelected(imageSize: image.size, scrollCenter: true)
    }
}

extension PhotoEditViewController {
    func edithorizontal(segment: Int) {
        switch segment {
        case 0: wallSizeControl(0, 0, 0, 0)
        case 1: wallSizeControl(0, 0, cuttonSize / 2, cuttonSize / 2)
        case 2: wallSizeControl(cuttonSize / 2, cuttonSize / 2, 0, 0)
        default: break
        }
    }
    
    func wallSizeControl(_ leftSize: CGFloat, _ rightSize: CGFloat, _ topSize: CGFloat, _ bottomSize: CGFloat) {
        leftView.snp.updateConstraints { remake in
            remake.width.equalTo(leftSize)
        }
        
        rightView.snp.updateConstraints { remake in
            remake.width.equalTo(rightSize)
        }
        
        topView.snp.updateConstraints { remake in
            remake.height.equalTo(topSize)
        }
        
        bottomView.snp.updateConstraints { remake in
            remake.height.equalTo(bottomSize)
        }
        
        UIView.animate(withDuration: 0.25, delay: 0) { [weak self] in
            self?.view.layoutIfNeeded()
        }
    }
}

// MARK: - PhotoListViewDelegate 함수 목록

extension PhotoEditViewController: PhotoListViewDelegate {
    func didSelectedPhoto(_ image: UIImage?, imageSegment: Int, indexPath: IndexPath?) {
        scrllImageView.image = image
        cropPostButton.isHidden = false
        rotateButton.isHidden = false
        editPhotoEvent()
        cropPostButton.setButtonSelected(imageSegment)
        photoListView.snp.updateConstraints { make in
            make.top.equalTo(editingScrollView.snp.bottom)
        }
    }
    
    func firstPhotSelect(image: PHAsset) {
        guard let image = view.setData(asset: image) else { return }
        print("firstPhotSelectfirstPhotSelect", image.size)
        let imageSize = image.size
        var imageSegment: Int {
            if imageSize.width > imageSize.height {
                return 1
            } else if imageSize.width < imageSize.height {
                return 2
            }
            return 0
        }
        
        print(aleadyImage, "dmdk아아하핳 ", myRoomEnter)
        scrllImageView.image = image
        editingScrollView.setZoomScale(1.0, animated: false)
        switch basicRatio {
        case "square": selectedIndex = 0
        case "horizontal": selectedIndex = 1
        case "vertical": selectedIndex = 2
        default: selectedIndex = 0
        }
        edithorizontal(segment: selectedIndex)
        resizeDidSelected(imageSize: imageSize, scrollCenter: true)
        
    }
    
    func increasePhotoListView() {
        cropPostButton.isHidden = true
        rotateButton.isHidden = true
        photoListView.snp.updateConstraints { make in
            make.top.equalTo(editingScrollView.snp.bottom).offset(-screenWidth)
        }
        
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.view.layoutIfNeeded()
        }
    }
    
    func deincreasePhotoListView() {
        cropPostButton.isHidden = false
        rotateButton.isHidden = false
        photoListView.snp.updateConstraints { make in
            make.top.equalTo(editingScrollView.snp.bottom)
        }
        
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.view.layoutIfNeeded()
        }
    }
}

// MARK: - Cell 선택 혹은 Segemnt 터치시 이미지 사이즈 자동 갱신

extension PhotoEditViewController {
    func resizeDidSelected(imageSize: CGSize, scrollCenter: Bool) {
        UIView.animate(withDuration: 0.1) { [weak self] in
            self?.editingScrollView.alpha = 0.95
        } completion: { _ in
            UIView.animate(withDuration: 0.1) { [weak self] in
                self?.editingScrollView.alpha = 1
            }
        }
        
        switch selectedIndex {
        case 0:
            if imageSize.width < imageSize.height {
                squareVerticalThinSizing(size: imageSize, scrollCenter: scrollCenter) // 정방 세로
            } else if imageSize.width > imageSize.height {
                squareHorizontalThinSizing(size: imageSize, scrollCenter: scrollCenter) // 정방 가로
            } else {
                squareSizing(type: .square)
            }
        case 1:
            if imageSize.width < imageSize.height {
                horizontalVerticalSizing(size: imageSize, scrollCenter: scrollCenter)
            } else if imageSize.width > imageSize.height {
                horizontalHorzontalSizing(size: imageSize, scrollCenter: scrollCenter) // 가로 가로
            } else {
                squareSizing(type: .horizontal)
            }
        case 2:
            if imageSize.width < imageSize.height {
                verticalVerticalSizing(size: imageSize, scrollCenter: scrollCenter) // 정방 세로
            } else if imageSize.width > imageSize.height {
                verticalHorizaontalSizing(size: imageSize, scrollCenter: scrollCenter) // 정방 정방
            } else {
                squareSizing(type: .vertical)
            }
        default: break
        }
    }
}

// MARK: - UISrollView Delegate

extension PhotoEditViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return scrllImageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        guard scrollView.zoomScale < 1 else { return }
        let contentSize = scrollView.contentSize
        let side = (screenWidth - cuttonSize - contentSize.width)
        let side2 = (screenWidth - cuttonSize - contentSize.height)
        scrollView.contentInset.left = cuttonSize/2 + side/2
        scrollView.contentInset.top = cuttonSize/2 + side2/2
    }
}

extension PhotoEditViewController {
    func squareVerticalThinSizing(size: CGSize, scrollCenter: Bool) {
        let ratio = size.width / size.height
        let newHeight = screenWidth / ratio
        let minY = (newHeight - screenWidth) / 2
        let rect = CGRect(x: 0, y: minY, width: screenWidth, height: screenWidth)
        
        editingScrollView.contentSize = CGSize(width: screenWidth, height: newHeight)
        imageViewWidth?.update(offset: screenWidth)
        imageViewHeight?.update(offset: newHeight)
        editScrollViewInSet(type: .square, rect: rect, scrollCenter: scrollCenter)
    }
    
    func squareHorizontalThinSizing(size: CGSize, scrollCenter: Bool) {
        let ratio = size.height / size.width
        let newWidth = screenWidth / ratio
        let minX = (newWidth - screenWidth) / 2
        let rect = CGRect(x: minX, y: 0, width: screenWidth, height: screenWidth)
        
        editingScrollView.contentSize = CGSize(width: newWidth, height: screenWidth)
        imageViewWidth?.update(offset: newWidth)
        imageViewHeight?.update(offset: screenWidth)
        editScrollViewInSet(type: .square, rect: rect, scrollCenter: scrollCenter)
    }
    
    func horizontalVerticalSizing(size: CGSize, scrollCenter: Bool) {
        let ratio = size.width / size.height
        var newHeight = screenWidth / ratio
        let minY = (newHeight - screenWidth) / 2
        let rect = CGRect(x: 0, y: minY, width: screenWidth, height: screenWidth)
        editingScrollView.contentSize = CGSize(width: screenWidth, height: newHeight)
        
        imageViewWidth?.update(offset: screenWidth)
        if newHeight < screenWidth - 15 {
            newHeight = screenWidth
        }
        imageViewHeight?.update(offset: newHeight)
        editScrollViewInSet(type: .horizontal, rect: rect, scrollCenter: scrollCenter)
    }
    
    func horizontalHorzontalSizing(size: CGSize, scrollCenter: Bool) {
        let ratio = size.height / size.width
        var newWitdh = (screenWidth - cuttonSize) / ratio
        var height = screenWidth - cuttonSize
        let minX = (newWitdh - screenWidth) / 2
        
        if newWitdh < screenWidth {
            newWitdh *= 1.3
            height *= 1.3
        }
        
        if ratio > 0.95 {
            newWitdh = screenWidth / ratio
            height = screenWidth
        } else {
            editingScrollView.contentSize = CGSize(width: newWitdh, height: height)
        }
        print((screenWidth - cuttonSize) / ratio, "미쳤내", height, newWitdh, ratio, minX, scrollCenter)
        // editingScrollView.contentSize = CGSize(width: newWitdh, height: screenWidth - cuttonSize)
        imageViewHeight?.update(offset: height)
        imageViewWidth?.update(offset: newWitdh)
        let rect = CGRect(x: minX, y: 0, width: screenWidth, height: screenWidth - cuttonSize)
        editScrollViewInSet(type: .horizontal, rect: rect, scrollCenter: scrollCenter)
    }
    
    func squareSizing(type: InsetType) {
        editScrollViewInSet(type: type, scrollCenter: true)
        editingScrollView.contentSize = CGSize(width: screenWidth, height: screenWidth)
        imageViewWidth?.update(offset: screenWidth)
        imageViewHeight?.update(offset: screenWidth)
    }
    
    func verticalVerticalSizing(size: CGSize, scrollCenter: Bool) {
        let ratio = size.width / size.height
        var newHeight = (screenWidth - cuttonSize) / ratio
        var width = screenWidth - cuttonSize
        var minY = (newHeight - screenWidth) / 2
        
        if newHeight < screenWidth - 15 {
            newHeight *= 1.3
            width *= 1.3
        }
        
        let rect = CGRect(x: 0, y: minY, width: screenWidth - cuttonSize, height: screenWidth)
        editingScrollView.contentSize = CGSize(width: width, height: newHeight)
        imageViewWidth?.update(offset: width)
        imageViewHeight?.update(offset: newHeight)
        editScrollViewInSet(type: .vertical, rect: rect, scrollCenter: scrollCenter)
    }
    
    func verticalHorizaontalSizing(size: CGSize, scrollCenter: Bool) {
        let ratio = size.height / size.width
        var newWidth = screenWidth / ratio
        let minX = (newWidth - screenWidth) / 2
        let rect = CGRect(x: minX, y: 0, width: screenWidth, height: screenWidth - cuttonSize / 2)
        editingScrollView.contentSize = CGSize(width: newWidth, height: screenWidth - cuttonSize)
        
        if newWidth < screenWidth - 15 {
            newWidth = screenWidth
        }
        
        imageViewWidth?.update(offset: newWidth)
        imageViewHeight?.update(offset: screenWidth)
        
        editScrollViewInSet(type: .vertical, rect: rect, scrollCenter: scrollCenter)
    }
    
    func editScrollViewInSet(type: InsetType, rect: CGRect = .zero, scrollCenter: Bool) {
        var insert: UIEdgeInsets = .zero
        switch type {
        case .square: insert = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        case .horizontal: insert = UIEdgeInsets(top: cuttonSize / 2, left: 0, bottom: cuttonSize / 2, right: 0)
        case .vertical: insert = UIEdgeInsets(top: 0, left: cuttonSize / 2, bottom: 0, right: cuttonSize / 2)
        }
        UIView.animate(withDuration: 0.2, delay: 0) { [weak self] in
            guard let self = self else { return }
            self.editingScrollView.scrollRectToVisible(rect, animated: !scrollCenter)
            self.editingScrollView.contentInset = insert
            self.view.layoutIfNeeded()
        }
    }
}

extension PhotoEditViewController {
    func removeToastBlur() {
        view.isUserInteractionEnabled = true
    }
}
