//
//  UIImage+Size.swift
//  photoram
//
//  Created by Anna Zharkova on 10.05.2021.
//  Copyright © 2021 azharkova. All rights reserved.
//

import Foundation
import UIKit

extension UIImage {
    func toData()->Data? {
        return self.jpegData(compressionQuality: 90)
    }
    
    func resize(newSize: CGSize, completion: @escaping((UIImage, Data?) -> Void)) {
        DispatchQueue.global(qos: .userInitiated).async {

            let widthScale = newSize.width / self.size.width
            let heightScale = newSize.height / self.size.height

            if widthScale > 1 || heightScale > 1 {
                DispatchQueue.main.async {
                    completion(self.copy() as! UIImage, self.jpegData(compressionQuality: 1))
                }
                return
            }

            let scaleFactor = widthScale < heightScale ? widthScale : heightScale
            let scaledSize = CGSize(width: self.size.width * scaleFactor, height: self.size.height * scaleFactor)

            let rect = CGRect(x: 0, y: 0, width: scaledSize.width, height: scaledSize.height)
            UIGraphicsBeginImageContextWithOptions(scaledSize, false, 1.0)
            self.draw(in: rect)
            if let newImage = UIGraphicsGetImageFromCurrentImageContext() {
                UIGraphicsEndImageContext()
                let imageData = newImage.jpegData(compressionQuality: 0.5)
                DispatchQueue.main.async {
                    completion(newImage, imageData)
                }
            }
        }
    }
}

