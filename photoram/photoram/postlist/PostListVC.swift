//
//  PhotoListVC.swift
//  photoram
//
//  Created by Anna Zharkova on 10.05.2021.
//  Copyright © 2021 azharkova. All rights reserved.
//

import UIKit

protocol PostsListOwner: AnyObject {
    func select(index: Int)
    
    func liked(index: Int)
    
    func edit(index: Int)
    
    func delete(index: Int)
    
}

protocol PostListView : AnyObject, IInputView {
    func setupPosts(items: [PostItem])
    
    func changeLoadButton(enabled: Bool)
    
    func openToCreate(post: PostItem)
    
    func open(post: PostItem)
}

class PostListVC: UIViewController {
    
    @IBOutlet weak var postsList: UITableView!
    @IBOutlet weak var loadMoreButton: UIButton!
    
    private var adapter: PostListAdapter? = nil
    
    lazy var presenter: IPostListPresenter? = {
        return PostListPresenter.setup(view: self)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.postsList.register(UINib(nibName: PostCell.cellId, bundle: nil), forCellReuseIdentifier: PostCell.cellId)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setupMenu()
        self.title = "Posts"
        
        self.presenter?.loadPosts()
        self.presenter?.startListen()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.presenter?.stopListen()
        super.viewWillDisappear(animated)
    }
    
    func setupMenu() {
        let addButton = UIBarButtonItem(title: "Add", style: .plain, target: self, action: #selector(addPost))
        let settings = UIBarButtonItem(title: "Info", style: .plain, target: self, action: #selector(showInfo))
        self.navigationItem.rightBarButtonItems = [settings, addButton]
    }
    
    @IBAction func onLoadClicked(_ sender: Any) {
        self.presenter?.loadFresh()
    }
    
    @objc func showInfo() {
        self.navigationController?.pushViewController(SettingsVC(), animated: true)
    }
    
    @objc func addPost() {
        self.navigationController?.pushViewController(CreatePostVC(), animated: true)
    }
}

extension PostListVC : PostListView {
    func input(_ data: Any?)  {}
    
    func setupPosts(items: [PostItem]) {
        if self.adapter == nil {
            self.adapter = PostListAdapter()
        }
        self.adapter?.updateItems(items: items)
        self.adapter?.owner = self 
        self.postsList.delegate = self.adapter
        self.postsList.dataSource = self.adapter
        self.postsList.reloadData()
    }
    
    func changeLoadButton(enabled: Bool) {
        
    }
    
    func openToCreate(post: PostItem) {
        let vc = CreatePostVC()
        vc.input(post)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func open(post: PostItem) {
        let vc = PostItemVC()
        vc.input(post)
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension PostListVC : PostsListOwner {
    func select(index: Int) {
        self.presenter?.requestOpen(index: index)
    }
    
    func liked(index: Int) {
        self.presenter?.liked(index: index)
    }
    
    func edit(index: Int) {
        self.presenter?.requestForEdit(index: index)
    }
    
    func delete(index: Int) {
        self.presenter?.delete(index: index)
    }
}
