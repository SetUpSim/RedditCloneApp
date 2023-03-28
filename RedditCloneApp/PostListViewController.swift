//
//  PostListViewController.swift
//  RedditCloneApp
//
//  Created by Illia Stasiuk on 27.03.2023.
//

import UIKit
import Foundation

class PostListViewController: UIViewController {

    struct Const {
        static let subreddit = "ios"
        static let chunkSize = 10
        static let postsBeforeNewLoad = 2
    }
    
    @IBOutlet weak var tableView: UITableView!
    
    var newPostsAt = ""
    var posts = [PostModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        (self.posts, self.newPostsAt) = PostService.loadPosts(subreddit: Const.subreddit, limit: Const.chunkSize)
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
        if (indexPath.row + Const.postsBeforeNewLoad >= posts.count) {
            let (newPosts, newPostsAt) = PostService.loadPosts(subreddit: Const.subreddit, limit: Const.chunkSize, after: newPostsAt)
            self.newPostsAt = newPostsAt
            posts.append(contentsOf: newPosts)
            tableView.reloadData()
        }
        return cell
    }
}

extension PostListViewController: UITableViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        print("Scroll view offset: ", scrollView.contentOffset.y)
    }
}


