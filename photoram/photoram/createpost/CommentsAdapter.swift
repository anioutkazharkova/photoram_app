//
//  CommentsAdapter.swift
//  photoram
//
//  Created by Anna Zharkova on 25.05.2021.
//  Copyright © 2021 azharkova. All rights reserved.
//

import Foundation
import UIKit

class CommentsAdapter
: NSObject, UITableViewDelegate, UITableViewDataSource {
    private var items = [CommentItem]()
   
   
    func updateItems(items: [CommentItem]) {
        self.items = [CommentItem]()
        self.items.append(contentsOf: items)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CommentCell.cellId, for: indexPath) as? CommentCell else {
            return UITableViewCell()
        }
        cell.setup(item: items[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
      }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}
