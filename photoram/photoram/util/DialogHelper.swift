//
//  DialogHelper.swift
//  photoram
//
//  Created by Anna Zharkova on 10.05.2021.
//  Copyright © 2021 azharkova. All rights reserved.
//

import Foundation
import Foundation
import UIKit

class DialogHelper {

    static let sharedInstance = DialogHelper()
    private init() {}
    private var alert: UIAlertController?

    func createDialog(message: String? = "", _ title: String? = "", _ cancelAction: (() -> Void)? = nil, _ okAction: (() -> Void)? = nil ) -> UIAlertController? {

        alert?.dismiss(animated: true, completion: nil)

        alert = UIAlertController.init(title: title, message: message, preferredStyle: .alert)

        if cancelAction != nil {
            alert?.addAction(UIAlertAction.init(title: "Нет", style: .default, handler: { (_: UIAlertAction) -> Void in
                cancelAction?()
            }))

        }

        alert?.addAction(UIAlertAction.init(title: "Да", style: .default, handler: { (_: UIAlertAction) -> Void in
            okAction?()
        }))

        return alert
    }

    func createInfoDialog(message: String? = "", title: String? = "", _ okAction:(() -> Void)? = nil) -> UIAlertController? {
        return self.createDialog(message: message, title, nil, okAction)
    }

    func dismissAll() {

        alert?.dismiss(animated: true, completion: nil)

    }

}
