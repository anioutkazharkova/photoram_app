//
//  ImageService.swift
//  photoram
//
//  Created by Anna Zharkova on 11.05.2021.
//  Copyright © 2021 azharkova. All rights reserved.
//

import Foundation
import FirebaseStorage


class ImageService {
    static let shared = ImageService()
    private let storage = Storage.storage()
    
    private  var reference: StorageReference {
        return storage.reference().child("image-\(Date()).jpg")
    }
    
    //MARK: upload image to storage
    func uploadImage(_ imageData: Data, completion: @escaping (URL?) -> Void) {
        let reference = self.reference
        
        //Create reference to load image data
        reference.putData(imageData, metadata: nil) {(metadata, error) in
            if let error = error {
                assertionFailure(error.localizedDescription)
                return completion(nil)
            }

            //Retrieve url to image
            reference.downloadURL(completion: { (url, error) in
                if let error = error {
                    assertionFailure(error.localizedDescription)
                    return completion(nil)
                }
                completion(url)
            })
        }
    }
}
