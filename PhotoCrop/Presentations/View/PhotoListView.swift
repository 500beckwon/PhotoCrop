//
//  PhotoListView.swift
//  PhotoCrop
//
//  Created by ByungHoon Ann on 2023/01/30.
//

import MobileCoreServices
import UIKit
import Photos
import RxSwift
import RxCocoa
import RxDataSources

struct AlbumObject {
    var title: String?
    var imageTotalCount: String?
    var coverImage: UIImage?
    var fetchResult: PHFetchResult<PHAsset>?
}

final class SelectedIndex {
    private init() {}
    static let shared = SelectedIndex()

    var index = [IndexPath]()
    var indexPath: IndexPath?
    var deIndexPath: IndexPath?
    var itemCount = 0
    var dictionarySelectedIndexPath = [IndexPath: Bool]()
    var selectCount = 0
    var isHidden = true
    var lastSelected = false
}

final class ZoomScale {
    static let shared = ZoomScale()
    private init() {}

    var zoomScale: CGFloat?
    var locationBounds: CGRect?
    var segmentNumber: Int?
    var currentIndexPath: IndexPath?
}

struct SelectControl {
    var selectNumber: Int?
    var indexPath: IndexPath?
    var locationPoint: CGRect?
    var zoomScale: CGFloat?
    var selected: Bool?
    var segmentNumber: Int?
    var selectedImage: UIImage?
}

@objc protocol PhotoListViewDelegate: AnyObject {
    func didSelectedPhoto(_ image: UIImage?, imageSegment: Int, indexPath: IndexPath?)
    @objc optional func firstPhotSelect(image: PHAsset)
    @objc optional func increasePhotoListView()
    @objc optional func deincreasePhotoListView()
}

 class PhotoListView: UIView {
    weak var delegate: PhotoListViewDelegate?
     var disposeBag = DisposeBag()
     var photos = [Photos]()
    
    // MARK: - 사진 앨범 목록
     
     var systemAlbums: [PHAssetCollection]? {
         return getSystemAlbum()
     }
     
     /// 사용자 생성 앨범
      var userAlbums: [PHAssetCollection]? {
         return getUserCreateAlbum()
     }
    
    var albumArray = [AlbumObject]()
    var sharedSelectControl = [SelectControl]()
     var subject: BehaviorRelay<[Photos]> = BehaviorRelay(value: [])
     var fisrtShow = false

     var fetchResult: PHFetchResult<PHAsset>?
     var assets = [PHAsset]()
     var assetCollectionArray: [PHAssetCollection]?
     var selectedImage: UIImage?
     let imageManager = PHCachingImageManager()
     var editingScrollView = UIScrollView()
     var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
         layout.scrollDirection = .vertical
        let cView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        return cView
    }()
    
    override  init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
      
        insertUI()
        basicSetUI()
        anchorUI()
        //requestAlbumAuth()
        rxCollectionBasicSet()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func pan(_ gesture: UIPanGestureRecognizer) {
        let velocityY = gesture.velocity(in: collectionView).y
        let translationY = gesture.translation(in: collectionView).y
        let offset = collectionView.contentOffset.y
        print(velocityY, translationY, "팬제스쳐", offset)
        
        switch gesture.state {
        case .began: ()
        case .changed:
            if translationY < -200 {
                delegate?.increasePhotoListView?()
            } else if velocityY > 200, translationY > 300 {
                delegate?.deincreasePhotoListView?()
            }
        default: ()
        }
    }
    
    func insertUI() {
        addSubview(collectionView)
        
    }
    
    func anchorUI() {
        collectionAnchor()
    }
    
    func basicSetUI() {
        collectionViewBasicSet()
        panGestureBasicSet()
    }
    
    func panGestureBasicSet() {
        let pan = UIPanGestureRecognizer(target: self, action: #selector(pan))
        pan.delegate = self
        collectionView.addGestureRecognizer(pan)
    }
    
    func collectionViewBasicSet() {
        collectionView.backgroundColor = .white
        collectionView.delegate = self
        collectionView.register(PhotoListCollectionCell.self, forCellWithReuseIdentifier: "PhotoListCollectionCell")
        collectionView.showsVerticalScrollIndicator = false
    }
    
    func rxCollectionBasicSet() {
        let dataSources = RxCollectionViewSectionedReloadDataSource<Photos> { _, collectionView, indexPath, item in
            let cell: PhotoListCollectionCell = collectionView.dequeueCell(indexPath: indexPath)
          //  cell.indexPath = indexPath
            cell.phAsset = item
            cell.setDatas(asset: item, cachingImageManager: self.imageManager)
            if indexPath.row == 0, self.fisrtShow == false {
                self.fisrtShow = true
                self.delegate?.firstPhotSelect?(image: item)
            }
            return cell
        }
        
        collectionView.rx.itemSelected
            .map { [weak self] indexPath in
                return (self?.photos[indexPath.section].albums[indexPath.row], indexPath)
            }.map { [weak self] result in
            //    print("리절트리절",result.0, result.1)
                return (self?.setData(asset: result.0), result.1)
            }.subscribe { event in
                let segment = self.getSegment(size: event.0?.size)
                self.delegate?.didSelectedPhoto(event.0, imageSegment: segment, indexPath: event.1)
            } onCompleted: { }
            .disposed(by: disposeBag)
        
        subject
            .bind(to: collectionView
                    .rx
                    .items(dataSource: dataSources))
            .disposed(by: disposeBag)
    }
    
    func collectionAnchor() {
        collectionView.snp.makeConstraints { make in
            make.top.left.right.bottom.equalTo(self)
        }
    }
    
    func getSegment(size: CGSize?) -> Int {
        var segment = 0
        if let imageSize = size {
            if imageSize.width > imageSize.height {
                 segment = 1
            } else if imageSize.width < imageSize.height {
                segment = 2
            }
        }
        return segment
    }
}

