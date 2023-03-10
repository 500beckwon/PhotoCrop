//
//  PhotoCrop.swift
//  PhotoCrop
//
//  Created by ByungHoon Ann on 2023/01/30.
//

import UIKit
import RxSwift

let screenWidth = UIScreen.main.bounds.width
let screenHeight = UIScreen.main.bounds.height

final class CropImageManager {
    static let shared = CropImageManager()

    var images = [UIImage]()
    var imageNames = [String]()
    var ratios = [String]()
    
    var imageDatas = [Data]()

    var fixImages = [UIImage]()
    var fixRatios = [String]()
    var modifiyImage = [IndexPath: UIImage]()
    
    let disposeBag = DisposeBag()
    
    enum ImageTypes: Int {
        case square = 0
        case horizontal = 1
        case vertical = 2
    }
    
    private init() {}
    
    func resetCreateMode() {
        images.removeAll()
        ratios.removeAll()
        imageNames.removeAll()
    }
    
    func resizingThunbnailImage(image: UIImage) -> UIImage? {
        guard let cgImage = image.cgImage else { return nil}
        
        let size = CGSize(width: image.size.width, height: image.size.height)
        let context = CGContext( // #1
            data: nil,
            width: Int(size.width),
            height: Int(size.height),
            bitsPerComponent: 16,
            bytesPerRow: 0,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
        context.interpolationQuality = .medium // #2
        context.draw(cgImage, in: CGRect(origin: .zero, size: size))
        guard let resultImage = context.makeImage() else { return nil }
        let thunbnailImage = UIImage(cgImage: resultImage)
        return thunbnailImage
    }
    
    func squareThumbnailCrop(image: UIImage, scroll: CGRect, contentViewFrame: CGRect, zoomScale: CGFloat) -> UIImage {
        let imageSize = image.size
        let imageView = getOriginialSizeImageView(image: image)
        
        let ratioX = scroll.minX/contentViewFrame.width
        let ratioY = scroll.minY/contentViewFrame.height
        
        let minX = ratioX * imageSize.width
        let minY = ratioY * imageSize.height
        
        var width =  imageSize.width/zoomScale
        var height = imageSize.width/zoomScale
        
        if imageSize.width > imageSize.height {
            width = imageSize.height/zoomScale
            height = imageSize.height/zoomScale
        }
        
        let rect = CGRect(x: minX, y: minY, width: width, height: height)
        return cropPhotos(rect, imageView: imageView)
    }
    
    func resizingAlbumImage(image: CGImage, type: ImageTypes.RawValue) -> Observable<CGImage?> {
        Observable.create { obsevable in
           // print(image.width, image.height, "?????? ??????", type)
            let width: CGFloat = 1080.0
            var height: CGFloat = 0.0
            switch type {
            case 0 : height = 1080.0
            case 1 : height = 810.0
            case 2 : height = 1440
            default: height = 1080.0
            }

            let size = CGSize(width: width, height: height)
            let context = CGContext( // #1
                data: nil,
                width: Int(size.width),
                height: Int(size.height),
                bitsPerComponent: 16,
                bytesPerRow: 0,
                space: CGColorSpaceCreateDeviceRGB(),
                bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
            context.interpolationQuality = .medium // #2
            context.draw(image, in: CGRect(origin: .zero, size: size))
            let resultImage = context.makeImage()
            obsevable.onNext(resultImage)
            return Disposables.create()
        }
    }
    
    func convertToUnityImage(image: UIImage,
                             imageName: String,
                             cropType: PhotoCropType,
                             startPoint: CGPoint,
                             zoomScale: CGFloat) {
        let imageSize = image.size
        
    }
    
    func newCrop(cropInfo: CropInformation) -> Observable<UIImage?> {
        let imageView = makeImageView(image: cropInfo.selectedImage)
        let rect = cropInfo.cropType.cropConvertRect(cropInfo: cropInfo)
        let cropImage = cropPhotos(rect, imageView: imageView)

        return Observable.create { observable  in
            if let cgImage = cropImage.cgImage {
                let size = cropInfo.cropType.convertCGImageSize
                let context = CGContext( // #1
                    data: nil,
                    width: Int(size.width),
                    height: Int(size.height),
                    bitsPerComponent: 16,
                    bytesPerRow: 0,
                    space: CGColorSpaceCreateDeviceRGB(),
                    bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
                context.interpolationQuality = .medium // #2
                context.draw(cgImage, in: CGRect(origin: .zero, size: size))
                //let resultCGImage = context.makeImage()
                if let resultCGImage = context.makeImage() {
                    let resultImage = UIImage(cgImage: resultCGImage)
                    observable.onNext(resultImage)
                }
            }
            return Disposables.create()
        }
    }
    
    func makeImageView(image: UIImage) -> UIImageView {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        var imageSize = image.size
        
        if imageSize.height > 2000 {
            imageSize.width /= 3
            imageSize.height /= 3
        }
         
        imageView.frame = CGRect(origin: .zero, size: imageSize)
        imageView.image = image
        return imageView
    }
    
    /// ?????? ?????? ??? Unity??? ??????
    func sendResizeImage(s3Upload: Bool = false, image: UIImage, time: String, segment: Int, scroll: CGRect, contentViewFrame: CGRect, zoomScale: CGFloat, edit: Bool = false, number: Int = 0, completion: ((UIImage?) -> Void)? = nil) {
        DispatchQueue
            .main
            .async { [weak self] in
                guard let self = self else { return }
                let cropImage = self.getCropImage(segmentCount: segment,
                                                  image: image,
                                                  scroll: scroll,
                                                  contentViewFrame: contentViewFrame,
                                                  zoomScale: zoomScale)
                
                if let image = cropImage?.cgImage {
                    self.resizingAlbumImage(image: image, type: segment)
                        .subscribe (onNext:{ [weak self] resultImage in
                        guard let self = self else { return }
                        
                        guard let _cgImage = resultImage else { return }
                        let image = UIImage(cgImage: _cgImage)
                            completion?(image)
                        //    completion?(__image)
                            if s3Upload == true {
                                //self.uploadS3(image: image, imageName: "\(time).jpeg")
                            } else {
                        if edit == true {
                            self.images[number] = image
                        } else {
                            self.images.append(image)
                        }
                            }
                 
                    }).disposed(by: self.disposeBag)
                }
            }
    }
    
    func uploadS3(image: UIImage, imageName: String) {
        self.resetCreateMode()
      
    }
    
    func getCropImage(segmentCount: Int, image: UIImage, scroll: CGRect, contentViewFrame: CGRect, zoomScale: CGFloat) -> UIImage? {
        var cropImage: UIImage?
        switch segmentCount {
        case 0: cropImage = squareCrop(image: image, scroll: scroll, contentViewFrame: contentViewFrame, zoomScale: zoomScale) // ????????? ?????????/ ?????? ????????? ????????? ?????? y??? ????????????
        case 1: cropImage = horizontalCrop(image: image, scroll: scroll, contentViewFrame: contentViewFrame, zoomScale: zoomScale) // ????????? ?????????/ ??????????????? ?????????
        case 2: cropImage = verticalCrop(image: image, scroll: scroll, contentViewFrame: contentViewFrame, zoomScale: zoomScale) // ????????? ?????????/ ????????? ????????? ????????????
        default: break
        }
        
        return cropImage
    }
    
    func cropPhotos(_ rect: CGRect, imageView: UIImageView) -> UIImage {
        UIGraphicsBeginImageContext(rect.size)
        let render = UIGraphicsImageRenderer(bounds: rect)
        let images = render.image { render in
            imageView.layer.render(in: render.cgContext)
        }
        UIGraphicsEndImageContext()
        imageView.image = nil
        imageView.removeFromSuperview()
        return images
    }
    
    func squareCrop(image: UIImage, scroll: CGRect, contentViewFrame: CGRect, zoomScale: CGFloat) -> UIImage {
        var imageSize = image.size
        if imageSize.height > 2000 {
            imageSize.width /= 3
            imageSize.height /= 3
        }
        
        let imageView = getOriginialSizeImageView(image: image)
        
        let ratioX = scroll.minX/contentViewFrame.width
        let ratioY = scroll.minY/contentViewFrame.height
        
        let minX = ratioX * imageSize.width
        let minY = ratioY * imageSize.height
        
        var width =  imageSize.width/zoomScale
        var height = imageSize.width/zoomScale
        
        if imageSize.width > imageSize.height {
            width = imageSize.height/zoomScale
            height = imageSize.height/zoomScale
        }
        
        let rect = CGRect(x: minX, y: minY, width: width, height: height)
        return cropPhotos(rect, imageView: imageView)
    }
    
    func horizontalCrop(image: UIImage, scroll: CGRect, contentViewFrame: CGRect, zoomScale: CGFloat) -> UIImage {
        var imageSize = image.size
    
        if imageSize.height > 2000 {
            imageSize.width /= 3
            imageSize.height /= 3
        }
        
        let imageView = getOriginialSizeImageView(image: image, smallCheck: true)
        
        let ceilX = ceil(scroll.height/8)
        let ratioX = scroll.minX/contentViewFrame.width
        let ratioY = (scroll.minY + ceilX)/contentViewFrame.height
        
        let minX = ratioX * imageSize.width
        let minY = ratioY * imageSize.height
        
        var width =  imageSize.width/zoomScale
        var height = (imageSize.width - imageSize.width/4)/zoomScale
        
        let watchWidthRatio = screenWidth / (contentViewFrame.width / zoomScale)
        
        if imageSize.width > imageSize.height {
            width = (imageSize.width * watchWidthRatio) / zoomScale
            height = (imageSize.height) / zoomScale
        }
        
        let rect = CGRect(x: minX, y: minY, width: width, height: height)
        return cropPhotos(rect, imageView: imageView)
    }
    
    // MARK: - ??????????????????
    
    func verticalCrop(image: UIImage, scroll: CGRect, contentViewFrame: CGRect, zoomScale: CGFloat) -> UIImage {
        var imageSize = image.size
        if imageSize.height > 2000 {
            imageSize.width /= 3
            imageSize.height /= 3
        }
        
        let imageView = getOriginialSizeImageView(image: image)
        
        let ceilX = ceil(scroll.width/8)
        let ratioX = (scroll.minX+ceilX) / contentViewFrame.width
        let ratioY = (scroll.minY) / contentViewFrame.height
        
        let minX = ratioX * imageSize.width
        let minY = ratioY * imageSize.height
        
        var width =  (imageSize.height * 0.75) / zoomScale
        var height = (imageSize.height) / zoomScale
        
        let watchHeightRatio = screenWidth / (contentViewFrame.height / zoomScale)
        
        if imageSize.height > imageSize.width {
            height = imageSize.height * watchHeightRatio / zoomScale
            width =  (imageSize.width) / zoomScale
        }
        
        let rect = CGRect(x: minX, y: minY, width: width, height: height)
      
        return cropPhotos(rect, imageView: imageView)
    }
    
    func getOriginialSizeImageView(image: UIImage, smallCheck: Bool = false, zoomScale: CGFloat = 1.0) -> UIImageView {
        let originalImageView = UIImageView()
        originalImageView.contentMode = .scaleAspectFill
        var imageSize = image.size
        
        if imageSize.height > 2000 {
            imageSize.width /= 3
            imageSize.height /= 3
        }
         
        originalImageView.frame = CGRect(x: 0, y: 0, width: imageSize.width / zoomScale, height: imageSize.height / zoomScale)
        originalImageView.image = image
        return originalImageView
    }
}
