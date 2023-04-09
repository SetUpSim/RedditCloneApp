//
//  PostListViewController.swift
//  RedditCloneApp
//
//  Created by Illia Stasiuk on 27.03.2023.
//

import UIKit
import Foundation
import SDWebImage

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
    
    func loadImage(for cell: PostTableViewCell, post: PostModel) {
        if let imgSource = findSourceOfOptimalSizedImage(post) {
            let preparedUrl = prepareImageURL(url: imgSource.url)
            
            let ratio = Double(imgSource.width) / Double(imgSource.height)
            let viewWidth = cell.postImageView.frame.width
            let viewHeight = viewWidth / ratio
            let trasformer = SDImageResizingTransformer(size: CGSize(width: viewWidth, height: viewHeight), scaleMode: .fill)
//            print("Image source size:", imgSource.width, imgSource.height)
//            print("Setting image to view with size:", viewWidth, viewHeight, "for post", post.title[..<post.title.index(post.title.startIndex, offsetBy: 20)])
            
            cell.postImageView.sd_setImage(
                with: URL(string: preparedUrl),
                placeholderImage: UIImage(named: PostTableViewCell.Const.placeholderImageName),
                options: .progressiveLoad,
                context: [.imageTransformer: trasformer],
                progress: nil,
                completed: {(image, error, cacheType, url) in
                    if let err = error {
                        print("Error during image load (", preparedUrl,  "): ", err)
                        cell.clearImage()
                    } else {
                        cell.postImageHeigthConstraint.isActive = false
                        cell.postImageView.image = image
                    }
                    cell.postImageView.setNeedsLayout();
//                    print("Resulting image view size:", cell.postImageView.image?.size)
                })
        } else {
            cell.clearImage()
        }
    }
    
    func findSourceOfOptimalSizedImage(_ post: PostModel) -> ImageSource? {
        let postImgs = post.preview?.images
        if let postImages = postImgs {
            if postImages.count != 0 {
                let resolutions = postImages[0].resolutions
                for res in resolutions {
                    if tableView.frame.size.width.isLess(than: CGFloat(res.width)) {
                        return res
                    }
                }
            }
        }
        
        return postImgs?[0].source
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
        let post = posts[indexPath.row]
        cell.configure(post)
        cell.shareDelegate = self
        loadImage(for: cell, post: post)
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
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                self.loadingPending = true
                self.loadNewPosts(after: self.newPostsAt)
            }
        }
    }
}

extension PostListViewController: ShareDelegate {
    func cellShareButtonClicked(url: String) {
        let shareLink = URL(string: PostService.baseURL + url)
        let activityVC = UIActivityViewController(activityItems: [shareLink!], applicationActivities: nil)
        navigationController?.present(activityVC, animated: true, completion: nil)
    }
}


