#  Likes

```
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
```

