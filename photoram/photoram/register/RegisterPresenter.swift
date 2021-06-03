//
//  RegisterPresenter.swift
//  photoram
//
//  Created by Anna Zharkova on 10.05.2021.
//  Copyright © 2021 azharkova. All rights reserved.
//

import Foundation

protocol  IRegisterPresenter {
    var view: RegisterView? {get set}
    
    func register(name: String, email: String, password: String)
    
    func checkLogin()
}

class RegisterPresenter: IRegisterPresenter {
    weak var view: RegisterView?
    
    static func setup(view: RegisterView)->IRegisterPresenter {
        let presenter = RegisterPresenter()
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
                //self.view?.showPosts()
            }
        }
    }
    
    func register(name: String, email: String, password: String) {
        FirebaseAuthHelper.shared.register(name: name, email: email, password: password) { result in
            switch result {
            case .success(let user):
                self.view?.showPosts()
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    
}
