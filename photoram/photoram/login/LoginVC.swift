//
//  LoginVC.swift
//  photoram
//
//  Created by Anna Zharkova on 10.05.2021.
//  Copyright © 2021 azharkova. All rights reserved.
//

import UIKit

protocol LoginView: AnyObject {
    func showPosts()
}

class LoginVC: UIViewController, LoginView, UITextFieldDelegate {
    lazy var presenter: ILoginPresenter? = {
        return LoginPresenter.setup(view: self)
    }()

    @IBOutlet weak var scroll: UIScrollView!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.presenter?.checkLogin()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func onTouchClicked(_ sender: Any) {
        self.resign()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.registerKeyboardNotifications()
        self.emailField.delegate = self
        self.passwordField.delegate = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.emailField.delegate = nil
        self.passwordField.delegate = nil
        self.unregisterKeyboardNotifications()
        super.viewWillDisappear(animated)
    }

    @IBAction func onSignupClicked(_ sender: Any) {
        self.resign()
        self.navigationController?.pushViewController(RegisterVC(), animated: true)
    }
    
    @IBAction func onSignInClicked(_ sender: Any) {
        self.resign()
        self.presenter?.login(email: emailField.text ?? "", password: passwordField.text ?? "")
    }
    
    func resign() {
        self.passwordField.resignFirstResponder()
        self.emailField.resignFirstResponder()
    }

    func showPosts() {
        SceneDelegate.setupRoot(vc: PostListVC())
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.resign()
        return true
    }
}
extension LoginVC {
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
