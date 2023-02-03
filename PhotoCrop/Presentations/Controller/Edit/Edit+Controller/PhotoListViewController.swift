//
//  PhotoListViewController.swift
//  PhotoCrop
//
//  Created by ByungHoon Ann on 2023/02/01.
//

import UIKit
import Photos

import RxSwift
import RxCocoa
import SnapKit

enum PhotoSelect {
    case newPhoto
    case alreadyPhoto(photoName: String) //ex)"2023-02-01T17:43:14.072Z.jpeg"
}

final class PhotoListViewController: UIViewController {
    lazy private var photoView = PhotoSelectView(viewModel: viewModel.selectedViewModel)
    lazy var photoListView = ImageViewListView()
    
    private var editButton = UIButton(type: .system)
    private var albumButton = UIButton(type: .system)
    
    private let disposeBag = DisposeBag()
    
    private let cropPhoto = PublishRelay<CropInformation>()
    
    let type = PhotoSelect.alreadyPhoto(photoName: "")
    
    private let viewModel = PhotoEditViewModel()
    let albumSelected = PublishRelay<AssetAlbum>()
    
//    init(viewModel: PhotoEditViewModel = PhotoEditViewModel()) {
//        self.viewModel = viewModel
//        super.init(nibName: nil, bundle: nil)
//    }
//
//    required init?(coder: NSCoder) {
//        self.viewModel = PhotoEditViewModel()
//        super.init(nibName: nil, bundle: nil)
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        insertUI()
        basicSetUI()
        anchorUI()
        bindUI()
        fetch()
    }
}

private extension PhotoListViewController {
    func makeInput() -> PhotoEditViewModel.Input {
        let cropRequest = editButton.rx.tap
            .throttle(.milliseconds(500), scheduler: MainScheduler.instance)
            .flatMap { [weak self] _ -> Observable<CropInformation> in
                guard let self = self else { return .never() }
                return Observable.just(self.photoView.makeCropInfo())
            }
        
        let photoSelected = photoListView.itemSelected.asObservable()
        let albumSelected = self.albumSelected.asObservable()
        
        return PhotoEditViewModel.Input(photoSelected: photoSelected,
                                        albumSelected: albumSelected,
                                        cropRequest: cropRequest)
    }
    
    func bindUI() {
        let transform = viewModel.transform(input: makeInput())
        transform.albumSelected
            .bind(to: photoListView.assetList)
            .disposed(by: disposeBag)
        
        transform.photoSelected
            .bind(to: photoView.showImage)
            .disposed(by: disposeBag)
        
        transform.cropResult.subscribe(onNext: {
            let vc = CutResultViewController(image: $0)
            self.present(vc, animated: true)
        }).disposed(by: disposeBag)
        
        photoListView.showFirstItem
            .bind(to: photoView.showImage)
            .disposed(by: disposeBag)
    }
    
    func fetch() {
        let assetList = PHAssetManager.shared.getPHAssets(with: .image)
        PHAssetManager
            .shared
            .getImageList(assetList: assetList)
            .bind(to: photoListView.assetList)
            .disposed(by: disposeBag)
    }
}

extension PhotoListViewController: BasicViewDrawRule {
    func insertUI() {
        [
            photoView,
            photoListView
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
    }
    
    func anchorUI() {
        photoViewAnchor()
        photoListViewAnchor()
    }
}

private extension PhotoListViewController {
    @objc func albumButtonTapped(_ sender: UIButton) {
       let vc = AlbumListViewController()
        vc.controller = self
        vc.modalPresentationStyle = .overFullScreen
        present(vc, animated: true)
    }
}

private extension PhotoListViewController {
    func viewBasicSet() {
        view.backgroundColor = .white
    }
    
    func editButtonBasicSet() {
        editButton.setTitle("자르기", for: .normal)
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
}
