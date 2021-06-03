//
//  FirebaseAuthHelper.swift
//  photoram
//
//  Created by Anna Zharkova on 10.05.2021.
//  Copyright © 2021 azharkova. All rights reserved.
//

import Foundation
import Firebase

class FirebaseAuthHelper {
    static let shared = FirebaseAuthHelper()
    private weak var userStorage = DI.dataContainer.userStorage
    
    //MARK: check authorization
    func checkAuth(isAuth: @escaping(Bool)->Void) {
        //Listening to changes
        Auth.auth().addStateDidChangeListener() { auth, user in
            isAuth(user != nil)
        }
    }
    
    func isAuthorized()->Bool {
        //Load session and check with saved
        return Auth.auth().currentUser != nil && userStorage?.getUser() != nil
    }
    
    //MARK: Login
    func login(email: String, password: String, completion: @escaping(Result<UserData,Error>)->Void) {
        //1 Login with signIn
        Auth.auth().signIn(withEmail: email, password: password) { user, error in
            if let error = error {
                completion(.failure(error))
            } else {
                //2 Current session
                let signedInUser = Auth.auth().currentUser
                if let uid = signedInUser?.uid {
                    //3 Load data about user
                    self.loadUser(uid: uid) { (result) in
                        switch result {
                        case .success(let userData):
                            completion(.success(userData))
                        case .failure(let error):
                            completion(.failure(error))
                        }
                    }
                } 
            }
        }
    }
    
    //MARK: registation
    func register(name: String, email: String, password: String, completion: @escaping(Result<UserData,Error>)->Void) {
        
        //1 Create user with email and password
        Auth.auth().createUser(withEmail: email, password: password) { user, error in
            if error == nil {
                
                //2 Perform login to get session
                Auth.auth().signIn(withEmail: email, password: password) { user, error in
                    if let error = error {
                        completion(.failure(error))
                    }
                    
                    //3 Check current user
                    if let signedInUser = Auth.auth().currentUser {
                        
                        //4 Create profile change request to save name
                        let request = signedInUser.createProfileChangeRequest()
                        request.displayName = name
                        
                        //5 Commit changes
                        request.commitChanges { (error) in
                            if let e = error {
                                completion(.failure(e))
                            } else {
                                let newUser = UserData(uid: signedInUser.uid, name: name, email: email)
                                self.userStorage?.saveUser(data: newUser)
                                
                                //6 Save user to specific collection
                                self.saveUser(user: newUser) { (result) in
                                    switch result {
                                    case .success(_):
                                        completion(.success(newUser))
                                    case .failure(let error):
                                        completion(.failure(error))
                                    }
                                }
                            }
                        }
                    }
                    
                }
            } else {
                completion(.failure(error!))
            }
        }
    }
    
    //MARK: User load/save methods with specific collection
    func saveUser(user: UserData, completion: @escaping(Result<Bool, Error>)->Void) {
        let collection = Firestore.firestore().collection("users")
        let doc = collection.document(user.uid)
        do { try doc.setData(from: user){ error in
            if let error = error {
                completion(.failure(error))
            } else {
                
                //Save to local storage
                self.userStorage?.saveUser(data: user)
                completion(.success(true))
            }
            
        }
        }catch {
            completion(.failure(error))
        }
    }
    
    func loadUser(uid: String, completion: @escaping(Result<UserData,Error>)->Void) {
        let collection = Firestore.firestore().collection("users")
        let docRef = collection.document(uid)
        docRef.getDocument { [weak self] (snapshot, error) in
            guard let self = self else {return}
            if let snapshot = snapshot {
                if let user = try? snapshot.data(as: UserData.self) {
                    
                    //Save to local storage
                    self.userStorage?.saveUser(data: user)
                    completion(.success(user))
                }
            } else {
                if let error = error {
                    completion(.failure(error))
                }
            }
        }
    }
    
    //MARK: Log out
    func logout() {
        try?  Auth.auth().signOut()
    }
}
