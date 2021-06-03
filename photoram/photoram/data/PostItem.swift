//
//  Posst.swift
//  photoram
//
//  Created by Anna Zharkova on 10.05.2021.
//  Copyright © 2021 azharkova. All rights reserved.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

struct PostItem : Codable, Equatable  {
    @DocumentID var id: String? = ""
    var uuid = UUID().uuidString
    var imageLink: String = ""
    var postText: String = ""
    var date = Date()
    var userId: String = ""
    var userName: String = ""
    var likeItems: [LikeItem] = [LikeItem]()
    var editedTime: Date? = nil
    var editor: String? = nil
    var dateString: String {
        return date.formatIso()
    }
    
    init() {}
    init(imageLink: String, postText: String){
        self.imageLink = imageLink
        self.postText = postText
    }
    
    enum CodingKeys: String, CodingKey {
        case uuid
        case imageLink
        case postText
        case date = "date"
        case id
        case userId
        case userName
        case likeItems = "likeItems"
        case editor
        case editedTime
    }
    
    var wasEdited: Bool {
        return editedTime != nil
    }
    
    var likes: Int {
        return likeItems.count
    }
    
    var isLiked: Bool = false 
    
    mutating func updateLikes(likes: [LikeItem]) {
        likeItems = [LikeItem]()
        likeItems.append(contentsOf: likes)
    }
    
    mutating func update(with item: PostItem) {
        self.imageLink = item.imageLink
        self.postText = item.postText
        self.editor = item.editor
        self.editedTime = item.editedTime
        updateLikes(likes: item.likeItems)
    }
    
    static func == (lhs: PostItem, rhs: PostItem) -> Bool {
        return  lhs.uuid == rhs.uuid
    }
    
    var dictionary: [String: Any] {
        return [
            "imageLink": imageLink,
            "postText": postText,
            "timeStamp": Timestamp(date: Date()),
            "date": date.formatIso(),
            "likeItems": likeItems,
            "userId": userId,
            "userName": userName,
            "uuid": uuid
        ]
    }
    
    var editedDictionary: [String : Any] {
        return [ "imageLink": imageLink,
                 "postText": postText, "editedTime": Date().formatIso()]
    }
    
    init?(dictionary: [String : Any]) {
        uuid = dictionary["uuid"] as? String ?? ""
        imageLink = dictionary["imageLink"] as? String ?? ""
        postText = dictionary["postText"] as? String ?? ""
        date = (dictionary["date"] as? String)?.fromIso() ?? Date()
        editedTime = (dictionary["editedTime"] as? String)?.fromIso()
        userId = dictionary["userId"] as? String ?? ""
        editor = dictionary["editor"] as? String
        userName = dictionary["userName"] as? String ?? ""
        if let likes = dictionary["likeItems"] as? [[String: Any]] {
            likeItems = likes.map{LikeItem(dictionary: $0)}.compactMap({$0})
        }
        
    }
}
