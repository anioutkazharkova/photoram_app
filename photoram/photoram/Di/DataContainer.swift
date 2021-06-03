//
//  DataContainer.swift
//  photoram
//
//  Created by Anna Zharkova on 10.05.2021.
//  Copyright © 2021 azharkova. All rights reserved.
//

import Foundation

protocol IDataContainer : AnyObject {
    var storage: CommonStorage? {get}
    var userStorage: IUserStorage? {get}
}

class DataContainer: IDataContainer {
   lazy var storage: CommonStorage? = {
        return CommonStorage()
    }()
    
    lazy var userStorage: IUserStorage? = {
       return UserStorage()
    }()
}
