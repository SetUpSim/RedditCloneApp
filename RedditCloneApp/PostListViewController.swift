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
        static let subreddit = "food"
        static let selectPostSequeID = "go_to_post_details"
        static let chunkSize = 15
        static let postsBeforeNewLoad = 3
    }
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var navigationBar: UINavigationItem!
    
    var lastChunkFailedToLoad = false
    var loadingPending = false
    var newPostsAt: String? = nil
    var posts = [PostModel]()
    var lastSelectedPost: PostModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationBar.title = "r/" + Const.subreddit
        navigationBar.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .bookmarks, target: self, action: nil)
        loadNewPosts(after: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
            case Const.selectPostSequeID:
                let postDetailsVC = segue.destination as! PostDetailsViewController
                postDetailsVC.configure(lastSelectedPost!)
            default:
                break
        }
    }
    
    func loadNewPosts(after: String?) {
        loadingPending = true
        PostService.loadPosts(subreddit: Const.subreddit, limit: Const.chunkSize, after: after) { loadedPosts, afterSection in
            if let newPosts = loadedPosts, !newPosts.isEmpty {
                self.posts.append(contentsOf: newPosts)
                if afterSection != nil {
                    self.newPostsAt = afterSection
                } else {
                    self.lastChunkFailedToLoad = true
                }
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            } else {
                self.lastChunkFailedToLoad = true
            }
            self.loadingPending = false
        }
        loadingPending = false
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
        if (!lastChunkFailedToLoad && !loadingPending && indexPath.row + Const.postsBeforeNewLoad >= posts.count) {
            loadNewPosts(after: newPostsAt)
            
        }
        return cell
    }
}

extension PostListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        lastSelectedPost = posts[indexPath.row]
        performSegue(withIdentifier: Const.selectPostSequeID, sender: nil)
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let endScrolling = scrollView.contentOffset.y + scrollView.frame.size.height
        if (lastChunkFailedToLoad && !loadingPending && endScrolling >= scrollView.contentSize.height) {
            print("!!!!BOTTOM REFRESH TRIGGERED!!!!")
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                self.loadingPending = true
                self.loadNewPosts(after: self.newPostsAt)
            }
        }
    }
}


