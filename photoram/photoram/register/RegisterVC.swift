//
//  RegisterVC.swift
//  photoram
//
//  Created by Anna Zharkova on 10.05.2021.
//  Copyright © 2021 azharkova. All rights reserved.
//

import UIKit

protocol RegisterView : AnyObject {
    func showPosts()
    
    func changeRegisterButton(enabled: Bool)
}

class RegisterVC: UIViewController, RegisterView, UITextFieldDelegate {
    lazy var presenter: IRegisterPresenter? = {
        return RegisterPresenter.setup(view: self)
    }()
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var passwordField: UITextField!
    

    @IBOutlet weak var scroll: UIScrollView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.presenter?.checkLogin()
        // Do any additional setup after loading the view.
    }

    func showPosts() {
        self.resign()
        SceneDelegate.setupRoot(vc: PostListVC())
    }
    
    @IBAction func onTapClicked(_ sender: Any) {
        self.resign()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.title = "Register"
        self.registerKeyboardNotifications()
        self.nameField.delegate = self
        self.emailField.delegate = self
        self.passwordField.delegate = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.resign()
        self.unregisterKeyboardNotifications()
        self.nameField.delegate = nil
        self.emailField.delegate = nil
        self.passwordField.delegate = nil
        super.viewWillDisappear(animated)
    }
    
    func changeRegisterButton(enabled: Bool) {
        self.registerButton.isEnabled = enabled
    }

    @IBAction func onRegisterClicked(_ sender: Any) {
        resign()
        self.presenter?.register(name: nameField.text ?? "", email: emailField.text ?? "", password: passwordField.text ?? "")
    }
    
    func resign() {
        self.nameField.resignFirstResponder()
        self.passwordField.resignFirstResponder()
        self.emailField.resignFirstResponder()
    }
    
    override func resignFirstResponder() -> Bool {
        self.resign()
        return true
    }
}

extension RegisterVC {
 func registerKeyboardNotifications() {
    NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)

}

func unregisterKeyboardNotifications() {
    NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
    NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)

}

@objc func keyboardWillShow(notification: NSNotification) {
    if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.size {
        let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height, right: 0)
        scroll!.contentInset = contentInsets

    }

    self.view.setNeedsLayout()
    self.view.layoutIfNeeded()
}


@objc func keyboardWillHide(notification: NSNotification) {
    let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    scroll!.contentInset = contentInsets
   scroll!.scrollIndicatorInsets = contentInsets

    self.view.setNeedsLayout()
    self.view.layoutIfNeeded()
}
}
