//
//  SettingsVC.swift
//  photoram
//
//  Created by Anna Zharkova on 26.05.2021.
//  Copyright © 2021 azharkova. All rights reserved.
//

import UIKit

protocol SettingsView : AnyObject {
    func setupUser(name: String, email: String)
    
    func logout()
}

class SettingsVC: UIViewController, SettingsView {
    lazy var presenter: ISettingsPresenter? = {
        return SettingsPresenter.setup(view: self)
    }()
    
    @IBOutlet weak var emailLabel: UILabel!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.presenter?.listenLogout()
        self.presenter?.loadUser()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.title = "Info"
    }

    func setupUser(name: String,  email: String) {
        self.emailLabel.text = email
        self.nameLabel.text = name
    }

    @IBAction func onLogoutClicked(_ sender: Any) {
        self.presenter?.logout()
    }
    
    func logout() {
        SceneDelegate.setupRoot(vc: LoginVC())
    }
}
