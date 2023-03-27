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
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBOutlet weak var postInfoLabel: UILabel!
    @IBOutlet weak var bookmarkButton: UIButton!
    @IBOutlet weak var postTitleLabel: UILabel!
    @IBOutlet weak var postImageView: UIImageView!
    
    @IBOutlet weak var ratingImage: UIImageView!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var commentsLabel: UILabel!
    
    var post: PostModel?
    
    func configure(_ post: PostModel) {
        self.post = post
        postTitleLabel.text = post.title
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
            let viewHeight = viewWidth / ratio
            let trasformer = SDImageResizingTransformer(size: CGSize(width: viewWidth, height: viewHeight), scaleMode: .fill)
        
            postImageView.heightAnchor.constraint(equalToConstant: viewHeight).isActive = true
            let image = UIImage(named: "placeholder.jpeg")
            postImageView.sd_setImage(with: URL(string: preparedUrl), placeholderImage: UIImage(named: "placeholder.jpeg"), context: [.imageTransformer: trasformer])
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
    }}
