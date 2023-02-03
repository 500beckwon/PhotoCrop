//
//  PhotoCustomAlbumView.swift
//  PhotoCrop
//
//  Created by ByungHoon Ann on 2023/01/30.
//

import Foundation
import Photos
import RxCocoa
import RxDataSources
import RxSwift
import RxRelay
import UIKit

struct PhotoAsset {
    let asset: PHAsset?
    let sampleImage: UIImage?
    
    static func sampleAsset() -> [PhotoAsset] {
        return [ PhotoAsset(asset: nil, sampleImage: UIImage(named: "Frozen1")),
                 PhotoAsset(asset: nil, sampleImage: UIImage(named: "Frozen2")),
                 PhotoAsset(asset: nil, sampleImage: UIImage(named: "Frozen3")),
                 PhotoAsset(asset: nil, sampleImage: UIImage(named: "Frozen4")),
                 PhotoAsset(asset: nil, sampleImage: UIImage(named: "Frozen5"))]
    }
}

protocol PhotoCustomAlbumViewDelegate: AnyObject {
    func didSelectedAlbum(album: AlbumList)
}

extension PhotoCustomAlbumViewDelegate {
    func didSelectedAlbum(album: AlbumList) { }
}

struct AlbumList {
    var title: String
    var album: [PHAsset]
    var count: Int
}

final class PhotoCustomAlbumView: UIView {
    weak var delegate: PhotoCustomAlbumViewDelegate?
    var albums = [AlbumList]() {
        didSet {
            OperationQueue.main.addOperation {
                self.tableView.reloadData()
            }
        }
    }

    var tableView = UITableView()
    var selectedAsset = PublishRelay<[PhotoAsset]>()
    
    override  init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        insertUI()
        basicSetUI()
        anchorUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func insertUI() {
        addSubview(tableView)
    }

    func basicSetUI() {
        tableBasicSet()
    }

    func anchorUI() {
        tableViewAnchor()
    }

    func tableBasicSet() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(PhotoCustomTableCell.self, forCellReuseIdentifier: "PhotoCustomTableCell")
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
    }

    func tableViewAnchor() {
        tableView.snp.makeConstraints { make in
            make.top.left.right.bottom.equalTo(self)
        }
    }

     func getAlbumList() {
        let albumsPhoto: PHFetchResult<PHAssetCollection> = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: nil)
        let favoritePhoto: PHFetchResult<PHAssetCollection> = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumFavorites, options: nil)
        var albumlist = [AlbumList]()
        var count = 0

        albumsPhoto.enumerateObjects { collection, _, _ in
            let photoInAlbum = PHAsset.fetchAssets(in: collection, options: self.getAssetFetchOptions())
            let arrayFetchResult = photoInAlbum.objects(at: IndexSet(0 ..< photoInAlbum.count))
            let album = AlbumList(title: collection.localizedTitle ?? "", album: arrayFetchResult, count: photoInAlbum.count)

            count += 1
            if !arrayFetchResult.isEmpty {
                albumlist.append(album)
            }

            if count == albumsPhoto.count {
                albumlist.insert(self.getAllAlbum(), at: 0)
                self.albums = albumlist
                favoritePhoto.enumerateObjects { collection, _, _ in
                    let photoInAlbum = PHAsset.fetchAssets(in: collection, options: self.getAssetFetchOptions())
                    let arrayFetchResult = photoInAlbum.objects(at: IndexSet(0 ..< photoInAlbum.count))
                    let album = AlbumList(title: collection.localizedTitle ?? "", album: arrayFetchResult, count: photoInAlbum.count)
                    self.albums.append(album)
                }
            }
        }
    }

    private func getAssetFetchOptions() -> PHFetchOptions {
        let options = PHFetchOptions()
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: false)
        options.sortDescriptors = [sortDescriptor]
        options.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.image.rawValue)
        return options
    }

    func getAllAlbum() -> AlbumList {
        var album = AlbumList(title: "전체", album: [PHAsset](), count: 0)
        let fetchResult = PHAsset.fetchAssets(with: .image, options: getAssetFetchOptions())
      //  let systemAlbums = getSystemAlbum()
        guard let userAlbums = getUserCreateAlbum() else { return album }
        let arrayFetchResult = fetchResult.objects(at: IndexSet(0 ..< fetchResult.count))
        album = AlbumList(title: "전체", album: arrayFetchResult, count: fetchResult.count)
        return album
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

extension PhotoCustomAlbumView: UITableViewDataSource, UITableViewDelegate {
     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return albums.count
    }

     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: PhotoCustomTableCell = tableView.dequeueCell(indexPath: indexPath)
        cell.albumList = albums[indexPath.row]
        return cell
    }

     func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
     func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.didSelectedAlbum(album: albums[indexPath.row])
        let photoAssetList = albums[indexPath.row].album.map { PhotoAsset(asset: $0, sampleImage: nil) }
        selectedAsset.accept(photoAssetList)
    }
}

