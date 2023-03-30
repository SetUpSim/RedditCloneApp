//
//  PostTableViewCell.swift
//  RedditCloneApp
//
//  Created by Illia Stasiuk on 27.03.2023.
//

import UIKit
import SDWebImage

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
    
    @IBOutlet weak var postImageHeigthConstraint: NSLayoutConstraint!
    var postImageZeroHeightConstraint: NSLayoutConstraint?
    
    var post: PostModel?
    var isBookmarked = false;
    
    func configure(_ post: PostModel) {
        self.post = post
        print("CONFIGURING CELL for post with title", post.title ?? "", separator: "\n\t")
        postTitleLabel.text = post.title
        updateBookmarkButtonState()
        setPostInfoText()
        updatePostRatingLabelAndImage()
        updateCommentsLabel()
        loadImage()
        postImageZeroHeightConstraint = postImageView.heightAnchor.constraint(equalToConstant: 0)
    }
    
    override func prepareForReuse() {
        print("PREPARING FOR REUSE cell for post with title", post?.title ?? "", separator: "\n\t")
        super.prepareForReuse()
        post = nil
        isBookmarked = false
    }
    
    func loadImage() {
        print("LOADING IMAGE for post with title", post?.title ?? "", separator: "\n\t")
        if let imgSource = post?.preview?.images[0].source {
            let preparedUrl = prepareImageURL(url: imgSource.url)
            
            let ratio = Double(imgSource.width) / Double(imgSource.height)
            let viewWidth = postImageView.frame.width
            let viewHeight = viewWidth / ratio
            let trasformer = SDImageResizingTransformer(size: CGSize(width: viewWidth, height: viewHeight), scaleMode: .fill)
        
            postImageView.sd_setImage(
                with: URL(string: preparedUrl),
                placeholderImage: UIImage(named: Const.placeholderImageName),
                options: .progressiveLoad,
                context: [.imageTransformer: trasformer],
                progress: nil,
                completed: {(image, error, cacheType, url) in
                    if image != nil {
                        self.postImageHeigthConstraint.isActive = false
                        return
                    } else if let err = error{
                        print("Error during image load (", preparedUrl,  "): ", err)
                    }
                    self.clearImage()
                }
            )
        } else {
            print("NO IMAGE for post with title", post?.title ?? "", separator: "\n\t")
            self.clearImage()
        }
            
    }
    
    func clearImage() {
        postImageView.image = nil
        postImageZeroHeightConstraint?.isActive = true
        postImageHeigthConstraint.isActive = false
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
            ratingImage.image = UIImage(systemName: (rating > 0 ? "arrow.up" : "arrow.down"))
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
