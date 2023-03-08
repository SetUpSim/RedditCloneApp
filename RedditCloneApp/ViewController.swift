//
//  ViewController.swift
//  RedditCloneApp
//
//  Created by Illia Stasiuk on 05.03.2023.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        print(PostService.loadPosts(subreddit: "ios", limit: 3))
    }
    
}

