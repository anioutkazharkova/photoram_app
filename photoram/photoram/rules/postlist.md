#  Posts

```
func loadPosts(completion: @escaping([PostItem])->Void) {
    let collection = Firestore.firestore().collection("posts")
    collection.order(by: "timeStamp",  descending: true).getDocuments { (snapshot, error) in
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
        //self.checkLiked()
        completion(self.currentPosts)
    }
}

func startListenToPosts(completion: @escaping([PostItem])->Void) {
    let collection = Firestore.firestore().collection("posts")
    listener =  collection.order(by: "timeStamp",  descending: true)
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
                if let item = PostItem(dictionary: doc.data()) {
                        if !self.currentPosts.contains(item) {
                            self.currentPosts.append(item)
                        }
                    }
                }
                if diff.type == .modified {
                    if let item = try? diff.document.data(as: PostItem.self) {
                        if self.currentPosts.contains(item) {
                            if let index = self.currentPosts.firstIndex(of: item) {
                                self.currentPosts[index].update(with: item)
                            }
                        }
                    }
                }
                if diff.type == .removed {
                    if let item = try? diff.document.data(as: PostItem.self) {
                        if self.currentPosts.contains(item) {
                            self.currentPosts.remove(item: item)
                        }
                    }
                }
            }
            //self.checkLiked()
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

```

