//
//  PostService.swift
//  photoram
//
//  Created by Anna Zharkova on 11.05.2021.
//  Copyright © 2021 azharkova. All rights reserved.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

class PostService {
    private var listener: ListenerRegistration? = nil
    private var commentListener: ListenerRegistration? = nil
    static let shared = PostService()
    private weak var userStorage = DI.dataContainer.userStorage
    var currentPosts: [PostItem] = [PostItem]()
    
    //MARK: post
    func publishPost(item: PostItem, completion: @escaping(Result<Bool, Error>)->Void) {
        guard let user = userStorage?.getUser() else {
            return
        }
        let collection = Firestore.firestore().collection("posts")
        var postItem = item
        postItem.userId = user.uid
        postItem.userName = user.name
        let doc = collection.document(postItem.uuid)
        do {
            try doc.setData(postItem.dictionary) { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(true))
                }
            }
        } catch {
            completion(.failure(error))
        }
        //If offline
        completion(.success(true))
    }

    func updatePost(item: PostItem, completion: @escaping(Result<Bool, Error>)->Void) {
        guard let user = userStorage?.getUser() else {
            return
        }
        let collection = Firestore.firestore().collection("posts")
        let doc = collection.document(item.uuid)
        var params = item.editedDictionary
        params["editor"] = user.uid
        doc.updateData(params) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(true))
            }
        }
        completion(.success(true))
    }

    func deletePost(postId: String,completion: @escaping(Result<Bool, Error>)->Void) {
        let collection = Firestore.firestore().collection("posts")
       collection.document(postId).delete() { err in
            if let err = err {
                print("Error removing document: \(err)")
                completion(.failure(err))
            } else {
                print("Document successfully removed!")
                completion(.success(true))
            }
        }
    }
    
    //MARK: posts
    func loadPosts(completion: @escaping([PostItem])->Void) {
        let collection = Firestore.firestore().collection("posts")
        collection.order(by: "timeStamp",  descending: false).getDocuments { (snapshot, error) in
            guard let snapshot = snapshot else {
                print("Error retreiving snapshot: \(error!)")
                return
            }
            for doc in snapshot.documents {
                do {
                    if let item = PostItem(dictionary: doc.data()) { //try doc.data(as: PostItem.self) {
                        if !self.currentPosts.contains(item) {
                            self.currentPosts.append(item)
                        } else {
                            if self.currentPosts.contains(item) {
                                if let index = self.currentPosts.firstIndex(of: item) {
                                    self.currentPosts[index].update(with: item)
                                }
                            }
                        }
                    }
                }
                catch {
                    print(error.localizedDescription)
                }
            }
            self.checkLiked()
            completion(self.currentPosts)
        }
    }

    func startListenToPosts(completion: @escaping([PostItem])->Void) {
        let collection = Firestore.firestore().collection("posts")
        listener =  collection.order(by: "timeStamp",  descending: false)
            .addSnapshotListener(includeMetadataChanges: true) { querySnapshot, error in
                guard let snapshot = querySnapshot else {
                    print("Error retreiving snapshot: \(error!)")
                    return
                }
                for doc in snapshot.documents {
                    do {
                        if let item = PostItem(dictionary: doc.data()) { //try doc.data(as: PostItem.self) {
                            if !self.currentPosts.contains(item) {
                                self.currentPosts.append(item)
                            }
                        }
                    }
                    catch {
                        print(error.localizedDescription)
                    }
                }
                for diff in snapshot.documentChanges {
                    if diff.type == .added {
                        if let item = PostItem(dictionary: diff.document.data()) {
                            if !self.currentPosts.contains(item) {
                                self.currentPosts.append(item)
                            }
                        }
                    }
                    if diff.type == .modified {
                        if let item = PostItem(dictionary: diff.document.data()) {
                            if self.currentPosts.contains(item) {
                                if let index = self.currentPosts.firstIndex(of: item) {
                                    self.currentPosts[index].update(with: item)
                                }
                            }
                        }
                    }
                    if diff.type == .removed  {
                        if let item = PostItem(dictionary: diff.document.data()){
                            if self.currentPosts.contains(item) {
                                self.currentPosts.remove(item: item)
                            }
                        }
                    }
                }
                self.checkLiked()
                completion(self.currentPosts)
            }
        
    }
    
    private func checkLiked() {
        guard let user = userStorage?.getUser() else {
            return
        }
        for i in 0..<self.currentPosts.count {
            self.currentPosts[i].isLiked = ( self.currentPosts[i].likeItems.filter{$0.userId == user.uid}).count > 0
        }
    }
    
    func stopListenToPosts() {
        listener?.remove()
    }
    
    //MARK: likes
    
    //Complicated transaction
    /*func addLike(postId: String, completion: @escaping(Result<[PostItem],Error>)->Void) {
     guard let user = userStorage?.getUser() else {
     return
     }
     let db = Firestore.firestore()
     let collection = Firestore.firestore().collection("posts")
     let postRef = collection.document(postId)
     db.runTransaction { transaction, pointer in
     do {
     try document = transaction.getDocument(postRef)
     } catch let fetchError as NSError {
     errorPointer?.pointee = fetchError
     return nil
     }
     //document do something
     
     let likeItem = LikeItem(userId: user.uid, postId: postId)
     return transaction.updateData(["likeItems":FieldValue.arrayUnion([likeItem.dictionary])],forDocument: postRef)
     
     } completion: { response, error in
     if let error = error  {
     completion(.failure(error))
     } else {
     self.loadPosts { (posts) in
     completion(.success(posts))
     }
     }
     }
     }*/
    
    func addLike(postId: String, completion: @escaping(Result<[PostItem],Error>)->Void) {
        guard let user = userStorage?.getUser() else {
            return
        }
        let db = Firestore.firestore()
        let collection = Firestore.firestore().collection("posts")
        let postRef = collection.document(postId)
        db.runTransaction { transaction, pointer in
            let likeItem = LikeItem(userId: user.uid, postId: postId)
            return transaction.updateData(["likeItems":FieldValue.arrayUnion([likeItem.dictionary])],forDocument: postRef)
            
        } completion: { response, error in
            if let error = error  {
                completion(.failure(error))
            } else {
                self.loadPosts { (posts) in
                    completion(.success(posts))
                }
            }
        }

        /*
         //Without transaction
         let likeItem = LikeItem(userId: user.uid, postId: postId)
        postRef.updateData(["likeItems":FieldValue.arrayUnion([likeItem.dictionary])]) { error in
            if let error = error  {
                completion(.failure(error))
            } else {
                self.loadPosts { (posts) in
                    completion(.success(posts))
                }
            }
        }*/
    }
    func unLike(postId: String, completion: @escaping(Result<[PostItem],Error>)->Void) {
        guard let user = userStorage?.getUser() else {
            return
        }
        let db = Firestore.firestore()
        let collection = Firestore.firestore().collection("posts")
        let postRef = collection.document(postId)
        db.runTransaction { transaction, pointer in
            let likeItem = LikeItem(userId: user.uid, postId: postId)
            return transaction.updateData(["likeItems":FieldValue.arrayRemove([likeItem.dictionary])],forDocument: postRef)
            
        } completion: { response, error in
            if let error = error  {
                completion(.failure(error))
            } else {
                self.loadPosts { (posts) in
                    completion(.success(posts))
                }
            }
        }
        
        /*let likeItem = LikeItem(userId: user.uid, postId: postId)
        postRef.updateData(["likeItems":FieldValue.arrayRemove([likeItem.dictionary])]) { error in
            if let error = error  {
                completion(.failure(error))
            } else {
                self.loadPosts { (posts) in
                    completion(.success(posts))
                }
            }
        }*/
    }
    
    //MARK: comments
    func publishComment(item: CommentItem, completion: @escaping(Result<Bool, Error>)->Void) {
        
        let collection = Firestore.firestore().collection("posts").document(item.postId).collection("comments")
        let doc = collection.document(item.uuid)
        do {
            try doc.setData(from: item) { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(true))
                }
            }
        } catch {
            completion(.failure(error))
        }
        completion(.success(true))
    }
    
    func loadComments(postId: String, completion: @escaping(Result<[CommentItem], Error>)->Void) {
        let collection = Firestore.firestore().collection("comments")
        collection.whereField("postId", in: [postId]).getDocuments { (snapshot, error) in
            guard let snapshot = snapshot else {
                print("Error retreiving snapshot: \(error!)")
                completion(.failure(error!))
                return
            }
            var comments = [CommentItem]()
            for doc in snapshot.documents {
                if let item = try? doc.data(as: CommentItem.self) {
                    comments.append(item)
                }
                
            }
            completion(.success(comments))
        }
    }
    
    func startListenComments(postId: String, completion: @escaping(Result<[CommentItem], Error>)->Void ) {
        let collection = Firestore.firestore().collection("posts").document(postId).collection("comments")
        commentListener = collection.addSnapshotListener(includeMetadataChanges: true) { (snapshot, error) in
            guard let snapshot = snapshot else {
                print("Error retreiving snapshot: \(error!)")
                completion(.failure(error!))
                return
            }
            var comments = [CommentItem]()
            for doc in snapshot.documents {
                if let item = try? doc.data(as: CommentItem.self) {
                    comments.append(item)
                }
                
            }
            completion(.success(comments))
        }
    }


    func stopCommentListen() {
        commentListener?.remove()
        commentListener = nil
    }
    
    //MARK: comments collection
    /*func publishComment(item: CommentItem, completion: @escaping(Result<Bool, Error>)->Void) {
     
     let collection = Firestore.firestore().collection("comments")
     let doc = collection.document(item.uuid)
     do {
     try doc.setData(from: item) { error in
     if let error = error {
     completion(.failure(error))
     } else {
     completion(.success(true))
     }
     }
     } catch {
     completion(.failure(error))
     }
     completion(.success(true))
     }
     
     //Comments as collection
     func startListenComments(postId: String, completion: @escaping(Result<[CommentItem], Error>)->Void ) {
     let collection = Firestore.firestore().collection("comments")
     commentListener = collection.whereField("postId", in: [postId]).addSnapshotListener(includeMetadataChanges: true) { (snapshot, error) in
     guard let snapshot = snapshot else {
     print("Error retreiving snapshot: \(error!)")
     completion(.failure(error!))
     return
     }
     var comments = [CommentItem]()
     for doc in snapshot.documents {
     if let item = try? doc.data(as: CommentItem.self) {
     comments.append(item)
     }
     
     }
     completion(.success(comments))
     }
     }
     */
    
    
    
}
