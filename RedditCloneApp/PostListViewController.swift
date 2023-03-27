//
//  PostListViewController.swift
//  RedditCloneApp
//
//  Created by Illia Stasiuk on 27.03.2023.
//

import UIKit

class PostListViewController: UIViewController {

    let posts = PostService.loadPosts(subreddit: "gaming", limit: 10)
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

extension PostListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: PostTableViewCell.Const.restorationID,
            for: indexPath
        ) as! PostTableViewCell
        cell.configure(posts[indexPath.row])
        return cell
    }
}

