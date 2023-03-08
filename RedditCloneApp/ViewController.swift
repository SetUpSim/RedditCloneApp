//
//  ViewController.swift
//  RedditCloneApp
//
//  Created by Illia Stasiuk on 05.03.2023.
//

import UIKit

class ViewController: UIViewController {
    
    
    @IBOutlet weak var postInfoLabel: UILabel!
    @IBOutlet weak var bookmarkButton: UIButton!
    @IBOutlet weak var postTitleLabel: UILabel!
    @IBOutlet weak var postImageView: UIImageView!
    
    @IBOutlet weak var ratingButton: UIButton!
    @IBOutlet weak var commentsButton: UIButton!
    
    var post: PostModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        post = PostService.loadPosts(subreddit: "ios", limit: 1)[0]
        updatePostView()
    }
    
    func updatePostView() {
        postTitleLabel.text = post?.title
        setBookMarkButtonState()
        setPostInfoText()
        setPostRatingText()
        setCommentsCountText()
    }
    
    func setBookMarkButtonState() {
        let bookmarked = Bool.random()
        if (bookmarked) {
            bookmarkButton.setImage(UIImage(systemName: "bookmark.fill"), for: .normal)
        } else {
            bookmarkButton.setImage(UIImage(systemName: "bookmark"), for: .normal)
        }
        
    }
    
    func setPostInfoText() {
        if let userName = post?.author, let date = post?.created, let domain = post?.domain {
            
            let timePassed = -date.timeIntervalSinceNow
            
            let formatter = DateComponentsFormatter()
            formatter.unitsStyle = .abbreviated
            formatter.allowedUnits = [.day, .hour]
            
            let timeFormatted = formatter.string(from: timePassed)!
            
            postInfoLabel.text = "\(userName) · \(timeFormatted) · \(domain)"
        }
    }
    
    func setPostRatingText() {
        if let ups = post?.ups, let downs = post?.downs {
            let rating = ups - downs
            ratingButton.titleLabel?.text = formatNumber(rating)
        }
    }
    
    func setCommentsCountText() {
        if let count = post?.numComments {
            commentsButton.titleLabel?.text = formatNumber(count)
        }
    }
    
}

