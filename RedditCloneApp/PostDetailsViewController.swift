//
//  ViewController.swift
//  RedditCloneApp
//
//  Created by Illia Stasiuk on 05.03.2023.
//

import UIKit
import SDWebImage

class PostDetailsViewController: UIViewController {
    
    struct Const {
        static let placeholderImageName = "noimage.jpeg"
    }
    
    @IBOutlet weak var postInfoLabel: UILabel!
    @IBOutlet weak var bookmarkButton: UIButton!
    @IBOutlet weak var postTitleLabel: UILabel!
    @IBOutlet weak var postImageView: UIImageView!
    
    @IBOutlet weak var ratingImage: UIImageView!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var commentsLabel: UILabel!
    
    @IBOutlet weak var postImageHeigthConstraint: NSLayoutConstraint!
    
    var post: PostModel?
    var isBookmarked = false;
    
    func configure(_ post: PostModel) {
        self.post = post
    }
    
    func updateView() {
        postTitleLabel.text = post!.title
        updateBookmarkButtonState()
        setPostInfoText()
        updatePostRatingLabelAndImage()
        updateCommentsLabel()
        loadImage()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateView()
    }
    
    @IBAction func shareButtonClicked(_ sender: Any) {
        let shareLink = URL(string: PostService.baseURL + post!.permalink)
        let activityVC = UIActivityViewController(activityItems: [shareLink!], applicationActivities: nil)
        navigationController?.present(activityVC, animated: true, completion: nil)
    }
    
    func loadImage() {
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
                    } else {
                        print("Error during image load (", preparedUrl,  "): ", error ?? "")
                    }
                })
        } else {
            postImageView.image = UIImage(named: Const.placeholderImageName)
            postImageHeigthConstraint.isActive = false
        }
            
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

