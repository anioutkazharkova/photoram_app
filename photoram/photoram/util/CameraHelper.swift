//
//  CameraHelper.swift
//  photoram
//
//  Created by Anna Zharkova on 10.05.2021.
//  Copyright © 2021 azharkova. All rights reserved.
//

import Foundation
import Foundation
import UIKit
import AVFoundation
class CameraHelper {
    weak var listener: CameraAccessListener?

    static let shared = CameraHelper()

    func requestCamera() {
        let status = AVCaptureDevice.authorizationStatus(for: .video)

        if status == .authorized {
            DispatchQueue.main.async {
                self.listener?.cameraAccessGranted()
            }
        } else if status == .denied {
            listener?.cameraAccessDenied()
        } else if status == .notDetermined {
            // Access has not been determined.
            AVCaptureDevice.requestAccess(for: .video) { [weak self] (granted) in
                if granted {
                    self?.listener?.cameraAccessGranted()
                } else {
                    self?.listener?.cameraAccessDenied()
                }
            }
        } else if status == .restricted {
            listener?.cameraAccessDenied()
        }
    }

    func checkCamera(action:@escaping() -> Void) {
        let status = AVCaptureDevice.authorizationStatus(for: .video)

        if status == .authorized {
            DispatchQueue.main.async {
                action()
            }
        } else if status == .denied {
            listener?.cameraAccessDenied()
        } else if status == .notDetermined {
            // Access has not been determined.
            AVCaptureDevice.requestAccess(for: .video) { [weak self] (granted) in
                if granted {
                    action()
                } else {
                    self?.listener?.cameraAccessDenied()
                }
            }
        } else if status == .restricted {
            self.listener?.cameraAccessDenied()
        }
    }

    private func openSettings() {
        DispatchQueue.main.async {
            if let url = URL.init(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
    }
}

protocol CameraAccessListener: class {
    func cameraAccessGranted()

    func cameraAccessDenied()

    func requestAccess(completion: () -> Void)
}
