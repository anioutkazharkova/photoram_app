//
//  CommentCell.swift
//  photoram
//
//  Created by Anna Zharkova on 25.05.2021.
//  Copyright © 2021 azharkova. All rights reserved.
//

import UIKit

class CommentCell: UITableViewCell {
    static let cellId = String(describing: CommentCell.self)
    
    @IBOutlet weak var commonView: UIView!
    @IBOutlet weak var commenInfo: UILabel!
    @IBOutlet weak var commentText: UILabel!

    
    func setup(item: CommentItem) {
        self.commentText.text = item.text
        self.commenInfo.text = item.info
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.commonView.layer.cornerRadius = 10
    }
}
