//
//  CreatePostPresenter.swift
//  photoram
//
//  Created by Anna Zharkova on 10.05.2021.
//  Copyright © 2021 azharkova. All rights reserved.
//

import Foundation

protocol  ICreatePostPresenter {
    var view: CreatePostView? {get set}
    
    func setupImage(data: Data)
    
    func setupText(text: String)
    
    func post()
    
    func setup(post: PostItem)
    
    func setupContent()
}

class CreatePostPresenter : ICreatePostPresenter {
    private var imageData: Data? = nil
    var currentUser = DI.dataContainer.userStorage?.getUser()
    private weak var postService = DI.serviceContainer.postService
    private weak var imageService = DI.serviceContainer.imageService
    private var currentPost: PostItem = PostItem()
    private var text: String = ""
    
    private var isEditMode: Bool = false
    
    weak var view: CreatePostView?
    
    init() {
        self.currentPost.userId = self.currentUser?.uid ?? ""
        self.currentPost.userName = self.currentUser?.name ?? ""
    }
    
    static func setup(view: CreatePostView)->ICreatePostPresenter {
        let presenter = CreatePostPresenter()
        presenter.view = view
        return presenter
    }
    
    func setupImage(data: Data) {
        self.imageData = data
    }
    
    func setupText(text: String) {
        self.text = text
        self.currentPost.postText = text
    }
    
    func setup(post: PostItem) {
        self.currentPost = post
        
        self.isEditMode = true
    }
    
    func setupContent() {
        self.view?.setupPost(image: currentPost.imageLink, text: currentPost.postText)
        self.view?.setTitle(title: "\(currentPost.userName), \((currentPost.editedTime ?? currentPost.date).defaultText)")
    }
    
    func post() {
        if !currentPost.postText.isEmpty {
            if let image = imageData {
                self.imageService?.uploadImage(image) { [weak self] (url) in
                    guard let self = self else {return}
                    let imageUrl = url?.absoluteString ?? ""
                    self.currentPost.imageLink = imageUrl
                    self.createOrUpdate()
                }
            } else {
                self.createOrUpdate()
            }
        }
    }
    
    func createOrUpdate() {
        if self.isEditMode {
            self.postService?.updatePost(item: self.currentPost){ [weak self] result in
                guard let self = self else {return}
                switch result {
                case .failure(let error):
                    self.view?.showError(message: error.localizedDescription)
                default:
                    self.view?.goBack()
                    break
                }
            }
        } else {
            self.postService?.publishPost(item: self.currentPost){  [weak self] result in
                guard let self = self else {return}
                switch result {
                case .failure(let error):
                    self.view?.showError(message: error.localizedDescription)
                default:
                    self.view?.goBack()
                    break
                }
               
            }
        }
    }
}