extension PhotoListView: UIScrollViewDelegate {
     func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {

    }
    
     func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {

    }
}

extension PhotoListView: UICollectionViewDelegateFlowLayout, UICollectionViewDelegate {
     func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cgSize = CGSize(width: screenWidth/4 - 1, height: screenWidth/4 - 1)
        return cgSize
    }
    
     func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0.5
    }

     func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0.5
    }
}

// MARK: - Photo Library 데이터 가져오기 함수
extension PhotoListView {
    func getSystemAlbum() -> [PHAssetCollection] {
        var albumList = [PHAssetCollection]()
        // 카메라 롤
        if let cameraRoll = PHAssetCollection.fetchAssetCollections(with: .smartAlbum,
                                                                    subtype: .smartAlbumUserLibrary,
                                                                    options: nil).firstObject {
            albumList.append(cameraRoll)
        }

        // 셀카
        if let selfieAlbum = PHAssetCollection.fetchAssetCollections(with: .smartAlbum,
                                                                     subtype: .smartAlbumSelfPortraits,
                                                                     options: nil).firstObject {
            albumList.append(selfieAlbum)
        }

        // 즐겨찾는 사진
        if let favoriteAlbum = PHAssetCollection.fetchAssetCollections(with: .smartAlbum,
                                                                       subtype: .smartAlbumFavorites,
                                                                       options: nil).firstObject {
            albumList.append(favoriteAlbum)
        }
        
        return albumList
    }
    
    // MARK: - Get PHFetchOptions
    
    func getAssetFetchOptions() -> PHFetchOptions {
        let options = PHFetchOptions()
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: false)
        options.sortDescriptors = [sortDescriptor]
        options.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.image.rawValue)
        return options
    }
    
    // MARK: - Photo Libarary 전체 사진 가져오기
    
    func loadAllAlbums() {
        print("loadAllAlbums")
          fetchResult = PHAsset.fetchAssets(with: .image, options: getAssetFetchOptions())
          guard let _systemAlbums = systemAlbums else { return }
          guard let _userAlbums = userAlbums else { return }
          let albumList = _systemAlbums + _userAlbums
        
          assetCollectionArray = albumList.filter { collection in
              PHAsset.fetchAssets(in: collection, options: nil).count > 0
          }
        guard let fetch = fetchResult else { return }
        let arrayFetchResult = fetch.objects(at: IndexSet(0..<fetch.count))
        photos = [Photos(albums: arrayFetchResult)]
          createAlbumsArray()

          OperationQueue.main.addOperation { [weak self] in
            guard let self = self else { return }
              self.subject.accept(self.photos)

              self.collectionView.reloadData()
          }
      }
    
    func getUserCreateAlbum() -> [PHAssetCollection]? {
        var albumList = [PHAssetCollection]()
        let userAlbums = PHAssetCollection.fetchTopLevelUserCollections(with: nil)
        
        for index in 0 ..< userAlbums.count {
            if let collection: PHAssetCollection =
                userAlbums.object(at: index) as? PHAssetCollection {
                albumList.append(collection)
            }
        }
        return albumList
    }
}

