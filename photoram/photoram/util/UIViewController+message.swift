//
//  UIViewController+message.swift
//  photoram
//
//  Created by Anna Zharkova on 10.05.2021.
//  Copyright © 2021 azharkova. All rights reserved.
//

import Foundation
import UIKit
extension UIViewController {
    func showError(message: String) {
        if let alert = DialogHelper.sharedInstance.createInfoDialog(message: message) {
            self.present(alert, animated: true, completion: nil)
        }
    }

    func showMessage(message: String, _ action: (() -> Void)? = nil) {
        if let alert = DialogHelper.sharedInstance.createInfoDialog(message: message, title: "", action) {
            self.present(alert, animated: true, completion: nil)
        }
    }

    func showMessage(message: String, action: @escaping (() -> Void), cancel: @escaping (() -> Void)) {
        if let alert = DialogHelper.sharedInstance.createDialog(message: message, nil, {
            cancel()
        }, {
            action()
        }) {
            self.present(alert, animated: true, completion: nil)
        }
    }
}
