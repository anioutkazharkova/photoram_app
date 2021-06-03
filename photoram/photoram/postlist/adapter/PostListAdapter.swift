//
//  PostListAdapter.swift
//  photoram
//
//  Created by Anna Zharkova on 10.05.2021.
//  Copyright © 2021 azharkova. All rights reserved.
//

import Foundation
import UIKit

class PostListAdapter: NSObject, UITableViewDelegate, UITableViewDataSource {
    private var items = [PostItem]()
    weak var owner: PostsListOwner? = nil
   
    func updateItems(items: [PostItem]) {
        self.items = [PostItem]()
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
        guard let cell = tableView.dequeueReusableCell(withIdentifier: PostCell.cellId, for: indexPath) as? PostCell else {
            return UITableViewCell()
        }
        if cell.likeButton.target(forAction: #selector(onLikeClicked(_:)), withSender: self) == nil {
            cell.likeButton.addTarget(self, action: #selector(onLikeClicked(_:)), for: .touchUpInside)
        }
        cell.likeButton.tag = indexPath.row
        
        cell.setup(item: items[indexPath.row])
        return cell
    }
    
    @objc func onLikeClicked(_ sender: Any){
        if let tag = (sender as? UIButton)?.tag {
            self.owner?.liked(index: tag)
        }
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let editItem = UIContextualAction(style: .normal, title: "Edit") {  (contextualAction, view, boolValue) in
            self.owner?.edit(index: indexPath.row)
      }
        let deleteItem = UIContextualAction(style: .normal, title: "Delete") {  (contextualAction, view, boolValue) in
            self.owner?.delete(index: indexPath.row)
      }
      let swipeActions = UISwipeActionsConfiguration(actions: [deleteItem, editItem])

      return swipeActions
  }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.owner?.select(index: indexPath.row)
    }


    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
      }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}
