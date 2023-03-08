//
//  PostService.swift
//  RedditCloneApp
//
//  Created by Illia Stasiuk on 08.03.2023.
//

import Foundation

class PostService {
    
    static func loadPosts(subreddit: String, limit: Int) -> [PostModel] {
        let url = URL(string: "https://www.reddit.com/r/\(subreddit)/top.json?limit=\(limit)")
        
        var postsLoaded: [PostModel]?
        
        let sem = DispatchSemaphore(value: 0)
        
        let task = URLSession.shared.dataTask(with: url!) { data, response, error in
            if let data = data {
                postsLoaded = try! convertJsonResponseToPostsArray(response: data)
                sem.signal()
            } else if let error = error {
                print("HTTP Request failed with following error \n \(error)")
            }
        }
        task.resume()
        sem.wait()
        return postsLoaded!
    }
    
    static func convertJsonResponseToPostsArray(response: Data) throws -> [PostModel] {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .secondsSince1970
        let response = try! decoder.decode(Response.self, from: response)
        return response.data.children.map { child in
            child.data
        }
    }
}
