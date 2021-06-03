//
//  PhotoHelper.swift
//  photoram
//
//  Created by Anna Zharkova on 10.05.2021.
//  Copyright © 2021 azharkova. All rights reserved.
//

import Foundation
import Foundation
import Photos

class PhotoHelper {
    weak var listener: PhotoAccessListener?

    static let shared = PhotoHelper()

    func requestPhotos() {
        let status = PHPhotoLibrary.authorizationStatus()

        if status == PHAuthorizationStatus.authorized {
           listener?.accessGranted()
        } else if status == PHAuthorizationStatus.denied {
           listener?.accessDenied()
        } else if status == PHAuthorizationStatus.notDetermined {
            // Access has not been determined.
            PHPhotoLibrary.requestAuthorization({ [weak self] (newStatus) in

                if newStatus == PHAuthorizationStatus.authorized {
                  self?.listener?.accessGranted()
                } else {
                    self?.listener?.accessDenied()
                }
            })
        } else if status == PHAuthorizationStatus.restricted {
            listener?.accessDenied()
        }
    }
}

protocol PhotoAccessListener: class {
    func accessGranted()

    func accessDenied()
}
