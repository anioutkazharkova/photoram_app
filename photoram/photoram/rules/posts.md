#  Post

```

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
        try doc.setData(from: postItem) { error in
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
    //completion(.success(true))
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
        } else {
            print("Document successfully removed!")
        }
    }
}
```

