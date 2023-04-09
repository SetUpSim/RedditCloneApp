//
//  PostTableViewCell.swift
//  RedditCloneApp
//
//  Created by Illia Stasiuk on 27.03.2023.
//

import UIKit
class PostTableViewCell: UITableViewCell {
    
    struct Const {
        static let restorationID = "post_cell_id"
        static let placeholderImageName = "loading.gif"
    }
    
    @IBOutlet weak var postInfoLabel: UILabel!
    @IBOutlet weak var bookmarkButton: UIButton!
    @IBOutlet weak var postTitleLabel: UILabel!
    @IBOutlet weak var postImageView: UIImageView!
    
    @IBOutlet weak var ratingImage: UIImageView!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var commentsLabel: UILabel!
    
    @IBOutlet var postImageHeigthConstraint: NSLayoutConstraint!
    
    weak var shareDelegate: ShareDelegate?

    var post: PostModel?
    var isBookmarked = false
    
    func configure(_ post: PostModel) {
        self.post = post
        postTitleLabel.text = post.title
        updateBookmarkButtonState()
        setPostInfoText()
        updatePostRatingLabelAndImage()
        updateCommentsLabel()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        post = nil
        isBookmarked = false
    }
    
    @IBAction func shareButtonClicked(_ sender: Any) {
        self.shareDelegate?.cellShareButtonClicked(url: post?.permalink ?? "")
    }
    
    func clearImage() {
        postImageView.image = nil
        postImageHeigthConstraint.constant = 0
        postImageHeigthConstraint.isActive = true
    }
    
    func updateBookmarkButtonState() {
        if (isBookmarked) {
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
    
    func updatePostRatingLabelAndImage() {
        if let ups = post?.ups, let downs = post?.downs {
            let rating = ups - downs
            ratingLabel.text = formatNumber(rating)
            ratingImage.image = UIImage(systemName: (rating >= 0 ? "arrow.up" : "arrow.down"))
        }
    }
    
    func updateCommentsLabel() {
        if let count = post?.numComments {
            commentsLabel.text = formatNumber(count)
        }
    }
    
    @IBAction func bookmarkButtonClicked(_ sender: Any) {
        isBookmarked.toggle()
        updateBookmarkButtonState()
    }
}

protocol ShareDelegate: AnyObject {
    func cellShareButtonClicked(url: String)
}
