//
//  PostService.swift
//  RedditCloneApp
//
//  Created by Illia Stasiuk on 08.03.2023.
//

import Foundation

class PostService {
    
    static let baseURL = "https://www.reddit.com"
    
    static func loadPosts(subreddit: String, limit: Int, after: String? = nil, completion: @escaping([PostModel]?, String?) -> ()){
        var urlString = baseURL + "/r/\(subreddit)/top.json?limit=\(limit)"
        
        if let after = after {
            urlString += "&after=\(after)"
        }
        
        let url = URL(string: urlString)
        
        var postsLoaded: [PostModel]?
        var nextPostsAt: String?
        
        let dataTask = URLSession.shared.dataTask(with: url!) { data, respontsse, error in
            if let data = data, error == nil {
                if let myResp = decodeResponse(response: data) {
                    postsLoaded = getPostsArrayOfResponse(response: myResp)
                    nextPostsAt = myResp.data.after
                    completion(postsLoaded, nextPostsAt)
                } else {
                    completion(nil, nil)
                }
                
            } else if let error = error {
                print("HTTP Request failed with following error \n \(error)")
            }
        }
        dataTask.resume()
        	
    }
    
    static func decodeResponse(response: Data) -> Response? {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .secondsSince1970

        do {
            let result = try decoder.decode(Response.self, from: response)
            return result
        } catch {
            print("Error occured while decoding API response:", error)
            return nil
        }
    }
    
    static func getPostsArrayOfResponse(response: Response) -> [PostModel] {
        return response.data.children.map { child in
            child.data
        }
    }
}
