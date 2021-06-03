//
//  SettingsPresenter.swift
//  photoram
//
//  Created by Anna Zharkova on 26.05.2021.
//  Copyright © 2021 azharkova. All rights reserved.
//

import Foundation

protocol ISettingsPresenter: AnyObject {
    var view: SettingsView? {get set}
    func loadUser()
    
    func logout()
    
    func listenLogout()
}

class SettingsPresenter: ISettingsPresenter {
   weak var view: SettingsView?
  
    static func setup(view: SettingsView)->ISettingsPresenter {
        let presenter = SettingsPresenter()
        presenter.view = view
        return presenter
    }
    
    func listenLogout() {
        FirebaseAuthHelper.shared.checkAuth { (isAuth) in
            if !isAuth {
                self.view?.logout()
            }
        }
    }
    
    func loadUser() {
        if let user =  DI.dataContainer.userStorage?.getUser() {
            self.view?.setupUser(name: user.name, email: user.email)
        }
    }
    
    func logout() {
        FirebaseAuthHelper.shared.logout()
        //self.view?.logout()
    }
}
