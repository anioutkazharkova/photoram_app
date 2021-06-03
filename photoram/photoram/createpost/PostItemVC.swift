//
//  CreatePostVC.swift
//  photoram
//
//  Created by Anna Zharkova on 10.05.2021.
//  Copyright © 2021 azharkova. All rights reserved.
//

import UIKit

protocol PostItemView : AnyObject, IInputView {
    func goBack()
    
    func setupPost(image: String?, text: String)
    
    func setupComments(comments: [CommentItem])
    
    func setTitle(title: String)
}

class PostItemVC: UIViewController, PostItemView {
    lazy var presenter: IPostItemPresenter? = {
        return PostItemPresenter.setup(view: self)
    }()
    
    private var commentsAdapter: CommentsAdapter? = nil
    
   
    @IBOutlet weak var scroll: UIScrollView!
    @IBOutlet weak var commentListHeight: NSLayoutConstraint!
    @IBOutlet weak var commentField: UITextView!
    @IBOutlet weak var commentList: UITableView!
    @IBOutlet weak var postText: UILabel!
    @IBOutlet weak var postImage: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.commentList.register(UINib(nibName: CommentCell.cellId, bundle: nil), forCellReuseIdentifier: CommentCell.cellId)
        self.presenter?.setupContent()
    }
    
    @IBAction func onComment(_ sender: Any) {
        self.commentField.resignFirstResponder()
        self.commentField.text = ""
        self.presenter?.postComment()
    }
    
    func goBack() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func setupComments(comments: [CommentItem]) {
        if self.commentsAdapter == nil {
            self.commentsAdapter = CommentsAdapter()
        }
        self.commentList.delegate = self.commentsAdapter
        self.commentList.dataSource = self.commentsAdapter
        self.commentsAdapter?.updateItems(items: comments)
        self.commentList.reloadData()
    }
    
    func setTitle(title: String){
        self.title = title
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.registerKeyboardNotifications()
        self.commentField.delegate = self
        commentList?.addObserver(self, forKeyPath: "contentSize", options: [], context: nil)
        self.presenter?.listenComments()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.commentField.delegate = nil
        self.presenter?.stopListen()
        self.unregisterKeyboardNotifications()
        commentList?.removeObserver(self, forKeyPath: "contentSize")
        super.viewWillDisappear(animated)
    }
    @IBAction func onTouched(_ sender: Any) {
        self.commentField.resignFirstResponder()
    }
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
            if  keyPath == "contentSize"{
                var frame = self.commentList.frame
                frame.size = self.commentList.contentSize
                self.commentList?.frame = frame
                self.commentListHeight?.constant = frame.size.height
            }
        }
    
    func input(_ data: Any?) {
        if let data = data as? PostItem {
            self.presenter?.setup(post: data)
        }
    }
    
    func setupPost(image: String?, text: String) {
        self.postImage.isHidden = false
        self.postText.text = text
        if let link = image {
            ImageStorage.sharedInstance.setupImage(imageKey: link, imageView: self.postImage)
        } else {
            self.postImage.isHidden = true
        }
    }
}

extension PostItemVC : UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        self.presenter?.setupComment(text: textView.text)
    }
}

extension PostItemVC {
 func registerKeyboardNotifications() {
    NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)

}

func unregisterKeyboardNotifications() {
    NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
    NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)

}

@objc func keyboardWillShow(notification: NSNotification) {
    if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.size {
        let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height, right: 0)
        scroll!.contentInset = contentInsets

    }

    self.view.setNeedsLayout()
    self.view.layoutIfNeeded()
}


@objc func keyboardWillHide(notification: NSNotification) {
    let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    scroll!.contentInset = contentInsets
   scroll!.scrollIndicatorInsets = contentInsets

    self.view.setNeedsLayout()
    self.view.layoutIfNeeded()
}
}
