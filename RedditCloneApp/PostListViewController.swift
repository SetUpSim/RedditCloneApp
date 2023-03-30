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
        static let subreddit = "ukraine"
        static let selectPostSequeID = "go_to_post_details"
        static let chunkSize = 10
        static let postsBeforeNewLoad = 2
    }
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var navigationBar: UINavigationItem!
    
    var newPostsAt = ""
    var posts = [PostModel]()
    var lastSelectedPost: PostModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationBar.title = "r/" + Const.subreddit
        navigationBar.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .bookmarks, target: self, action: nil)
        (self.posts, self.newPostsAt) = PostService.loadPosts(subreddit: Const.subreddit, limit: Const.chunkSize)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
            case Const.selectPostSequeID:
                let postDetailsVC = segue.destination as! PostViewController
            postDetailsVC.configure(lastSelectedPost!)
            default:
                break
        }
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
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        lastSelectedPost = posts[indexPath.row]
        print("Selected post with title: ", lastSelectedPost?.title ?? "")
        performSegue(withIdentifier: Const.selectPostSequeID, sender: nil)
        tableView.deselectRow(at: indexPath, animated: false)
    }
}


