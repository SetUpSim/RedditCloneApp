//
//  PostModel.swift
//  RedditCloneApp
//
//  Created by Illia Stasiuk on 08.03.2023.
//

import Foundation

struct PostModel: Codable {
    let author: String
    let domain: String
    let created: Date
    let title: String
    let ups: Int
    let downs: Int
    let numComments: Int
//    let imageUrl: String?
}

struct ResponseDataChild: Codable {
    let data: PostModel
}

struct ResponseData: Codable {
    let children: [ResponseDataChild]
}

struct Response: Codable {
    let data: ResponseData
}
