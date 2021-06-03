//
//  LoginPresenter.swift
//  photoram
//
//  Created by Anna Zharkova on 10.05.2021.
//  Copyright © 2021 azharkova. All rights reserved.
//

import Foundation

protocol ILoginPresenter {
    var view: LoginView? {get set}
    
    func login(email: String, password: String)
    
    func checkLogin()
    
    func startListen()
}

class LoginPresenter: ILoginPresenter {
    weak var view: LoginView?
    
    static func setup(view: LoginView)->ILoginPresenter {
        let presenter = LoginPresenter()
        presenter.view = view
        return presenter
    }
    
    func checkLogin() {
        if FirebaseAuthHelper.shared.isAuthorized() {
            self.view?.showPosts()
        } else {
            startListen()
        }
    }
    
    func startListen() {
        FirebaseAuthHelper.shared.checkAuth { result in
            if result {
                self.view?.showPosts()
            }
        }
    }
    
    func login(email: String, password: String) {
        FirebaseAuthHelper.shared.login(email: email, password: password) { result in
            //self.view?.showPosts()
        }
    }
}
