//
//  UserData.swift
//  photoram
//
//  Created by Anna Zharkova on 23.05.2021.
//  Copyright © 2021 azharkova. All rights reserved.
//

import Foundation

struct UserData : Codable {
    var uid: String = ""
    var name: String = ""
    var email: String = ""
    
    enum CodingKeys: String, CodingKey {
        case uid
        case name
        case email
    }
}