extension PhotoListView: PHPhotoLibraryChangeObserver {
     func photoLibraryDidChange(_ changeInstance: PHChange) {
        OperationQueue.main.addOperation {
            guard let fetchResult = self.fetchResult else { return }
            if let changes = changeInstance.changeDetails(for: fetchResult) {
                self.fetchResult = changes.fetchResultAfterChanges
                self.collectionView.reloadData()
            }
        }
    }

    func createAlbumsArray() {
        guard let _assetCollectionArray = assetCollectionArray else { return }
        for collectionData in _assetCollectionArray {
            let fetchResult = PHAsset.fetchAssets(in: collectionData, options: getAssetFetchOptions())
            let numFormatter = NumberFormatter()
            numFormatter.numberStyle = .decimal
            let count = fetchResult.count
            let countText = numFormatter.string(from: NSNumber(value: count))

            var album = AlbumObject()
            album.fetchResult = fetchResult
            album.title = collectionData.localizedTitle
            album.imageTotalCount = countText
            albumArray.append(album)
        }
    }

    func requestAlbumAuth() {
        switch PHPhotoLibrary.authorizationStatus() {
        case .authorized:
            loadAllAlbums()
        case .denied:
            print("denied")
        case .restricted:
            print("restricted")

        case .notDetermined:
            print("notDetermined")
            PHPhotoLibrary.requestAuthorization { status in
                
                switch status {
                case .authorized:
                    print("reAuthorized")
                    self.loadAllAlbums()
                case .denied:
                    print("사진첩 접근 거부됨")
                default:
                    break
                }
            }
        case .limited: print("limited")
        default: ()
        }
    }
    
    func getSystemAlbum(albumList: inout [PHAssetCollection]) {
        if let cameraRoll = PHAssetCollection.fetchAssetCollections(with: .smartAlbum,
                                                                    subtype: .smartAlbumUserLibrary,
                                                                    options: nil).firstObject {
            albumList.append(cameraRoll)
        }

        // 셀카
        if let selfieAlbum = PHAssetCollection.fetchAssetCollections(with: .smartAlbum,
                                                                     subtype: .smartAlbumSelfPortraits,
                                                                     options: nil).firstObject {
            albumList.append(selfieAlbum)
        }

        // 즐겨찾는 사진
        if let favoriteAlbum = PHAssetCollection.fetchAssetCollections(with: .smartAlbum,
                                                                       subtype: .smartAlbumFavorites,
                                                                       options: nil).firstObject {
            albumList.append(favoriteAlbum)
        }
    }
}

extension UIView {
    func setData(asset: PHAsset?) -> UIImage? {
        guard let asset = asset else { return nil }
        var setImage: UIImage?
        let options = PHImageRequestOptions()
        let imageManager = PHImageManager.default()
        options.isSynchronous = true
        
        options.resizeMode = .none
        let cgSize = getTargetSize(currentWidth: asset.pixelWidth, currentHeight: asset.pixelHeight)
      
        let exceptionSize = CGSize(width: screenWidth, height: screenWidth)
        
        imageManager.requestImageData(for: asset, options: options) { data, uti, orientaion, _ in
            if let imageData = data {
                if let _uti = uti {
                    let gifCheck = UTTypeConformsTo(_uti as CFString, kUTTypeGIF)
                    if gifCheck == true {
                        print("ddddddddd", gifCheck, orientaion.rawValue)
                        // MARK: gif는 나중에
                        // guard let source = CGImageSourceCreateWithData(imageData as CFData, nil) else { return }
                        // setImage = UIImage.animatedImageWithSource(source)
                        setImage = UIImage(data: imageData)
                    } else {
                        setImage = UIImage(data: imageData)
                    }
                }
            } else {
                imageManager.requestImage(for: asset,
                                          targetSize: cgSize,
                                          contentMode: .aspectFill,
                                          options: options) { image, _ in
                    print("dsfdsfdfs232")
                    setImage = image
                    if image == nil {
                        print("sdfjkhsdkflhadjlfalk")
                       // let size = CGSize(width: asset.pixelWidth, height: asset.pixelHeight)
                        options.isNetworkAccessAllowed = true
                        // options.resizeMode = .exact
                        imageManager.requestImage(for: asset,
                                                  targetSize: exceptionSize,
                                                  contentMode: .aspectFill,
                                                  options: options) { image, _ in
                            setImage = image
                        }
                    }
                }
            }
        }
        return setImage
    } 
}

extension PhotoListView: UIGestureRecognizerDelegate {
     func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
