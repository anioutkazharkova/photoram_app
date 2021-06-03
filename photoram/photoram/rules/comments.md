#  Comments
```
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
}*/

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
/*
 
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
```
