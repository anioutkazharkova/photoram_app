//
//  PostCell.swift
//  photoram
//
//  Created by Anna Zharkova on 10.05.2021.
//  Copyright © 2021 azharkova. All rights reserved.
//

import UIKit

class PostCell: UITableViewCell {
    static let cellId = String(describing: PostCell.self)

    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var editLabel: UILabel!
    @IBOutlet weak var likeCounts: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var postText: UILabel!
    @IBOutlet weak var postDate: UILabel!
    @IBOutlet weak var postImage: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBAction func onLikeClicked(_ sender: Any) {
    }
    
    func setup(item: PostItem){
        self.postDate.text = "\(item.date.defaultText)"
        self.postText.text = item.postText
        self.postImage.image = nil
        self.postImage.isHidden = item.imageLink.isEmpty
        self.userNameLabel.text = item.userName
        if item.isLiked {
            self.likeButton.setImage(UIImage(named: "liked"), for: .normal)
        } else {
            self.likeButton.setImage(UIImage(named: "unliked"), for: .normal)
        }
        editLabel.text = item.wasEdited ?  "\((item.editedTime ?? Date()).defaultText) \(item.userId == item.editor ? "by author" : "wrong editor")" : ""
        ImageStorage.sharedInstance.setupImage(imageKey: item.imageLink, imageView: self.postImage)
    }
}
