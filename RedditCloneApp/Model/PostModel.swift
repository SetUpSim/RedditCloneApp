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
    let preview: ImagePreview?
}

struct ImagePreview : Codable {
    let images: [ImageObj]
}

struct ImageObj: Codable {
    let source: ImageSource
}

struct ImageSource: Codable {
    let url: String
    let width: Int
    let height: Int
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
