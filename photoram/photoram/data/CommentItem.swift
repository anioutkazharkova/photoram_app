//
//  CommentItem.swift
//  photoram
//
//  Created by Anna Zharkova on 25.05.2021.
//  Copyright © 2021 azharkova. All rights reserved.
//

import Foundation

struct CommentItem : Codable {
    var uuid = UUID().uuidString
    var text: String = ""
    var date = Date()
    var userId: String = ""
    var userName: String = ""
    var postId: String = ""
    
    init(text: String, postId: String){
        self.text = text
        self.postId = postId
    }
    
    enum CodingKeys: String, CodingKey {
        case uuid
        case text
        case date
        case userId
        case userName
        case postId
    }
    
    var info: String {
        return "\(userName), \(date.defaultText)"
    }
}
