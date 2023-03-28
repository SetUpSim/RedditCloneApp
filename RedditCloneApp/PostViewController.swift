//
//  ViewController.swift
//  RedditCloneApp
//
//  Created by Illia Stasiuk on 05.03.2023.
//

import UIKit
import SDWebImage

class PostViewController: UIViewController {
    
    
    @IBOutlet weak var postInfoLabel: UILabel!
    @IBOutlet weak var bookmarkButton: UIButton!
    @IBOutlet weak var postTitleLabel: UILabel!
    @IBOutlet weak var postImageView: UIImageView!
    
    @IBOutlet weak var ratingImage: UIImageView!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var commentsLabel: UILabel!
    
    var post: PostModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        post = PostService.loadPosts(subreddit: "ios", limit: 1)[0]
        updatePostView()
    }
    
    func updatePostView() {
        postTitleLabel.text = post?.title
        setBookMarkButtonState()
        setPostInfoText()
        updatePostRatingLabelAndImage()
        updateCommentsLabel()
        loadImage()
    }
    
    func loadImage() {
        if let imgSource = post?.preview?.images[0].source {
            let preparedUrl = prepareImageURL(url: imgSource.url)
            print(preparedUrl)
            
            let ratio = Double(imgSource.width) / Double(imgSource.height)
            let viewWidth = postImageView.frame.width
            let trasformer = SDImageResizingTransformer(size: CGSize(width: viewWidth, height: viewWidth / ratio), scaleMode: .fill)
        
            postImageView.sd_setImage(with: URL(string: preparedUrl), placeholderImage: nil, context: [.imageTransformer: trasformer])
        }
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
    
}

