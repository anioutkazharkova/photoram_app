//
//  UserStorage.swift
//  photoram
//
//  Created by Anna Zharkova on 10.05.2021.
//  Copyright © 2021 azharkova. All rights reserved.
//

import Foundation
protocol  IUserStorage: AnyObject {
    func saveUser(data: UserData)

    func getUser() -> UserData?
    
    func logout()
}

class UserStorage : IUserStorage {
    private weak var storage = DI.dataContainer.storage

    func saveUser(data: UserData) {
        storage?.saveData(data: data, forKey: "user")
    }

    func getUser() -> UserData? {
        return storage?.getData(forKey: "user")
    }

    func clearUser() {
        storage?.clearData(forKey: "user")
    }
    
    func logout() {
        clearUser()
    }
}
