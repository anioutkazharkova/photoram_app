//
//  CreatePostPresenter.swift
//  photoram
//
//  Created by Anna Zharkova on 10.05.2021.
//  Copyright © 2021 azharkova. All rights reserved.
//

import Foundation

protocol  IPostItemPresenter {
    var view: PostItemView? {get set}
    
    func loadComments()
    
    func postComment()
    
    func setup(post: PostItem)
    
    func setupComment(text: String)
    
    func setupContent()
    
    func stopListen()
    
    func listenComments()
}

class PostItemPresenter : IPostItemPresenter {
    private var imageData: Data? = nil
    var currentUser = DI.dataContainer.userStorage?.getUser()
    private weak var postService = DI.serviceContainer.postService
    private var currentPost: PostItem = PostItem()
    private var text: String = ""
    
    private var comments = [CommentItem]()
    
    weak var view: PostItemView?
    
    static func setup(view: PostItemView)->IPostItemPresenter {
        let presenter = PostItemPresenter()
        presenter.view = view
        return presenter
    }
    
    func loadComments() {
        self.postService?.loadComments(postId: self.currentPost.uuid) { [weak self] (result) in
            guard let self = self else {return}
            switch result {
            case .success(let comments):
                self.comments = [CommentItem]()
                self.comments.append(contentsOf: comments)
                self.view?.setupComments(comments: self.comments)
            default:
                break
            }
        }
    }
    
    func listenComments() {
        self.postService?.startListenComments(postId: self.currentPost.uuid) { [weak self] (result) in
            guard let self = self else {return}
            switch result {
            case .success(let comments):
                self.comments = [CommentItem]()
                self.comments.append(contentsOf: comments)
                self.view?.setupComments(comments: self.comments)
            default:
                break
            }
    }
    }
        
    func stopListen() {
        self.postService?.stopCommentListen()
    }
    
    func setup(post: PostItem) {
        self.currentPost = post
    }
    
    func setupComment(text: String) {
        self.text = text
    }
    
    func setupContent() {
        self.view?.setupPost(image: currentPost.imageLink, text: currentPost.postText)
        self.view?.setTitle(title: "\(currentPost.userName), \((currentPost.editedTime ?? currentPost.date).defaultText)")
    }
    
    func postComment() {
        var comment = CommentItem(text: text, postId: self.currentPost.uuid)
        if let user = self.currentUser {
            comment.userName = user.name
            comment.userId = user.uid
        }
        self.postService?.publishComment(item: comment) { [weak self] result in
               guard let self = self else {return}
               switch result {
               case .failure(let error):
                   self.view?.showError(message: error.localizedDescription)
               default:
                   break
               }
        }
    }
}
