//
//  ImageStorage.swift
//  photoram
//
//  Created by Anna Zharkova on 10.05.2021.
//  Copyright © 2021 azharkova. All rights reserved.
//

import Foundation
import Foundation
import SDWebImage

final class ImageStorage {
    static let sharedInstance = ImageStorage()
    private init() {
    }

    func setupImage(imageKey: String, imageView: UIImageView?) {
        if let image = getImageByKey(imageKey) {
            imageView?.image = image
        } else {
            loadImage(imageKey: imageKey, imageView: imageView)
        }
    }

    func loadImage(imageKey: String, imageView: UIImageView?) {
        SDWebImageDownloader.shared.downloadImage(with: URL(string: imageKey)) { (image, _, _, _) in
            if let image = image {
                image.resize(newSize: CGSize(width: 512, height: 512), completion: {[weak self] (im, imagedata) in
                    imageView?.image = nil
                    self?.saveImageWithKey(imagedata, imageKey)
                    imageView?.image = im
                })

            }
        }
    }

    func saveToGallery(link: String) {
        SDWebImageDownloader.shared.downloadImage(with: URL(string: link)) { (image, _, _, _) in
            if let image = image {
                image.resize(newSize: CGSize(width: 512, height: 512), completion: {[weak self] (im, _) in
                      UIImageWriteToSavedPhotosAlbum(im, self, nil, nil)
                })
            }
        }

    }

    func saveImageWithKey(_ imageData: Data?, _ imageKey: String) {
        SDImageCache.shared.removeImage(forKey: imageKey, fromDisk: true) {
            if let data = imageData, let image = UIImage(data: data) {
                image.resize(newSize: CGSize(width: 512, height: 512), completion: { (_, imagedata) in
                    SDImageCache.shared.storeImageData(toDisk: imagedata, forKey: imageKey)
                })
            }
        }

    }

    func cleanImage(_ imageKey: String) {
        SDImageCache.shared.removeImage(forKey: imageKey, fromDisk: true, withCompletion: nil)
    }

    func getImageByKey(_ imageKey: String) -> UIImage? {
        return SDImageCache.shared.imageFromDiskCache(forKey: imageKey)

    }

    func getImageData(imageKey: String) -> Data? {
        return getImageByKey(imageKey)?.toData()
    }

    func cleanDisk() {
        SDImageCache.shared.clearDisk {
        }
    }
    deinit {
        SDImageCache.shared.clearMemory()

    }
}
